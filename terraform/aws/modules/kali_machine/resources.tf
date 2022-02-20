
data "aws_ami" "latest-kali-linux" {
  count       = var.config.kali_machine == "1" ? 1 : 0
  most_recent = true
  owners      = ["679593333241"] # owned by AWS marketplace

  filter {
      name   = "name"
      values = ["kali-linux-2020*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "kali_machine" {
  count                  = var.config.kali_machine == "1" ? 1 : 0
  ami                    = data.aws_ami.latest-kali-linux[count.index].id
  instance_type          = var.config.instance_type_ec2
  key_name               = var.config.key_name
  subnet_id              = var.ec2_subnet_id
  vpc_security_group_ids = [var.vpc_security_group_ids]
  private_ip             = var.config.kali_machine_private_ip
  tags = {
    Name = "ar-kali-${var.config.range_name}-${var.config.key_name}"
  }

  provisioner "remote-exec" {
    inline = ["echo booted"]

    connection {
      type        = "ssh"
      user        = "kali"
      host        = aws_instance.kali_machine[count.index].public_ip
      private_key = file(var.config.private_key_path)
    }
  }
  
  provisioner "local-exec" {
    working_dir = "../../../ansible/"
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u kali --private-key ${var.config.private_key_path} -i '${aws_instance.kali_machine[0].public_ip},' playbooks/kali.yml -e 'ansible_python_interpreter=/usr/bin/python3'"
  }
}
