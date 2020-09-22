// Kubernetes cluster connection
variable "cluster_fqdn" {}
variable "cluster_client_key" {}
variable "cluster_client_certificate" {}
variable "cluster_ca_certificate" {}

// Probably no reason to ever change
variable "ingress_namespace" {
  type = string
  default = "kube-system"
}
variable "ingress_release_name" {
  type = string
  default = "nginx-ingress"
}

// Ingress has pre-provisioned static public IP in different RG
variable "ingress_public_ip" {}
variable "ingress_public_ip_rg" {}

// DNS things
// DNS zone should already exist 
variable "dns_zone_name" {}
variable "dns_zone_rg" {}
variable "dns_zone_ingress_a_record" {
  type = string
  default = "*.kube-new"
}

// Cert-manager
variable "cert_manager_namespace" {
  type = string
  default = "cert-manager"
}
variable "cert_manager_release_name" {
  type = string
  default = "cert-manager"
}