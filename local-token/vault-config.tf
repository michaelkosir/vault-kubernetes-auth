resource "vault_auth_backend" "k8s" {
  depends_on = [kubernetes_service.vault]

  type        = "kubernetes"
  path        = "kubernetes"
  description = "Kubernetes Auth Backend"
}

resource "vault_kubernetes_auth_backend_config" "k8s" {
  backend         = vault_auth_backend.k8s.path
  kubernetes_host = "https://kubernetes.default.svc.cluster.local"
}

resource "vault_kubernetes_auth_backend_role" "this" {
  depends_on = [kubernetes_service.vault]

  backend                          = vault_auth_backend.k8s.path
  role_name                        = "workload-role"
  audience                         = "vault"
  bound_service_account_names      = [kubernetes_service_account.app.metadata[0].name]
  bound_service_account_namespaces = [kubernetes_namespace.workloads.metadata[0].name]
  token_policies                   = ["default"]
  token_ttl                        = 60 * 60 * 24          # 1 day
  token_max_ttl                    = 60 * 60 * 24 * 7 * 30 # 1 month
}
