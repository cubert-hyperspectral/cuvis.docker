![image](https://raw.githubusercontent.com/cubert-hyperspectral/cuvis.sdk/main/branding/logo/banner.png)

# cuvis.docker

cuvis.docker builds the Linux container image that ships the cuvis SDK ([available here](https://github.com/cubert-hyperspectral/cuvis.sdk)) preinstalled, and holds the release tooling shared by the cuvis wrapper repositories.

- **Website:** https://www.cubert-hyperspectral.com/
- **Source code:** https://github.com/cubert-hyperspectral/
- **Support:** http://support.cubert-hyperspectral.com/

## Images

| Image | Built by | Content |
| --- | --- | --- |
| [cubertgmbh/cuvis_base](https://hub.docker.com/r/cubertgmbh/cuvis_base) | this repository | Ubuntu, cuvis SDK, cmake |
| [cubertgmbh/cuvis_pyil](https://hub.docker.com/r/cubertgmbh/cuvis_pyil) | [cuvis.pyil](https://github.com/cubert-hyperspectral/cuvis.pyil) | `cuvis_base` plus the compiled `cuvis-il` interface layer in a Python virtual environment |

Tags are `<sdk version>-ubuntu<22.04|24.04|26.04>[-arm64]`, for example `cubertgmbh/cuvis_base:3.5.3-ubuntu24.04`; Ubuntu 26.04 exists for amd64 only.
All images package the CUDA-less SDK build except the Jetson ones.
The tag names the SDK version only; a rebuild or a wrapper revision for the same SDK overwrites it, so a tag always points at the newest working build for that SDK.
The arm64 variants target NVIDIA Jetson and package the CUDA build of the SDK.

There is no `cuvis_python` image.
The `cuvis` wrapper is pure Python and changes independently of the SDK, so add it yourself and you always get the current release:

```dockerfile
FROM cubertgmbh/cuvis_pyil:3.5.3-ubuntu24.04
RUN pip install "cuvis==3.5.3.*"
```

or interactively:

```bash
docker run -it cubertgmbh/cuvis_pyil:3.5.3-ubuntu24.04 bash
pip install cuvis
```

## Building locally

```bash
CUVIS_VERSION=3.5.3 docker buildx bake amd64            # all Ubuntu variants for this machine
CUVIS_VERSION=3.5.3 docker buildx bake --print          # show what would be built
```

`docker-bake.hcl` refuses to run without `CUVIS_VERSION`; there is no default version in the repository.

## Release order

The three repositories release in a fixed order, each gated on the previous artifact:

```
1. cuvis.docker   tag vX.Y.Z        -> cubertgmbh/cuvis_base:X.Y.Z-ubuntu*
2. cuvis.pyil     tag vX.Y.Z.W      -> cuvis-il X.Y.Z.W on PyPI, cubertgmbh/cuvis_pyil:X.Y.Z-ubuntu*
3. cuvis.python   tag vX.Y.Z.W      -> cuvis X.Y.Z.W on PyPI
```

- cuvis.docker checks that the SDK download for `X.Y.Z` exists.
- cuvis.pyil checks that `cuvis_base:X.Y.Z-ubuntu24.04` exists before building wheels inside it.
- cuvis.python checks that `cuvis_pyil:X.Y.Z-ubuntu24.04` exists; its tests run inside it.

## Releasing cuvis.docker

Versions are `X.Y.Z`, the cuvis SDK release being packaged.
Use `X.Y.Z.W` for an image-only rebuild against the same SDK; the image tag stays `X.Y.Z`.
Append `a1`, `b1` or `rc1` for a pre-release: the pipeline runs and pushes the same image tags, but no GitHub Release is created and the changelog entries stay under `## [Unreleased]`.

1. Record the changes under `## [Unreleased]` in `CHANGELOG.md`.
   For a final release rename that section to `## [X.Y.Z] - <today>` and add a fresh empty `## [Unreleased]` above it.
2. Merge to `main`, then tag and push:

   ```bash
   git checkout main && git pull
   git tag -a vX.Y.Z -m "cuvis_base X.Y.Z"
   git push origin vX.Y.Z
   ```

3. `release.yml` validates the tag and the changelog, downloads the SDK release, bakes and pushes every variant it contains packages for, verifies each pushed tag, and for a final version creates the GitHub Release with the changelog section as notes.

A pre-release SDK download may lack some variants, typically the Jetson packages.
Those images are skipped and the run finishes green with a warning annotation and a step summary listing what was built and what was not; the existing image tags for the missing variants stay as they are.
A final release needs every variant and fails otherwise.

### One-time repository setup

- Environment `dockerhub` under Settings -> Environments with the secrets `DOCKERHUB_USERNAME` (the organisation name) and `DOCKERHUB_TOKEN` (an organisation access token with read and write access to the image repositories).
  cuvis.pyil needs the same environment.
- Once the Docker organisation is on a Team, Business or Sponsored OSS plan, replace the token with an OIDC connection: create it under Docker Home -> Organization -> OIDC connections with the subject rule `repo:cubert-hyperspectral/cuvis.docker:ref:refs/tags/*`, give the `build` job `id-token: write`, and pass `DOCKERHUB_OIDC_CONNECTIONID` to `docker/login-action` instead of the password.
- Tag protection so only maintainers can push `v*` tags; the tag push is the release decision.

## Shared release tooling

The wrapper repositories reference these composite actions as `cubert-hyperspectral/cuvis.docker/.github/actions/<name>@main`:

| Action | Purpose |
| --- | --- |
| `release-meta` | Splits a version into base version, SDK version and pre-release flag; checks a tag against it. |
| `changelog` | Validates `CHANGELOG.md`, checks it is ready for a release, or extracts one section as release notes. |
| `tag-on-main` | Fails unless the tagged commit is an ancestor of `main`. |

### Getting involved

cuvis.hub welcomes your enthusiasm and expertise!

With providing our SDK wrappers on GitHub, we aim for a community-driven open
source application development by a diverse group of contributors.
Cubert GmbH aims for creating an open, inclusive, and positive community.
Feel free to branch/fork this repository for later merge requests, open
issues or point us to your application specific projects.
Contact us, if you want your open source project to be included and shared
on this hub; either if you search for direct support, collaborators or any
other input or simply want your project being used by this community.
We ourselves try to expand the code base with further more specific
applications using our wrappers to provide starting points for research
projects, embedders or other users.

### Getting help

Directly code related issues can be posted here on the GitHub page, other, more
general and application related issues should be directed to the
aforementioned Cubert GmbH [support page](http://support.cubert-hyperspectral.com/).
