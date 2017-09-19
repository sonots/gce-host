provider "google" {
  credentials = "${file("service_account.json")}"
  region = "asia-northeast1"
}

resource "google_compute_instance" "gce-host-web" {
  name         = "gce-host-web"
  machine_type = "f1-micro"
  zone         = "asia-northeast1-a"

  disk {
    image = "ubuntu-1404-trusty-v20161020"
  }

  network_interface {
    network = "default"
    access_config {
      # Ephemeral IP
    }
  }

  metadata {
    roles = "foo,web:test:foo:bar:baz"
    service = "gce-host"
    status = "reserve"
    tags = "standby"
  }
}

resource "google_compute_instance" "gce-host-db" {
  name         = "gce-host-db"
  machine_type = "f1-micro"
  zone         = "asia-northeast1-a"

  disk {
    image = "ubuntu-1404-trusty-v20161020"
  }

  network_interface {
    network = "default"
    access_config {
      # Ephemeral IP
    }
  }

  metadata {
    roles = "foo,db:test"
    service = "gce-host"
    status = "active"
    tags = "master"
  }
}
