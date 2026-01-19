variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type for backend"
  type        = string
  default     = "t3.micro"
}

variable "app_port" {
  description = "Application port exposed by backend"
  type        = number
  default     = 5000
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "key_name" {
  description = "Optional existing EC2 key pair name; leave null to use SSM only"
  type        = string
  default     = null
}

variable "bucket_prefix" {
  description = "Prefix for S3 bucket storing backend artifact"
  type        = string
  default     = "mean-backend-artifacts"
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {
    Project   = "mean-terraform"
    Component = "backend"
  }
}

variable "existing_instance_profile_name" {
  description = "Name of an existing IAM instance profile to attach to EC2. If provided, Terraform will not create IAM role/profile. Set to \"NONE\" to attach no profile (SSH only)."
  type        = string
  default     = "NONE"
}

variable "existing_s3_bucket_name" {
  description = "Name of an existing S3 bucket to store the backend artifact. If provided, Terraform will not create a bucket. Set to \"NONE\" to bypass S3 (use repo_url)."
  type        = string
  default     = "NONE"
}

variable "repo_url" {
  description = "Optional Git repository URL to clone backend from, bypassing S3 artifact upload."
  type        = string
  default     = ""
}

variable "server_dir_relative" {
  description = "Relative path to the server folder within the repo when using repo_url."
  type        = string
  default     = "server"
}