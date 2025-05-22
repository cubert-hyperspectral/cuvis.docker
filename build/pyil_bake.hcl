
variable "cuvis_ver"     { default = "3.3.3" }     # override with --set cuvis_ver=3.4.0

variable "variants"  {
  default = [
    #  ubuntu       py        numpy
    { ubuntu = "22.04", py = "3.10", np = "1.22.0" },
    { ubuntu = "24.04", py = "3.12", np = "1.26.0" }
  ]
}

group "default" { targets = ["cuvis_pyil"] }

target "cuvis_pyil" {
  name = "cuvis_pyil-ubuntu${replace(v.ubuntu, ".", "-")}"
  context    = "."
  dockerfile = "docker/pyil/Dockerfile"
  platforms  = ["linux/amd64"]

  matrix = { v = "${variants}" }

  args = {
    UBUNTU_VERSION = "${v.ubuntu}"
    PYTHON_VERSION = "${v.py}"
    NUMPY_VERSION  = "${v.np}"
    CUVIS_VERSION  = "${cuvis_ver}"
    CUVIS_MINOR_V = "${regex_replace(cuvis_ver, "\\.[0-9]+$", "")}"  # 3.3.3 → 3.3
  }

  tags = [
    "cubertgmbh/cuvis_pyil:${cuvis_ver}-ubuntu${v.ubuntu}",
  ]

  push = true
}
