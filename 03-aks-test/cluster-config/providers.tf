provider "helm" {
  kubernetes {
    host                   = var.cluster_fqdn
    load_config_file       = false
    client_key             = base64decode(var.cluster_client_key)
    client_certificate     = base64decode(var.cluster_client_certificate)
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  }
}

provider "kubernetes" {
  host                   = var.cluster_fqdn
  load_config_file       = false
  client_key             = base64decode(var.cluster_client_key)
  client_certificate     = base64decode(var.cluster_client_certificate)
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

provider "kubernetes-alpha" {
  server_side_planning = true
  config_path = "~/.kube/config"
  # host                   = var.cluster_fqdn
  # client_key             = base64decode(var.cluster_client_key)
  # client_certificate     = base64decode(var.cluster_client_certificate)
  # cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}