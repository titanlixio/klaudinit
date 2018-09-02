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
