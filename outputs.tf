output "frc_ec2_instance_ssh_command" {
  value = "ssh -i ~/.ssh/frcaws ec2-user@${aws_instance.frc_ec2_instance.public_ip}"
}
