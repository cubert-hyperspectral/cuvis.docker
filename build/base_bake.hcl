
variable "cuvis_ver"     { default = "3.4.0" }     # override with --set cuvis_ver=3.4.0

variable "variants"  {
  default = [
    #  ubuntu
    { ubuntu = "22.04" },
    { ubuntu = "24.04" }
  ]
}

group "default" { targets = ["cuvis_base"] }

target "cuvis_base" {
  name = "cuvis_base-ubuntu${replace(v.ubuntu, ".", "-")}"
  context    = "."
  dockerfile = "docker/base/Dockerfile"
  platforms  = ["linux/amd64"]

  matrix = { v = "${variants}" }

  args = {
    UBUNTU_VERSION = "${v.ubuntu}"
    CUVIS_VERSION  = "${cuvis_ver}"
  }

  tags = [
    "cubertgmbh/cuvis_base:${cuvis_ver}-ubuntu${v.ubuntu}",
  ]

  push = true
}
