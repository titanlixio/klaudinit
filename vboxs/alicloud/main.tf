# https://github.com/terraform-providers/terraform-provider-alicloud/tree/master/examples

provider "alicloud" {
  region = "cn-huhehaote"
}

#module "alicloud-play1" {
#  source   = "play1"
#}

module "alicloud-play2" {
  source   = "play2"
}
