# Contributing to DevOpsKit

Thank you for your interest in contributing! 🎉

This document outlines the process for contributing to the DevOpsKit project.

---

## 1. Code of Conduct
All contributors must follow the [Contributor Covenant](https://www.contributor-covenant.org/). Be respectful, collaborative, and inclusive.

---

## 2. Getting Started

1. Fork the repo and clone locally.
2. Set up your [Dev Environment](docs/dev-setup.md).
3. Create a new feature branch:
   ```bash
   git checkout -b feature/my-feature
   ```

---

## 3. Development Workflow

- **Infrastructure (Terraform)**:
  - Run `terraform fmt`, `terraform validate`, and `tflint` before committing.
  - Run `tfsec` or `checkov` for security checks.
- **Code Style**:
  - Follow existing naming conventions (e.g., `<env>-<service>-<purpose>`).
  - Use required tags: `Environment`, `Service`, `Owner`, `CostCenter`, `Compliance`, `Backup`.

---

## 4. Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):
```
feat(module): add vpc endpoints
fix(ci): correct CodeBuild role policy
docs(readme): update quick start
```

---

## 5. Pull Requests

1. Push your branch and open a PR to `main`.
2. Ensure the PR includes:
   - `terraform plan` output (as comment or artifact).
   - Security scan results (`tflint`, `tfsec`).
3. Request review from at least **one CODEOWNER**.
4. PR will be merged once checks pass and approval is granted.

---

## 6. Testing Changes

- Use `dev` environment for initial testing.
- Promote changes to `stage` and `prod` only via CI/CD pipeline after approval.

---

## 7. Documentation

- All major changes require an ADR in `docs/adr/`.
- Update runbooks or setup docs if workflows change.

---

✅ Thank you for contributing to DevOpsKit!
