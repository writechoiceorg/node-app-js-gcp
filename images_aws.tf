# WORKFLOWS_TEMPLATE: Aspect providers a number of pre-built starer base images for Workflows CI
# runners for use during the trial period. See
# https://docs.aspect.build/workflows/features/packer#choose-a-base-image for instructions on finding
# a starter image suitable for your project. We recommend building and maintaining your own base
# image after the trial period is complete. Read
# https://docs.aspect.build/workflows/features/packer#create-packer-script for instructions on how to
# build a custom base image for Aspect Workflows.
data "aws_ami" "runner_image" {
  owners      = ["213396452403"] # Aspect's workflows-images account
  most_recent = true
  filter {
    name   = "name"
    values = ["aspect-workflows-debian-12-kitchen-sink-amd64-20250613-0"]
  }
}
