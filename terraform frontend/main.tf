########################
# Networking (supports existing VPC/subnet)
########################

# If a security_group_id is provided, infer its VPC id.
data "aws_security_group" "existing" {
  count = var.security_group_id != null ? 1 : 0
  id    = var.security_group_id
}

locals {
  sg_vpc_id      = var.security_group_id != null ? data.aws_security_group.existing[0].vpc_id : null
  create_vpc     = var.existing_vpc_id == null && local.sg_vpc_id == null
  create_subnet  = local.create_vpc && var.existing_subnet_id == null
  vpc_id         = var.existing_vpc_id != null ? var.existing_vpc_id : (local.sg_vpc_id != null ? local.sg_vpc_id : try(aws_vpc.main[0].id, null))
  subnet_id      = var.existing_subnet_id != null ? var.existing_subnet_id : try(aws_subnet.public[0].id, null)
}

resource "aws_vpc" "main" {
  count                 = local.create_vpc ? 1 : 0
  cidr_block            = var.vpc_cidr
  enable_dns_support    = true
  enable_dns_hostnames  = true

  tags = merge(var.tags, { Name = "mean-frontend-vpc" })
}

resource "aws_subnet" "public" {
  count                    = local.create_subnet ? 1 : 0
  vpc_id                   = local.vpc_id
  cidr_block               = var.public_subnet_cidr
  map_public_ip_on_launch  = true

  tags = merge(var.tags, { Name = "mean-frontend-public-subnet" })
}

# Internet gateway and route table are created only when we create a new VPC
resource "aws_internet_gateway" "igw" {
  count  = local.create_vpc ? 1 : 0
  vpc_id = aws_vpc.main[0].id
  tags   = merge(var.tags, { Name = "mean-frontend-igw" })
}

resource "aws_route_table" "public" {
  count = local.create_vpc ? 1 : 0
  vpc_id = aws_vpc.main[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id
  }

  tags = merge(var.tags, { Name = "mean-frontend-public-rt" })
}

resource "aws_route_table_association" "public_assoc" {
  count         = local.create_vpc && local.create_subnet ? 1 : 0
  subnet_id     = aws_subnet.public[0].id
  route_table_id = aws_route_table.public[0].id
}

########################
# Security Group
########################
resource "aws_security_group" "frontend_sg" {
  count       = var.security_group_id == null ? 1 : 0
  name        = "mean-frontend-sg"
  description = "Allow Angular dev server and SSH"
  vpc_id      = local.vpc_id

  ingress {
    description = "Angular dev server"
    from_port   = 4200
    to_port     = 4200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "mean-frontend-sg" })
}

########################
# AMI
########################
data "aws_ami" "ubuntu" {
  owners      = ["099720109477"] # Canonical
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

########################
# EC2 instance
########################
locals {
  name_tag = "mean-frontend-ec2"
}

resource "aws_instance" "frontend" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = local.subnet_id
  vpc_security_group_ids      = var.security_group_id != null ? [var.security_group_id] : [aws_security_group.frontend_sg[0].id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/templates/user_data.sh", {
    repo_url               = var.repo_url
    frontend_dir_relative  = var.frontend_dir_relative
  })
  user_data_replace_on_change = true

  key_name = (var.key_name != null && var.key_name != "") ? var.key_name : null

  tags = merge(var.tags, { Name = local.name_tag })

  lifecycle {
    precondition {
      condition     = local.subnet_id != null
      error_message = "No subnet provided. When using an existing VPC (explicitly or inferred via security_group_id), set variable existing_subnet_id to a valid subnet in that VPC."
    }
  }
}
