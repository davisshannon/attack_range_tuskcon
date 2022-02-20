
data "aws_ami" "windows-server-ami" {
  count  = "${var.config.windows_server}"
  owners = ["self"]

  filter {
    name   = "name"
    values = [var.config.windows_server_os]
  }

  most_recent = true
}

resource "aws_instance" "windows_server" {
  count         = "${var.config.windows_server}"
  ami           = data.aws_ami.windows-server-ami[count.index].id
  instance_type = var.config.windows_server_zeek_capture == "1" ? "m5.2xlarge" : var.config.instance_type_ec2
  key_name = var.config.key_name
  subnet_id = var.ec2_subnet_id
  vpc_security_group_ids = [var.vpc_security_group_ids]
  private_ip             = "10.0.1.2${count.index}"
  root_block_device {
    volume_type = "gp3"
    volume_size = "300"
    iops = "3000"
    throughput = "125"
    delete_on_termination = "true"
  }
  depends_on             = [var.windows_domain_controller_instance]
  tags = {
    Name = "ar-win-server-${var.config.range_name}-${var.config.key_name}--${count.index}"
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
      password = "Surg315C00l!"
      host     = "${self.public_ip}"
      port     = 5985
      insecure = true
      https    = false
      timeout  = "10m"
    }
  }

  provisioner "local-exec" {
    working_dir = "../../../ansible"
    command = "ansible-playbook -i '${self.public_ip},' playbooks/windows_server.yml --extra-vars 'splunk_indexer_ip=${var.config.splunk_server_private_ip} ansible_user=Administrator ansible_password=${var.config.attack_range_password} win_password=${var.config.attack_range_password} splunk_uf_win_url=${var.config.splunk_uf_win_url} win_sysmon_url=${var.config.win_sysmon_url} win_sysmon_template=${var.config.win_sysmon_template} splunk_admin_password=${var.config.attack_range_password} windows_domain_controller_private_ip=${var.config.windows_domain_controller_private_ip} windows_server_join_domain=${var.config.windows_server_join_domain} splunk_stream_app=${var.config.splunk_stream_app} s3_bucket_url=${var.config.s3_bucket_url} win_4688_cmd_line=${var.config.win_4688_cmd_line} verbose_win_security_logging=${var.config.verbose_win_security_logging} install_red_team_tools=${var.config.install_red_team_tools}'"
  }

}
