resource "aws_vpc" "frc_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "frc_vpc_dev"
  }
}

resource "aws_subnet" "frc_public_subnet" {
  vpc_id                  = aws_vpc.frc_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "frc_public_subnet_dev"
  }
}

resource "aws_internet_gateway" "frc_internet_gateway" {
  vpc_id = aws_vpc.frc_vpc.id

  tags = {
    Name = "frc_internet_gateway_dev"
  }
}

resource "aws_route_table" "frc_route_table" {
  vpc_id = aws_vpc.frc_vpc.id

  tags = {
    Name = "frc_route_table_dev"
  }
}

resource "aws_route" "frc_route" {
  route_table_id         = aws_route_table.frc_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.frc_internet_gateway.id
}

resource "aws_route_table_association" "frc_route_table_association" {
  subnet_id      = aws_subnet.frc_public_subnet.id
  route_table_id = aws_route_table.frc_route_table.id
}

resource "aws_security_group" "frc_security_group" {
  name        = "frc_security_group_dev"
  description = "frc dev security group"

  vpc_id = aws_vpc.frc_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "frc_key_pair" {
  key_name   = "frcaws_key"
  public_key = file("~/.ssh/frcaws.pub")
}

resource "aws_instance" "frc_ec2_instance" {
  ami                    = data.aws_ami.frc_ami.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.frc_key_pair.id
  vpc_security_group_ids = [aws_security_group.frc_security_group.id]
  subnet_id              = aws_subnet.frc_public_subnet.id
  user_data              = file("./templates/userdata.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "frc_ec2_instance_dev"
  }

  provisioner "local-exec" {
    command = templatefile("./templates/${var.host_os}-ssh-config.tpl", {
      hostname     = self.public_ip,
      user         = "ec2-user"
      identityfile = "~/.ssh/frcaws"
    })
    interpreter = var.host_os == "unix" ? ["bash", "-c"] : ["Powershell", "-Command"]
  }
}

