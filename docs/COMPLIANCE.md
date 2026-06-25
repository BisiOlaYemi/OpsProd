# Compliance mapping

This baseline implements controls aligned with **CIS Cloud Foundations** and **CIS Docker Benchmark** patterns. It is not a certification — adapt to your auditor's requirements.

## AWS (CIS AWS Foundations v1.4)

| Control area | Implementation |
|--------------|----------------|
| Logging | Multi-region CloudTrail, log file validation, encrypted S3 audit bucket |
| Monitoring | GuardDuty, Security Hub (CIS + FSBP standards) |
| Networking | Multi-AZ VPC, locked default SG, VPC endpoints, flow logs |
| Encryption | KMS with rotation, EBS encryption by default |
| Identity | Strict account password policy |
| Storage | S3 public access block (account + bucket), SSE-KMS, versioning |

## GCP

| Control area | Implementation |
|--------------|----------------|
| Networking | Custom VPC, private Google access, default-deny firewall, VPC flow logs |
| Encryption | CMEK key ring with 90-day rotation |
| Logging | Cloud Audit log sink to encrypted GCS bucket |
| IAM | Custom least-privilege Terraform deployer role |
| Storage | Uniform bucket-level access, versioning, lifecycle |

## Azure

| Control area | Implementation |
|--------------|----------------|
| Secrets | Key Vault with RBAC, purge protection, soft delete |
| Storage | HTTPS-only, no public blob access, GRS, diagnostic settings |
| Networking | NSG default deny Internet, VNet flow logs + Traffic Analytics |
| Monitoring | Log Analytics workspace, Defender for Cloud (VM + Storage) |
| Governance | Azure Policy assignments for HTTPS and public access |

## Docker (CIS Docker Benchmark patterns)

| Control area | Implementation |
|--------------|----------------|
| 4.1 Non-root user | FastAPI on UID 10001, nginx-unprivileged on UID 101 |
| 4.5 Content trust | Pin base image digests in production |
| 5.x Runtime | `read_only`, `cap_drop: ALL`, `no-new-privileges`, `pids_limit` |
| 5.15 Central logging | Uvicorn stdout, nginx access/error to stdout/stderr |
| Image minimization | Multi-stage builds, slim runtime, docs disabled on API |

## Continuous verification

CI enforces:
- `terraform fmt` / `validate`
- Checkov (1000+ policies + custom CloudTrail rule)
- Trivy (IaC + container CVEs)
- Hadolint (Dockerfile lint)
- Gitleaks (secret scanning)

Run locally:

```bash
pre-commit install
pre-commit run --all-files
```
