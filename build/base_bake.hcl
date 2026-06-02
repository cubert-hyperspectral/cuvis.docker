
variable "cuvis_ver"     { default = "3.5.3" }     # override with --set cuvis_ver=3.4.0

variable "variants"  {
  default = [
    #  ubuntu    arch      cuda_suffix                          name_suffix  tag_suffix
    { ubuntu = "22.04", arch = "amd64", cuda_suffix = "nocuda",                       ns = "",       ts = ""       },
    { ubuntu = "24.04", arch = "amd64", cuda_suffix = "nocuda",                       ns = "",       ts = ""       },
    { ubuntu = "24.04", arch = "arm64", cuda_suffix = "cuda13.0-jetson-experimental", ns = "-arm64", ts = "-arm64" },
  ]
}

group "default" { targets = ["cuvis_base"] }

target "cuvis_base" {
  name = "cuvis_base-ubuntu${replace(v.ubuntu, ".", "-")}${v.ns}"
  context    = "."
  dockerfile = "docker/base/Dockerfile"
  platforms  = ["linux/${v.arch}"]

  matrix = { v = "${variants}" }

  args = {
    UBUNTU_VERSION = "${v.ubuntu}"
    CUVIS_VERSION  = "${cuvis_ver}"
    ARCH           = "${v.arch}"
    CUDA_SUFFIX    = "${v.cuda_suffix}"
  }

  tags = [
    "cubertgmbh/cuvis_base:${cuvis_ver}-ubuntu${v.ubuntu}${v.ts}",
  ]

  push = true
}
