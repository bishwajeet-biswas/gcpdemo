## PROVIDERS##
provider "google" {
    credentials             = file("service-account.json")
    project                 = "zipper-284005"
    region                  = "us-central1"
}
provider "google-beta" {
    credentials             = file("service-account.json")
    project                 = "zipper-284005"
    region                  = "us-central1"
}

  ## VPC, SUBNETS, NAT, & FIREWALLS ##
module "demo_vpc" {
    source                      = "./modules/vpc"
    vpc_name                    = "demovpc"
    description                 = "demo purpose vpc"
    delete_default_route        = false             // true/false; if set to true default route to 0.0.0.0/0 will be deleted
}

    ##SUBNET
module  "public_subnet" {
    source              = "./modules/subnet"
    vpc                 = module.demo_vpc.vpc_named 
    private_access      = true
    subnet_name         = "subnet-public"
    region              = "us-central1"
    primary_range       = "10.10.0.0/24"
    second_range_name   = "iprange2"
    second_range        = "192.168.10.0/24"
    third_range_name    = "iprange3"
    third_range         = "10.128.10.0/24"
}
module  "subnet_app" {
    source              = "./modules/subnet"
    vpc                 = module.demo_vpc.vpc_named 
    private_access      = true
    subnet_name         = "subnet-app"
    region              = "us-central1"
    primary_range       = "10.20.0.0/24"
    second_range_name   = "pod"
    second_range        = "10.4.0.0/14"
    third_range_name    = "services"
    third_range         = "10.8.0.0/20"
}
module  "subnet_db" {
    source              = "./modules/subnet"
    vpc                 = module.demo_vpc.vpc_named 
    private_access      = true
    subnet_name         = "subnet-db"
    region              = "us-central1"
    primary_range       = "10.30.0.0/24"
    second_range_name   = "iprange2"
    second_range        = "192.168.30.0/24"
    third_range_name    = "iprange3"
    third_range         = "10.128.30.0/24"

}

    ## NAT##
module "nat" {
  source                    = "./modules/nat"
  vpc                       = module.demo_vpc.vpc_named
  router_name               = "ourrouter"
  router_region             = "us-central1"
  nat_ip_name               = "natip"
  nat_region                = "us-central1"
  nat_name                  = "natzero"
  app_subnet                = module.subnet_app.subnet_name
  app_subnet_ipranges       = module.subnet_app.subnet_ranges
  db_subnet                 = module.subnet_db.subnet_name
  db_subnet_ipranges        = module.subnet_db.subnet_ranges
}

    ## Firewalls ##
module "ssh_firewall_public" {
    source            = "./modules/firewall"
    fire_name         = "ssh-firewall-public"
    protocol          = "tcp"
    ports             = ["22"]
    other_protocol    = "icmp"            //"icmp","ah", "sctp"
    tags              = ["public"]
    ip_access         = ["139.5.255.225/32"] 
    vpc_name          = module.demo_vpc.vpc_named
}
module "ssh_firewall_app" {
    source            = "./modules/firewall"
    fire_name         = "ssh-firewall-app"
    protocol          = "tcp"
    ports             = ["22"]
    other_protocol    = "icmp"            //"icmp","ah", "sctp"
    tags              = ["app"]
    ip_access         = ["139.5.255.31/32"] 
    vpc_name          = module.demo_vpc.vpc_named
}
module "rdp_firewall" {
    source            = "./modules/firewall"
    fire_name         = "rdp-firewall"
    protocol          = "tcp"
    ports             = ["3389"]
    other_protocol    = "icmp"            //"icmp","ah", "sctp"
    tags              = ["app"]
    ip_access         = ["139.5.255.31/32"] 
    vpc_name          = module.demo_vpc.vpc_named
}
module "ssh_firewall_db" {
    source            = "./modules/firewall"
    fire_name         = "ssh-firewall-db"
    protocol          = "tcp"
    ports             = ["22"]
    other_protocol    = "icmp"            //"icmp","ah", "sctp"
    tags              = ["db"]
    ip_access         = ["139.5.255.31/32"] 
    vpc_name          = module.demo_vpc.vpc_named
}

    ## INSTANCES##
