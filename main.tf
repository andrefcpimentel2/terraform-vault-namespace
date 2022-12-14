resource "vault_namespace" "namespace" {
  path = var.name
}

resource "vault_policy" "namespace-admin-policy" {
  name   = "${var.name}-admin-policy"
  namespace = vault_namespace.namespace.path
  policy = <<EOP
# Manage namespaces
#adding below to allow creation of child token
path "auth/token/create" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "sys/namespaces/*" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
# Manage policies
path "sys/policies/acl/*" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
# List policies
path "sys/policies/acl" {
   capabilities = ["list"]
}
# Enable and manage secrets engines
path "sys/mounts/*" {
   capabilities = ["create", "read", "update", "delete", "list"]
}
# List available secrets engines
path "sys/mounts" {
  capabilities = [ "read" ]
}
# Create and manage entities and groups
path "identity/*" {
   capabilities = ["create", "read", "update", "delete", "list"]
}
# Manage tokens
path "auth/token/*" {
   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
# Manage secrets at '*'
path "*" {
   capabilities = ["create", "read", "update", "delete", "list"]
}
EOP

}

resource "vault_token" "namespace-admin-token" {
  policies        = [vault_policy.namespace-admin-policy.name]
  renewable       = true
  no_parent       = true
  ttl             = "768h"
  renew_min_lease = 43200
  renew_increment = 86400
  namespace = vault_namespace.namespace.path
}

resource "vault_mount" "kv" {
  namespace = vault_namespace.namespace.path
  path      = "secrets"
  type      = "kv-v2"

}

resource "vault_mount" "pki-example" {
  path        = "pki-example"
  type        = "pki"
  description = "This is an example PKI mount"
  namespace = vault_namespace.namespace.path
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 86400
}