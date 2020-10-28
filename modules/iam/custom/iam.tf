## Variables ##

variable "account_id" {}
variable "display_name" {}
variable "role_id" {}
variable "role_title" {}
variable "role_description" {}
variable "role_permissions" {}
// variable "users" {
//   type      = list 

// }
variable "user1" {}
variable "user2" {}
variable "user3" {}

data "google_project" "project" {}

resource "google_service_account" "internal_service_account" {
  account_id   = var.account_id
  display_name = var.display_name
}

resource "google_project_iam_custom_role" "bucket-admin-role" {
  role_id     = var.role_id
  title       = var.role_title
  description = var.role_description
  permissions = var.role_permissions
  //["resourcemanager.projects.get","resourcemanager.projects.getIamPolicy","storage.buckets.get","storage.buckets.getIamPolicy","storage.buckets.list","storage.buckets.setIamPolicy"]

}

resource "google_project_iam_binding" "bucket_admin_binding" {
  role = "projects/${data.google_project.project.project_id}/roles/${google_project_iam_custom_role.bucket-admin-role.role_id}"

  members = [
    "serviceAccount:${google_service_account.internal_service_account.email}", "user:${var.user1}", "user:${var.user2}", "user:${var.user3}",
  ]
  // members = [
  //   "serviceAccount:${google_service_account.internal_service_account.email}", "${var.users[2]}",
  //   ]
}



resource "google_service_account_key" "mykey" {
  service_account_id = google_service_account.internal_service_account.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "local_file" "myaccountjson" {
    content     = base64decode(google_service_account_key.mykey.private_key)
    filename = "${path.module}/bucketkey.json"

}
