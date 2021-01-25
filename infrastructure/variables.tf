variable "project_id" {
  description = "project id"
}

variable "name" {
  description = "the name of the project"
  default     = "travel-share"
}

variable "gke_num_nodes" {
  default     = 4
  description = "number of gke nodes"
}

variable "region" {
  description = "region"
  default     = "us-central1"
}
