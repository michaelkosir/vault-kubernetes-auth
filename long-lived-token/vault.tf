resource "docker_image" "vault" {
  name         = var.vault_image
  keep_locally = true
}

resource "docker_container" "vault" {
  depends_on = [kind_cluster.dev]

  name  = "vault"
  image = docker_image.vault.name
  wait  = true

  ports {
    internal = var.vault_port
    external = var.vault_port
  }

  env = [
    "VAULT_DEV_ROOT_TOKEN_ID=root",
    "VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:${var.vault_port}",
  ]

  command = ["server", "-dev"]

  networks_advanced {
    name = "kind"
  }

  healthcheck {
    test     = ["CMD", "vault", "status", "-address=http://localhost:8200"]
    interval = "10s"
    timeout  = "5s"
    retries  = 3
  }
}
