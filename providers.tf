provider "libvirt" {
  uri = "qemu+ssh://javi@${var.libvirt_server}/system"
}

provider "talos" {}

provider "time" {}

provider "tls" {}

provider "local" {}