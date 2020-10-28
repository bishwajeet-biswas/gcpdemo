## variables #####
variable "vm_name" {}
variable "machine_type" {}
variable "zone" {}
variable "ip_forwarding" {}
variable "tags" {}
variable "image" {}
// variable "sshkeys" {}
variable "vpc_named" {}
variable "subnetwork" {}
variable "label_env" {}
variable "label_created_by" {}
variable "label_creation_date" {}
variable "label_requester" {}
variable "label_owner" {}
// variable "extra_disk" {}
variable "additional_disk_size" {}
variable "auto_delete" {}     // true or false
variable "boot_disk_size" {}  // starts with 50GB
variable "boot_disk_type" {}  // pd-standard, pd-balanced, pd-SSD 
variable "deletion_protection" {}  // true or false
variable "additional_disk_type" {}

# variable "additional_disk" {}

# variable "gce_ssh_user" {}
# variable "gce_ssh_pub_key_file" {}

#################disk ##############



#########################
// calling static ip module internally 

//  module "staticip" {
//    source = "../../staticip"
//    vm_name      = var.vm_name
//  }

 module "data_disk" {
    source                          = "../../disk"
    disk_name                       = "data-${var.vm_name}"
    zone                            = var.zone
    disk_size                       = var.additional_disk_size
    additional_disk_type            = var.additional_disk_type
    label_env                       = var.label_env
    label_created_by                = var.label_created_by
    label_creation_date             = var.label_creation_date
    label_requester                 = var.label_requester
    label_owner                     = var.label_owner
    
 }


resource "google_compute_instance" "default" {
  name                        = var.vm_name
  machine_type                = var.machine_type
  zone                        = var.zone
  can_ip_forward              = var.ip_forwarding
  allow_stopping_for_update   = true   // this line will allow terraform to stop the instance in case of instance editing is required. for eg, scopes. 
  deletion_protection         = var.deletion_protection      //true/false
  tags                        = var.tags
  labels = {
    environment               = var.label_env
    created_by                = var.label_created_by
    creation_date             = var.label_creation_date
    requester                 = var.label_requester
    owner                     = var.label_owner
    creation_mode             = "terraform"
  }
  
  boot_disk {
    auto_delete       = var.auto_delete
    initialize_params {
      image             = var.image
      size              = var.boot_disk_size
      type              = var.boot_disk_type        // pd-standard, pd-balanced, pd-SSD   
    }
  }

  
  // Data disk//
  attached_disk {
    source      = module.data_disk.additional_disk_named
    // source = var.extra_disk
    // device_name = "data-disk"

   }

  // Local SSD disk
  # scratch_disk {
  #   interface = "SCSI"
  # }

  network_interface {
      network = var.vpc_named
      subnetwork = var.subnetwork
    # network = module.firewall.google_compute_network.custom-test.name
      

// this section is for static public ip
    // access_config {
    //   // Ephemeral
    //    nat_ip = module.staticip.static_ip_created       // hide this for ephemeral IP
    // }
  }


//  metadata = {
//     "ssh-keys" = var.sshkeys
  
//   }
  

  service_account {
     scopes = ["compute-rw", "userinfo-email", "monitoring", "logging-write"]
    #scopes = ["storagesa@xap-test1.iam.gserviceaccount.com"]
  }
}

//outputs

output "vm_named" {
  value = google_compute_instance.default.name
}
