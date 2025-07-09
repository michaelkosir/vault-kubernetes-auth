resource "kubernetes_namespace" "vault" {
  depends_on = [kind_cluster.dev]

  metadata {
    name = "vault"
  }
}

resource "kubernetes_service_account" "vault" {
  metadata {
    name      = "vault"
    namespace = kubernetes_namespace.vault.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding" "vault" {
  metadata {
    name = "vault"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.vault.metadata[0].name
    namespace = kubernetes_namespace.vault.metadata[0].name
  }
}

resource "kubernetes_secret" "vault" {
  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true

  metadata {
    name      = kubernetes_service_account.vault.metadata[0].name
    namespace = kubernetes_namespace.vault.metadata[0].name

    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.vault.metadata[0].name
    }
  }
}

data "kubernetes_secret" "vault" {
  depends_on = [kubernetes_secret.vault]

  metadata {
    name      = kubernetes_secret.vault.metadata[0].name
    namespace = kubernetes_secret.vault.metadata[0].namespace
  }
}
