resource "kubernetes_namespace" "workloads" {
  depends_on = [kind_cluster.dev]

  metadata {
    name = "workloads"
  }
}

resource "kubernetes_service_account" "app" {
  metadata {
    name      = "app"
    namespace = kubernetes_namespace.workloads.metadata[0].name
  }
}

resource "kubernetes_pod" "app" {
  depends_on = [vault_kubernetes_auth_backend_role.this]

  metadata {
    name      = "app"
    namespace = kubernetes_namespace.workloads.metadata[0].name

    labels = {
      app = "workloads"
    }
  }

  spec {
    service_account_name = kubernetes_service_account.app.metadata[0].name

    volume {
      name = "vault-auth-token"
      projected {
        sources {
          service_account_token {
            path               = "vault"
            audience           = "vault"
            expiration_seconds = 60 * 60 # 1 hour
          }
        }
      }
    }

    container {
      name  = "app"
      image = "alpine/curl:latest"

      env {
        name  = "VAULT_ADDR"
        value = "http://vault:8200"
      }

      volume_mount {
        name       = "vault-auth-token"
        mount_path = "/var/run/secrets/tokens"
        read_only  = true
      }

      # For demonstration purposes, this pod will manually authenticate with Vault using the Kubernetes auth method.
      # In a production environment, you would typically use a Vault Secrets Operator or Vault Agent Injector.
      command = ["/bin/sh", "-c"]
      args = [
        <<EOF
        # install jq for JSON parsing
        apk add jq > /dev/null;

        # load kubernetes service account token
        TOKEN=$(cat /var/run/secrets/tokens/vault);

        # format the data for Vault login
        DATA="{\"role\": \"workload-role\", \"jwt\": \"$TOKEN\"}";

        # login to Vault using the Kubernetes auth method
        curl -sX POST "$VAULT_ADDR/v1/auth/kubernetes/login" -d "$DATA" | jq .auth;
        sleep 3600;
        EOF
      ]
    }
  }
}
