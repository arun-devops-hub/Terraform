# This repo is for terraform practice.

# Useful link to filter vpc_id's for vpc data src "https://www.taccoform.com/posts/tfg_p7/"

aws key pair creation through terraform example for future reference

The requirement is for instances being launched via this module to always have the latest Ubuntu AMI. Configuring our module to operate this way ensures that the instances will always be up to date.
To do this the data resource block will be utilized to pull the latest version of the AWS Ubuntu AMI.

data "aws_ami" "ubuntu_ami" {
  most_recent = true

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter{
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
  
}
Now for the instance itself. For this we have to set up an aws_instance resource.

resource "aws_instance" "test_env_ec2" {
  count                       = var.counter
  ami                         = data.aws_ami.ubuntu_ami.id
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
  security_groups             = ["${aws_security_group.security.id}"]
  associate_public_ip_address = true

  subnet_id = aws_subnet.subnet.id

  tags = {
    Name = var.instance_tag[count.index]
  }
}
All the values of the instances are being provided by the variables that were defined earlier.

The Internet Gateway:

For traffic to be routed to the VPC it needs an Internet Gateway

resource "aws_internet_gateway" "test_env_gw" {
  vpc_id = aws_vpc.test_env.id
}
Route Table:

The Internet Gateway will be attached to this Route Table and a link between the subnet and the Route Table will expose the subnet to the internet allowing access.

resource "aws_subnet" "subnet" {
  cidr_block        = cidrsubnet(aws_vpc.test_env.cidr_block, 3, 1)
  vpc_id            = aws_vpc.test_env.id
  availability_zone = var.availability_zone
}
Now it’s ready….or is it?
As opposed to creating the key pair for the Instance via the AWS Console this will be done via Terraform as well.

Key Pair Creation:

In the Terraform official documentation there is an AWS key pair resource that can be used to get this done.

resource "aws_key_pair" "tf_key" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.rsa.public_key_openssh
}
I am going to set the name of the key pair to the variable that was declared earlier in the module (var.key_pair_name)

When making a key pair you get a private and public key. The private key is to be downloaded and kept secure, whilst the public key is to be shared on the server.

To create the private key the tis_private_key resource will be utilized

# RSA key of size 4096 bits
resource "tls_private_key" "rsa-4096-example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
Just like in the AWS Console this block of code provides all the configurations necessary to generate a private key pair. The name will be changed to rsa.

After this creation a public and private key will be generate
Update the public_key in the aws_key_pair resource block to “tls_private_key.rdssa.public_key_openssh”. This will allow us to get the public key

Storing the Key Pair:

Next the Private Key needs to be stored in the instance in order to ssh into the instance. To do this a folder must be created.
For this the local_file resource will be used.

The content will be private content of the key that will be created

resource "local_file" "tf_key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = var.file_name

}
