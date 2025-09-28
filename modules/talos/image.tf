locals {
  factory_url = "https://factory.talos.dev"

  platform   = var.image.platform
  arch       = var.image.arch
  version    = var.image.version
  schematic  = var.image.schematic
  image_type = var.image.image_type

  schematic_id = jsondecode(data.http.schematic_id.response_body)["id"]
  image_id     = "${local.schematic_id}_${local.version}"
}

data "http" "schematic_id" {
  url          = "${local.factory_url}/schematics"
  method       = "POST"
  request_body = local.schematic

  request_headers = {
    Accept       = "application/json"
    Content-Type = "text/yaml"
  }
}

resource "libvirt_volume" "boot_image" {
  name   = "talos-${local.version}-${local.platform}-${local.arch}.${local.image_type}"
  source = "${local.factory_url}/image/${local.schematic_id}/${local.version}/${local.platform}-${local.arch}.${local.image_type}"
  pool   = libvirt_pool.homeserver.name
  
  depends_on = [libvirt_pool.homeserver]
}