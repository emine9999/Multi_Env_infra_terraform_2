resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "${terraform.workspace}-vpc"
  }
}

resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = var.availability_zones[count.index]
  
  tags = {
    Name = "${terraform.workspace}-private-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 1)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${terraform.workspace}-public-subnet-${count.index + 1}"
  }
}

# ALB Configuration
resource "aws_lb" "alb" {
  name               = "ALB-${var.alb_config[terraform.workspace].name}"
  internal           = var.alb_config[terraform.workspace].internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets           = slice(aws_subnet.public[*].id, 0, var.alb_config[terraform.workspace].az_count)
  
  enable_deletion_protection = var.alb_config[terraform.workspace].deletion_protection

  tags = {
    Name = "${terraform.workspace}-ALB"
  }
}

# Target Group
resource "aws_lb_target_group" "tg" {
  name     = "TG-${var.target_groups[terraform.workspace].name}"
  port     = var.target_groups[terraform.workspace].port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  
  health_check {
    protocol = "HTTP"
    path     = var.target_groups[terraform.workspace].health_check_path
  }

  tags = {
    Name = "${terraform.workspace}-TG"
  }
}

# Bastion Host
resource "aws_instance" "bastion" {
  ami                         = var.bastion_host.ami
  instance_type               = var.bastion_host.instance_type
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.jumper-SG.id]
  associate_public_ip_address = true
  key_name                   = var.bastion_host.key_name
  
  tags = {
    Name = "${terraform.workspace}-bastion"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
 vpc_id = aws_vpc.main.id
 tags = {
 Name = "main-gateway"
 }
}

resource "aws_eip" "nat_eip" {
 tags = {
 Name = "nat-eip"
 }
}
resource "aws_nat_gateway" "nat_gw" {
 allocation_id = aws_eip.nat_eip.id
 subnet_id = aws_subnet.public[1].id
 tags = {
 Name = "nat-gateway"
 }
}



# Create Route Table
resource "aws_route_table" "public_RT" {
 vpc_id = aws_vpc.main.id
 route {
 cidr_block = "0.0.0.0/0"
 gateway_id = aws_internet_gateway.main.id
 }
 tags = {
 Name = "public_RT"
 }
}
resource "aws_route_table" "private_RT" {
 vpc_id = aws_vpc.main.id
tags = {
 Name = "private_RT"
 }
}
resource "aws_route" "private_route" {
 route_table_id = aws_route_table.private_RT.id
 destination_cidr_block = "0.0.0.0/0"
 nat_gateway_id = aws_nat_gateway.nat_gw.id
}

# Associate Subnets with Route Tables
resource "aws_route_table_association" "private1_association" {
 subnet_id = aws_subnet.private[11].id
 route_table_id = aws_route_table.private_RT.id
}

resource "aws_route_table_association" "private1_association" {
 subnet_id = aws_subnet.private[10].id
 route_table_id = aws_route_table.private_RT.id
}

resource "aws_route_table_association" "private1_association" {
 subnet_id = aws_subnet.private[12].id
 route_table_id = aws_route_table.private_RT.id
}



resource "aws_route_table_association" "subnet3_association" {
 subnet_id = aws_subnet.public[0].id
 route_table_id = aws_route_table.public_RT.id
}

resource "aws_route_table_association" "subnet3_association" {
 subnet_id = aws_subnet.public[1].id
 route_table_id = aws_route_table.public_RT.id
}

resource "aws_route_table_association" "subnet3_association" {
 subnet_id = aws_subnet.public[3].id
 route_table_id = aws_route_table.public_RT.id
}

