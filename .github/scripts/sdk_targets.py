#!/usr/bin/env python3
"""Select the bake targets whose SDK packages are present in the downloaded SDK archive.

Reads `docker buildx bake --print` JSON on stdin, looks up each target's
"Cuvis <version>/Ubuntu <ubuntu>-<arch>-<cuda>/" folder in the zip and writes the build
matrix, the image tags that will exist and the skipped targets as GITHUB_OUTPUT lines.
A variant without packages is reported as a warning annotation; --strict turns it into a failure.
"""

import argparse
import json
import os
import sys
import zipfile
from fnmatch import fnmatch
from itertools import groupby
from pathlib import Path

RUNNERS = {"amd64": "ubuntu-latest", "arm64": "ubuntu-24.04-arm"}
DEBS = ("libcuvis", "cuviscommon")


def folder_pattern(target):
    args = target["args"]
    return f"Cuvis {args['CUVIS_VERSION']}/Ubuntu {args['UBUNTU_VERSION']}-{args['ARCH']}-{args['CUDA_SUFFIX']}/"


def packaged(names, folder):
    return all(
        any(name.startswith(f"{folder}{deb}_") and name.endswith(".deb") for name in names)
        for deb in DEBS
    )


def sdk_folders(names, target):
    """The variant folders matching the target's pattern that hold both debs."""
    folders = {"/".join(name.split("/")[:2]) + "/" for name in names if name.count("/") >= 2}
    return sorted(f for f in folders if fnmatch(f, folder_pattern(target)) and packaged(names, f))


def matrix(targets):
    by_arch = groupby(sorted(targets.items(), key=lambda t: t[1]["args"]["ARCH"]), key=lambda t: t[1]["args"]["ARCH"])
    return {
        "include": [
            {"arch": arch, "runner": RUNNERS[arch], "targets": ",".join(sorted(name for name, _ in group))}
            for arch, group in by_arch
        ]
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sdk-zip", type=Path, required=True)
    parser.add_argument("--strict", action="store_true", help="fail instead of warn when a variant is missing")
    args = parser.parse_args()

    targets = json.load(sys.stdin)["target"]
    names = zipfile.ZipFile(args.sdk_zip).namelist()
    folders = {name: sdk_folders(names, t) for name, t in targets.items()}
    ambiguous = {name: f for name, f in folders.items() if len(f) > 1}
    if ambiguous:
        sys.exit("\n".join(
            f"{name}: {folder_pattern(targets[name])} matches {', '.join(f)}; narrow cuda_suffix in docker-bake.hcl"
            for name, f in ambiguous.items()
        ))
    available = {name: t for name, t in targets.items() if folders[name]}
    missing = {name: t for name, t in targets.items() if name not in available}

    for name, target in missing.items():
        print(
            f"::warning title=SDK variant missing::no {folder_pattern(target)} with {' and '.join(DEBS)} debs in the SDK download; "
            f"{', '.join(target['tags'])} is not rebuilt",
            file=sys.stderr,
        )
    if summary := os.environ.get("GITHUB_STEP_SUMMARY"):
        with open(summary, "a", encoding="utf-8") as out:
            out.write("### cuvis_base variants\n\n")
            out.writelines(f"- built: `{tag}`\n" for t in available.values() for tag in t["tags"])
            out.writelines(f"- skipped, no SDK packages: `{tag}`\n" for t in missing.values() for tag in t["tags"])
    if missing and args.strict:
        sys.exit("a final release needs every variant; add the packages to the SDK download or tag a pre-release")
    if not available:
        sys.exit("the SDK download contains packages for none of the variants")

    print(f"matrix={json.dumps(matrix(available))}")
    print(f"tags={' '.join(tag for t in available.values() for tag in t['tags'])}")
    print(f"skipped={' '.join(tag for t in missing.values() for tag in t['tags'])}")


if __name__ == "__main__":
    main()
