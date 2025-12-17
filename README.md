# data-pipeline Demo Modules

Terraform modules for building a secure, auditable AWS Data Lake platform.

## Modules

| Module | Description |
|--------|-------------|
| [storage](./storage) | S3 Data Lake with MNPI/Public isolation, Glue Catalog, CloudTrail |
| [database](./database) | PostgreSQL RDS with CDC-enabled parameters |
| [msk](./msk) | Amazon MSK cluster with SCRAM auth and NLB endpoint |
| [msk-connect](./msk-connect) | MSK Connect connectors (Debezium source, S3 sink) |
| [kafka-data-plane](./kafka-data-plane) | Kafka topics and ACLs |
| [athena](./athena) | Athena workgroups with role-based access control |
| [ecs-service](./ecs-service) | ECS Fargate services with ALB and EFS |
| [sg-ingress](./sg-ingress) | Security group ingress rules helper |

## Architecture

**Data Pipeline:**
```
                         Schema Registry
                      (schema management)
                              │
                              ▼
PostgreSQL ──▶ Debezium ──▶ MSK ──▶ S3 Sink ──▶ S3 Data Lake ◀── Athena
 (database)  (msk-connect)  (msk)  (msk-connect)   (storage)     (athena)
                                                        │
                                                        ▼
                                                  Glue Catalog
                                                   (storage)
```

**Platform Services (ECS Fargate - ecs-service):**
```
┌─────────────────┬─────────────────┬─────────────────┬─────────────────┐
│ Schema Registry │  Cruise Control │   Prometheus    │  Alertmanager   │
│ (schema mgmt)   │ (cluster mgmt)  │  (metrics)      │   (alerting)    │
└─────────────────┴─────────────────┴─────────────────┴─────────────────┘
```

**Data Isolation:**
```
MNPI Zone (sensitive)              Public Zone (non-sensitive)
├── cdc.*.mnpi (topics)            ├── cdc.*.public (topics)
├── raw_mnpi (S3)                  ├── raw_public (S3)
├── curated_mnpi (S3)              ├── curated_public (S3)
├── analytics_mnpi (S3)            ├── analytics_public (S3)
└── KMS: kms_mnpi                  └── KMS: kms_public
```

## Usage

```hcl
module "storage" {
  source = "git::https://github.com/leonlaf66/data-pipeline-demo-module.git//storage?ref=v1.0.0"

  app_name   = "data-pipeline-demo"
  env        = "dev"
  # ...
}
```

## Stack Structure

```
infra stack (deploy first)
├── storage   - S3 buckets, Glue databases, CloudTrail
├── database  - PostgreSQL RDS
└── msk       - MSK cluster with NLB

data-plane stack (depends on infra)
├── kafka-data-plane  - Topics and ACLs
├── msk-connect       - Debezium + S3 Sink connectors
├── ecs-service       - Schema Registry, monitoring
└── athena            - Query workgroups
```

## Requirements

- Terraform >= 1.5.0
- AWS Provider ~> 5.0
- Kafka Provider ~> 0.5.4 (for kafka-data-plane)

## Security Features

- **Encryption**: KMS at-rest (separate keys for MNPI/Public), TLS in-transit
- **Authentication**: SCRAM-SHA-512 for Kafka, IAM for AWS services
- **Authorization**: MNPI/Public data isolation, RBAC via Athena workgroups
- **Auditing**: CloudTrail for S3 data access events
- **Network**: Private subnets only, security group isolation
- **Compliance**: MFA enforcement for MNPI data access
