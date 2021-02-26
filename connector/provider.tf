variable "path" {default = "/home/karel/terraform/credentials"}
terraform {
  required_providers {
    netapp-cloudmanager = {
      source = "NetApp/netapp-cloudmanager"
      version = "21.2.0"
    }
  }
}
provider "google" {
    project = "modern-dream-289506"
    region = "europe-west2-a"
    credentials = "${file("${var.path}/secrets.json")}"
}
provider "netapp-cloudmanager" {
  #refresh_token         = uX1hR2YbxU3fWl2QiZ41QqkZAQBmGv2x6Rzj_F1247qTL
}
