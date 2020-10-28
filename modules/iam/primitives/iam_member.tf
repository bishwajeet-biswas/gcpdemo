## variables ##
variable "project" {}
variable "editors" {}
variable "owners" {}
variable "browsers" {}

resource "google_project_iam_binding" "project_editor" {
  project = var.project
  role    = "roles/editor"

//   members = [
//     "user:jane@example.com",
//   ]
  members = var.editors
}

resource "google_project_iam_binding" "project_owner" {
  project = var.project
  role    = "roles/owner"

//   members = [
//     "user:jane@example.com",
//   ]
  members = var.owners
}

resource "google_project_iam_binding" "project_browser" {
  project = var.project
  role    = "roles/browser"

//   members = [
//     "user:jane@example.com",
//   ]
  members = var.browsers
}