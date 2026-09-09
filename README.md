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
