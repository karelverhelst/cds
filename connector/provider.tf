variable "path" {default = "../credentials"}
variable "region" = "europe-west2"
variable "project" = "modern-dream-289506"

terraform {
  required_providers {
    netapp-cloudmanager = {
      source = "NetApp/netapp-cloudmanager"
      version = "21.2.0"
    }
  }
}
provider "google" {
    project = "$var.project"
    region = "$var.region"
    credentials = "${file("${var.path}/secrets.json")}"
}
provider "netapp-cloudmanager" {

}
