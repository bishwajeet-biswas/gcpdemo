variable "vm_name" {}

resource "google_compute_address" "static" {
    name            = "ipv4-address-${var.vm_name}"
    // depends_on      = [google_compute_instance.default]

}
output "static_ip_created" {
  value = google_compute_address.static.address
}