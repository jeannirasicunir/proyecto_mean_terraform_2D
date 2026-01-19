# Terraform: Backend EC2 Deployment

This Terraform stack provisions the backend Node.js application on an EC2 instance, with networking, IAM, and bootstrap user-data to install Node.js and PM2. No MongoDB is installed or required. The backend can run in an in-memory mode when the `DISABLE_DB` environment variable is set (default in this stack).

## What it creates
- VPC (10.0.0.0/16), public subnet, Internet Gateway, route table
- Security Group allowing TCP 5000 (backend) and SSH (configurable)
- Optional S3 artifact upload of `../server` (or clone from repo)
- Optional IAM role for SSM and S3 (or none if permissions restricted)
- Ubuntu EC2 instance with public IP and user-data to bootstrap and run the app

## Prerequisites
- AWS credentials configured (e.g., `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
- Existing key pair if you want SSH (optional; SSM works without it)
- Terraform `>= 1.5`

## Quick start

```bash
cd terraform
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

To override defaults:

```bash
terraform apply \
  -var aws_region=us-east-1 \
  -var instance_type=t3.micro \
  -var allowed_ssh_cidr=203.0.113.0/24 \
  -var key_name=my-keypair
```

## Outputs
- `instance_public_ip`: Public IP of EC2
- `instance_public_dns`: Public DNS name
- `application_url`: Convenience URL `http://IP:5000`

## Notes
- Backend listens on port 5000 per `server/index.js`.
- MongoDB is not provisioned. The app runs with in-memory storage when `DISABLE_DB=true` (set via user-data). You can switch to a real MongoDB by unsetting `DISABLE_DB` and providing a connection string in `server/db.js`.
- For production persistence, plug in your database and disable the in-memory mode.
