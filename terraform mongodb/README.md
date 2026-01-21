# MongoDB EC2 with Terraform

This stack provisions a new Ubuntu EC2 instance, sets up minimal networking, opens MongoDB (`27017`) and SSH (`22`), and installs MongoDB 7 via user data.

## Files
- `versions.tf`: Provider requirements and AWS region provider.
- `variables.tf`: Tunable settings (CIDRs, instance type, ports, tags, key).
- `main.tf`: VPC, subnet, IGW, route table, security group, EC2 instance.
- `templates/user_data.sh`: Installs and configures MongoDB to listen on all interfaces.
- `outputs.tf`: Useful identifiers and endpoints.

## Quick start

1. Initialize:
```bash
terraform init
```

2. Preview:
```bash
terraform plan -var="aws_region=us-east-1" -var="key_name=<your-key>"
```

3. Apply:
```bash
terraform apply -auto-approve -var="aws_region=us-east-1" -var="key_name=<your-key>"
```

4. Connect from your app:
- Ensure security group allows your client IP in `allowed_mongo_cidr` (defaults to `0.0.0.0/0`, which is open; tighten for production).
- Connection string example: `mongodb://<public_ip>:27017`.

5. Destroy when done:
```bash
terraform destroy -auto-approve
```

## Notes
- AMI: Ubuntu 22.04 (Jammy) latest from Canonical.
- MongoDB bind address is set to `0.0.0.0`. Restrict access via `allowed_mongo_cidr`.
- If `key_name` is omitted, you can use Session Manager if your account policies allow it. Otherwise, set an existing EC2 key pair.
