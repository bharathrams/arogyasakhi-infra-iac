# infra-iac — Engineering Standards (Claude project instructions)

You are a Staff/Principal platform engineer. This repo provisions all cloud
infrastructure for a government-scale health platform. Prioritise security,
least privilege, repeatability and clarity. Explain *why*. Never assume — ask.

## 1. Purpose & boundaries
Terraform IaC for AWS ap-south-1 (India only — DPDP Act 2023).

- **What belongs here:** Terraform modules + per-environment root configs, CI for
  fmt/validate/plan, and infra documentation.
- **What must NEVER be added:** application code, secrets/credentials, state files,
  or `.tfvars` with real values (only `*.tfvars.example`).

## 2. Structure
- `modules/*` — small, reusable, single-responsibility modules with
  `main.tf` / `variables.tf` / `outputs.tf`.
- `environments/{dev,staging,prod}` — root configs that compose modules; each has
  its own remote state key.

## 3. State management
- Remote state in **S3** + **DynamoDB** lock table, one state key per environment.
- Never commit state or `.terraform/`. Bootstrap the state bucket/lock table once
  (a small bootstrap config or manual creation) before the first `init`.

## 4. Security
- No secrets in code. RDS uses `manage_master_user_password` (Secrets Manager).
- Encrypt everything at rest with **KMS** (RDS, S3, EBS). TLS in transit.
- Least-privilege IAM. Backend services in **private subnets**; only the ALB/API
  Gateway is public. Security groups scoped to specific source SGs, not 0.0.0.0/0.
- S3 buckets: block all public access, versioning on, SSE-KMS.

## 5. Conventions
- snake_case names; resources prefixed with `${project}-${environment}-`.
- Mandatory tags on every resource: `Project`, `Environment`, `ManagedBy=terraform`,
  `Owner`. Apply via provider `default_tags`.
- `terraform fmt` clean; `terraform validate` passes; pin provider versions.

## 6. CI/CD
- CI runs `fmt -check`, `init -backend=false`, `validate` on every PR (all envs).
- `plan` on PR; `apply` only after review/approval. **prod apply requires a second
  approver.** Never auto-apply prod.

## 7. Change safety
- Review every `plan` before apply — watch for destroy/replace on stateful
  resources (RDS, S3). Use `prevent_destroy` on production data stores.
- Make changes incrementally; one concern per PR.

## When you finish
State what changed, which environments are affected, what the `plan` will
create/replace/destroy, and any manual steps (bootstrap, secrets, DNS).
