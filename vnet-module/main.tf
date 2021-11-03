# Terraform configuration

locals {
  network_cidr      = "${var.network_cidr_prefix}/${var.network_cidr_suffix}"
  network_obj       = [
    for i, n in var.subnet : {
      name          = n.name
      new_bits      = abs(var.network_cidr_suffix - n.cidr_block)
    }]
}

module "subnet_addrs" {
  source            = "git@github"
  base_cidr_block   = locals.network_cidr
  networks          = locals.network_obj

}

resource "azure_virtual_network" "network" {
  name                = "${var.name}-network"
  address_space       = [module.subnet_addrs.base_cidr_block]
  location            = var.region
  resource_group_name = var.resource_group_name
  dynamic "subnet" {
    for_each = module.subnet_addrs.network_cidr_blocks
    content {
      name            =  subnet.key
      address_prefix  =  subnet.value
    }
  }
}
