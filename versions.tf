terraform {
  required_version = ">= 1.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.9.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.13.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}