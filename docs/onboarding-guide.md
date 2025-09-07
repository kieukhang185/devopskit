# Onboarding Guide for Contributors

Welcome to the **DevOpsKit** project! 🎉  
This guide will help new contributors quickly get started.

---

## 1. Overview

DevOpsKit is a reference AWS DevOps project aligned with the **AWS DevOps Engineer – Professional** exam.  
It provisions a **multi-environment platform (dev/stage/prod)** using Terraform, with built-in CI/CD, monitoring, security, and DR.

---

## 2. Prerequisites

Before contributing, ensure you have:

- AWS account with required permissions (sandbox preferred).
- Installed tools:
  - Terraform (>= 1.5)
  - AWS CLI v2
  - Git
  - jq
  - Docker (optional, for builds/tests)
- Clone the repository:
  ```bash
  git clone https://github.com/kieukhang185/devopskit.git
  cd devopskit
  ```

---

## 3. First Steps

1. Follow the [Dev Environment Setup Guide](dev-setup.md).
2. Deploy the **dev environment** using Terraform.
3. Verify access to:
   - ALB DNS (web service).
   - CloudWatch Logs (for EC2 logs).
   - SSM Session Manager (for EC2 access).

---

## 4. Contribution Workflow

1. Create a new branch from `main`:
   ```bash
   git checkout -b feature/my-feature
   ```
2. Make your changes and test locally (`terraform plan`, `terraform apply` in `dev`).
3. Run checks:
   - `terraform fmt`
   - `terraform validate`
   - `tflint`
   - `tfsec` or `checkov`
4. Commit with a [Conventional Commit](https://www.conventionalcommits.org/) message.
5. Open a Pull Request against `main`.
6. Request review from **CODEOWNERS**.

---

## 5. Documentation Expectations

- Major changes → add/update **ADR** in `docs/adr/`.
- Infra modules → must include `README.md` with inputs/outputs.
- Scripts & runbooks → stored in `docs/runbooks/`.

---

## 6. Support

- Tag `@kieukhang185` in PRs for reviews.
- Report issues via GitHub Issues.

---

✅ You are now ready to contribute to DevOpsKit!
