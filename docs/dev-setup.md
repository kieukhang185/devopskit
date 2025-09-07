# Dev Environment Setup Guide

This guide helps you set up your **local development environment** for the DevOpsKit project.

---

## 1. Prerequisites

### OS
- Linux (Ubuntu/Debian) or macOS preferred.
- Windows users should use **WSL2** with Ubuntu.

### Required Tools
Install the following:

| Tool | Minimum Version | Install Notes |
|------|-----------------|---------------|
| [Terraform](https://developer.hashicorp.com/terraform/downloads) | 1.5+ | Required for infra deployment |
| [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) | latest | Used for auth, SSM sessions, checks |
| [Git](https://git-scm.com/) | 2.30+ | Source control |
| [jq](https://stedolan.github.io/jq/) | latest | JSON parsing for scripts |
| [Docker](https://docs.docker.com/get-docker/) | 20+ | Optional, for local builds/tests |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | latest | (Optional) Used if exploring EKS extension |

---

## 2. AWS Account Setup

1. Create/obtain an **AWS account** (sandbox preferred).
2. Configure AWS CLI:
   ```bash
   aws configure
   ```
   Provide:
   - Access Key ID
   - Secret Access Key
   - Default region: `ap-southeast-1`
   - Output format: `json`

3. Verify:
   ```bash
   aws sts get-caller-identity
   ```

---

## 3. Repository Setup

Clone the repo:

```bash
git clone https://github.com/<your-org>/devopskit.git
cd devopskit
```

---

## 4. Terraform Backend Bootstrap

Each environment (`dev`, `stage`, `prod`) requires a remote backend (S3 + DynamoDB).

For `dev`:
```bash
cd iac/envs/dev
terraform init
terraform apply -target=module.backend
```

For `stage`/`prod`, repeat inside `iac/envs/stage` or `iac/envs/prod`.

---

## 5. Deploying the Environment

Deploy `dev` stack:
```bash
cd iac/envs/dev
terraform init
terraform apply
```

This provisions:
- VPC + subnets
- IAM roles
- EC2 instances (web/api/db/monitoring)
- ALB + target groups
- CloudWatch log groups
- S3 log bucket

---

## 6. Post-Deployment

- Get ALB DNS:
  ```bash
  terraform output alb_dns_name
  ```
  Visit `http://<alb-dns>` in browser.

- Connect via **SSM Session Manager**:
  ```bash
  aws ssm start-session --target <instance-id>
  ```

- Logs: available in **CloudWatch Logs**.

---

## 7. Optional Tools

- **VS Code Extensions**: Terraform, AWS Toolkit, Markdown All-in-One.
- **tfenv**: Manage multiple Terraform versions.
- **direnv**: Auto-load environment variables per folder.

---

## 8. Troubleshooting

- Run `terraform validate` and `terraform fmt` before commits.
- If backend errors: check S3 bucket + DynamoDB exist.
- If `apply` fails: run `terraform plan` to debug changes.
- Check IAM permissions if AWS calls are denied.

---

✅ At this point, your local dev environment is ready for contributing!
