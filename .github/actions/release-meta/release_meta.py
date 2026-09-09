#!/usr/bin/env python3
"""Print the release facts derived from one cuvis version string, as GITHUB_OUTPUT lines.

Accepted form: GENERATION.MAJOR.MINOR[.PATCH][{a|b|rc}N]
GENERATION.MAJOR.MINOR is the cuvis SDK release; PATCH counts revisions against that SDK.
A pre-release suffix runs the release pipeline without producing a GitHub Release.
"""

import argparse
import re
import sys

VERSION = re.compile(r"(?P<base>\d+\.\d+\.\d+(?:\.\d+)?)(?P<pre>(?:a|b|rc)\d+)?")


def facts(version):
    match = VERSION.fullmatch(version)
    if not match:
        sys.exit(f"version {version!r} is not GENERATION.MAJOR.MINOR[.PATCH][a|b|rcN]")
    base = match["base"]
    return {
        "version": version,
        "base_version": base,
        "sdk": ".".join(base.split(".")[:3]),
        "prerelease": str(bool(match["pre"])).lower(),
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--version", required=True, help="version string, with or without a leading v")
    parser.add_argument("--tag", help="git tag that must equal v<version>")
    args = parser.parse_args()

    version = args.version.removeprefix("v")
    if args.tag and args.tag != f"v{version}":
        sys.exit(f"tag {args.tag} does not match version {version}")

    print("\n".join(f"{key}={value}" for key, value in facts(version).items()))


if __name__ == "__main__":
    main()
