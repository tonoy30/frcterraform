output "ec2_ssh_command" {
  value = "ssh -i ~/.ssh/frcaws ec2-user@${aws_instance.frc_ec2_instance.public_ip}"
}
