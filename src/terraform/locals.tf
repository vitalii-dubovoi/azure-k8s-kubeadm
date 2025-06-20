locals {
  k8s_subnets = [
    {
      name             = "snet-controlplane-01"
      address_prefixes = ["10.10.0.0/27"]
      network_security_group = {
        id = module.nsg.resource_id
      }
    },
    {
      name             = "snet-workers-01"
      address_prefixes = ["10.10.0.32/27"]
      network_security_group = {
        id = module.nsg.resource_id
      }
    }
  ]
  k8s_subnets_map = { for subnet in local.k8s_subnets : subnet.name => subnet }
  k8s_nodes = [
    {
      name        = "controlplane01"
      subnet_name = "snet-controlplane-01"
    },
    {
      name        = "worker01"
      subnet_name = "snet-workers-01"
    }
  ]
  nsg_rules = {
    for rule in [
      {
        name                       = "${module.naming.network_security_rule.name_unique}-ssh"
        access                     = "Allow"
        destination_address_prefix = "*"
        destination_port_range     = "22"
        direction                  = "Inbound"
        priority                   = 100
        protocol                   = "Tcp"
        source_address_prefix      = "*"
        source_port_range          = "*"
      }
    ] : rule.name => rule
  }
}
