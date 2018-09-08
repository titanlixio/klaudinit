variable "os_name" {
  default = "centos"
}

variable "image_name_regex" {
  default = "^centos_7_02_64.*"
}

variable "instance_type" {
  default = "ecs.g5.2xlarge"
}

variable "disk_type" {
  default = "cloud_efficiency"
}

variable "disk_size" {
  default = 40
}

variable "data_disk_type" {
  default = "cloud_efficiency"
}

variable "data_disk_size" {
  default = 40
}

variable "availability_zone" {
  default = "cn-huhehaote-b"
}

variable "vpc_id" {
  default = ""
}

variable "vpc_cidr" {
  default = "10.36.0.0/16"
}

variable "subnet_id" {
  default = ""
}

variable "subnet_cidr" {
  default = "10.36.1.0/24"
}

variable "keypair_id" {
  default = ""
}

variable "image_id" {
  default = "centos_7_02_64_20G_alibase_20170818.vhd"
}

variable "security_group_id" {
  default = ""
}

variable "bandwidth" {
  default = 5
}

variable "ssh_user" {
  default = "root"
}

variable "private_key_path" {
  default = "../.ssh/id_rsa"
}

variable "public_key_path" {
  default = "../.ssh/id_rsa.pub"
}

variable "user_data_script" {
  default = "sh -c 'mkdir -p /tmp/xxoo; lsblk | tee  -a /tmp/lsblk.log'"
}

variable "project_home" {
  default = "../.."
}

variable "klaudinit_home" {
  default = "/tmp/klaudinit"
}

variable "period_unit" {
  default = "Month"
}

variable "period" {
  default = "1"
}

variable "charge_type" {
  default = "PostPaid"
}

variable "tag_role" {
  default = "any"
}

variable "tag_dc" {
  default = "dev"
}

