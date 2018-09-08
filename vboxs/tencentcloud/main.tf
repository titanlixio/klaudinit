# https://github.com/tencentyun/terraform-provider-tencentcloud/tree/master/examples

provider "tencentcloud" {
  region = "ap-guangzhou"
}

module "tencentcloud-play1" {
  source   = "play1"
  image_id = "img-2xnn7dex"
  availability_zone = "ap-guangzhou-3"
}
