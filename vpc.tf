resource "google_compute_network" "my_network" {
  name    = "my-network"
  project = "just-aura-416511"

}

resource "google_compute_subnetwork" "subnet" {
  name          = "my-subnetwork"
  network       = google_compute_network.my_network.id
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  project       = var.project
}

resource "google_compute_router" "router" {
  name    = "my-router"
  project = var.project
  region  = google_compute_subnetwork.subnet.region
  network = google_compute_network.my_network.id

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
  project                   = var.project
  name                      = element(["controlplane", "worker-1", "worker-2"], count.index)
  allow_stopping_for_update = true
  machine_type              = "e2-medium"
  count                     = 3
  zone                      = var.zone
  metadata_startup_script   = "python3 kubeadm.py"
  connection {
    type     = "ssh"
    user     = "ubuntu"
    password = "ubuntu"
    host     = self.hostname
  }
#  provisioner "file" {
 #   source      = "/d/Abhi/Projects/own-project/kubeadm.py"
  #  destination = "/tmp/kubeadm.py"
  #}
  #provisioner "remote-exec" {
   # inline = [
    #  "chmod +x /tmp/kubeadm.py",
     # "sudo /usr/bin/python3 /tmp/kubeadm.py"
    #]

  #}
  network_interface {
    network    = google_compute_network.my_network.self_link
    subnetwork = google_compute_subnetwork.subnet.self_link
  }
  metadata = {
    ssh_key = "ubuntu:${tls_private_key.ssh_key.public_key_openssh}"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-jammy-v20240319"
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
  network = google_compute_network.my_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "22", "443", "8080", "1000-2000", "9000", "9092"]
  }

  source_ranges = ["0.0.0.0/0"]
}
data "google_compute_machine_types" "all" {
  zone   = var.zone
  filter = " memoryMb = 2048 AND guestCpus = 2"


}
/*
output "machine_types" {
  value = data.google_compute_machine_types.all.machine_types
}
*/




resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

output "public_key" {
  value = tls_private_key.ssh_key.public_key_openssh
}



##########################33
resource "google_compute_instance" "bastion-host" {
  project                   = var.project
  name                      = "jumpserver"
  allow_stopping_for_update = true
  machine_type              = "e2-medium"
  zone                      = var.zone
  network_interface {
    
    network    = google_compute_network.my_network.self_link
    subnetwork = google_compute_subnetwork.subnet.self_link
  
    access_config {}

  }
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-jammy-v20240319"
      size  = 20
      labels = {
        my_label = "value"
      }
    }

  }
  connection {
    type     = "ssh"
    user     = "ubuntu"
    password = "ubuntu"
    host     = self.hostname
  }
}
output "external_ip" {
  value = google_compute_instance.bastion-host.network_interface[0]
}