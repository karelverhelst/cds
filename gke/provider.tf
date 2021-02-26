variable "path" {default = "/home/karel/terraform/credentials"}
provider "google" {
    project = "modern-dream-289506"
    region = "europe-west2"
    credentials = "${file("${var.path}/secrets.json")}"
}

provider "google-beta" {
    project = "modern-dream-289506"
    region = "europe-west2"
    credentials = "${file("${var.path}/secrets.json")}"
}

