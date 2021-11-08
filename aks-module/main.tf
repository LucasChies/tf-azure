provider "helm" {
  kubernetes {
    host = azurerm_kubernetes_cluster.aks.kube_config[0].host

    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
  }
}
#
resource "azurerm_virtual_network" "vnet" {
  name                = "aks-vnet"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "aksnodes"
  resource_group_name  = "${var.resource_group_name}"
  address_prefixes       = ["10.1.0.0/24"]
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
}


resource "azurerm_kubernetes_cluster" "aks" {
    name                = "${var.cluster_name}"
    location            = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
    dns_prefix          = "${var.dns_prefix}"

    linux_profile {
        admin_username = "azureuser"

        ssh_key {
            key_data = "${file("${var.ssh_public_key}")}"
        }
    }

    default_node_pool {
        name            = "akspool"
        node_count      = "${var.agent_count}"
        vm_size         = "Standard_DS2_v2"
        os_disk_size_gb = 30
        enable_auto_scaling = false
        vnet_subnet_id = "${azurerm_subnet.subnet.id}"
        
    }

    addon_profile {

        kube_dashboard {
            enabled = true
        }
    
    }

    service_principal {
        client_id     = "${var.client_id}"
        client_secret = "${var.client_secret}"
    }

    network_profile {
        network_plugin = "${var.network_plugin}"
    }

    role_based_access_control {
        enabled = true
    }

    tags = merge({
        Environment = "Development"
    })
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"


  set {
    name  = "rbac.create"
    value = "true"
  }
}

data "azuread_service_principal" "akssp" {
  application_id = "${var.client_id}"
}

resource "azurerm_role_assignment" "netcontribrole" {
  scope                = "${azurerm_subnet.subnet.id}"
  role_definition_name = "Network Contributor"
  principal_id         = "${data.azuread_service_principal.akssp.object_id}"
}

## new addiction
resource "azurerm_role_assignment" "acrpull" {
  scope                = "${azurerm_subnet.subnet.id}"
  role_definition_name = "AcrPull"
  principal_id         = "${data.azuread_service_principal.akssp.object_id}"
}

resource "azurerm_public_ip" "ingress" {
  name                = "AKS-Ingress-Controller"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.location}"
  allocation_method   = "Static"
}

resource "azurerm_container_registry" "acr" {
  name                     = "${var.acrname}"
  resource_group_name      = "${var.resource_group_name}"
  location                 = "${var.location}"
  sku                      = "Standard"
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}



