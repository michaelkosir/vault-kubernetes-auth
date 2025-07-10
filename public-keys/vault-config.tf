data "http" "jwks" {
  url = "https://localhost:6443/openid/v1/jwks"

  ca_cert_pem     = kind_cluster.dev.cluster_ca_certificate
  client_cert_pem = kind_cluster.dev.client_certificate
  client_key_pem  = kind_cluster.dev.client_key
}

data "external" "jwks" {
  program = ["python3", "${path.module}/jwk-to-pem.py"]
  query = {
    data = data.http.jwks.response_body
  }
}

resource "vault_jwt_auth_backend" "jwt" {
  depends_on = [docker_container.vault]

  path        = "k8s"
  type        = "jwt"
  description = "JWT auth backend for Kubernetes workloads"

  jwt_validation_pubkeys = jsondecode(data.external.jwks.result.pem)
}

resource "vault_jwt_auth_backend_role" "jwt" {
  backend   = vault_jwt_auth_backend.jwt.path
  role_name = "workload-role"
  role_type = "jwt"

  bound_audiences = ["https://kubernetes.default.svc.cluster.local"] # The Kubernetes Issuer URL
  bound_subject   = "system:serviceaccount:${kubernetes_namespace.workloads.metadata[0].name}:${kubernetes_service_account.app.metadata[0].name}"
  user_claim      = "sub"

  token_policies = ["default"]
  token_ttl      = 60 * 60 * 24          # 1 day
  token_max_ttl  = 60 * 60 * 24 * 7 * 30 # 1 month
}
