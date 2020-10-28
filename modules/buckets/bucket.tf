## VARIABLES ##
variable "role_id" {}
variable "member" {}
variable "bucket-name" {}
variable "location" {}
variable "storageclass" {}
variable "project" {}
variable "role" {}
variable "environment" {}
variable "owner" {}
variable "terraform" {}
variable "project_owner" {}
variable "requester" {} 

resource "google_storage_bucket_iam_member" "member" {
  bucket = google_storage_bucket.internal_bucket.name
  role = var.role_id
  #member = "user:jane@example.com"
  member = var.member
}    

resource "google_storage_bucket" "internal_bucket" {
    name    = var.bucket-name
    location = var.location
    storage_class = var.storageclass
    labels = {
         project = var.project
         role    =  var.role
         owner   = var.owner
         environment = var.environment
         terraform = var.terraform
         project_owner = var.project_owner
         requester = var.requester
    }
}
