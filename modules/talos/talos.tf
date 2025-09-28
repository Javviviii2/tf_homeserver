# Generar secretos para Talos
resource "talos_machine_secrets" "this" {
  talos_version = var.cluster.talos_version
}

# Configuración cliente de Talos
data "talos_client_configuration" "this" {
  cluster_name         = var.cluster.name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = [for k, v in var.nodes : v.ip]
  endpoints            = [for k, v in var.nodes : v.ip if v.machine_type == "controlplane"]
}

# Configuración de máquinas
data "talos_machine_configuration" "this" {
  for_each         = var.nodes
  cluster_name     = var.cluster.name
  cluster_endpoint = "https://${var.cluster.endpoint}:6443"
  talos_version    = var.cluster.talos_version
  machine_type     = each.value.machine_type
  machine_secrets  = talos_machine_secrets.this.machine_secrets

  config_patches = each.value.machine_type == "controlplane" ? [
    templatefile("${path.module}/files/control-plane.yaml.tftpl", {
      hostname      = each.key
      cluster_name  = var.cluster.name
      installer_url = "factory.talos.dev/${local.schematic_id}:${local.version}"
      ip            = each.value.ip
      cidr_prefix   = split("/", var.cluster.network_cidr)[1]
      gateway       = var.cluster.gateway
      dns_servers   = var.cluster.dns_servers
    })
    ] : [
    templatefile("${path.module}/files/worker.yaml.tftpl", {
      hostname      = each.key
      cluster_name  = var.cluster.name
      installer_url = "factory.talos.dev/${local.schematic_id}:${local.version}"
      ip            = each.value.ip
      cidr_prefix   = split("/", var.cluster.network_cidr)[1]
      gateway       = var.cluster.gateway
      dns_servers   = var.cluster.dns_servers
    })
  ]
}

# Aplicar configuración a las máquinas
resource "talos_machine_configuration_apply" "this" {
  for_each                    = var.nodes
  node                        = each.value.ip
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this[each.key].machine_configuration

  depends_on = [libvirt_domain.talos_cluster]
}

# Bootstrap del cluster (solo en el primer controlplane)
resource "talos_machine_bootstrap" "this" {
  node                 = [for k, v in var.nodes : v.ip if v.machine_type == "controlplane"][0]
  endpoint             = var.cluster.endpoint
  client_configuration = talos_machine_secrets.this.client_configuration

  depends_on = [talos_machine_configuration_apply.this]
}

# Generar kubeconfig
resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoint             = var.cluster.endpoint
  node                 = [for k, v in var.nodes : v.ip if v.machine_type == "controlplane"][0]

  depends_on = [
    talos_machine_bootstrap.this
  ]
}

# Guardar kubeconfig localmente
resource "local_file" "kubeconfig" {
  content              = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename             = "${pathexpand("~")}/.kube/config"
  directory_permission = "0755"
  file_permission      = "0600"
}