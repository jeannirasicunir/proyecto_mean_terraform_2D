# Frontend Terraform Stack

This Terraform configuration provisions an Ubuntu EC2 instance that serves the Angular application (from the `frontend` folder of this repo) over HTTP on port 80 using Nginx. The instance builds the app from a Git repository using cloud-init `user_data`.

## Inputs

- `aws_region`: AWS region (default `us-east-1`).
- `vpc_cidr`: VPC CIDR (default `10.1.0.0/16`).
- `public_subnet_cidr`: Public subnet CIDR (default `10.1.1.0/24`).
- `instance_type`: EC2 type (default `t3.micro`).
- `allowed_ssh_cidr`: CIDR allowed for SSH (default `0.0.0.0/0`).
- `key_name`: Optional EC2 key pair to enable SSH.
- `repo_url`: Git URL of this project so the instance can clone and build the Angular app.
- `frontend_dir_relative`: Relative path to the Angular project in the repo (default `frontend`).
- `security_group_id`: Optional existing security group ID to attach to the EC2 instance. If provided, the module will not create a new security group.
- `existing_vpc_id`: Optional existing VPC ID. If provided (or inferred from `security_group_id`), the module will not create a new VPC.
- `existing_subnet_id`: Optional existing subnet ID to launch the EC2 into. If not provided, a new public subnet will be created in the selected VPC.

## Outputs

- `instance_public_ip`: Public IP address.
- `instance_public_dns`: Public DNS.
- `application_url`: HTTP URL for the Angular app.

## Usage

1. Ensure you have AWS credentials configured and a key pair if you want SSH access.
2. Option A (recommended): Push this repository to a Git host and set `repo_url`.
3. Option B: Omit `repo_url` to deploy a placeholder static page.

Example `terraform.tfvars`:

```
aws_region          = "us-east-1"
instance_type       = "t3.micro"
allowed_ssh_cidr    = "YOUR_IP/32"
key_name            = "your-keypair-name"
repo_url            = "https://github.com/your-org/your-repo.git"
frontend_dir_relative = "frontend"
security_group_id   = "sg-0123456789abcdef0" # (optional)
# If using existing network:
# existing_vpc_id      = "vpc-0abc..."        # optional; inferred from security_group_id if set
# existing_subnet_id   = "subnet-0def..."      # optional; if omitted, a new public subnet is created in selected VPC
```

Commands:

```bash
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

After apply, open the value of `application_url` in a browser.

## Notes

- The instance installs Node.js 16 (compatible with Angular 13) and Nginx.
- The Angular app is built with `npm run build` and served from `/var/www/angular`.
- SPA routing is supported via `try_files ... /index.html;` in Nginx.
- If you set `security_group_id`, ensure the SG belongs to the same VPC as the subnet used by this stack (the VPC created here by default). AWS will reject cross-VPC attachments.
- If you provide `security_group_id` and do not specify `existing_vpc_id`, the module will infer the SG's VPC and place the instance (and any created subnet) there. In this case, it will not create a new Internet Gateway or route table; ensure your existing VPC/subnet has internet connectivity if needed.
