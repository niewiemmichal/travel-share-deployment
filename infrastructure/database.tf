resource "google_sql_database_instance" "this" {
  name             = var.name
  database_version = "POSTGRES_11"

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      authorized_networks {
        name = "Internet"
        value = "0.0.0.0/0"
      }
    }
  }
}

resource "google_sql_user" "this" {
  name     = var.name
  instance = google_sql_database_instance.this.name
  password = google_secret_manager_secret_version.database_password.secret_data
}

resource "google_sql_database" "this" {
  name     = var.name
  instance = google_sql_database_instance.this.name
}