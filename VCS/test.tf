terraform { 
  /*
    cloud {
    organization = "HussOufkir"
    workspaces {
      name = "Test1"
    }
  }
  */
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      #version = "~> 4.16"
    }
  }
  required_version = "1.5.0"
}

provider "aws" {
  region = "us-east-1"
}

# Create a VPC

resource "aws_vpc" "myVpc_tf" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = var.vpc_name # it's a variable
  }
}

# Create a SUBNET

resource "aws_subnet" "mySubnet_tf" {
  vpc_id            = aws_vpc.myVpc_tf.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.0.0/24"
  tags = {
    Name = "mySubnet_tf"
  }
}

# Create an INTERNET GATEWAY

resource "aws_internet_gateway" "myInternetGateway_tf" {
  vpc_id = aws_vpc.myVpc_tf.id
  tags = {
    Name = "myInternetGateway_tf"
  }
}

# Create a ROUTE TABLE

resource "aws_route_table" "myRouteTable_tf" {
  vpc_id = aws_vpc.myVpc_tf.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myInternetGateway_tf.id
  }
  tags = {
    Name = "myRouteTable_tf"
  }
}

# Create an ASSOCIATION between the ROUTE TABLE and the SUBNET

resource "aws_route_table_association" "myRouteTableAssociation" {
  route_table_id = aws_route_table.myRouteTable_tf.id
  subnet_id      = aws_subnet.mySubnet_tf.id
}

# Create a SECURITY GROUP

resource "aws_security_group" "mySecGroup_tf" {
  vpc_id = aws_vpc.myVpc_tf.id
  tags = {
    Name = "mySecGroup_tf"
  }
}

# CREATE an INGRESS RULE (inbound) to allow port 22

resource "aws_vpc_security_group_ingress_rule" "myIngressRule22_tf" {
  security_group_id = aws_security_group.mySecGroup_tf.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

# CREATE an INGRESS RULE (inbound) to allow port 80

resource "aws_vpc_security_group_ingress_rule" "myIngressRule80_tf" {
  security_group_id = aws_security_group.mySecGroup_tf.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

# CREATE an INGRESS RULE (inbound) to allow port 443

resource "aws_vpc_security_group_ingress_rule" "myIngressRule443_tf" {
  security_group_id = aws_security_group.mySecGroup_tf.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

# CREATE an EGRESS RULE (outbound) to allow all protocols on all ports

resource "aws_vpc_security_group_egress_rule" "myEgressRule_tf" {
  security_group_id = aws_security_group.mySecGroup_tf.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # to allow traffic to all protocols and all ports
}

# Create an NETWORK INTERFACE (dont attach the network with the instance in this declaration, because on the instance creation a default network interface will be created on index 0)

resource "aws_network_interface" "myNetInterface_tf" {
  subnet_id       = aws_subnet.mySubnet_tf.id
  security_groups = [aws_security_group.mySecGroup_tf.id]
  private_ip      = "10.0.0.1"
  #attachment {
  #  device_index = 1
  #  instance     = aws_instance.myInstance_tf.id
  #}
  tags = {
    Name = "myNetInterface_tf"
  }
}

# Create an INSTANCE with UBUNTU and APACHE2 installed (network interface must be attached here to avoid the creation of the default network interface, see above)

resource "aws_instance" "myInstance_tf" {
  ami               = "ami-053b0d53c279acc90"
  availability_zone = "us-east-1a"
  instance_type     = "t2.micro"
  user_data         = <<-EOF
  #!/bin/bash
  sudo apt update -y
  sudo touch /home/ubuntu/test
  sudo apt install apache2 -y
  sudo systemctl start apache2.service
  sudo systemctl enable apache2.service
  EOF
  network_interface {
    network_interface_id = aws_network_interface.myNetInterface_tf.id
    device_index         = 0
  }
  tags = {
    Name = "myInstance_tf"
  }
}

# Create an ELASTIC IP for the NETWORK INTERFACE (by adding the "depends_on", we will wait the end of the creation of the instance to create the EIP because we cannot associate an EIP with an instance that is in PENDING-CREATION state)

resource "aws_eip" "myEIP_tf" {
  network_interface = aws_network_interface.myNetInterface_tf.id
  depends_on        = [aws_instance.myInstance_tf]
}