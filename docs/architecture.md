# Architecture Diagram

```mermaid
flowchart TD
    GH[GitHub Repository] --> GA[GitHub Actions]
    GA -->|OIDC| AWS[IAM Role in AWS]
    GA --> ECR[Amazon ECR]
    GA --> TF[Terraform Apply]

    subgraph VPC
      ALB[Application Load Balancer]
      ECS[ECS Cluster / Fargate Service]
      SM[Secrets Manager]
      RDS[(Amazon RDS PostgreSQL)]
    end

    ALB --> ECS
    ECS --> SM
    ECS --> RDS
    ECR --> ECS
```

## High-level explanation

- Developers push code to GitHub.
- GitHub Actions deploys to `test` or `prod` depending on the branch.
- The application image is stored in ECR.
- Terraform provisions or updates the infrastructure.
- ECS Fargate runs the containerized application.
- Secrets Manager stores sensitive values.
- RDS runs in private subnets.
