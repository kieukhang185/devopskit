# Epic 1 – Task 1: S3 bucket for Terraform remote state (dev)

This module creates a secure S3 bucket for storing Terraform state **for the dev environment**. It enables versioning, server-side encryption (SSE-S3), public access blocks, and sensible lifecycle rules. A KMS CMK will be added in a later task (E1-S10).

## Inputs
- `bucket_name` (string, required): Globally unique bucket name.
- `region` (string, default `ap-southeast-1`)
- `project` (string, default `devopskit`)
- `environment` (string, default `dev`)
- `owner`, `cost_center`, `compliance` (tags)

## Usage

```bash
cd repo/iac/envs/dev/bootstrap-s3
cat > terraform.tfvars <<EOF
bucket_name = "devopskit-dev-tfstate-<unique>"
owner       = "khang.kieu@endava.com"
cost_center = "devops"
EOF

terraform init
terraform apply -auto-approve
```

## Notes
- DynamoDB state locking is done in the **next task (E1-S2)**.
- Backend configuration (`backend.tf`) is applied in **E1-S3** after the bucket exists.
