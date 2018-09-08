data "tencentcloud_image" "my_favorate_image" {
  os_name = "${var.os_name}"
  image_name_regex = "${var.image_name_regex}"

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


resource "tencentcloud_key_pair" "keypair1" {
  "key_name"   = "keypair1"
  "public_key" = "${file(var.public_key_path)}"
}

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

#resource "tencentcloud_eip" "eip1" {
#  name = "eip1"
#}

#resource "tencentcloud_nat_gateway" "natgw1" {
#  vpc_id           = "${tencentcloud_vpc.vpc1.id}"
#  name             = "natgw1"
#  max_concurrent   = 3000000
#  bandwidth        = 500
#  assigned_eip_set = [
#    "${tencentcloud_eip.eip1.public_ip}",
#  ]
#}

resource "tencentcloud_instance" "node1" {

  instance_name     = "node1"
  image_id          = "${data.tencentcloud_image.my_favorate_image.image_id}"
  instance_type     = "${data.tencentcloud_instance_types.my_favorate_instance_types.instance_types.0.instance_type}"
  availability_zone = "${var.availability_zone}"
  key_name          = "${tencentcloud_key_pair.keypair1.id}"

  system_disk_type  = "CLOUD_BASIC"
  data_disks        = "${var.data_disks}"

  instance_charge_type = "POSTPAID_BY_HOUR"

  vpc_id            = "${tencentcloud_vpc.vpc1.id}"
  subnet_id         = "${tencentcloud_subnet.subnet1.id}"

  disable_security_service   = true
  disable_monitor_service    = true
  internet_max_bandwidth_out = 2
  count                      = 1

  user_data                  = "${base64encode(var.user_data_script)}"

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /tmp/111222",
      "mkdir -p ${var.klaudinit_home}",
    ]

    connection {
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file(var.private_key_path)}"
    }
  }


  provisioner "file" {
    source      = "${var.project_home}/plays/"
    destination = "${var.klaudinit_home}/plays"

    connection {
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file(var.private_key_path)}"
    }
  }

  provisioner "file" {
    source      = "${var.project_home}/envs/"
    destination = "${var.klaudinit_home}/envs"

    connection {
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file(var.private_key_path)}"
    }
  }

  provisioner "file" {
    source      = "${var.project_home}/roles/"
    destination = "${var.klaudinit_home}/roles"

    connection {
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file(var.private_key_path)}"
    }
  }

  provisioner "file" {
    source      = "${var.project_home}/scripts/"
    destination = "${var.klaudinit_home}/scripts"

    connection {
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file(var.private_key_path)}"
    }
  }

  provisioner "file" {
    source      = "${var.project_home}/vboxs/"
    destination = "${var.klaudinit_home}/vboxs"

    connection {
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file(var.private_key_path)}"
    }
  }

  provisioner "file" {
    source      = "${var.project_home}/ansible.cfg"
    destination = "${var.klaudinit_home}/ansible.cfg"

    connection {
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file(var.private_key_path)}"
    }
  } 

  provisioner "file" {
    source      = "${var.project_home}/main.tf"
    destination = "${var.klaudinit_home}/main.tf"

    connection {
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file(var.private_key_path)}"
    }
  } 

  provisioner "file" {
    source      = "${var.project_home}/requirements.yaml"
    destination = "${var.klaudinit_home}/requirements.yaml"

    connection {
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file(var.private_key_path)}"
    }
  } 

  provisioner "remote-exec" {
    inline = [
      "echo hello2 > /tmp/hello2.txt",
      "cat /tmp/hello2.txt >> /tmp/hello.txt",
    ]

    connection {
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file(var.private_key_path)}"
    }
  }
}

#resource "tencentcloud_dnat" "dnat1" {
#  vpc_id       = "${tencentcloud_nat_gateway.natgw1.vpc_id}"
#  nat_id       = "${tencentcloud_nat_gateway.natgw1.id}"
#  protocol     = "tcp"
#  elastic_ip   = "${tencentcloud_eip.eip1.public_ip}"
#  elastic_port = "3000"
#  private_ip   = "${tencentcloud_instance.node1.private_ip}"
#  private_port = "3000"
#}

output "instance_id" {
  value = "${tencentcloud_instance.node1.id}"
}
