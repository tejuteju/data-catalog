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
  //linked_resource = "dc"
  type = "FILESET"

  gcs_fileset_spec {
    file_patterns = ["gs://spatial-ship-354209/dir/*"]
  }
}

resource "google_data_catalog_entry_group" "entry_group" {
  entry_group_id = var.entry_group_id
  
}
resource "google_data_catalog_tag_template" "example" {  
  tag_template_id = var.tag_template_id
  region          = var.region 
  display_name    = "Required Tags"  
  fields {    
    field_id = "data_classification"    
    display_name = "Data Classification"    
    type {      
      enum_type {        
        allowed_values {          
          display_name = "PRIVATE"        
        }        
        allowed_values {          
          display_name = "RESTRICTED"        
        }        
        allowed_values {          
          display_name = "PUBLIC"        
        }      
      }
    }
    is_required = true
  }
  force_delete = true
}
resource "google_data_catalog_taxonomy" "basic_taxonomy" {
  project = var.project_id
  provider = google-beta
  region = "us"
  display_name =  "my_display_name"
  description = "A collection of policy tags"
  activated_policy_types = ["FINE_GRAINED_ACCESS_CONTROL"]
}
resource "google_data_catalog_policy_tag" "basic_policy_tag" {   
  provider = google-beta
  taxonomy = google_data_catalog_taxonomy.basic_taxonomy.id
  display_name = "sample policy tag" 
  description = "basic policy tag"
}
resource "google_data_catalog_tag" "basic_tag" {
  parent   = google_data_catalog_entry.basic_entry.id
  template = google_data_catalog_tag_template.example.id

  fields {
    field_name   = "data_classification"
    enum_value = "PRIVATE"
  }
}
