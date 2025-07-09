resource "vault_auth_backend" "k8s" {
  depends_on = [docker_container.vault]

  type        = "kubernetes"
  path        = "kubernetes"
  description = "Kubernetes Auth Backend"
}

resource "vault_kubernetes_auth_backend_config" "k8s" {
  backend            = vault_auth_backend.k8s.path
  kubernetes_host    = "https://dev-control-plane:6443"           # External Kubernetes API server
  kubernetes_ca_cert = kind_cluster.dev.cluster_ca_certificate    # CA Cert for External Kubernetes API server
  token_reviewer_jwt = data.kubernetes_secret.vault.data["token"] # Service Account Token for Vault
}

resource "vault_kubernetes_auth_backend_role" "this" {
  backend                          = vault_kubernetes_auth_backend_config.k8s.backend
  role_name                        = "workload-role"
  audience                         = "vault"
  bound_service_account_names      = [kubernetes_service_account.app.metadata[0].name]
  bound_service_account_namespaces = [kubernetes_namespace.workloads.metadata[0].name]
  token_policies                   = ["default"]
  token_ttl                        = 60 * 60 * 24          # 1 day
  token_max_ttl                    = 60 * 60 * 24 * 7 * 30 # 1 month
}
