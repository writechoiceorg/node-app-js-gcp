locals {
  customer_id = "writechoice"
  }

module "aspect_workflows" {
  customer_id = local.customer_id

providers = {
    aws = aws.workflows
  }

  source = "https://static.aspect.build/aspect/5.14.0/terraform-aws-aspect-workflows.zip"

  aspect_artifacts_bucket = "aw-artifacts-${local.region}"
  vpc_id             = module.vpc.vpc_id
  vpc_subnets        = module.vpc.private_subnets
  vpc_subnets_public = module.vpc.public_subnets

  support = {
    alert_aspect       = true
    enable_ssm_access  = true
    support_role_name  = aws_iam_role.support.name
    operator_role_name = aws_iam_role.operator.name
  }

  # WORKFLOWS_TEMPLATE: Export traces to Honeycomb
  # telemetry = {
  #   destinations = {
  #     honeycomb = {
  #       dataset     = "workflows"
  #       team_secret = aws_secretsmanager_secret.honeycomb_api_key
  #     }
  #   }
  # }
remote = {
    frontend = {
      min_scaling = 1
      max_scaling = 20
    }
debug_tools = true
    # WORKFLOWS_TEMPLATE: Customize your remote cache size.
    # Ask Aspect about right sizing the remote cache size & throughput for your build.
    storage = {
      # 2 shards with 937GiB SSDs each = 1.874TiB cache size
      num_shards    = 2
      instance_type = "im4gn.large"
      # WORKFLOWS_TEMPLATE: Enable mirroring to duplicate each shard. This makes the cache
      # more resiliant to data but also doubles the compute costs for the cache.
      # mirror        = true
    }
    # WORKFLOWS_TEMPLATE: Uncomment the `remote_execution` block to enable remote execution.
    # Ask Aspect about right sizing the remote execution cluster to your workloads.
    # remote_execution = {
    #   executors = {
    #     default = {
    #       platform = "Linux"
    #       image    = "ghcr.io/catthehacker/ubuntu:act-22.04@sha256:5f9c35c25db1d51a8ddaae5c0ba8d3c163c5e9a4a6cc97acd409ac7eae239448"
    #       workers = [
    #         {
    #           scaling = {
    #             minimum = 0
    #             maximum = 10
    #             fast    = {}
    #           }
    #           ec2 = {
    #             instance_type = "m6id.xlarge"
    #           }
    #         }
    #       ]
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
instance_types = ["t3a.small"]
      image_id       = data.aws_ami.runner_image.id
# WORKFLOWS_TEMPLATE: You can add tags to the resources from a specific resource type.
      # Note that workflows adds the following tag to all resources by default
      #     "created-by": "aspect-workflows"
      # tags = {
      #   "some-resource-tag-key": "some-resource-tag-value"
      # }
    }
    default = {
instance_types = ["m6id.xlarge"]
      image_id       = data.aws_ami.runner_image.id
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
      gh_repo                   = "writechoiceorg/bazel-teste-python" # `org/repo` of the GitHub repository under test
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
      gh_repo                   = "writechoiceorg/bazel-teste-python" # `org/repo` of the GitHub repository under test
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
      gh_repo                = "writechoiceorg/bazel-teste-python" # `org/repo` of the GitHub repository under test
      gha_workflow_ids       = [] # WORKFLOWS_TEMPLATE: to reduce GitHub API call frequency and prevent rate limiting, add the workflow ID of the Aspect Workflows warming GitHub Action
      max_runners            = 1
      min_runners            = 0
policies               = { warming_manage : module.aspect_workflows.warming_management_policies["default"].arn }
queue                  = "aspect-warming"
      resource_type          = "default"
      warming                = false # do not warm runners used to generate warming archives
    }
  }


}
