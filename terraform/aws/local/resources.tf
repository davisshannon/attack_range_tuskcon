provider "aws" {
  region     =  var.config.region
}

module "networkModule" {
  source			  = "../modules/network"
  config                = var.config
}

module "splunk-server" {
  source			           = "../modules/splunk-server"
	vpc_security_group_ids = module.networkModule.sg_vpc_id
	ec2_subnet_id         = module.networkModule.ec2_subnet_id
  config                = var.config
}

module "windows-domain-controller" {
  source			           = "../modules/windows-domain-controller"
	vpc_security_group_ids = module.networkModule.sg_vpc_id
	ec2_subnet_id          = module.networkModule.ec2_subnet_id
  config                 = var.config
}

module "windows-client" {
  source			           = "../modules/windows-client"
	vpc_security_group_ids = module.networkModule.sg_vpc_id
	ec2_subnet_id          = module.networkModule.ec2_subnet_id
  windows_domain_controller_instance = module.windows-domain-controller.windows_domain_controller_instance
  config                 = var.config
}

module "zeek_sensor" {
  source			           = "../modules/zeek_sensor"
	vpc_security_group_ids = module.networkModule.sg_vpc_id
	ec2_subnet_id          = module.networkModule.ec2_subnet_id
  windows_domain_controller_instance = module.windows-domain-controller.windows_domain_controller_instance
  windows_client_instance = module.windows-client.windows_client_instance
  config                 = var.config
}
