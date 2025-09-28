variable "envname" {
  description = "Environment name"
  type        = string
}

variable "nodes" {
  description = "Configuration for cluster nodes"
  type = map(object({
    machine_type      = string
    ip                = string
    mac_address       = string
    enable_qemu_agent = optional(bool, true)
    cpu               = number
    memory            = number
    disk_size         = number
  }))
  default = {}
}

variable "libvirt_server" {
  type        = string
  description = "Home Lab KVM server"
  default     = "192.168.1.10"
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
  default     = "homeserver-k8s"
}

variable "network_cidr" {
  description = "CIDR de la red del cluster"
  type        = string
  default     = "10.0.100.0/24"
}

variable "gateway_ip" {
  description = "IP del gateway de la red"
  type        = string
  default     = "10.0.100.1"
}

variable "dns_servers" {
  description = "Servidores DNS"
  type        = list(string)
  default     = ["1.1.1.1", "8.8.8.8"]
}

variable "talos_version" {
  description = "Versión de Talos OS"
  type        = string
  default     = "v1.11.2"
}