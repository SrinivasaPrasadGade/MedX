# Enable Required APIs
resource "google_project_service" "apis" {
  for_each = toset([
    "healthcare.googleapis.com",
    "aiplatform.googleapis.com",
    "run.googleapis.com",
    "bigquery.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudbuild.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "vpcaccess.googleapis.com",
    "firestore.googleapis.com"
  ])
  service = each.key
  disable_on_destroy = false
}

# VPC Network
resource "google_compute_network" "medx_vpc" {
  name                    = "medx-vpc"
  auto_create_subnetworks = false
  depends_on              = [google_project_service.apis]
}

# Subnet for Backend Services
resource "google_compute_subnetwork" "backend_subnet" {
  name          = "medx-backend-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.medx_vpc.id
}

# Serverless VPC Access Connector (for Cloud Run to talk to VPC)
resource "google_vpc_access_connector" "connector" {
  name          = "medx-connector"
  region        = var.region
  ip_cidr_range = "10.8.0.0/28"
  network       = google_compute_network.medx_vpc.name
}
