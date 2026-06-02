
variable "cuvis_ver"     { default = "3.5.3" }     # override with --set cuvis_ver=3.4.0

variable "variants"  {
  default = [
    #  ubuntu       py        numpy      arch      name_suffix  tag_suffix
    { ubuntu = "22.04", py = "3.10", np = "2.0.0", arch = "amd64", ns = "",       ts = ""       },
    { ubuntu = "24.04", py = "3.12", np = "2.0.0", arch = "amd64", ns = "",       ts = ""       },
    { ubuntu = "24.04", py = "3.12", np = "2.0.0", arch = "arm64", ns = "-arm64", ts = "-arm64" },
  ]
}

group "default" { targets = ["cuvis_pyil"] }

target "cuvis_pyil" {
  name = "cuvis_pyil-ubuntu${replace(v.ubuntu, ".", "-")}${v.ns}"
  context    = "."
  dockerfile = "docker/pyil/Dockerfile"
  platforms  = ["linux/${v.arch}"]

  matrix = { v = "${variants}" }

  args = {
    UBUNTU_VERSION = "${v.ubuntu}"
    PYTHON_VERSION = "${v.py}"
    NUMPY_VERSION  = "${v.np}"
    CUVIS_VERSION  = "${cuvis_ver}"
    TAG_SUFFIX     = "${v.ts}"
  }

  tags = [
    "cubertgmbh/cuvis_pyil:${cuvis_ver}-ubuntu${v.ubuntu}${v.ts}",
  ]

  push = true
}
