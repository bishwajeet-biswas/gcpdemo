// This will create vpc

variable "vpc_name" {}
variable "description" {}
// variable "routing_mode" {}
variable "delete_default_route" {}

resource "google_compute_network" "custom-test" {
  name                                  = var.vpc_name
  auto_create_subnetworks               = false
  description                           = var.description
//   routing_mode                          = var.routing_mode          //REGIONAL/GLOBAL
  delete_default_routes_on_create       = var.delete_default_route      // true/false If set to true, default routes (0.0.0.0/0) will be deleted immediately after network creation. Defaults to false.

}


// outputs

output "vpc_named" {
  value                       = google_compute_network.custom-test.name
}

output "vpc_id" {
  value                       = google_compute_network.custom-test.id
}
