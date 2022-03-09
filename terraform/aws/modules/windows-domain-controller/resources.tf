data "aws_ami" "latest-windows-server-2019" {
  count       = var.config.windows_domain_controller == "1" ? 1 : 0
  most_recent = true
  owners      = ["801119661308"] # Canonical

  filter {
    name   = "name"
    values = [var.config.windows_domain_controller_os]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_instance" "windows_domain_controller" {
  count         = var.config.windows_domain_controller == "1" ? 1 : 0
  ami           = data.aws_ami.latest-windows-server-2019[count.index].id
  instance_type          = var.config.instance_type_ec2
  key_name = var.config.key_name
  subnet_id = var.ec2_subnet_id
  private_ip             = "10.0."{var.config.range_number}".13"
  vpc_security_group_ids = [var.vpc_security_group_ids]
  tags = {
    Name = "ar-win-dc-${var.config.range_name}-${var.config.key_name}--${count.index}"
  }
  user_data = <<EOF
<powershell>
$admin = [adsi]("WinNT://./Administrator, user")
$admin.PSBase.Invoke("SetPassword", "${var.config.attack_range_password}")
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Url = 'https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1'
$PSFile = 'C:\ConfigureRemotingForAnsible.ps1'
Invoke-WebRequest -Uri $Url -OutFile $PSFile
C:\ConfigureRemotingForAnsible.ps1
</powershell>
EOF

  provisioner "remote-exec" {
    inline = ["echo booted"]

    connection {
      type     = "winrm"
      user     = "Administrator"
      password = var.config.attack_range_password
      host     = aws_instance.windows_domain_controller[count.index].public_ip
      port     = 5986
      insecure = true
      https    = true
      timeout  = "10m"
        }
  }

  provisioner "local-exec" {
    working_dir = "../../../ansible"
    command = "ansible-playbook -i '${aws_instance.windows_domain_controller[count.index].public_ip},' playbooks/windows_dc.yml --extra-vars 'aws_tier=${var.config.aws_tier} splunk_headend_ip=${var.config.splunk_headend_ip} splunk_indexer_ip=${var.config.splunk_server_private_ip} ansible_user=Administrator ansible_password=${var.config.attack_range_password} win_password=${var.config.attack_range_password} splunk_uf_win_url=${var.config.splunk_uf_win_url} win_sysmon_url=${var.config.win_sysmon_url} win_sysmon_template=${var.config.win_sysmon_template} splunk_admin_password=${var.config.attack_range_password} splunk_stream_app=${var.config.splunk_stream_app} s3_bucket_url=${var.config.s3_bucket_url} win_4688_cmd_line=${var.config.win_4688_cmd_line} verbose_win_security_logging=${var.config.verbose_win_security_logging} install_red_team_tools=${var.config.install_red_team_tools}'"
  }
}