module "instance_public" {
  source                    = "./modules/instance/public"
  vm_name                   = "demo-bastion"
  machine_type              = "n1-standard-1"                   //"custom-1-2048"
  zone                      = "us-central1-a"
  ip_forwarding             = false                             // true/false (default: false)
  deletion_protection       = false
  image                     = "ubuntu-os-cloud/ubuntu-2004-lts" //     "windows-cloud/windows-2019"  // images list https://cloud.google.com/compute/docs/images/os-details
  //extra_disk                = module.disk.additional_disk_named
  additional_disk_size      = "50"
  additional_disk_type      = "pd-balanced"          //options: pd-ssd/pd-standard/pd-balanced

  tags                      = ["public"]
  vpc_named                 = module.demo_vpc.vpc_named
  subnetwork                = module.public_subnet.subnet_name
    ### boot_disk##
  auto_delete               = true            // true/false
  boot_disk_size            = 30              // minimum 50GB for windows and min 10Gb for other os
  boot_disk_type            = "pd-standard"     // pd-standard, pd-balanced, pd-SSD  
    ## attached_disk##
  
  
  ###### labels##
  label_env             = "demo"
  label_created_by      = "bishwajeet"
  label_creation_date   = "27th-october"
  label_owner           = "demo-team"
  label_requester       = "demo-server"
}
module "instance_app" {
  source                    = "./modules/instance/private"
  vm_name                   = "buildserver"
  machine_type              = "n1-standard-1"                   //"custom-1-2048"
  zone                      = "us-central1-a"
  ip_forwarding             = false                             // true/false (default: false)
  deletion_protection       = false
  image                     = "ubuntu-os-cloud/ubuntu-2004-lts" //     "windows-cloud/windows-2019"  // images list https://cloud.google.com/compute/docs/images/os-details
  //   extra_disk                = module.disk.additional_disk_named
  additional_disk_size      = "20"
  additional_disk_type      = "pd-standard"          //options: pd-ssd/pd-standard/pd-balanced

  tags                      = ["app"]
  vpc_named                 = module.demo_vpc.vpc_named
  subnetwork                = module.subnet_app.subnet_name
    ### boot_disk##
  auto_delete               = true            // true/false
  boot_disk_size            = 10              // minimum 50GB for windows and min 10Gb for other os
  boot_disk_type            = "pd-standard"     // pd-standard, pd-balanced, pd-SSD  
    ## attached_disk##
  
  
  ###### labels##
  label_env             = "demo"
  label_created_by      = "bishwajeet"
  label_creation_date   = "27th-october"
  label_owner           = "demo-team"
  label_requester       = "demo-server"
}
module "instance_db" {
  source                    = "./modules/instance/private"
  vm_name                   = "dbserver"
  machine_type              = "n1-standard-1"                   //"custom-1-2048"
  zone                      = "us-central1-a"
  ip_forwarding             = false                             // true/false (default: false)
  deletion_protection       = false
  image                     = "ubuntu-os-cloud/ubuntu-2004-lts" //     "windows-cloud/windows-2019"  // images list https://cloud.google.com/compute/docs/images/os-details
  //   extra_disk                = module.disk.additional_disk_named
  additional_disk_size      = "20"
  additional_disk_type      = "pd-balanced"          //options: pd-ssd/pd-standard/pd-balanced

  tags                      = ["db"]
  vpc_named                 = module.demo_vpc.vpc_named
  subnetwork                = module.subnet_db.subnet_name
    ### boot_disk##
  auto_delete               = true            // true/false
  boot_disk_size            = 10              // minimum 50GB for windows and min 10Gb for other os
  boot_disk_type            = "pd-standard"     // pd-standard, pd-balanced, pd-SSD  
    ## attached_disk##
  
  
  ###### labels##
  label_env             = "demo"
  label_created_by      = "bishwajeet"
  label_creation_date   = "27th-october"
  label_owner           = "demo-team"
  label_requester       = "demo-server"
}

    ## GKE ##
