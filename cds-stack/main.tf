variable "studentnr" {
  type        = number
  description = "The student number"

  validation {
    condition     = var.studentnr > 0 && var.studentnr < 12
    error_message = "The student number is incorrect (must be between 1 and 12)."
  }
}

variable "gatewayip" {
  type        = string
  description = "The public ip of the gateway provided by the instructor"

  validation {
    condition     = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.gatewayip))
    error_message = "The address provided is not confrom the ip notation, should be in the form xx.xx.xx.xx."
  }
}

resource "google_compute_network" "gcp-network" {
    name = "gcp-network"
    auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "gcp-subnetwork1" {
    name = "gcp-subnetwork1"
    ip_cidr_range = "10.${var.studentnr}.1.0/24"
    region = "europe-west2" 
    network = "${google_compute_network.gcp-network.self_link}"
}
resource "google_compute_subnetwork" "gcp-subnetwork2" {
    name = "gcp-subnetwork2"
    ip_cidr_range = "10.${var.studentnr}.2.0/24"
    region = "europe-west3" 
    network = "${google_compute_network.gcp-network.self_link}"
}

resource "google_compute_vpn_gateway" "target_gateway" {
  name    = "vpn-to-azure"
  network = google_compute_network.gcp-network.id
}


resource "google_compute_address" "vpn_static_ip" {
  name = "vpn-static-ip"
}

resource "google_compute_forwarding_rule" "fr_esp" {
  name        = "fr-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.target_gateway.id
}

resource "google_compute_forwarding_rule" "fr_udp500" {
  name        = "fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.target_gateway.id
}

resource "google_compute_forwarding_rule" "fr_udp4500" {
  name        = "fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.target_gateway.id
}

resource "google_compute_vpn_tunnel" "tunnel1" {
  name          = "tunnel1"
  peer_ip       = "${var.gatewayip}"
  shared_secret = "Netapp01!"
  local_traffic_selector = ["10.${var.studentnr}.0.0/16"]
  remote_traffic_selector = ["192.168.0.0/16"]
  target_vpn_gateway = google_compute_vpn_gateway.target_gateway.id

  depends_on = [
    google_compute_forwarding_rule.fr_esp,
    google_compute_forwarding_rule.fr_udp500,
    google_compute_forwarding_rule.fr_udp4500,
  ]
}

resource "google_compute_route" "route1" {
  name       = "route1"
  network    = google_compute_network.gcp-network.name
  dest_range = "192.168.0.0/16"
  priority   = 1000

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel1.id
}

resource "google_compute_instance" "default" {
name = "test"
machine_type = "e2-small"
zone= "europe-west2-a"

 tags = ["allow-ssh"]  # FIREWALL

boot_disk {
    initialize_params {
        image = "ubuntu-os-cloud/ubuntu-1604-lts"
    }
 }

network_interface {
    network = google_compute_network.gcp-network.id
    subnetwork = google_compute_subnetwork.gcp-subnetwork1.id
    access_config {
      }

 }


service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
 }
}

resource "google_compute_firewall"  "allow_ssh" {
    name = "allow-ssh"
    network = google_compute_network.gcp-network.id

    allow {
        protocol = "tcp"
        ports = ["22"]
    }

    target_tags = ["allow-ssh"]

}

resource "google_compute_firewall"  "rules_cds_ingress" {
    name = "rules-cds-ingress"
    network = google_compute_network.gcp-network.id

    allow {
        protocol = "all"
    }
    source_ranges = ["172.16.0.0/24","192.168.0.0/24","10.0.0.0/8"]

}

resource "google_compute_firewall"  "rules_cds_egress" {
    name = "rules-cds-egress"
    network = google_compute_network.gcp-network.id
    
    allow {
        protocol = "tcp"
        ports    = ["22","80", "443"]
    }
    destination_ranges = ["172.16.0.0/24","192.168.0.0/24","10.0.0.0/8"]
	direction = "EGRESS"

}
