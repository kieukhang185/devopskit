# Tagging Policy

All AWS resources in the DevOpsKit project must be tagged consistently.
This ensures visibility, cost tracking, compliance, and automation.

---

## Required Tags

| Key        | Values                                | Purpose                          |
|------------|---------------------------------------|----------------------------------|
| Environment | dev, stage, prod                      | Identifies environment           |
| Service     | web, api, db, monitoring, ci, bastion | Identifies owning service        |
| Owner       | <email/alias>                         | Contact point for resource       |
| CostCenter  | <id>                                  | Cost allocation tracking         |
| Compliance  | internal, public                      | Compliance classification        |
| Backup      | true, false                           | Determines backup requirement    |

---

## Rules
1. **Every resource** created via Terraform inherits these tags.
2. Modules **must not** overwrite required tags; they may **add** `extra_tags`.
3. Environments keep their own values for `Environment` + `Owner` + `CostCenter`.
4. CI/CD runs fail if tags are missing/invalid (via Terraform validation).

---

## Examples

**EC2 instance in dev for api service:**

```hcl
tags = {
  Environment = "dev"
  Service     = "api"
  Owner       = "team@example.com"
  CostCenter  = "1234"
  Compliance  = "internal"
  Backup      = "true"
}
```

**S3 bucket in prod for logging service:**

```hcl
tags = {
  Environment = "prod"
  Service     = "logging"
  Owner       = "security@example.com"
  CostCenter  = "5678"
  Compliance  = "public"
  Backup      = "false"
}
```

---

## Enforcement

- Terraform modules must include a `var.tags` map.
- CI checks (`tflint` / `terraform validate`) will fail if required tags are missing.
- Tag keys are **case-sensitive**.
