variable "resource_group_name" {
    type = string
    default = "aks-vnet-rg"
  
}

variable "region" {
    default = "eastus2"
  
}

variable "name" {
    default = "aks-vnet"
  
}

variable "network_cidr_prefix" {
    type = string
    default = "10.0.0.0"
  
}

variable "network_cidr_suffix" {
    type = number
    default = "8"
  
}

variable "subnet" {
    type = list(object({
        name        = string
        cidr_block  = number
    }))
    default = [{
        name        = "subnet-1"
        cidr_block  = 18
    },
    {
        name        = "subnet-2"
        cidr_block  = 18
    }]
}