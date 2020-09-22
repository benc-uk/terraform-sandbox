//
// Common Azure config
//
variable "rg_name" {}
variable "prefix" {}
variable "location" {
  type = string
  default = "westeurope"
}

//
// AKS configuration
//
variable "aks_node_count" {
  type = number
  default = 2
}

variable "aks_node_size" {
  type = string
  default = "Standard_D2s_v3"
}

variable "aks_kube_version" {
  type = string
  default = "1.17.7"
}

//
// Networking variables
//
variable "vnet_address_space" {
  type = string
  default = "10.0.0.0/8"
}

variable "vnet_aks_subnet_cidr" {
  type = string
  default = "10.240.0.0/16"
}

//
// Prexisting resources to use
//
variable "acr_name" {}
variable "acr_rg" {}
variable "dns_zone_name" {}
variable "dns_zone_rg" {}