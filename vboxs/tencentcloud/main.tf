data "tencentcloud_image" "my_favorate_image" {
  os_name = "${var.os_name}"

  filter {
    name   = "image-type"
    values = ["PUBLIC_IMAGE"]
  }
}

data "tencentcloud_instance_types" "my_favorate_instance_types" {
  filter {
    name   = "instance-family"
    values = ["S1"]
  }

  cpu_core_count = 1
  memory_size    = 2
}


#resource "tencentcloud_key_pair" "random_key" {
#  "key_name" = "tf_example_key6"
#}

resource "tencentcloud_vpc" "vpc1" {
  name       = "vpc1"
  cidr_block = "10.36.0.0/16"
}

resource "tencentcloud_subnet" "subnet1" {
  vpc_id            = "${tencentcloud_vpc.vpc1.id}"
  name              = "subnet1"
  cidr_block        = "10.36.1.0/24"
  availability_zone = "${var.availability_zone}"
}

resource "tencentcloud_eip" "eip1" {
  name = "eip1"
}

resource "tencentcloud_nat_gateway" "natgw1" {
  vpc_id           = "${tencentcloud_vpc.vpc1.id}"
  name             = "natgw1"
  max_concurrent   = 3000000
  bandwidth        = 500
  assigned_eip_set = [
    "${tencentcloud_eip.eip1.public_ip}",
  ]
}

resource "tencentcloud_instance" "node1" {
  image_id  = "${data.tencentcloud_image.my_favorate_image.image_id}"
  instance_type = "${data.tencentcloud_instance_types.my_favorate_instance_types.instance_types.0.instance_type}"
  availability_zone = "${var.availability_zone}"

  system_disk_type = "CLOUD_BASIC"

  data_disks = [
    {
      data_disk_type = "CLOUD_BASIC"
      data_disk_size = 300
    },
  ]

  instance_charge_type = "POSTPAID_BY_HOUR"


  vpc_id            = "${tencentcloud_vpc.vpc1.id}"
  subnet_id         = "${tencentcloud_subnet.subnet1.id}"

  disable_security_service   = true
  disable_monitor_service    = true
  internet_max_bandwidth_out = 2
  count                      = 1
}

resource "tencentcloud_dnat" "dnat1" {
  vpc_id       = "${tencentcloud_nat_gateway.natgw1.vpc_id}"
  nat_id       = "${tencentcloud_nat_gateway.natgw1.id}"
  protocol     = "tcp"
  elastic_ip   = "${tencentcloud_eip.eip1.public_ip}"
  elastic_port = "3000"
  private_ip   = "${tencentcloud_instance.node1.private_ip}"
  private_port = "3000"
}

output "instance_id" {
  value = "${tencentcloud_instance.node1.id}"
}
