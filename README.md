# PagerDuty CSG Innovation Team - Take Home Exercise

This repository contains a complete reference solution for the PagerDuty Customer Success Group Innovation Team take-home exercise.

## What this solution includes

- **Terraform** for AWS infrastructure provisioning
- **Reusable Terraform modules** for networking, security, secrets, RDS, ECR, and ECS
- **Two environments**: `test` and `prod`
- **GitHub Actions** pipeline for automated deployment
- **Single Git repository** for both infrastructure and application code
- **Branch-based deployment strategy**
  - `develop` → deploy to **test**
  - `main` → deploy to **prod**
- **Tagging policy**: every resource is tagged with `name=csgtest`

## Architecture

This solution uses:

- **Amazon ECS Fargate** for the containerized application
- **Application Load Balancer** for inbound HTTP traffic
- **Amazon RDS PostgreSQL** in private subnets
- **AWS Secrets Manager** to store database credentials / application secrets
- **Amazon ECR** to store container images
- **GitHub Actions with OIDC** to authenticate to AWS without long-lived AWS keys
- **Remote Terraform state** in S3 with DynamoDB locking (bootstrapped once)

## Repository structure

```text
.
├── app/
│   ├── Dockerfile
│   ├── package.json
│   └── server.js
├── docs/
│   └── architecture.md
├── infra/
│   ├── bootstrap/
│   │   └── main.tf
│   ├── envs/
│   │   ├── test/
│   │   └── prod/
│   └── modules/
│       ├── ecr/
│       ├── ecs/
│       ├── network/
│       ├── rds/
│       ├── secrets/
│       └── security/
└── .github/
    └── workflows/
        └── deploy.yml
```

## Branching strategy

- `feature/*` → feature branches
- `develop` → testing environment
- `main` → production environment

Typical flow:
1. Develop on a feature branch
2. Open a PR to `develop`
3. Merge to `develop` to deploy to **test**
4. Validate changes
5. Open a PR from `develop` to `main`
6. Merge to `main` to deploy to **prod**

## Deployment flow

1. A push to `develop` or `main` triggers GitHub Actions
2. The workflow determines the target environment
3. The app image is built and pushed to ECR
4. Terraform runs against the selected environment directory
5. ECS service is updated with the new image tag

## One-time bootstrap

Before using the main pipeline, provision:
- S3 bucket for Terraform state
- DynamoDB table for Terraform locking
- ECR repository

```bash
cd infra/bootstrap
terraform init
terraform apply -auto-approve \
  -var aws_region=us-east-1 \
  -var project_name=pagerduty-csg \
  -var repository_name=hello-world-app
```

## GitHub repository configuration

Set the following **repository variables**:

- `AWS_REGION`
- `TF_STATE_BUCKET`
- `TF_LOCK_TABLE`
- `ECR_REPOSITORY_NAME`

Set the following **repository secret** if needed:
- `AWS_ROLE_ARN` (or define as a repository variable if you prefer)

> Recommended: use GitHub Actions **OIDC** with an IAM role instead of storing static AWS credentials.

## Required GitHub Actions permissions

The workflow uses:

- `id-token: write`
- `contents: read`

## Terraform usage

### Test
```bash
cd infra/envs/test
terraform init -backend-config=backend.hcl
terraform plan -var="image_tag=dev-local"
terraform apply -auto-approve -var="image_tag=dev-local"
```

### Prod
```bash
cd infra/envs/prod
terraform init -backend-config=backend.hcl
terraform plan -var="image_tag=prod-local"
terraform apply -auto-approve -var="image_tag=prod-local"
```

## Security decisions

- ECS tasks run in **private subnets**
- RDS runs in **private subnets only**
- The ALB is the only internet-facing component
- Security groups enforce least-privilege traffic flow:
  - Internet → ALB : 80/443
  - ALB → ECS : app port
  - ECS → RDS : 5432
- Secrets are stored in **AWS Secrets Manager**
- GitHub Actions authenticates to AWS via **OIDC**
- Terraform state is stored remotely and locked

## Demo checklist

Before the interview:

- [ ] Apply `infra/bootstrap`
- [ ] Configure GitHub OIDC role in AWS
- [ ] Push repo to GitHub
- [ ] Set repository variables / secrets
- [ ] Merge a change into `develop`
- [ ] Validate deployment in **test**
- [ ] Merge the same change into `main`
- [ ] Validate deployment in **prod**
- [ ] Be ready to explain security groups, IAM roles, module reusability, and branch-based CI/CD

## What to explain during the interview

1. **Why Fargate**
   - removes EC2 management overhead
   - good default for a small, container-based demo

2. **Why separate environment directories instead of CLI workspaces**
   - safer separation
   - clearer pipeline behavior
   - easier to review and troubleshoot

3. **Why OIDC**
   - avoids long-lived AWS access keys in GitHub

4. **Why modules**
   - consistent, reusable infrastructure patterns
   - easier expansion later

5. **How the solution can evolve**
   - TLS/HTTPS on the ALB
   - autoscaling policies
   - WAF
   - RDS Multi-AZ
   - private ECS image scanning gates
   - Terraform fmt/validate/tflint/checkov in pipeline

## Notes

This repository is intentionally small enough for a take-home exercise, but structured as a production-oriented starting point.
