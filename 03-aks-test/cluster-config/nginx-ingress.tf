resource "helm_release" "nginx_ingress" {
  name       = var.ingress_release_name
  repository = "https://kubernetes.github.io/ingress-nginx" 
  chart      = "ingress-nginx"
  namespace  = var.ingress_namespace

  # Set values for pre-provisioned public IP on ingress controller service
  # Also special annotation with Azure resource group containing this public IP
  # See https://docs.microsoft.com/en-us/azure/aks/static-ip#create-a-service-using-the-static-ip-address
  values     = [<<EOF
controller:
  service:
    loadBalancerIP: ${var.ingress_public_ip}
    annotations:
      service.beta.kubernetes.io/azure-load-balancer-resource-group: ${var.ingress_public_ip_rg}
EOF
  ]
}

// DNS record
resource "azurerm_dns_a_record" "ingress" {
  name                = var.dns_zone_ingress_a_record
  zone_name           = var.dns_zone_name
  resource_group_name = var.dns_zone_rg
  ttl                 = 300
  records             = [ var.ingress_public_ip ]
}
