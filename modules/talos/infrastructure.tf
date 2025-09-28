# Storage pool para las VMs
resource "libvirt_pool" "homeserver" {
  name = var.cluster.name
  type = "dir"

  target {
    path = "/var/lib/libvirt/images/${var.cluster.name}"
  }
}

# Red del cluster
resource "libvirt_network" "cluster_network" {
  name      = "${var.cluster.name}-net"
  mode      = "route"
  domain    = "${var.cluster.name}.local"
  addresses = [var.cluster.network_cidr]

  autostart = true

  dhcp {
    enabled = false
  }

  dns {
    enabled    = true
    local_only = true
  }
}