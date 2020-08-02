variable "common" {
  type = map
  default = {
    location = "westeurope"
  }
}

variable "prefix" {
  type = string
}

variable "image" {
  type = string
}
