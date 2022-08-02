provider "google" {
    project = var.project_id
    region = var.region
}

resource "google_service_account" "DC-sa" {
  account_id   = var.sa
  display_name = "Test Service Account for data catalog"
  project      = var.project_id
}

resource "google_project_iam_member" "dc_entrygroup_owner" {  
    project = var.project_id 
    role    = "roles/datacatalog.entryGroupOwner"  
    member  = "serviceAccount:${google_service_account.DC-sa.email}"
}

resource "google_data_catalog_entry" "basic_entry" {
  entry_group = google_data_catalog_entry_group.entry_group.id
  entry_id = var.entry_id

  type = "FILESET"

  gcs_fileset_spec {
    file_patterns = ["gs://spatial-ship-354209/dir/*"]
  }
}

resource "google_data_catalog_entry_group" "entry_group" {
  entry_group_id = var.entry_group_id
  
}
