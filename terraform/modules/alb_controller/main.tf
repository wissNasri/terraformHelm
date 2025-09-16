# Fichier : terraformHelm/modules/alb_controller/main.tf (Version Finale)

# --- DÉCLARATION DES VARIABLES ---

# ... (gardez toutes vos variables existantes : app, namespace, etc.)
variable "app" { type = any }
variable "namespace" { type = string }
variable "repository" { type = string }
variable "repository_config" { type = any; default = {} }
variable "values" { type = list(string); default = [] }
variable "set" { type = any; default = [] }
variable "set_sensitive" { type = any; default = [] }

# --- AJOUTEZ CETTE NOUVELLE VARIABLE ---
variable "wait_for_completion" {
  description = "Si Terraform doit attendre la fin des opérations Helm (true/false)."
  type        = bool
  default     = true # Par défaut, on attend.
}
# ------------------------------------


# --- RESSOURCE HELM ---

resource "helm_release" "this" {
  # ... (tous les arguments du début restent les mêmes : count, namespace, etc.) ...
  count                      = var.app["deploy"] ? 1 : 0
  namespace                  = var.namespace
  repository                 = var.repository
  repository_key_file        = lookup(var.repository_config, "repository_key_file", null)
  repository_cert_file       = lookup(var.repository_config, "repository_cert_file", null)
  repository_ca_file         = lookup(var.repository_config, "repository_ca_file", null)
  repository_username        = lookup(var.repository_config, "repository_username", null)
  repository_password        = lookup(var.repository_config, "repository_password", null)
  name                       = var.app["name"]
  version                    = var.app["version"]
  chart                      = var.app["chart"]
  force_update               = lookup(var.app, "force_update", false)
  description                = lookup(var.app, "description", null)
  
  # --- REMPLACEZ L'ANCIENNE LIGNE 'wait' PAR CELLE-CI ---
  wait                       = var.wait_for_completion
  # ----------------------------------------------------

  # ... (tous les autres arguments jusqu'à la fin restent les mêmes : recreate_pods, timeout, etc.) ...
  recreate_pods              = lookup(var.app, "recreate_pods", true)
  max_history                = lookup(var.app, "max_history", 0)
  lint                       = lookup(var.app, "lint", true)
  cleanup_on_fail            = lookup(var.app, "cleanup_on_fail", false)
  create_namespace           = lookup(var.app, "create_namespace", true)
  disable_webhooks           = lookup(var.app, "disable_webhooks", false)
  verify                     = lookup(var.app, "verify", false)
  reuse_values               = lookup(var.app, "reuse_values", false)
  reset_values               = lookup(var.app, "reset_values", false)
  atomic                     = lookup(var.app, "atomic", false)
  skip_crds                  = lookup(var.app, "skip_crds", false)
  render_subchart_notes      = lookup(var.app, "render_subchart_notes", true)
  disable_openapi_validation = lookup(var.app, "disable_openapi_validation", false)
  wait_for_jobs              = lookup(var.app, "wait_for_jobs", false)
  dependency_update          = lookup(var.app, "dependency_update", false)
  replace                    = lookup(var.app, "replace", false)
  timeout                    = lookup(var.app, "timeout", 300)
  values                     = var.values

  dynamic "set" {
    for_each = coalesce(var.set, [])
    content {
      name  = set.value.name
      value = set.value.value
    }
  }

  dynamic "set_sensitive" {
    for_each = coalesce(var.set_sensitive, [])
    content {
      name  = set_sensitive.value.name
      value = set_sensitive.value.value
    }
  }
}
