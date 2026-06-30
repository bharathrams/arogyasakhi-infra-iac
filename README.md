# infra-iac

Infrastructure as Code (Terraform) for the Arogya Sakhi platform on **AWS
ap-south-1 (Mumbai)** — all data stays in India (DPDP Act 2023). Standards:
[`.claude/CLAUDE.md`](./.claude/CLAUDE.md).

## Layout
```
modules/         reusable building blocks
  network/       VPC, public/private subnets, NAT, IGW
  rds-postgres/  managed PostgreSQL (encrypted, Multi-AZ option)
  redis/         ElastiCache (Redis)
  s3/            encrypted, versioned object storage
  ecs-cluster/   ECS Fargate cluster
  ecs-service/   one Fargate service (reused per microservice)
environments/
  dev/ staging/ prod/   one root config per environment
versions.tf      Terraform + provider versions
```

## Usage
```bash
cd environments/dev
cp terraform.tfvars.example terraform.tfvars   # fill in values
terraform init      # uses the S3 remote state backend
terraform plan
terraform apply     # gated by review/approval in CI for staging & prod
```

## Remote state
State is stored in an S3 bucket with a DynamoDB lock table (see `backend.tf` in
each environment). Bootstrap these once before the first `init` (see
`.claude/CLAUDE.md`). State is never committed.

## Secrets
No secrets in code. Database master credentials are managed by **AWS Secrets
Manager** (RDS `manage_master_user_password`). App secrets come from Secrets
Manager / SSM at deploy time.
