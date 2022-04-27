resource "docker_image" "terraform-secure-express" {
  name = "terraform-secure-express:1.0"
}


resource "docker_container" "terraform-secure-express" {
  image = docker_image.terraform-secure-express.latest
  name  = "terraform-secure-express"
  ports {
    internal = 3000
    external = 3000
  }
}
