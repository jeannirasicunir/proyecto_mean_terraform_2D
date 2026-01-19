########################
# Networking
########################
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = "mean-backend-vpc" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "mean-backend-igw" })
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = merge(var.tags, { Name = "mean-backend-public-subnet" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.tags, { Name = "mean-backend-public-rt" })
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

########################
# Security Group
########################
resource "aws_security_group" "backend_sg" {
  name        = "mean-backend-sg"
  description = "Allow app traffic and SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "App port"
    from_port   = var.app_port
    to_port     = var.app_port
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

  tags = merge(var.tags, { Name = "mean-backend-sg" })
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
# S3 bucket + artifact
########################
resource "random_pet" "artifacts" {
  length = 2
}

resource "aws_s3_bucket" "artifacts" {
  count         = var.existing_s3_bucket_name == null ? 1 : 0
  bucket        = "${var.bucket_prefix}-${random_pet.artifacts.id}"
  force_destroy = true

  tags = merge(var.tags, { Name = "mean-backend-artifacts" })
}

# Zip local server folder and upload to S3
resource "archive_file" "server_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../server"
  output_path = "${path.module}/server.zip"
}

locals {
  artifact_bucket_name = var.repo_url != "" ? "" : (
    var.existing_s3_bucket_name != null && var.existing_s3_bucket_name != "NONE"
    ? var.existing_s3_bucket_name
    : try(aws_s3_bucket.artifacts[0].bucket, "")
  )
}

resource "aws_s3_object" "server_zip" {
  count  = var.repo_url != "" ? 0 : (local.artifact_bucket_name == "" ? 0 : 1)
  bucket = local.artifact_bucket_name
  key    = "server.zip"
  source = archive_file.server_zip.output_path
  etag   = archive_file.server_zip.output_md5
}

########################
# IAM role for EC2
########################
resource "aws_iam_role" "ec2_role" {
  count              = var.existing_instance_profile_name == null ? 1 : 0
  name               = "mean-backend-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Principal = { Service = "ec2.amazonaws.com" }
      Effect    = "Allow"
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "s3_read" {
  count      = var.existing_instance_profile_name == null ? 1 : 0
  role       = aws_iam_role.ec2_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  count      = var.existing_instance_profile_name == null ? 1 : 0
  role       = aws_iam_role.ec2_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  count = var.existing_instance_profile_name == null ? 1 : 0
  name  = "mean-backend-ec2-profile"
  role  = aws_iam_role.ec2_role[0].name
}

########################
# EC2 instance
########################
locals {
  name_tag = "mean-backend-ec2"
}

resource "aws_instance" "backend" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.backend_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = var.existing_instance_profile_name == "NONE" ? null : (var.existing_instance_profile_name != null ? var.existing_instance_profile_name : aws_iam_instance_profile.ec2_profile[0].name)

  user_data = templatefile("${path.module}/templates/user_data.sh", {
    app_port            = var.app_port
    repo_url            = var.repo_url
    server_dir_relative = var.server_dir_relative
  })
  user_data_replace_on_change = true

  key_name = (var.key_name != null && var.key_name != "") ? var.key_name : null

  tags = merge(var.tags, { Name = local.name_tag })
}
