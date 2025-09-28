module "talos" {
  source = "./modules/talos"

  image = {
    version   = var.talos_version
    schematic = file("${path.module}/modules/talos/files/schematic.yaml")
  }

  cluster = {
    name          = var.cluster_name
    endpoint      = [for k, v in var.nodes : v.ip if v.machine_type == "controlplane"][0]
    gateway       = var.gateway_ip
    talos_version = var.talos_version
    network_cidr  = var.network_cidr
    dns_servers   = var.dns_servers
  }

  nodes = var.nodes
}