# Environment: homeserver
envname = "homeserver"

# Nodes configuration following shirwalab pattern
nodes = {
  "talos-ctrl-1" = {
    machine_type = "controlplane"
    ip           = "10.0.110.11"
    mac_address  = "52:54:00:12:34:11"
    cpu          = 2
    memory       = 3072
    disk_size    = 21474836480 # 20GB
  }
  "talos-work-1" = {
    machine_type = "worker"
    ip           = "10.0.110.12"
    mac_address  = "52:54:00:12:34:12"
    cpu          = 2
    memory       = 3072
    disk_size    = 21474836480 # 20GB
  }
}

# Infrastructure configuration
libvirt_server = "192.168.1.10"
cluster_name   = "homeserver-k8s"
network_cidr   = "10.0.110.0/24"
gateway_ip     = "10.0.110.1"
dns_servers    = ["1.1.1.1", "8.8.8.8"]
talos_version  = "v1.11.2"