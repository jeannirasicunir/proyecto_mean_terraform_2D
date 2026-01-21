variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.1.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type for frontend"
  type        = string
  default     = "m7i-flex.large"
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

variable "repo_url" {
  description = "Git repository URL that contains this project so the instance can clone the code."
  type        = string
  default     = ""
}

variable "frontend_dir_relative" {
  description = "Relative path to the Angular frontend folder within the repo"
  type        = string
  default     = "frontend"
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {
    Project   = "mean-terraform"
    Component = "frontend"
  }
}

variable "security_group_id" {
  description = "Existing security group ID to attach to the EC2 instance. If set, a new security group will not be created. Note: The security group must belong to the same VPC as the subnet where the instance is launched."
  type        = string
  default     = "sg-08d55d3a2d1420f4d"
}

variable "existing_vpc_id" {
  description = "Optional existing VPC ID. If provided (or inferred from security_group_id), the module will not create a new VPC."
  type        = string
  default     = null
}

variable "existing_subnet_id" {
  description = "Optional existing subnet ID to launch the EC2 into. If not provided, a new public subnet will be created in the selected VPC."
  type        = string
  default     = "subnet-012dec819ef71dae0"
}
