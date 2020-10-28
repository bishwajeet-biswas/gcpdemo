## variables ##
variable "vpc" {}
variable "router_name" {}
variable "router_region" {}
variable "nat_ip_name" {}
variable "nat_region" {}
variable "nat_name" {}
variable "app_subnet" {}
variable "app_subnet_ipranges" {}
variable "db_subnet" {}
variable "db_subnet_ipranges" {}


resource "google_compute_address" "global-ip-one" {
  name      = var.nat_ip_name
  region    = var.nat_region
  
}

resource "google_compute_router" "router-1" {
  name    = var.router_name
  region  = var.router_region
  network = var.vpc

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = var.nat_name
  depends_on                         = [google_compute_router.router-1]
  router                             = var.router_name
  region                             = var.nat_region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.global-ip-one.self_link]
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = var.app_subnet
    source_ip_ranges_to_nat = var.app_subnet_ipranges     
  }
  subnetwork {
    name                    = var.db_subnet
    source_ip_ranges_to_nat = var.db_subnet_ipranges
  }
}


output  "nat_created" {
  value             = google_compute_address.global-ip-one.address
}
output  "nat_gateway" {
  value             = google_compute_router_nat.nat.id
}
