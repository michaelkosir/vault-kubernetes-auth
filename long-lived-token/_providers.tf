terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.36.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "4.6.0"
    }
    kind = {
      source  = "tehcyx/kind"
      version = "0.9.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.6.2"
    }
  }
}

provider "kubernetes" {
  config_path            = "~/.kube/config"
  host                   = kind_cluster.dev.endpoint
  client_key             = kind_cluster.dev.client_key
  cluster_ca_certificate = kind_cluster.dev.cluster_ca_certificate
}

provider "vault" {
  address = "http://localhost:${var.vault_port}"
  token   = "root"
}
