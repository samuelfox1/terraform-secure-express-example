# load environment variables into terminal
# export TF_VAR_auth0_domain=""
# export TF_VAR_auth0_client_id=""
# export TF_VAR_auth0_client_secret=""
variable "auth0_domain" {}
variable "auth0_client_id" {}
variable "auth0_client_secret" {}

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.13.0"
    }

    auth0 = {
      source  = "auth0/auth0"
      version = "0.29.0"
    }
  }
}

##################### AUTH0 ##########################################

provider "auth0" {
  domain        = var.auth0_domain
  client_id     = var.auth0_client_id
  client_secret = var.auth0_client_secret
}

resource "auth0_client" "terraform-secure-express" {
  name            = "Terraform Secure Express"
  description     = "App for running Dockerized Express application via Terraform"
  app_type        = "regular_web"
  callbacks       = ["http://localhost:3000/callback"]
  oidc_conformant = true

  jwt_configuration {
    alg = "RS256"
  }
}

##################### DOCKER ##########################################


provider "docker" {
  # Configuration options
}

data "docker_registry_image" "terraform-secure-express" {
  name = "sjfox/terraform-secure-express:1.0.2"
}

output "docker_container" {
  value = data.docker_registry_image.terraform-secure-express.name
}

resource "docker_image" "terraform-secure-express" {
  name          = data.docker_registry_image.terraform-secure-express.name
  pull_triggers = [data.docker_registry_image.terraform-secure-express.sha256_digest]
}

resource "docker_container" "terraform-secure-express" {
  image = docker_image.terraform-secure-express.latest
  name  = "terraform-secure-express"
  ports {
    internal = 3000
    external = 3000
  }
  env = [
    "AUTH0_CLIENT_ID=${auth0_client.terraform-secure-express.client_id}",
    "AUTH0_CLIENT_SECRET=${auth0_client.terraform-secure-express.client_secret}",
    "AUTH0_CLIENT_DOMAIN=${var.auth0_domain}"
  ]
}
