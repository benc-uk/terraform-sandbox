variable "common" {
  type    = map
  default = {
    location = "westeurope"
  }
}

variable "prefix" {
  type = string
  default = "tfapp"
}

variable "image" {
  type = string
}

variable "acr_name" {
  type = string
}

variable "acr_rg" {
  type = string
}
