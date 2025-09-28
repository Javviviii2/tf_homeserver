locals {
  envname_tags = {
    envname = var.envname
    group   = "infrastructure"
    stack   = "homeserver-talos-infra"
  }
}