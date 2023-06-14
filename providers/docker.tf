# Create the PROVIDER BLOCK

## Mandatory because provider not from hashicorp
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {
  host = "npipe:////.//pipe//docker_engine" # For windows, not mandantory for linux (to verify)
}

# Create an IMAGE

resource "docker_image" "myNginxImage" {
  name         = "nginx" # Other example : postgres, x/y, ...
  keep_locally = false
}

# Create a CONTAINER based on the previous IMAGE

resource "docker_container" "myNginxContainer" {
  image = docker_image.myNginxImage
  name  = "myNginx"
  ports {
    internal = 80
    external = 8001
  }
}
