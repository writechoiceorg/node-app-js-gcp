terraform {
  required_version = ">= 1.9.0"

  backend "s3" {
    bucket = "aspect-bucket-us-east-2"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = "~> 5.62.0"
    }
  }
}

provider "aws" {
  region = local.region
}

provider "aws" {
  alias = "workflows"

  region = local.region

  default_tags {
    tags = {
      (module.aspect_workflows.cost_allocation_tag) = module.aspect_workflows.cost_allocation_tag_value
    }
  }
}
