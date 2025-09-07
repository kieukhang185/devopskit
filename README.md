# DevOpsKit – AWS Multi-Environment Platform

## 📌 Overview
DevOpsKit is a reference AWS DevOps project aligned with the **AWS DevOps Engineer – Professional** exam.  
It provisions a **multi-environment (dev/stage/prod) platform** on AWS using **Terraform-first infrastructure**, with:

- Immutable compute (EC2 for web, api, db, monitoring, ci/bastion).
- CI/CD (AWS CodePipeline/CodeBuild/CodeDeploy).
- Centralized logging & observability (CloudWatch, Prometheus, Grafana).
- Security by design (IAM, KMS, SSM, Secrets Manager).
- Resilience, cost controls, and disaster recovery workflows.

This repository acts as a blueprint for real-world enterprise DevOps setups.

---

## 🏗️ Architecture
- **Networking**: VPC per env, 2–3 AZs, public/private/data subnets.
- **Compute**: 
  - `web`: Nginx reverse proxy/static
  - `api`: App runtime (Node/Go/Python)
  - `db`: PostgreSQL/MySQL on EC2
  - `monitoring`: Prometheus, Grafana, Alertmanager
  - `ci`: Jenkins or AWS Code* services
  - `bastion`: optional (prefer SSM Session Manager)
- **Routing**: Route53 → ALB → ASGs (web/api) → db.
- **Security**: IAM roles per service, KMS for S3/EBS/Secrets, GuardDuty, CloudTrail.
- **Observability**: CloudWatch Logs & metrics, S3 archival, Athena queries, Grafana dashboards.

---

## 🚀 Quick Start

### 1. Prerequisites
- AWS account with admin-level access (sandbox).
- Terraform ≥ 1.5.
- AWS CLI configured (`aws configure`).
- (Optional) Docker & jq for tooling.

### 2. Clone Repository
```bash
git clone https://github.com/<your-org>/devopskit.git
cd devopskit
```

### 3. Bootstrap Backend
Set up the **S3 + DynamoDB** for Terraform remote state (one-time per environment):
```bash
cd iac/envs/dev
terraform init
terraform apply -target=module.backend
```

### 4. Deploy Environment
Provision the full dev stack:
```bash
cd iac/envs/dev
terraform init
terraform apply
```

This will create VPC, subnets, IAM roles, EC2 instances, ALB, monitoring stack, etc.

### 5. Verify Deployment
- `terraform output` → check ALB DNS name.
- Visit `http://<alb-dns>` to see the **web service**.
- Use SSM Session Manager for access (`aws ssm start-session ...`).

---

## 📚 Documentation
- [Architecture Diagram](docs/diagrams/)
- [Runbooks](docs/runbooks/)
- [Onboarding Guide](docs/onboarding.md)
- [ADR Records](docs/adr/)

---

## 🤝 Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md).  
All resources must be tagged per [tagging policy](docs/tagging-policy.md).

---

## 📌 Status
- [x] Infra Foundation
- [x] Compute & ALB
- [x] CI/CD Pipeline
- [ ] Observability (in progress)
- [ ] Security & DR

---

## 🧩 Repo Layout
```
repo/
  app/           # web, api, tests
  iac/           # Terraform (modules + envs)
  ci/            # CI/CD (CodePipeline or Jenkins)
  docs/          # Diagrams, runbooks, onboarding
```
