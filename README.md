# AWS Multi-Environment Platform with Todo App

## 📌 Overview
DevOpsKit is a production-like AWS DevOps project for ToDo WebApp.
It provisions a **multi-environment (dev/stage/prod) platform** on AWS using **Terraform-first infrastructure**, with:

- Immutable compute on EC2 (web, api, db, monitoring, ci).
- CI/CD with **AWS CodePipeline/CodeBuild/CodeDeploy** (no Jenkins).
- Centralized logging & observability (CloudWatch, Prometheus, Grafana).
- Security by design (IAM, KMS, SSM, Secrets Manager).
- Resilience, cost controls, and disaster recovery workflows.

A reference **multi-user Todo web app** is included to demonstrate concurrency (OCC/versioning, idempotency, transactions, WebSocket updates).

---

## 🏗️ Architecture
- **Networking**: VPC per env, 2–3 AZs, public/private/data subnets.
- **Compute**:
  - `web`: Nginx/Caddy reverse proxy + static frontend.
  - `api`: REST API (auth, lists, items) with concurrency safety.
  - `db`: PostgreSQL on EC2 (snapshots + retention policy).
  - `monitoring`: Prometheus, Grafana, Alertmanager.
  - `ci`: CodePipeline/CodeBuild/CodeDeploy services.
- **Routing**: Route53 → (optional WAF) → ALB → ASGs (web/api) → db EC2.
- **Security**: IAM roles per service, KMS for EBS/S3/Secrets, GuardDuty, CloudTrail.
- **Observability**: CloudWatch Logs & metrics, S3 archival + Athena queries, Grafana dashboards.

---

## 📝 Application (Todo App)
The bundled Todo app demonstrates concurrency-safe design:
- JWT-based auth (`/auth/signup`, `/auth/login`).
- CRUD for lists/items with optimistic concurrency control (OCC).
- Safe retries via **Idempotency-Key**.
- Real-time updates via **WebSockets**.
- PostgreSQL schema with versioning + uniqueness validation.
- Unit, integration, and load tests (20+ concurrent clients).

---

## 🚀 Quick Start

### 1. Prerequisites
- AWS account (sandbox recommended).
- Terraform ≥ 1.5.
- AWS CLI v2 (`aws configure`).
- Git, jq, (optional) Docker.

### 2. Clone Repository
```bash
git clone https://github.com/kieukhang185/devopskit.git
cd devopskit
```

### 3. Bootstrap Backend
Setup remote state (S3 + DynamoDB) per environment:
```bash
cd iac/envs/dev
terraform init
terraform apply -target=module.backend
or
make tf-backend-bootstrap
```

### 4. Deploy Environment
```bash
cd iac/envs/dev
terraform init
terraform apply
or
make tf-up # tf-plan + tf-validate + tf-fmt
```

This provisions networking, IAM roles, EC2 (web/api/db/monitoring), ALB, and observability stack.

### 5. Verify
- `terraform output alb_dns_name` → visit in browser.
- Login via `/auth/signup` + `/auth/login` endpoints.
- Check logs in **CloudWatch Logs** and metrics in **Grafana**.

---

## Key Variables

You can override any of these at runtime, e.g. `make tf-plan ENV=stage`.

| Variable           | Default                          | Purpose |
| ---                | ---                              | --- |
| `ENV`              | `dev`                            | Environment selector (`dev`, `stage`, `prod`) |
| `AWS_REGION`       | `ap-south-1`                      | AWS region for Terraform operations |
| `IAC_DIR`          | `iac/envs/$(ENV)`                | Path to the environment folder |
| `TF_STATE_BUCKET`  | `devopskit-$(ENV)-tfstate-123abc`| Remote state bucket name (must be globally unique) |
| `TF_LOCK_TABLE`    | `devopskit-$(ENV)-tflock`        | DynamoDB table for state locking |
| `TF_IN_AUTOMATE`   | `-input=false -no-color`         | Non-interactive Terraform flags |
| `TF_VAR_FLAGS`     | `-var=region=$(AWS_REGION)`      | Example TF variable wiring |

## Common Tasks


```bash
# Format all *.tf files (quiet if already formatted)
make tf-fmt

# Validate configuration (runs fmt first)
make tf-validate

# Create and review a plan
make tf-plan ENV=dev

# Apply changes (non-interactive)
make tf-apply ENV=dev

# Convenience: plan + apply
make tf-up ENV=dev

# Show outputs as JSON
make tf-output ENV=dev

# Check tags required
make tf-tags
```

## Remote Backend (S3 + DynamoDB)

### Bootstrap (one-time per env)
Creates the S3 bucket for Terraform state and DynamoDB table for state locking, then initializes the env to use the remote backend.

```bash
# 1) Create S3 (versioned) + DynamoDB lock table
make tf-backend-bootstrap ENV=dev   TF_STATE_BUCKET=devopskit-dev-tfstate-<unique>   TF_LOCK_TABLE=devopskit-dev-tflock

# 2) Initialize Terraform in the env to point at the remote backend
make tf-backend-init ENV=dev

# 3) Encrytion EBS
make tf-ebs-encryption ENV=dev
```

### Destroy Backend (safety-gated)

> ⚠️ Only do this **after** you’ve destroyed all Terraform-managed infra in the env.

```bash
# Destroy DDB + S3 (empties versioned bucket), requires explicit confirmation
make tf-backend-destroy ENV=dev   TF_STATE_BUCKET=devopskit-dev-tfstate-<unique>   TF_LOCK_TABLE=devopskit-dev-tflock   CONFIRM=YES
```

Granular targets are also available:
```bash
make destroy-backend-dynamodb ENV=dev TF_LOCK_TABLE=... CONFIRM=YES
make destroy-backend-s3       ENV=dev TF_STATE_BUCKET=... CONFIRM=YES
```

## Destroying Infrastructure

```bash
# Normal destroy (refuses to run if remote state key is missing)
make tf-destroy ENV=dev
```

If you wiped your `.terraform/` folder or changed the backend, re-wire first:

---

## 📚 Documentation
- [Dev Setup Guide](docs/dev-setup.md)
- [Architecture Diagram](docs/diagrams/)
- [Onboarding Guide](docs/onboarding-guide.md)
- [Tagging Policy](docs/tagging-policy.md)

---

## 🤝 Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md).
[CODEOWNERS](CODEOWNERS) enforces team review per module/service.

---

## 📌 Status
- [ ] Infra Foundation (VPC, IAM, KMS, backend).
- [ ] Compute (web/api/db/monitoring).
- [ ] CI/CD (CodePipeline/Build/Deploy).
- [ ] Todo App backend (auth, CRUD, OCC/idempotency).
- [ ] Todo App frontend (login, lists, items, reorder).
- [ ] Observability dashboards & alerts.
- [ ] Security runbooks & DR drills.

---

## 🧩 Repo Layout
```
repo/
  app/
    web/        # Frontend (static pages)
    api/        # REST API (Todo service)
    tests/      # Unit, integration, load tests
  iac/
    envs/
      dev/
      stage/
      prod/
    modules/    # vpc, asg, alb, iam, monitoring, logging, cicd, data
  ci/
    codepipeline/
  docs/
    runbooks/
    diagrams/
    dashboards/
```

---
