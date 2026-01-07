resource "google_firestore_database" "database" {
  name        = "(default)"
  location_id = var.region
  type        = "FIRESTORE_NATIVE"

  # Delete protection prevents accidental deletion
  delete_protection_state = "DELETE_PROTECTION_ENABLED"

  depends_on = [google_project_service.apis]
}
