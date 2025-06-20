module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"

  suffix = [var.project, var.region]
}

resource "azurerm_resource_group" "core" {
  name     = module.naming.resource_group.name
  location = var.region
}
module "k8s-vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.8.1"

  name                = module.naming.virtual_network.name
  resource_group_name = azurerm_resource_group.core.name
  location            = azurerm_resource_group.core.location
  address_space       = ["10.10.0.0/24"]
  subnets             = local.k8s_subnets_map
  enable_telemetry    = var.enable_telemetry
}

module "nsg" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.4.0"

  resource_group_name = azurerm_resource_group.core.name
  location            = azurerm_resource_group.core.location
  name                = module.naming.network_security_group.name_unique
  security_rules      = local.nsg_rules
}


module "k8s-nodes" {
  source   = "Azure/avm-res-compute-virtualmachine/azurerm"
  version  = "0.19.3"
  for_each = { for node in local.k8s_nodes : node.name => node }

  location                   = azurerm_resource_group.core.location
  resource_group_name        = azurerm_resource_group.core.name
  name                       = each.key
  encryption_at_host_enabled = false
  network_interfaces = {
    network_interface_1 = {
      name = "${module.naming.network_interface.name}-${each.key}"
      ip_configurations = {
        ip_configuration_1 = {
          name                          = "${module.naming.network_interface.name_unique}-ipconfig1"
          private_ip_subnet_resource_id = module.k8s-vnet.subnets[each.value.subnet_name].resource.id
          create_public_ip_address      = true
          public_ip_address_name        = "${module.naming.public_ip.name_unique}-${each.key}"
        }
      }
    }
  }
  zone = null
  account_credentials = {
    admin_credentials = {
      username                           = "vitalii"
      ssh_keys                           = [file("~/.ssh/id_ed25519.pub")]
      generate_admin_password_or_ssh_key = false
    }
  }
  enable_telemetry = var.enable_telemetry

  os_type = "Linux"

  sku_size = "Standard_B2s"
  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
