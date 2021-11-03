resource "azurerm_kubernetes_cluster" "cluster" {
  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
      default_node_pool[0].node_taints,
      role_based_access_control[0].azure_active_directory[0].server_app_secret
    ]
  }
  name                = var.cluster_name
  location            = var.region
  dns_prefix          = var.cluster_name
  resource_group_name = var.resource_group_name
  kubernetes_version  = var.kubernetes_version

  linux_profile {
    admin_username = var.admin_username

    ssh_key {
      key_data = var.public_ssh_key
    }
  }

  addon_profile {
      kube_dashboard {
      enabled = var.enable_kube_dashboard
    }
    aci_connector_linux {
      enabled = var.enable_aci_connector_linux
    }
    azure_policy {
      enabled = var.enable_azure_policy
    }

 default_node_pool {
    name                  = "default"
    node_count            = var.node_count
    enable_auto_scaling   = var.enable_auto_scaling
    enable_node_public_ip = var.enable_node_public_ip
    node_taints           = var.node_taints
    os_disk_size_gb       = var.os_disk_size_gb
    min_count             = var.node_min_count
    max_count             = var.node_max_count
    vm_size               = var.node_type
    availability_zones    = var.node_availability_zones
    max_pods              = var.node_max_pods
    vnet_subnet_id        = var.node_subnet_id
    orchestrator_version  = var.kubernetes_version
  }
  network_profile {
    network_plugin    = var.network_plugin
    network_policy     = var.network_policy
    docker_bridge_cidr = var.docker_bridge_cidr
    pod_cidr           = var.pod_cidr
    service_cidr       = var.service_cidr
    }
  }
}