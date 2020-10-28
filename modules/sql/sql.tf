    ## Varibles##

variable "private_ip_address-name" {}
variable "vpc_network" {}
variable "private_network" {}
variable "db-name" {}
variable "db-version" {}
variable "region" {}
variable "db-tier" {}
variable "disk-size" {}
variable "disk-type" {}
variable "disk-autoresize" {}
variable "zone" {}
variable "project" {}
variable "role" {}
variable "env" {}
variable "owner" {}
variable "terraform" {}
variable "project_owner" {}
variable "requester" {} 
variable "db-password" {}
variable "db-password-demo" {}


resource "google_compute_global_address" "private_ip_address" {
  provider = google-beta

  name          = var.private_ip_address-name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.vpc_network
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta

  network                 = var.vpc_network
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}


resource "google_sql_database_instance" "db1" {
    provider = google-beta
    name = var.db-name
    database_version = var.db-version
    region = var.region

    depends_on = [google_service_networking_connection.private_vpc_connection]


    settings {
        tier = var.db-tier
        disk_size = var.disk-size
        disk_autoresize = var.disk-autoresize
        disk_type = var.disk-type
        location_preference {
            zone = var.zone
        }
        user_labels = {
        
            project = var.project
            role = var.role
            env = var.env
            owner = var.owner
            terraform = var.terraform
            project_owner = var.project_owner
            requester = var.requester



        }
        ip_configuration {
            ipv4_enabled = false
		    private_network = var.private_network
        }
        backup_configuration {
            enabled = "true"
        }
        maintenance_window {
            day = "7"
            hour = "16"
            update_track = "stable"
            
        }

        # database_flags {
        #     name = "log_min_duration_statement" 
        #     value = "1000"
        # }
    }
}
resource "google_sql_user" "master-users" {
  name     = "postgres"
  instance = google_sql_database_instance.db1.name
  password = var.db-password
}

resource "google_sql_user" "master-users01" {
  name     = "demo"
  instance = google_sql_database_instance.db1.name
  password = var.db-password-demo
}
