

resource "aws_instance" "ssh_bastion" {
  ami           = data.aws_ami.ubuntu.id
  key_name      = aws_key_pair.my_tf_key.key_name
  instance_type = var.instance_type
  subnet_id     = local.public_subnet_ids[0]
  tags = {
    name = "Bastion-Host"
  }
  root_block_device {
    volume_size           = var.volume_size
    delete_on_termination = true
  }

  vpc_security_group_ids = [aws_security_group.bastion_host.id]

  # Install unattended-upgrade package to automatically install security updates
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y nginx
              EOF
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]  # Canonical's AWS account ID
}

output "ubuntu_ami_id" {
  value = data.aws_ami.ubuntu.id
}


resource "aws_key_pair" "my_tf_key" {
    key_name = "tf_key"
    public_key = var.public_key
}

data "aws_vpc" "togetvpc_id" {
  filter {
    name   = "cidr-block"
    values = ["10.2.0.0/16"]
  }
}

output "vpc_id" {
  value = data.aws_vpc.togetvpc_id.id
}

data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.togetvpc_id.id]
  }
}

data "aws_subnet" "public" {
  for_each = toset(data.aws_subnets.selected.ids)
  id       = each.value
}

locals {
  public_subnet_ids = [for s in data.aws_subnet.public : s.id if s.map_public_ip_on_launch]
}

output "public_subnet_id" {
  value = local.public_subnet_ids[0]  # Assuming you want the first public subnet ID
}

resource "aws_security_group" "bastion_host" {
     name = "allow-all"

  vpc_id = data.aws_vpc.togetvpc_id.id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}