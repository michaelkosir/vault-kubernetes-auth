resource "kind_cluster" "dev" {
  name           = "dev"
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    networking {
      api_server_port = 6443
    }

    node {
      role = "control-plane"
    }

    node {
      role = "worker"
    }
  }
}
