# Healthcare Dataset
resource "google_healthcare_dataset" "dataset" {
  name      = "medx-primary-dataset"
  location  = var.region
  time_zone = "UTC"
  depends_on = [google_project_service.apis]
}

# FHIR Store (R4)
resource "google_healthcare_fhir_store" "fhir_store" {
  name    = "medx-fhir-store"
  dataset = google_healthcare_dataset.dataset.id
  version = "R4"

  enable_update_create          = true
  disable_referential_integrity = false # Enforce integrity for production-like quality

  labels = {
    env = "production"
  }
}

# IAM Binding for access (Example: make the default compute service account an editor)
# note: In a real scenario, use specific service accounts.
