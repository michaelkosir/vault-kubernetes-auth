variable "vault_image" {
  description = "The specific Vault version to deploy."
  default     = "hashicorp/vault:1.19"
}

variable "vault_port" {
  description = "The port on which Vault will listen."
  default     = 8200
}

variable "vault_node_port" {
  description = "The node port for the Vault service."
  default     = 30080
}
