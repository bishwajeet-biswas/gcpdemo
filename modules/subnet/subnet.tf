###Variables##
variable "vpc" {}
variable "subnet_name" {}
variable "primary_range" {}
variable "region" {}
variable "second_range" {}
variable "second_range_name" {}
variable "third_range_name" {}
variable "third_range" {}
variable "private_access" {}

resource "google_compute_subnetwork" "subnet" {
  name                            = var.subnet_name
  ip_cidr_range                   = var.primary_range
  region                          = var.region
  network                         = var.vpc
  private_ip_google_access        = var.private_access      // When enabled, VMs in this subnetwork without external IP addresses can access Google APIs and services by using Private Google Access.
  secondary_ip_range {
    range_name                    = var.second_range_name
    ip_cidr_range                 = var.second_range
  }
  secondary_ip_range {
    range_name                    = var.third_range_name
    ip_cidr_range                 = var.third_range
  }
}

// outputs

output "subnet_name" {
  value                           = google_compute_subnetwork.subnet.name
}

output "subnet_ranges" {
  value                           = ["${var.primary_range}","${var.second_range}","${var.third_range}"]
}

output "subnet_primary_range" {
  value                       = "${var.primary_range}"
}

output "subnet_secondary_range" {
  value                       = "${var.second_range}"
}

output "subnet_third_range" {
  value                       = "${var.third_range}"
}
