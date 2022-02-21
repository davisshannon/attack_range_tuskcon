# install stoq for linux on a fresh Ubuntu instances

data "aws_ami" "latest-ubuntu" {
count = var.config.stoq_linux == "1" ? 1 : 0
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# install Phantom on a bare ubuntu instance
resource "aws_instance" "stoq_linux" {
  count                  = var.config.stoq_linux == "1" ? 1 : 0
  ami                    = data.aws_ami.latest-ubuntu[count.index].id
  instance_type          = var.config.instance_type_ec2
  key_name               = var.config.key_name
  subnet_id              = var.ec2_subnet_id
  vpc_security_group_ids = [var.vpc_security_group_ids]
  private_ip             = var.config.stoq_linux_private_ip

  tags = {
    Name = "ar-stoq_linux-${var.config.range_name}-${var.config.key_name}"
  }

  provisioner "remote-exec" {
    inline = ["echo booted"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.stoq_linux[0].public_ip
      private_key = file(var.config.private_key_path)
    }
  }

  provisioner "local-exec" {
    working_dir = "../../../ansible/"
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu --private-key ${var.config.private_key_path} -i '${aws_instance.stoq_linux[0].public_ip},' playbooks/stoq_linux.yml -e ' stoq_linux_private_ip=${var.config.stoq_linux_private_ip} splunk_indexer_ip=${var.config.splunk_server_private_ip} splunk_uf_url=${var.config.splunk_uf_linux_deb_url}'"
  }
}

resource "aws_eip" "stoq_linux_ip" {
  count    = var.config.stoq_linux == "1" && var.config.use_elastic_ips == "1" ? 1 : 0
  instance = aws_instance.stoq_linux[0].id
}

