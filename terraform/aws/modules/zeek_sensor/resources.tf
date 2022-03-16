data "aws_ami" "latest-ubuntu" {
  count = var.config.zeek_sensor == "1" ? 1 : 0
  most_recent = true
  owners = ["099720109477"] # Canonical

  filter {
      name   = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }
}


resource "aws_instance" "zeek_sensor" {
  count = var.config.zeek_sensor == "1" ? 1 : 0
  ami           = data.aws_ami.latest-ubuntu[count.index].id
  instance_type = "c5n.18xlarge"
  key_name = var.config.key_name
  subnet_id = var.ec2_subnet_id
  vpc_security_group_ids = [var.vpc_security_group_ids]
  private_ip = var.config.zeek_sensor_private_ip
  root_block_device {
    volume_type = "gp3"
    volume_size = "1000"
    iops = "16000"
    throughput = "1000"
    delete_on_termination = "true"
  }
  tags = {
    Name = "ar-zeek-sensor-${var.config.range_name}-${var.config.key_name}-${var.config.range_number}"
  }
}

resource "aws_network_interface" "zeek_capture_nic" {
  count = var.config.zeek_sensor == "1" ? 1 : 0
  subnet_id       = var.ec2_subnet_id
  private_ips     = ["10.0.1.99"]
  security_groups = [var.vpc_security_group_ids]

  attachment {
    instance     = aws_instance.zeek_sensor[0].id
    device_index = 1
  }
}

resource "null_resource" "zeek_sensor_provision" {
  count = var.config.zeek_sensor == "1" ? 1 : 0
  provisioner "remote-exec" {
    inline = ["echo booted"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.zeek_sensor[0].public_ip
      private_key = file(var.config.private_key_path)
    }
  }

  provisioner "local-exec" {
    working_dir = "../../../ansible/"
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu --private-key ${var.config.private_key_path} -i '${aws_instance.zeek_sensor[0].public_ip},' playbooks/zeek.yml -e 'ansible_python_interpreter=/usr/bin/python3 splunk_uf_url=${var.config.splunk_uf_linux_deb_url} splunk_uf_binary=${var.config.splunk_uf_binary} windows_domain_controller_zeek_capture=${var.config.windows_domain_controller_zeek_capture} windows_client_zeek_capture=${var.config.windows_client_zeek_capture} splunk_indexer_ip=${var.config.splunk_server_private_ip}'"
  }
}

resource "aws_ec2_traffic_mirror_target" "zeek_target" {
  count = var.config.zeek_sensor == "1" ? 1 : 0
  description          = "VPC Tap for Zeek"
  network_interface_id = aws_network_interface.zeek_capture_nic[0].id
}

resource "aws_ec2_traffic_mirror_filter" "zeek_filter" {
  count = var.config.zeek_sensor == "1" ? 1 : 0
  description = "Zeek Mirror Filter - Allow All"
}

resource "aws_ec2_traffic_mirror_filter_rule" "zeek_outbound" {
  count = var.config.zeek_sensor == "1" ? 1 : 0
  description = "Zeek Outbound Rule"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.zeek_filter[0].id
  destination_cidr_block = "0.0.0.0/0"
  source_cidr_block = "0.0.0.0/0"
  rule_number = 1
  rule_action = "accept"
  traffic_direction = "egress"
}

resource "aws_ec2_traffic_mirror_filter_rule" "zeek_inbound" {
  count = var.config.zeek_sensor == "1" ? 1 : 0
  description = "Zeek Inbound Rule"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.zeek_filter[0].id
  destination_cidr_block = "0.0.0.0/0"
  source_cidr_block = "0.0.0.0/0"
  rule_number = 1
  rule_action = "accept"
  traffic_direction = "ingress"
}

resource "aws_ec2_traffic_mirror_session" "zeek_windows_dc_session" {
  count         = var.config.windows_domain_controller_zeek_capture == "1" && var.config.zeek_sensor == "1" ? "${var.config.windows_domain_controller}" : 0
  description              = "Zeek Mirror Session for Windows Domain Controller"
  depends_on = [var.windows_domain_controller_instance]
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.zeek_filter[0].id
  traffic_mirror_target_id = aws_ec2_traffic_mirror_target.zeek_target[0].id
  network_interface_id     = var.windows_domain_controller_instance[count.index].primary_network_interface_id
  session_number           = "10${count.index}"
}

resource "aws_ec2_traffic_mirror_session" "zeek_windows_client_session" {
  count         = var.config.windows_client_zeek_capture == "1" && var.config.zeek_sensor == "1" ? "${var.config.windows_client}" : 0
  description              = "Zeek Mirror Session for Windows Client"
  depends_on = [var.windows_client_instance]
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.zeek_filter[0].id
  traffic_mirror_target_id = aws_ec2_traffic_mirror_target.zeek_target[0].id
  network_interface_id     = var.windows_client_instance[count.index].primary_network_interface_id
  session_number           = "30${count.index}"
}
