# Changelog

All notable changes to the cuvis container images are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

Versions are `GENERATION.MAJOR.MINOR`, the cuvis SDK release the images package.
A fourth component counts image-only rebuilds against that same SDK; the image tag stays `GENERATION.MAJOR.MINOR`.
Pre-releases (`b*`, `rc*`) are not listed.

## [Unreleased]

### Added

- `CI` - `.github/workflows/release.yml` is driven by `v*` tags: it validates the tag against this file and the SDK download, bakes and pushes `cuvis_base` for every variant on native amd64 and arm64 runners, and creates a GitHub Release from the matching section here.
  Pre-release tags (`a`, `b`, `rc` suffix) push the same image tags but create no GitHub Release.
- `CI` - `.github/scripts/sdk_targets.py` builds only the variants the SDK download contains packages for; a pre-release finishes with a warning for the missing ones, a final release fails.
- `CI` - `.github/actions/release-meta`, `.github/actions/changelog` and `.github/actions/tag-on-main` are shared by the cuvis.pyil and cuvis.python release workflows.
- `cuvis_base` - Ubuntu 26.04 variant for amd64, tagged `<sdk>-ubuntu26.04`.
- `CHANGELOG.md` - this file.

### Changed

- `docker-bake.hcl` - replaces `build/base_bake.hcl`; the SDK version comes from the `CUVIS_VERSION` environment variable instead of a default in the file, and the `amd64` and `arm64` groups build one architecture natively.
- `docker/base/Dockerfile` - the SDK variant folder is matched by a glob (`*[!0-9]` for the plain amd64 build, `cuda*-jetson*` for Jetson) instead of a pinned suffix, so the `nocuda` to `cudano` rename and CUDA version bumps between SDK releases need no change here; two matches fail the build.
- `docker/base/Dockerfile` - `CUVIS_VERSION` has no default any more; the build fails instead of silently packaging an old SDK.
- `README.md` - documents the image tags, the release order across cuvis.docker, cuvis.pyil and cuvis.python, and how to add the `cuvis` wrapper on top of `cuvis_pyil`.

### Removed

- `docker/pyil/Dockerfile`, `build/pyil_bake.hcl` - the `cuvis_pyil` image is now built by the cuvis.pyil release from the wheels it publishes, instead of cloning and compiling `main`.
- `docker/python/Dockerfile`, `build/python_bake.hcl` - the `cuvis_python` image is discontinued; `pip install cuvis` inside `cuvis_pyil` replaces it and always yields the current wrapper.

## [3.5.3] - 2026-06-03

### Added

- `cuvis_base`, `cuvis_pyil`, `cuvis_python` - arm64 variants tagged `-arm64`, built against the Jetson CUDA SDK packages.

### Changed

- `cuvis_base` - packages cuvis SDK 3.5.3.
- `cuvis_pyil`, `cuvis_python` - NumPy pins raised to 2.0.0 for the interface layer build.

## [3.5.0] - 2026-01-07

### Changed

- `cuvis_base` - packages cuvis SDK 3.5.0.
- Build instructions moved to `docker buildx bake` files under `build/`.

## [3.4.1] - 2025-10-02

### Changed

- `cuvis_base` - packages cuvis SDK 3.4.1.
- `cuvis_pyil` - compiled against NumPy 2.

## [3.3.3] - 2025-05-22

### Added

- `cuvis_base`, `cuvis_pyil`, `cuvis_python` - first images for Ubuntu 22.04 and 24.04, packaging the cuvis SDK 3.3.x line.
