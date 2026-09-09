#!/usr/bin/env python3
"""Validate CHANGELOG.md against the Keep a Changelog conventions the cuvis repositories share.

Without --version the structure is checked.
With --version the file must be ready to release that version: its section is the newest and
'## [Unreleased]' is empty.
With --version and --prerelease the opposite holds: the version has no section yet and the pending
entries stay under '## [Unreleased]', from where they become the final release's notes.
With --extract the body of one release section is written to stdout, for the GitHub Release text.
"""

import argparse
import re
import sys
from pathlib import Path

SECTIONS = ("Added", "Changed", "Deprecated", "Removed", "Fixed", "Security")

UNRELEASED = re.compile(r"^## \[Unreleased\]$")
RELEASE = re.compile(r"^## \[(\d+(?:\.\d+)*(?:\.post\d+)?)\] - (\d{4}-\d{2}-\d{2})$")
SECTION = re.compile(r"^### (.+)$")
BULLET = re.compile(r"^- \S")
CONTINUATION = re.compile(r"^ {2}\S")


def version_key(version):
    """Order releases the way PEP 440 does, so 3.5.3 and 3.5.3.0 compare equal."""
    base, _, post = version.partition(".post")
    padded = (tuple(int(p) for p in base.split(".")) + (0,) * 8)[:8]
    return padded, int(post or 0)


def releases(lines):
    """Yield (index, version, date) for every release header."""
    return (
        (index, *match.groups())
        for index, line in enumerate(lines)
        if (match := RELEASE.match(line))
    )


def section_errors(no, heading, seen):
    if heading not in SECTIONS:
        yield f"{no}: unknown section '{heading}', expected one of {', '.join(SECTIONS)}"
    elif heading in seen:
        yield f"{no}: section '{heading}' appears twice in the same release"
    elif seen and SECTIONS.index(heading) < max(SECTIONS.index(s) for s in seen):
        yield f"{no}: section '{heading}' is out of order, expected {' < '.join(SECTIONS)}"


def structure_errors(lines):
    """Report every convention violation, one message per offending line."""
    if not any(map(UNRELEASED.match, lines)):
        yield "0: no '## [Unreleased]' section; add one so the next change has a home"

    versions = [(index + 1, v) for index, v, _ in releases(lines)]
    for (_, previous), (no, version) in zip(versions, versions[1:]):
        if version_key(version) == version_key(previous):
            yield f"{no}: version {version} duplicates {previous} (equal under PEP 440)"
        elif version_key(version) > version_key(previous):
            yield f"{no}: version {version} must sort below {previous}"

    seen = set()
    in_section = False
    for no, line in enumerate(lines, 1):
        if line.startswith("## "):
            if not (UNRELEASED.match(line) or RELEASE.match(line)):
                yield f"{no}: release header must be '## [<version>] - <YYYY-MM-DD>'"
            seen, in_section = set(), False
        elif match := SECTION.match(line):
            yield from section_errors(no, match.group(1), seen)
            if match.group(1) in SECTIONS:
                seen.add(match.group(1))
            in_section = True
        elif (
            in_section
            and line.strip()
            and not (BULLET.match(line) or CONTINUATION.match(line))
        ):
            yield f"{no}: expected a '- ' bullet or a two-space continuation line"


def section(lines, start):
    """The body of the section whose header sits at index start."""
    rest = lines[start:]
    end = next(
        (i for i, line in enumerate(rest) if i and line.startswith("## ")), len(rest)
    )
    return "\n".join(rest[1:end]).strip()


def release_index(lines, version):
    return next(
        (index for index, v, _ in releases(lines) if version_key(v) == version_key(version)),
        None,
    )


def unreleased_body(lines):
    start = next((i for i, line in enumerate(lines) if UNRELEASED.match(line)), None)
    return section(lines, start) if start is not None else ""


def release_errors(lines, version, prerelease):
    newest = next((v for _, v, _ in releases(lines)), None)
    pending = unreleased_body(lines)
    if prerelease:
        if release_index(lines, version) is not None:
            yield f"0: {version} already has a release section; a pre-release keeps its entries under [Unreleased]"
        if not pending:
            yield "0: [Unreleased] is empty; a pre-release must carry the pending entries"
    else:
        if newest is None or version_key(newest) != version_key(version):
            yield f"0: newest changelog release is {newest}, expected {version}"
        if pending:
            yield "0: [Unreleased] still has entries; move them into the release section"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--changelog", type=Path, default=Path("CHANGELOG.md"))
    parser.add_argument("--version", help="version about to be released, without pre-release suffix")
    parser.add_argument("--prerelease", action="store_true", help="the release is a pre-release")
    parser.add_argument("--extract", help="print the body of this release section and exit")
    args = parser.parse_args()

    lines = args.changelog.read_text(encoding="utf-8").splitlines()

    if args.extract:
        start = release_index(lines, args.extract)
        if start is None:
            sys.exit(f"no release section for version {args.extract} in {args.changelog}")
        print(section(lines, start))
        return 0

    errors = list(structure_errors(lines))
    if args.version:
        errors.extend(release_errors(lines, args.version, args.prerelease))

    for error in errors:
        print(f"{args.changelog}:{error}", file=sys.stderr)
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
