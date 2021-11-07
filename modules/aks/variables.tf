variable "client_id" {
    default = "1f5f9d2a-f4f4-4ec9-889b-e026e084225c"
}
variable "client_secret" {
    default = "di-zKprLbyPfXWGV_473zZ3T~WM6Nhw0f~"
}

variable "agent_count" {
    default = 1
}

variable "location" {
    default = "eastus2"
}

variable "ssh_public_key" {
    default = "~/.ssh/id_rsa.pub"
}
variable "dns_prefix" {
    default = "tf-aks-clcm"
}
variable cluster_name {
    default = "tf-aksclcm"
}

variable resource_group_name {
    default = "tf-aks-rg"
}

variable network_plugin {
    default = "kubenet"
}

variable acrname {
    default = "tfacr01"
}