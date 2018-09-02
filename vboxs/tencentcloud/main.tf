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
  memory_size    = 1
}


#resource "tencentcloud_key_pair" "random_key" {
#  "key_name" = "tf_example_key6"
#}

resource "tencentcloud_instance" "my-server" {
  image_id  = "${data.tencentcloud_image.my_favorate_image.image_id}"
  instance_type = "${data.tencentcloud_instance_types.my_favorate_instance_types.instance_types.0.instance_type}"
  availability_zone = "${var.availability_zone}"

  instance_charge_type = "POSTPAID_BY_HOUR"
  disable_monitor_service    = true
  internet_max_bandwidth_out = 2
  count                      = 1
}

output "instance_id" {
  value = "${tencentcloud_instance.my-server.id}"
}
