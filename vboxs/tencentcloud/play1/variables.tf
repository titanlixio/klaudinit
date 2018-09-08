variable "os_name" {
  default = "centos"
}

variable "image_name_regex" {
  default = "^CentOS\\s+7\\.2\\s+64\\w*"
}

variable "instance_type" {
  default = ""
}

variable "availability_zone" {
  default = "ap-guangzhou-3"
}

variable "image_id" {
  default = "img-2xnn7dex"
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
  default = "sh -c 'mkdir -p /tmp/xxoo'"
}

variable "project_home" {
  default = "../.."
}

variable "klaudinit_home" {
  default = "/tmp/klaudinit"
}

variable "data_disks" {
  default = [
    {
      data_disk_type = "CLOUD_BASIC"
      data_disk_size = 50
    },
  ]
}
