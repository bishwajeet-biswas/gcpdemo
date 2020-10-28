// variable "vpcs" {
//   type = list(string)
//   default = [
//     { vpc1 = module.public_vpc.vpc_id },
//     { vpc2 = module.app_vpc.vpc_id },
//     { vpc3 = module.db_vpc.vpc_id },
//   ]
// }



// resource "google_compute_network_peering" "peering1" {
//   count        = 3
//   name         = "peering.${count.index}"
//   network      = google_compute_network.default.id
//   peer_network = google_compute_network.other.id
// }


resource "google_compute_network_peering" "peering1" {
  name         = "peering12"
  network      = module.public_vpc.vpc_id
  peer_network = module.app_vpc.vpc_id
}

resource "google_compute_network_peering" "peering2" {
  name         = "peering21"
  network      = module.app_vpc.vpc_id
  peer_network = module.public_vpc.vpc_id
}

resource "google_compute_network_peering" "peering3" {
  name         = "peering23"
  network      = module.app_vpc.vpc_id
  peer_network = module.db_vpc.vpc_id
}

resource "google_compute_network_peering" "peering4" {
  name         = "peering32"
  network      = module.db_vpc.vpc_id
  peer_network = module.app_vpc.vpc_id
}

resource "google_compute_network_peering" "peering5" {
  name         = "peering13"
  network      = module.public_vpc.vpc_id
  peer_network = module.db_vpc.vpc_id

}

resource "google_compute_network_peering" "peering6" {
  name         = "peering31"
  network      = module.db_vpc.vpc_id
  peer_network = module.public_vpc.vpc_id

}
