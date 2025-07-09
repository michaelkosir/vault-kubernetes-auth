# Vault + Kubernetes - Authentication Strategies

## K8s Auth Method
The Kubernetes auth method can be used to authenticate with Vault using a Kubernetes Service Account Token. This method of authentication makes it easy to introduce a Vault token into a Kubernetes Pod. The Kubernetes auth method is specialized to use Kubernetes' TokenReview API.

- [Use local service account token as the reviewer JWT](./local-token/)
- [Use the Vault client's JWT as the reviewer JWT](./client-token/)
- [Use long-lived service account token as the reviewer JWT](./long-lived-token/)

## JWT Auth Method
The Kubernetes auth is specialized to use Kubernetes' TokenReview API. However, the JWT tokens Kubernetes generates can also be verified using Kubernetes as an OIDC provider. The JWT auth method documentation has instructions for setting up JWT auth with Kubernetes as the OIDC provider.

This solution allows you to use short-lived tokens for all clients and removes the need for a reviewer JWT. However, the client tokens cannot be revoked before their TTL expires, so it is recommended to keep the TTL short with that limitation in mind.

- Use JWT validation public keys
- Use service account issuer discovery
