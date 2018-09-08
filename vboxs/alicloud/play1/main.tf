# 

data "alicloud_instance_types" "instance_types" {
  instance_type_family = "ecs.g5"
  cpu_core_count = 2
  memory_size    = 8
}

resource "alicloud_key_pair" "keypair1" {
  count        = "${var.keypair_id == "" ? 1: 0}"
  key_name     = "keypair1"
  public_key   = "${file(var.public_key_path)}"
}

resource "alicloud_vpc" "vpc1" {
  count      = "${var.vpc_id == "" ? 1 : 0}"
  name       = "vpc1"
  cidr_block = "${var.vpc_cidr}"
}

resource "alicloud_vswitch" "subnet1" {
  count             = "${var.subnet_id == "" ? 1 : 0}"
  vpc_id            = "${var.vpc_id == "" ? alicloud_vpc.vpc1.id : var.vpc_id}"
  name              = "subnet1"
  cidr_block        = "${var.subnet_cidr}"
  availability_zone = "${var.availability_zone}"
}

resource "alicloud_security_group" "security_group1" {
  count        = "${var.security_group_id == "" ? 1: 0}"
  name         = "security_group1"
  vpc_id       = "${var.vpc_id == "" ? alicloud_vpc.vpc1.id : var.vpc_id}"
}

resource "alicloud_security_group_rule" "allow_http_80" {
  type = "ingress"
  ip_protocol = "tcp"
  nic_type = "intranet"
  policy = "accept"
  port_range = "80/80"
  priority = 1
  security_group_id = "${var.security_group_id == "" ? alicloud_security_group.security_group1.id : var.security_group_id}"
  cidr_ip = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_https_443" {
  type = "ingress"
  ip_protocol = "tcp"
  nic_type = "intranet"
  policy = "accept"
  port_range = "443/443"
  priority = 1
  security_group_id = "${var.security_group_id == "" ? alicloud_security_group.security_group1.id : var.security_group_id}"
  cidr_ip = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_ssh_22" {
  type = "ingress"
  ip_protocol = "tcp"
  nic_type = "intranet"
  policy = "accept"
  port_range = "22/22"
  priority = 1
  security_group_id = "${var.security_group_id == "" ? alicloud_security_group.security_group1.id : var.security_group_id}"
  cidr_ip = "0.0.0.0/0"
}

resource "alicloud_instance" "node1" {

  count                      = 0
  instance_name              = "node1"
  image_id                   = "${var.image_id}"
  instance_type              = "${var.instance_type}"
# instance_type              = "${data.alicloud_instance_types.instance_types.instance_types.0.instance_type}"
  availability_zone          = "${var.availability_zone}"
  key_name                   = "${var.keypair_id == "" ? alicloud_key_pair.keypair1.id : var.keypair_id}"
  security_groups            = ["${var.security_group_id == "" ? alicloud_security_group.security_group1.0.id : var.security_group_id}"]
  system_disk_category       = "${var.disk_type}"
  system_disk_size           = "${var.disk_size}"
# include_data_disks         = ""
  instance_charge_type       = "${var.charge_type}"
# period                     = "${var.charge_type == "PrePaid" ? var.period : "" }"
# period_unit                = "${var.charge_type == "PrePaid" ? var.period_unit : "" }"
  vswitch_id                 = "${var.subnet_id == "" ? alicloud_vswitch.subnet1.id : var.subnet_id}"
  internet_max_bandwidth_out = "${var.bandwidth}"
  user_data                  = "${var.user_data_script}"

  tags {
    role = "${var.tag_role}"
    dc   = "${var.tag_dc}"
  }

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


#resource "alicloud_disk" "data_disks" {
#  availability_zone = "${var.availability_zone}"
#  category          = "${var.data_disk_type}"
#  size              = "${var.data_disk_size}"
#  count             = 1
#}

#resource "alicloud_disk_attachment" "data_disks_attach" {
#  count            = 1
#  disk_id          = "${alicloud_disk.data_disks.0.id}"
#  instance_id      = "${alicloud_instance.node1.0.id}"
#}

