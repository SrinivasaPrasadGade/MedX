# BigQuery Dataset for Analytics
resource "google_bigquery_dataset" "analytics" {
  dataset_id                  = "medx_analytics"
  friendly_name               = "MedX Analytics"
  description                 = "Population health intelligence dataset"
  location                    = var.region
  depends_on                  = [google_project_service.apis]
}

# Cloud Storage for Clinical Documents
resource "google_storage_bucket" "docs_bucket" {
  name          = "${var.project_id}-clinical-documents-prod" # Unique name
  location      = var.region
  force_destroy = false

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

# Bucket for NLP Models (Custom)
resource "google_storage_bucket" "nlp_models_bucket" {
  name          = "${var.project_id}-nlp-models"
  location      = var.region
  uniform_bucket_level_access = true
}
