resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project_id}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}

resource "google_container_cluster" "primary" {
  name     = "${var.project_id}-gke"
  location = "${var.region}-a"

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  master_auth {
    username = var.name
    password = google_secret_manager_secret_version.gke_password.secret_data

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  workload_identity_config {
    identity_namespace = "${var.project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "${google_container_cluster.primary.name}-node-pool"
  location   = "${var.region}-a"
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project_id
    }

    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
    workload_metadata_config {
      node_metadata = "GKE_METADATA_SERVER"
    }
  }
}

resource "google_service_account" "this" {
  account_id   = "dns01-solver"
  display_name = "A service account for cert-manager"
}

resource "google_service_account_iam_binding" "this" {
  service_account_id = google_service_account.this.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[cert-manager/cert-manager]",
  ]
}

resource "google_project_iam_binding" "project" {
  project = var.project_id
  role    = "roles/dns.admin"

  members = [
    "serviceAccount:${google_service_account.this.email}",
  ]
}
