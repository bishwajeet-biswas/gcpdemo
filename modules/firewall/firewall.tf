//this module creates a vpc, a private subnetwork with primary and secondary ip ranges, along with a firewall 

variable "vpc_name" {}
variable "fire_name" {}
variable "tags" {}
variable "ip_access" {}
variable "other_protocol" {}
variable "protocol" {}
variable "ports" {
  type    = list
}



resource "google_compute_firewall" "firewall" {
  name            = var.fire_name
  network         = var.vpc_name
    allow {
    protocol      = var.protocol            //"tcp"
    ports         = var.ports              //["80", "8080", "3389"]
  }
    allow {
    protocol      = var.other_protocol      //"icmp","ah", "sctp"
  }

  source_tags     = var.tags
  source_ranges    = var.ip_access
}
