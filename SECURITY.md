# Security Policy

## Supported versions

| Version | Supported |
|---------|-----------|
| main    | yes       |

## Reporting a vulnerability

**Do not open public GitHub issues for security vulnerabilities.**

Email: security@DOMAIN.com (to be replaced before publishing)

Include:
- Description of the issue and potential impact
- Steps to reproduce
- Affected paths (Terraform module, Dockerfile, etc.)

We aim to acknowledge reports within **3 business days** and provide a remediation timeline within **10 business days**.

## Scope

In scope:
- Terraform modules under `terraform/`
- Dockerfiles and compose files under `docker/`
- GitHub Actions workflows under `.github/`

Out of scope:
- Cloud accounts you deploy this into (your IAM boundaries and secrets handling)
- Third-party base images (report upstream; we track CVEs via Trivy in CI)

## Secure deployment expectations

- Use remote encrypted state with locking (see `terraform/*/backend.tf`)
- Never commit `*.tfvars` with real credentials
- Assume a dedicated deployment role/SP with least privilege
- Review Checkov/Trivy failures before merging
