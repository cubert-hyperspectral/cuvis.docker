# Build with the SDK version taken from the environment, one architecture group per native runner:
#   CUVIS_VERSION=3.5.3 docker buildx bake amd64
variable "CUVIS_VERSION" {
  default = ""
  validation {
    condition     = CUVIS_VERSION != ""
    error_message = "Set CUVIS_VERSION to the cuvis SDK release to package, e.g. CUVIS_VERSION=3.5.3"
  }
}

# cuda_suffix is a glob over the SDK download's "Ubuntu <ubuntu>-<arch>-<suffix>" folders and
# must match exactly one. The suffix is the SDK's choice and changes between releases: CUDA
# builds end in the CUDA version (cuda12.9, cuda13.3), the plain build does not ("nocuda" up
# to 3.5, "cudano" from 3.6), Jetson builds carry both the CUDA version and "-jetson".
variable "variants" {
  default = [
    { ubuntu = "22.04", arch = "amd64", cuda_suffix = "*[!0-9]" },
    { ubuntu = "24.04", arch = "amd64", cuda_suffix = "*[!0-9]" },
    { ubuntu = "26.04", arch = "amd64", cuda_suffix = "*[!0-9]" },
    { ubuntu = "22.04", arch = "arm64", cuda_suffix = "cuda*-jetson*" },
    { ubuntu = "24.04", arch = "arm64", cuda_suffix = "cuda*-jetson*" },
  ]
}

function "target_name" {
  params = [v]
  result = "cuvis_base-ubuntu${replace(v.ubuntu, ".", "-")}${v.arch == "amd64" ? "" : "-${v.arch}"}"
}

group "default" { targets = ["amd64", "arm64"] }
group "amd64"   { targets = [for v in variants : target_name(v) if v.arch == "amd64"] }
group "arm64"   { targets = [for v in variants : target_name(v) if v.arch == "arm64"] }

target "cuvis_base" {
  name       = target_name(v)
  matrix     = { v = variants }
  context    = "."
  dockerfile = "docker/base/Dockerfile"
  platforms  = ["linux/${v.arch}"]

  args = {
    UBUNTU_VERSION = v.ubuntu
    CUVIS_VERSION  = CUVIS_VERSION
    ARCH           = v.arch
    CUDA_SUFFIX    = v.cuda_suffix
  }

  tags = ["cubertgmbh/cuvis_base:${CUVIS_VERSION}-ubuntu${v.ubuntu}${v.arch == "amd64" ? "" : "-${v.arch}"}"]
}
