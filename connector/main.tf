resource "netapp-cloudmanager_connector_gcp" "cl-occm-gcp" {
  provider = netapp-cloudmanager
  name = "occm-gcp"
  project_id = "modern-dream-289506"
  zone = "europe-west3-a"
  company = "NetApp"
  service_account_email = "585824788596-compute@developer.gserviceaccount.com"
  service_account_path = "/home/karel/terraform/credentials/secrets.json"
  account_id = "account-Qeu6p2pq"
  subnet_id = "gcp-subnetwork2"
  machine_type= "n2-standard-2"
}
