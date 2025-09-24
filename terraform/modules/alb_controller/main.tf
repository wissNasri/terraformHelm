# Fichier : terraform/modules/helm_app/main.tf

resource "helm_release" "this" {
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
  
  wait                       = var.wait_for_completion
  timeout                    = var.timeout
  atomic                     = var.atomic
  cleanup_on_fail            = var.cleanup_on_fail

  recreate_pods              = lookup(var.app, "recreate_pods", false)
  max_history                = lookup(var.app, "max_history", 0)
  lint                       = lookup(var.app, "lint", false)
  create_namespace           = lookup(var.app, "create_namespace", true)
  disable_webhooks           = lookup(var.app, "disable_webhooks", false)
  verify                     = lookup(var.app, "verify", false)
  reuse_values               = lookup(var.app, "reuse_values", false)
  reset_values               = lookup(var.app, "reset_values", false)
  skip_crds                  = lookup(var.app, "skip_crds", false)
  render_subchart_notes      = lookup(var.app, "render_subchart_notes", true)
  disable_openapi_validation = lookup(var.app, "disable_openapi_validation", false)
  wait_for_jobs              = lookup(var.app, "wait_for_jobs", false)
  dependency_update          = lookup(var.app, "dependency_update", false)
  replace                    = lookup(var.app, "replace", false)
  
  values                     = var.values

  dynamic "set" {
    for_each = var.set
    content {
      name  = set.value.name
      value = set.value.value
    }
  }

  dynamic "set_sensitive" {
    for_each = var.set_sensitive
    content {
      name  = set_sensitive.value.name
      value = set_sensitive.value.value
    }
  }

  # AJOUT : Bloc dynamique pour set_list
  dynamic "set_list" {
    for_each = var.set_list
    content {
      name  = set_list.value.name
      value = set_list.value.value
    }
  }
}
