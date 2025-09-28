variable "image" {
  description = "Talos image configuration"
  type = object({
    version      = string
    schematic    = string
    arch         = optional(string, "amd64")
    platform     = optional(string, "metal")
    image_type   = optional(string, "iso")
    datastore_id = optional(string, "iso")
  })
}

variable "cluster" {
  description = "Cluster configuration"
  type = object({
    name          = string
    endpoint      = string
    gateway       = string
    talos_version = string
    network_cidr  = string
    dns_servers   = list(string)
  })
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