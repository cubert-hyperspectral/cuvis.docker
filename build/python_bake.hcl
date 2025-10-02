
variable "cuvis_ver"     { default = "3.4.1" }     # override with --set cuvis_ver=3.4.0

variable "variants"  {
  default = [
    #  ubuntu       py        numpy
    { ubuntu = "22.04", py = "3.10", np = "1.22.0" },
    { ubuntu = "24.04", py = "3.12", np = "1.26.0" }
  ]
}

group "default" { targets = ["cuvis_python"] }

target "cuvis_python" {
  name = "cuvis_python-ubuntu${replace(v.ubuntu, ".", "-")}"
  context    = "."
  dockerfile = "docker/python/Dockerfile"
  platforms  = ["linux/amd64"]

  matrix = { v = "${variants}" }

  args = {
    UBUNTU_VERSION = "${v.ubuntu}"
    PYTHON_VERSION = "${v.py}"
    NUMPY_VERSION  = "${v.np}"
    CUVIS_VERSION  = "${cuvis_ver}"
  }

  tags = [
    "cubertgmbh/cuvis_python:${cuvis_ver}-ubuntu${v.ubuntu}",
  ]

  push = true
}
