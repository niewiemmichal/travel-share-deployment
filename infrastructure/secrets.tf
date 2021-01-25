resource "random_password" "database_password" {
  length = 16
  special = true
}

resource "google_secret_manager_secret" "database_password" {
  secret_id = "${var.name}_database_password"
 
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "database_password" {
  secret = google_secret_manager_secret.database_password.id

  secret_data = random_password.database_password.result
}

resource "random_password" "gke_password" {
  length = 16
  special = true
}

resource "google_secret_manager_secret" "gke_password" {
  secret_id = "${var.name}_gke_password"
 
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "gke_password" {
  secret = google_secret_manager_secret.gke_password.id

  secret_data = random_password.gke_password.result
}