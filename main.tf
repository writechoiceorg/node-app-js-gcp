terraform {
  required_version = ">= 1.4.0"

  backend "gcs" {
    bucket = "aspect-tests"
    prefix = "terraform/state"
  }
}

locals {
  project = "studied-radar-410113"
  project_id = "studied-radar-410113"
  region  = "us-central1"
  zones = [
    "${local.region}-a",
    "${local.region}-b",
  ]
}

provider "google" {
  project = local.project
  region  = local.region
}

provider "google-beta" {
  project = local.project
  region  = local.region
}