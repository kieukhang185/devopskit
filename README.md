# DevOpsKit – AWS Multi-Environment Platform with Todo App

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
```

### 4. Deploy Environment
```bash
cd iac/envs/dev
terraform init
terraform apply
```

This provisions networking, IAM roles, EC2 (web/api/db/monitoring), ALB, and observability stack.

### 5. Verify
- `terraform output alb_dns_name` → visit in browser.
- Login via `/auth/signup` + `/auth/login` endpoints.
- Check logs in **CloudWatch Logs** and metrics in **Grafana**.

---

## 📚 Documentation
- [Dev Setup Guide](docs/dev-setup.md)
- [Architecture Diagram](docs/diagrams/)
- [Onboarding Guide](docs/onboarding-guide.md)
- [Tagging Policy](docs/tagging-policy.md)

---

## 🤝 Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md).
CODEOWNERS enforces team review per module/service.

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
