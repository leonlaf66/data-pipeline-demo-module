# ECS Service Module

Fargate-based ECS services with ALB, HTTPS, Route53, and EFS support.

## Features

- ECS Cluster with Container Insights
- Fargate launch type (no capacity providers needed)
- Individual ALB per service with HTTPS support
- Route53 DNS records
- Shared EFS filesystem with per-service access points
- IAM roles for execution and tasks

## Usage

```hcl
module "streaming_services" {
  source = "../../../modules/ecs-service"

  app_name   = "myproject"
  environment    = "dev"
  aws_region     = "us-east-1"
  aws_account_id = "123456789012"

  vpc_id             = "vpc-xxx"
  private_subnet_ids = ["subnet-a", "subnet-b"]

  # HTTPS (optional)
  acm_certificate_arn = "arn:aws:acm:..."

  # Security
  alb_ingress_cidr_blocks = ["10.0.0.0/16"]

  services = {
    my-service = {
      image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:v1.0.0"

      cpu    = 1024
      memory = 2048

      container_port    = 8080
      health_check_path = "/health"

      enable_alb        = true
      alb_listener_port = 443

      enable_route53  = true
      route53_zone_id = "Z123..."

      efs_volumes = {
        data = {
          container_path = "/data"
          read_only      = false
        }
      }

      environment = [
        { name = "ENV_VAR", value = "value" }
      ]

      secrets = [
        { name = "SECRET", valueFrom = "arn:aws:secretsmanager:..." }
      ]
    }
  }
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| app_name | App name prefix | string | yes |
| environment | Environment name | string | yes |
| aws_region | AWS region | string | yes |
| aws_account_id | AWS account ID | string | yes |
| vpc_id | VPC ID | string | yes |
| private_subnet_ids | Private subnet IDs | list(string) | yes |
| services | Map of service configurations | map(object) | yes |
| acm_certificate_arn | ACM certificate ARN for HTTPS | string | no |
| alb_ingress_cidr_blocks | CIDRs allowed to access ALBs | list(string) | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | ECS cluster ID |
| cluster_name | ECS cluster name |
| services | Map of ECS service details |
| alb_dns_names | Map of ALB DNS names |
| route53_records | Map of Route53 FQDNs |
| efs_file_system_id | EFS filesystem ID |
| service_endpoints | Full endpoint URLs |

## Architecture

```
                    ┌─────────────────────────────────────────┐
                    │              Private VPC                 │
                    │                                          │
    HTTPS           │  ┌──────────┐     ┌──────────────────┐  │
    ────────────────┼─►│   ALB    │────►│  ECS Service     │  │
                    │  │(internal)│     │  (Fargate)       │  │
                    │  └──────────┘     └────────┬─────────┘  │
                    │        │                   │             │
                    │        ▼                   ▼             │
                    │  ┌──────────┐        ┌──────────┐       │
                    │  │ Route53  │        │   EFS    │       │
                    │  │ (A rec)  │        │          │       │
                    │  └──────────┘        └──────────┘       │
                    │                                          │
                    └─────────────────────────────────────────┘
```
