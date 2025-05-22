
variable "cuvis_ver"     { default = "3.3.3" }     # override with --set cuvis_ver=3.4.0

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
    CUVIS_MINOR_V = "${regex_replace(cuvis_ver, "\\.[0-9]+$", "")}"  # 3.3.3 → 3.3
  }

  tags = [
    "cubertgmbh/cuvis_base:${cuvis_ver}-ubuntu${v.ubuntu}",
  ]

  push = true
}
