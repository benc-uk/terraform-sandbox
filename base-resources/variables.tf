# Leave these secrets blank!, provided via secrets.auto.tfvars
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

variable "common" {
  type    = map
  default = {
    location = "West Europe"
  }
}

variable "prefix" {
  type = string
  default = "tfbase"
}