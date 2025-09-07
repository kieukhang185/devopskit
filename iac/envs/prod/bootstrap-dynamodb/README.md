# Epic 1 – Task 2: DynamoDB table for Terraform state locking (dev)

Creates a DynamoDB table used by Terraform's S3 backend to perform **state locking**.

## Inputs
- `table_name` (string, default `devopskit-dev-tflock`)
- `region` (string, default `ap-southeast-1`)
- Tagging variables: `project`, `environment`, `owner`, `cost_center`, `compliance`

## Usage

```bash
cd repo/iac/envs/dev/bootstrap-dynamodb

terraform init
terraform apply -auto-approve
```

## Next step (E1-S3)
After the S3 bucket (E1-S1) and this table are created, configure your **backend** in dev with a `backend.tf` like:

```hcl
terraform {
  backend "s3" {
    bucket         = "<your-s3-bucket-name>"     # from E1-S1 output
    key            = "envs/dev/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "devopskit-dev-tflock"      # or your chosen name
    encrypt        = true
  }
}
```

Then run:
```bash
terraform init -migrate-state
```
This will move local state (if any) to the remote S3 backend with DynamoDB **state locking** enabled.
```
