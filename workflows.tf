locals {
  customer_id = "writechoice"
  pagerduty_key = "PAGERDUTY_KEY" # replace with Aspect provided PagerDuty integration key
}

module "aspect_workflows" {
  customer_id = local.customer_id

source = "https://static.aspect.build/aspect/5.14.12/terraform-gcp-aspect-workflows.zip"

  network    = google_compute_network.workflows_network.id
  subnetwork = google_compute_subnetwork.workflows_subnet.id
  zones   = local.zones
  
  k8s_cluster = {
    # WORKFLOWS_TEMPLATE: Large builds that with heavy remote cache usage may need a larger node pool
    # for scaling the remote cache frontend.
    # Ask Aspect about right sizing remote cache size & throughput for your build.
    standard_nodes = {
      min_count    = 1
      max_count    = 20
      machine_type = "e2-standard-4"
    }
    # WORKFLOWS_TEMPLATE: Customize your remote cache size.
    # Ask Aspect about right sizing the remote cache size & throughput for your build.
    remote_cache_nodes = {
      # 3 shards with 375GiB SSDs each = 1.125TiB cache size
      count        = 3
      machine_type = "c3-standard-4-lssd"
    }
    # WORKFLOWS_TEMPLATE: Uncomment the `remote_exec_nodes` block to enable remote execution.
    # Ask Aspect about right sizing the remote execution cluster to your workloads.
    # remote_exec_nodes = {
    #   default = {
    #     min_count    = 0
    #     max_count    = 10
    #     machine_type = "c2d-standard-4"
    #     num_ssds     = 1
    #   }
    # }
  }
remote = {
    frontend = {
      min_scaling = 1
      max_scaling = 20
    }
cache = {
      # WORKFLOWS_TEMPLATE: `shards` should match `k8s_cluster.remote_cache_nodes.count` above.
      shards = 3
    }
    # WORKFLOWS_TEMPLATE: Uncomment the `remote_execution` block to enable remote execution.
    # Ask Aspect about right sizing the remote execution cluster to your workloads.
    # remote_execution = {
    #   executors = {
    #     default = {
    #       platform    = "Linux"
    #       image       = "ghcr.io/catthehacker/ubuntu:act-22.04@sha256:5f9c35c25db1d51a8ddaae5c0ba8d3c163c5e9a4a6cc97acd409ac7eae239448"
    #       node_type   = "default"
    #       min_scaling = 0
    #       max_scaling = 10
    #       concurrency = 4
    #     }
    #   }
    # }
}

  delivery_enabled = true

  warming_sets = {
    default = {}
  }

  # WORKFLOWS_TEMPLATE: You can add tags to the resources created by aspect workflows
  # for the purposes of tracking / cost analysis.
  # Note that workflows adds the following tag to all resources by default
  #     "created-by": "aspect-workflows"
  # tags = {
  #   "some-tag-key": "some-tag-value"
  # }

  resource_types = {
    # WORKFLOWS_TEMPLATE: `small` runner type is recommended for the Setup Aspect Workflows steps on Buildkite
    # and GitHub Actions. You can remove this runner type if not using Buildkite or GitHub Actions for your CI.
    small = {
machine_type = "e2-small"
      image_id     = data.google_compute_image.runner_image.id
# WORKFLOWS_TEMPLATE: You can add tags to the resources from a specific resource type.
      # Note that workflows adds the following tag to all resources by default
      #     "created-by": "aspect-workflows"
      # tags = {
      #   "some-resource-tag-key": "some-resource-tag-value"
      # }
    }
    default = {
machine_type = "c2d-standard-4"
      image_id     = data.google_compute_image.runner_image.id
      num_ssds     = 1
}
  }

  # WORKFLOWS_TEMPLATE:
  hosts = ["gha"]
  # Github Actions runner groups
  # WORKFLOWS_TEMPLATE: Once the Aspect Workflows GitHub actions land in your repository, run the following command
  # using the GitHub CLI to determine the workflow ID for the `gha_workflow_ids` fields below:
  # gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" /repos/<org>/<repo>/actions/workflows
  # See https://docs.github.com/en/rest/actions/workflows?apiVersion=2022-11-28#list-repository-workflows for more info.
  gha_runner_groups = {
    # The `default` runner group is used for general bazel tasks such as build & test.
    default = {
      agent_idle_timeout_min    = 120
      gh_repo                   = "writechoiceorg/node-app-js-gcp" # `org/repo` of the GitHub repository under test
      gha_workflow_ids          = [] # WORKFLOWS_TEMPLATE: to reduce GitHub API call frequency and prevent rate limiting, add the workflow ID of the Aspect Workflows main GitHub Action
      max_runners               = 50
      min_runners               = 0
      queue                     = "aspect-default"
      resource_type             = "default"
      scaling_polling_frequency = 2 # check for new jobs every 30s
      warming                   = true
    }
    # The `small` runner group is used for the Setup Aspect Workflows pipeline step.
    # These are intentionally small, inexpensive, long-lived instances that are not
    # meant for running bazel tasks.
    small = {
      agent_idle_timeout_min    = 720
      gh_repo                   = "writechoiceorg/node-app-js-gcp" # `org/repo` of the GitHub repository under test
      gha_workflow_ids          = [] # WORKFLOWS_TEMPLATE: to reduce GitHub API call frequency and prevent rate limiting, add the workflow ID of the Aspect Workflows main GitHub Action
      max_runners               = 4
      min_runners               = 0
      queue                     = "aspect-small"
      resource_type             = "small"
      scaling_polling_frequency = 2     # check for new jobs every 30s
      warming                   = false # no need to warm this runner since it doesn't run bazel
    }
    # The `warming` running group is used for the warming job to create warming
    # archives used by other runner groups to pre-warm external repositories
    # during bootstrap in order to speed up their first jobs.
    warming = {
      agent_idle_timeout_min = 1
      gh_repo                = "writechoiceorg/node-app-js-gcp" # `org/repo` of the GitHub repository under test
      gha_workflow_ids       = [] # WORKFLOWS_TEMPLATE: to reduce GitHub API call frequency and prevent rate limiting, add the workflow ID of the Aspect Workflows warming GitHub Action
      max_runners            = 1
      min_runners            = 0
      queue                  = "aspect-warming"
      resource_type          = "default"
      warming                = false # do not warm runners used to generate warming archives
    }
  }
}
