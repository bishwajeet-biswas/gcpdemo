## Variables ##
variable "k8sname" {}
variable "region"  {}
variable "zones" {}
variable "network" {}
variable "subnetwork" {}
variable "min_master_version" {}
variable "master_auth_cidr" {}
variable "ip_range_pods" {}
variable "ip_range_services" {}
variable "project_cluster" {}
variable "role" {}
variable "env" {}
variable "owner" {}
variable "terraform" {}
variable "project_owner" {}
variable "requester" {} 
variable "node-pool1" {}
variable "node_version" {}
variable "auto_repair" {}
variable "auto_upgrade" {}
variable "machine_type" {}
variable "disk_size_gb" {}
variable "image_type" {}
variable "disk_type" {}
variable "service_account" {}
variable "tags" {}

resource "random_password" "password" {
  length = 16
  special = true
  override_special = "_%@"
}
resource "google_container_cluster" "primary" {

  name     = var.k8sname
  location = var.region
  node_locations = var.zones

  ####### We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  network                    = var.network
  subnetwork                 = var.subnetwork
  min_master_version         = var.min_master_version

  master_auth {
    username = "admin"
    password = random_password.password.result

    client_certificate_config {
      issue_client_certificate = false
    }
  }

 master_authorized_networks_config {
  cidr_blocks {
          cidr_block   = var.master_auth_cidr
          display_name = "vpc"
        }
      }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.ip_range_pods
    services_secondary_range_name = var.ip_range_services
  #  ip_aliasing = enable

  }

  resource_labels = {
         
            project = var.project_cluster
            role = var.role
            env = var.env
            owner = var.owner
            terraform = var.terraform
            project_owner = var.project_owner
            requester = var.requester

  }

}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = var.node-pool1
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 2
  version    = var.node_version

  management {
       auto_repair  = var.auto_repair
       auto_upgrade = var.auto_upgrade
   }
  
  

  timeouts {
    create = "30m"
    update = "20m"
  }

  node_config {
    preemptible  = false
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb
    disk_type          = var.disk_type
    image_type         = var.image_type
    service_account    = var.service_account

    metadata = {
      disable-legacy-endpoints = "true"
    }

      labels = {
         
            project = var.project_cluster
            env = var.env
            owner = var.owner
            terraform = var.terraform
            project_owner = var.project_owner
            requester = var.requester
  }

    tags = var.tags

   oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/compute",
    ]
  }
  
}
  
  
####################NEW-NODE-POOL-2###############################################
/*
resource "google_container_node_pool" "preemptible_nodes" {

  name       = "node-pool2"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1
  version    = "1.15.11-gke.5"

  management {
       auto_repair  = var.auto_repair
       auto_upgrade = var.auto_upgrade
   }

  timeouts {
    create = "30m"
    update = "20m"
  }

  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"
    disk_size_gb = "10"
    disk_type          = "pd-standard"
    image_type         = "COS"
    service_account    = var.service_account

    metadata = {
      disable-legacy-endpoints = "true"
    }

    tags = var.tags

   oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
  
}
*/

