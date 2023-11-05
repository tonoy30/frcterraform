module "recap_terraform" {
  source = "./vpc"
}

output "ssh" {
  value = module.recap_terraform.ec2_ssh_command
}
