// this will add additional data disk to new instance

variable "disk_name" {}
variable "zone" {}
variable "disk_size" {}
variable "label_env" {}
variable "label_created_by" {}
variable "label_creation_date" {}
variable "label_requester" {}
variable "label_owner" {}
variable "additional_disk_type" {}


resource "google_compute_disk" "data" {
  zone      = var.zone
  name      = var.disk_name
  #name      = "${var.vm_named}_${var.disk_name}"
  size      = var.disk_size
  type      = var.additional_disk_type
  labels = {
    // environment = var.label_env
    // created_by = var.label_created_by
    // creation_date = var.label_creation_date
    // requester = var.label_requester
    // owner = var.label_owner
    creation_mode = "terraform"
  }
}

output "additional_disk_named" {
  value = google_compute_disk.data.self_link
}
