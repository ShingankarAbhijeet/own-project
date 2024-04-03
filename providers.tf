provider "google" {
  project = "just-aura-416511"
  region  = var.region
}
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "terraform-practice-abz"
    workspaces {
      name = "terra"
    }
  }
}

