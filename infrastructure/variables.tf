variable "project_id" {
  description = "The Google Cloud Project ID"
  type        = string
  default     = "medx-health-platform"
}

variable "region" {
  description = "The Google Cloud region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The Google Cloud zone"
  type        = string
  default     = "us-central1-a"
}
