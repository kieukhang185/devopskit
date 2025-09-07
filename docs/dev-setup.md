# Dev Environment Setup Guide

This guide explains how to set up your **local development environment** for the DevOpsKit project.

---

## 1. Prerequisites

### OS
- Linux (Ubuntu/Debian) or macOS preferred.
- Windows users: use **WSL2** with Ubuntu.

### Required Tools
|        Tool       |   Version  |                Purpose              |
|-------------------|------------|-------------------------------------|
|      Terraform    |   >= 1.5   |        Infrastructure as Code       |
|      AWS CLI v2   |   latest   |      AWS auth + session manager     |
|         Git       |   >= 2.30  |            Source control           |
|         jq        |    latest  |             JSON parsing            |
|       Docker      |    >= 20   |     Optional (local builds/tests)   |
| Node.js/Python/Go | latest LTS | For Todo API runtime (choose stack) |

---

## 2. AWS Account Setup

1. Use a **sandbox AWS account**.
2. Configure AWS CLI:
   ```bash
   aws configure
   ```
   Provide:
   - Access Key ID + Secret Key
   - Region: `ap-southeast-1`
   - Output: `json`
3. Verify identity:
   ```bash
   aws sts get-caller-identity
   ```

---

## 3. Repository Setup

Clone the repo:
```bash
git clone https://github.com/kieukhang185/devopskit.git
cd devopskit
```

---

## 4. Terraform Backend Bootstrap

Each env uses **S3 (state) + DynamoDB (lock)**.

For `dev`:
```bash
cd iac/envs/dev
terraform init
terraform apply -target=module.backend
```

Repeat for `stage` and `prod` in their respective env dirs.

---

## 5. Deploying Infrastructure

Deploy full stack (dev):
```bash
cd iac/envs/dev
terraform init
terraform apply
```

Provisioned components:
- VPC + subnets + endpoints
- IAM roles + KMS
- EC2: web/api/db/monitoring
- ALB + target groups
- CloudWatch log groups
- S3 log bucket (archival)
- CodePipeline/Build/Deploy

---

## 6. Application (Todo App)

The app is split into **web** (frontend) and **api** (backend).

- API endpoints: `/auth/signup`, `/auth/login`, `/lists`, `/items`.
- Supports **OCC (ETag/version)** + **Idempotency-Key**.
- Real-time updates via WebSockets.

To test locally:
```bash
cd app/api
npm install    # or pip install -r requirements.txt
npm run dev    # or python app.py
```

---

## 7. Post-Deployment Verification

- Get ALB DNS:
  ```bash
  terraform output alb_dns_name
  ```
  Visit in browser.

- Signup/Login via API:
  ```bash
  curl -X POST https://<alb-dns>/auth/signup -d '{"email":"me@test.com","password":"secret"}'
  ```

- Access EC2 via **SSM** (no SSH keys required):
  ```bash
  aws ssm start-session --target <instance-id>
  ```

- Check logs in **CloudWatch Logs**.

---

## 8. Optional Tools

- **VS Code Extensions**: Terraform, AWS Toolkit, Markdown.
- **tfenv**: Manage multiple Terraform versions.
- **direnv**: Auto-load AWS env vars.

---

## 9. Troubleshooting

- Run `terraform fmt`, `terraform validate`, `tflint` before commits.
- If backend init fails: confirm S3 bucket + DDB table exist.
- If CodePipeline fails: check buildspec.yml and appspec.yml.
- OCC conflicts: ensure clients retry on **409 Conflict**.

---

✅ At this point your dev environment is fully set up!
