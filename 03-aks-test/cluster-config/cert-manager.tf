resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = var.cert_manager_namespace
  }
}

resource "helm_release" "cert_manager" {
  name       = var.cert_manager_release_name
  repository = "https://charts.jetstack.io" 
  chart      = "cert-manager"
  namespace  = var.cert_manager_namespace

  set {
    name   = "installCRDs"
    value = "true"
  }
}

resource "kubernetes_manifest" "cluster_issuer" {
  depends_on = [ helm_release.cert_manager ]
  provider = kubernetes-alpha

  manifest = {
    apiVersion = "cert-manager.io/v1alpha2"
    kind = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
    }
    spec = {
      acme = {
        email = "ben.coleman@microsoft.com"
        privateKeySecretRef = {
          name = "letsencrypt-prod-key"
        }
        server = "https://acme-v02.api.letsencrypt.org/directory"
        solvers = [
          {
            http01 = {
              ingress = {
                class = "nginx"
              }
            }
          },
          {
            dns01 = {
              azuredns = {
                clientID = "b5c68105-ea7d-42ac-9642-17efdbf60c1a"
                clientSecretSecretRef = {
                  "key" = "CLIENT_SECRET"
                  "name" = "azuredns-config"
                }
                hostedZoneName = "benco.io"
                resourceGroupName = "Live.Misc"
                subscriptionID = "52512f28-c6ed-403e-9569-82a9fb9fec91"
                tenantID = "72f988bf-86f1-41af-91ab-2d7cd011db47"
              }
            }
          },
        ]
      }
    }
  }  
}