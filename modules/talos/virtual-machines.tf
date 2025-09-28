# Volúmenes de disco para los nodos
resource "libvirt_volume" "node" {
  for_each = var.nodes
  name     = "${each.key}.qcow2"
  size     = each.value.disk_size
  pool     = libvirt_pool.homeserver.name

  depends_on = [libvirt_pool.homeserver]
}

# VMs del cluster
resource "libvirt_domain" "talos_cluster" {
  for_each  = var.nodes
  name      = each.key
  memory    = each.value.memory
  vcpu      = each.value.cpu
  autostart = true

  cpu {
    mode = "host-passthrough"
  }

  network_interface {
    network_id     = libvirt_network.cluster_network.id
    addresses      = [each.value.ip]
    mac            = each.value.mac_address
    wait_for_lease = false
  }

  boot_device {
    dev = ["hd", "cdrom"]
  }

  # Boot desde ISO de Talos
  disk {
    file = libvirt_volume.boot_image.id
  }

  # Disco principal del sistema
  disk {
    volume_id = libvirt_volume.node[each.key].id
  }

  qemu_agent = each.value.enable_qemu_agent

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
  }

  depends_on = [
    libvirt_volume.boot_image,
    libvirt_volume.node,
    libvirt_network.cluster_network
  ]
}