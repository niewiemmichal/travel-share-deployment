resource "google_sql_database_instance" "this" {
  name             = "travel-share"
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
  name     = "travel-share"
  instance = google_sql_database_instance.this.name
  password = var.db_password
}

resource "google_sql_database" "this" {
  name     = "travel-share"
  instance = google_sql_database_instance.this.name
}