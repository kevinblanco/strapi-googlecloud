terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.51.0"
    }
  }
}

variable "project_id" {
  type        = string
  description = "Your GCP project ID, for example: my-gcp-project"
}

variable "database_password" {
  type        = string
  description = "Somthing strong like: e87Y0=rbS3QE}tPZ"
}

variable "network_name" {
  description = "Your VPC, it could be: default"
  type        = string
}

provider "google" {
  credentials = file("service-account.json")

  project = var.project_id
  region  = "us-central1"
  zone    = "us-central1-a"
}

resource "google_project_service" "cloudresourcemanager_api" {
  project = var.project_id
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "serviceusage_api" {
  project = var.project_id
  service = "serviceusage.googleapis.com"
  depends_on = [google_project_service.cloudresourcemanager_api]
}

resource "google_project_service" "secretmanager_api" {
  project = var.project_id
  service = "secretmanager.googleapis.com"
  depends_on = [
    google_project_service.cloudresourcemanager_api
  ]
}

resource "google_project_service" "cloudbuild_api" {
  project = var.project_id
  service = "cloudbuild.googleapis.com"
  depends_on = [
    google_project_service.cloudresourcemanager_api
  ]
}

resource "google_project_service" "servicenetworking_api" {
  project = var.project_id
  service = "servicenetworking.googleapis.com"
  depends_on = [
    google_project_service.cloudresourcemanager_api
  ]
}

resource "google_project_service" "cloudsql_admin_api" {
  project   = var.project_id
  service   = "sqladmin.googleapis.com"
  depends_on = [google_project_service.cloudresourcemanager_api]
}


resource "google_project_service" "compute_engine_api" {
  project = var.project_id
  service = "compute.googleapis.com"
  depends_on = [
    google_project_service.cloudresourcemanager_api
  ]
}

resource "google_project_service" "cloudlogging_api" {
  project = var.project_id
  service = "logging.googleapis.com"
  depends_on = [
    google_project_service.cloudresourcemanager_api
  ]
}

resource "google_project_service" "appengine_admin_api" {
  project = var.project_id
  service = "appengine.googleapis.com"
  depends_on = [
    google_project_service.cloudresourcemanager_api
  ]
}


resource "google_project_service" "iam_api" {
  project = var.project_id
  service = "iam.googleapis.com"
  depends_on = [
    google_project_service.cloudresourcemanager_api
  ]
}

resource "google_project_service" "cloud_sql" {
  provider                   = google-beta
  project                    = var.project_id
  service                    = "sql-component.googleapis.com"
  depends_on = [
    google_project_service.cloudresourcemanager_api
  ]
  disable_dependent_services = true
}

resource "google_sql_database_instance" "instance" {
  name             = "strapi"
  region           = "us-central1"
  database_version = "POSTGRES_15"
  settings {
    tier = "db-custom-2-8192"
    availability_type = "ZONAL"

    disk_autoresize = true
    disk_size       = 10
    disk_type       = "PD_SSD"

    backup_configuration {
      enabled    = true
      start_time = "02:00"
    }
    maintenance_window {
      day  = 1
      hour = 2
    }
    location_preference {
      zone = "us-central1-a"  # Adjust the zone as needed
    }

    database_flags {
      name  = "max_connections"
      value = "500"
    }
  }
  deletion_protection = true

  depends_on = [google_project_service.cloudsql_admin_api]
}

resource "google_sql_database" "database" {
  name     = "strapi"
  instance = google_sql_database_instance.instance.name
}

resource "google_sql_user" "user" {
  name     = "strapi"
  instance = google_sql_database_instance.instance.name
  password = var.database_password
}

resource "google_storage_bucket" "bucket" {
  name     = "${var.project_id}-strapi"
  location = "US"

  # REMOVE IF YOU DON'T NEED IMAGES AND FILES TO BE PUBLIC
  uniform_bucket_level_access = true
}


# Add the App Engine Standard Application
resource "google_app_engine_application" "app" {
  project = var.project_id
  location_id = "us-central"  # Add the appropriate location ID
  depends_on = [
    google_project_service.appengine_admin_api
  ] 
}


# Grant admin and write permissions to the default service account
resource "google_storage_bucket_iam_binding" "default_service_account_admin" {
  bucket = google_storage_bucket.bucket.name
  role   = "roles/storage.admin"
  members = [
    "serviceAccount:${var.project_id}-compute@developer.gserviceaccount.com"
  ]
  depends_on = [
    google_app_engine_application.app
  ]
}

resource "google_storage_bucket_iam_binding" "default_service_account_writer" {
  bucket = google_storage_bucket.bucket.name
  role   = "roles/storage.objectAdmin"
  members = [
    "serviceAccount:${var.project_id}-compute@developer.gserviceaccount.com"
  ]
  depends_on = [
    google_app_engine_application.app
  ]
}

resource "google_service_account" "default" {
  account_id = "default"
  display_name = "Default Service Account"
  depends_on = [
    google_app_engine_application.app
  ]
}

resource "google_project_iam_binding" "default" {
  project     = var.project_id
  role        = "roles/editor"
  members = [
    "serviceAccount:${var.project_id}-compute@developer.gserviceaccount.com",
  ]
  depends_on = [
    google_app_engine_application.app
  ]
}

resource "google_project_iam_binding" "cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  members = [
    "serviceAccount:${var.project_id}-compute@developer.gserviceaccount.com",
  ]
  depends_on = [
    google_app_engine_application.app
  ]
}
