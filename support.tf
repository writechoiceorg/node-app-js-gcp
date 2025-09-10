# This file contains IAM bindings for Aspect Workflows support roles


# To enable role bindings for the comaintainers roles, uncomment the following resource.

# resource "google_project_iam_member" "workflows_comaintainers_access" {
#   project = local.project
#   role    = module.aspect_workflows.aspect_support.comaintainer_role
#   # The included group is a Google Group owned by Aspect where 
#   # Aspect employees may request access to the workflows
#   # infrastructure for WRITE/READ/UPDATE/DELETE access.
#   member  = "group:workflows-comaintainers@aspect.build"
# }

resource "google_project_iam_member" "workflows_operators_access" {
  project = local.project
  role    = module.aspect_workflows.aspect_support.operator_role
  # The included group is a Google Group owned by Aspect where 
  # Aspect employees may request access to the workflows
  # infrastructure for READ/UPDATE access.
  member  = "group:workflows-operators@aspect.build"
}

resource "google_project_iam_member" "workflows_support_access" {
  project = local.project
  role    = module.aspect_workflows.aspect_support.support_role
  # The included group is a Google Group owned by Aspect where 
  # Aspect employees may request access to the workflows
  # infrastructure for READ access.
  member  = "group:workflows-support@aspect.build"
}

# Create additional IAM role bindings for `user:...`, `serviceaccount:...`, `group:...`, or `domain:...` as needed.