module "gke" {
  source                    = "./modules/gke"
  k8sname                   = "democluster"
  region                    = "us-central1"
  zones                     = ["us-central1-a","us-central1-b"]
  network                   = module.demo_vpc.vpc_named
  subnetwork                = module.subnet_app.subnet_name
  min_master_version        = "1.17.12-gke.2502"
  master_auth_cidr          = module.subnet_app.subnet_primary_range
  ip_range_pods             =  "pod"     //module.subnet_app.subnet_secondary_range
  ip_range_services         = "services"          //  module.subnet_app.subnet_third_range
  node-pool1                = "pool1"
  node_version              = "1.17.12-gke.2502"
  auto_repair               = true
  auto_upgrade              = true
  machine_type              = "e2-standard-2"
  disk_size_gb              = 100        
  image_type                = "cos"
  disk_type                 = "pd-standard"  // [pd-standard pd-balanced pd-ssd]
  service_account           = ""
  tags                      = ["k8s"]
    ## labels##
  project_cluster           = "demo"
  role                      = "demo"
  env                       = "demo"
  owner                     = "myself"
  terraform                 = "yes"
  project_owner             = "myself"
  requester                 = "demo" 
}

    ## SQL ##
module "sql" {
  source                      = "./modules/sql"
  private_ip_address-name     = "demo-db-ip"
  vpc_network                 = module.demo_vpc.vpc_named
  private_network             = module.demo_vpc.vpc_id
  db-name                     = "demodb"
  db-version                  = "POSTGRES_11"
  region                      = "us-central1"
  db-tier                     = "db-f1-micro"
  disk-size                   = "10"
  disk-type                   = "PD-SSD"
  disk-autoresize             = "false"
  zone                        = "us-central1-a"
  project                     = "demo"
  role                        = "demo"
  env                         = "demo"
  owner                       = "myself-demo"
  terraform                   = "yes"
  project_owner               = "demo-user"
  requester                   = "demo-poc"
  db-password                 = "letsthisbepassword"
  db-password-demo            = "letsthisbepassword"
}

    ## Buckets ##
module "bucket" {
  source                  = "./modules/buckets"
  role_id                 = "roles/storage.objectViewer"
  member                  = "user:alucky.sharma103@gmail.com"
  bucket-name             = "demonatrajbucket"
  location                = "us-central1"
  storageclass            = "STANDARD"                //STANDARD, NEARLINE, COLDLINE, or ARCHIVE
  project                 = "demo-project"
  role                    = "demo-role"
  environment             = "demo-env"
  owner                   = "demo-owner"
  terraform               = "yes"
  project_owner           = "demo-owner"
  requester               = "demo-requester"
}

    ## IAM ##
module "iam_primitives" {
  source                  = "./modules/iam/primitives"
  project                 = "zipper-284005"
  editors                 = ["user:alucky.sharma103@gmail.com", "user:vjeet5559@gmail.com",]
  owners                  = ["user:alucky.sharma103@gmail.com", "user:vjeet5559@gmail.com",]
  browsers                = ["user:alucky.sharma103@gmail.com", "user:vjeet5559@gmail.com",] 
}
module "custom_storage_admin" {
  source                  = "./modules/iam/custom"
  account_id              = "demoservice"
  display_name            = "demo service account"
  role_id                 = "storageadmin2"
  role_title              = "storage admin2"
  role_description        = "custom storage admin"
  role_permissions        = ["compute.images.create","resourcemanager.projects.get","resourcemanager.projects.getIamPolicy","storage.buckets.get","storage.buckets.getIamPolicy","storage.buckets.list","storage.buckets.setIamPolicy"]
  // users                   = ["user:alucky.sharma103@gmail.com", "user:vjeet5559@gmail.com", "user:bishwajeet833@gmail.com"]
  user1                   = "alucky.sharma103@gmail.com"
  user2                   = "vjeet5559@gmail.com"
  user3                   = "bishwajeet833@gmail.com"
}