
variable "cuvis_ver"     { default = "3.4.1" }     # override with --set cuvis_ver=3.4.0

variable "variants"  {
  default = [
    #  ubuntu       py        numpy
    { ubuntu = "22.04", py = "3.10", np = "2.0.0" },
    { ubuntu = "24.04", py = "3.12", np = "2.0.0" }
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
  }

  tags = [
    "cubertgmbh/cuvis_pyil:${cuvis_ver}-ubuntu${v.ubuntu}",
  ]

  push = true
}
