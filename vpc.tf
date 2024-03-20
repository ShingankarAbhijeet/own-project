resource "google_compute_network" "cicd-network" {
  name    = "cicd-network"
  project = var.project
}

resource "google_compute_subnetwork" "subnet" {
  name          = "my-subnetwork"
  network       = google_compute_network.net.id
  ip_cidr_range = "10.0.0.0/16"
  region        = var.region
  project       = var.project
}

resource "google_compute_router" "router" {
  name    = "my-router"
  project = var.project
  region  = google_compute_subnetwork.subnet.region
  network = google_compute_network.net.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "my-router-nat"
  project                            = var.project
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_instance" "default" {
  project = var.project
  name    = "my-instance"

  machine_type = "n2-standard-2"
  zone         = var.zone
  network_interface {
    network    = google_compute_network.net.self_link
    subnetwork = google_compute_subnetwork.subnet.self_link
    access_config {
      
    }
  }
  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 20
      labels = {
        my_label = "value"
      }
    }

  }
}

resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  project = var.project
  network = google_compute_network.net.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "22", "443", "8080", "1000-2000","9000","9092"]
  }

  source_ranges = ["0.0.0.0/0"]
}

