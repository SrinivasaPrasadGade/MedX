output "project_id" {
  value = var.project_id
}

output "region" {
  value = var.region
}

output "fhir_store_id" {
  value = google_healthcare_fhir_store.fhir_store.id
}

output "bigquery_dataset_id" {
  value = google_bigquery_dataset.analytics.dataset_id
}

output "docs_bucket_name" {
  value = google_storage_bucket.docs_bucket.name
}
