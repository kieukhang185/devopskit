# Epic 1 – Task 3: Configure backend.tf for dev

1) Edit `backend.tf` and replace:
   - `bucket` with your S3 bucket from **E1-S1**.
   - `dynamodb_table` if you used a different name than `devopskit-dev-tflock` in **E1-S2**.

2) From your dev working directory where you keep Terraform code (e.g., `repo/iac/envs/dev`):
   ```bash
   terraform init -migrate-state
   ```

This migrates any local state to the S3 backend and enables DynamoDB state locking.
