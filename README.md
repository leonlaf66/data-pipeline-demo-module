# Kraken Demo Modules

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

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                                     │
│   ┌─────────────────────────────────────────────────────────────────────────────────────────────┐   │
│   │                              ECS Fargate (ecs-service)                                      │   │
│   │     ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                 │   │
│   │     │   Schema     │  │   Cruise     │  │  Prometheus  │  │ Alertmanager │                 │   │
│   │     │  Registry    │  │  Control     │  │              │  │              │                 │   │
│   │     └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  └──────────────┘                 │   │
│   │            │ schema          │ manage          │ monitor                                    │   │
│   └────────────┼─────────────────┼─────────────────┼────────────────────────────────────────────┘   │
│                │                 │                 │                                                │
│                ▼                 ▼                 ▼                                                │
│   ┌─────────────────────────────────────────────────────────────────────────────────────────────┐   │
│   │                                    MSK Cluster (msk)                                        │   │
│   │                              SCRAM-SHA-512 Authentication                                   │   │
│   │                                 NLB + Route53 Endpoint                                      │   │
│   │         ┌──────────────────────────────────────────────────────────────────┐                │   │
│   │         │  Topics (kafka-data-plane): cdc.*.mnpi | cdc.*.public            │                │   │
│   │         └──────────────────────────────────────────────────────────────────┘                │   │
│   └───────────────────────────────────────┬─────────────────────────────────────────────────────┘   │
│                          ▲                │                 │                                       │
│                          │                │                 │                                       │
│   ┌──────────────────────┴───┐   ┌────────▼───────┐  ┌──────▼────────┐                             │
│   │   Debezium CDC Source    │   │ S3 Sink MNPI   │  │ S3 Sink Public│                             │
│   │     (msk-connect)        │   │ (msk-connect)  │  │ (msk-connect) │                             │
│   └──────────────────────────┘   └────────┬───────┘  └──────┬────────┘                             │
│                ▲                          │                 │                                       │
│                │ CDC                      │                 │                                       │
│   ┌────────────┴─────────┐                ▼                 ▼                                       │
│   │   PostgreSQL RDS     │   ┌──────────────────────────────────────────────────────────────────┐   │
│   │     (database)       │   │                    S3 Data Lake (storage)                        │   │
│   │                      │   │                                                                  │   │
│   │  - trades (MNPI)     │   │    ┌────────────────────┐      ┌────────────────────┐           │   │
│   │  - orders (MNPI)     │   │    │    MNPI Zone       │      │   Public Zone      │           │   │
│   │  - positions (MNPI)  │   │    │  (KMS: kms_mnpi)   │      │ (KMS: kms_public)  │           │   │
│   │  - market_data       │   │    │                    │      │                    │           │   │
│   │  - reference_data    │   │    │  raw_mnpi          │      │  raw_public        │           │   │
│   │                      │   │    │  curated_mnpi      │      │  curated_public    │           │   │
│   └──────────────────────┘   │    │  analytics_mnpi    │      │  analytics_public  │           │   │
│                              │    │                    │      │                    │           │   │
│                              │    └────────────────────┘      └────────────────────┘           │   │
│                              │                                                                  │   │
│                              │    ┌──────────────────────────────────────────────┐             │   │
│                              │    │              Glue Catalog                    │             │   │
│                              │    │  (6 databases: raw/curated/analytics × 2)    │             │   │
│                              │    └──────────────────────────────────────────────┘             │   │
│                              │                                                                  │   │
│                              │    ┌──────────────────────────────────────────────┐             │   │
│                              │    │              CloudTrail Audit                │             │   │
│                              │    │         (S3 data access logging)             │             │   │
│                              │    └──────────────────────────────────────────────┘             │   │
│                              └──────────────────────────────────────────────────────────────────┘   │
│                                                      │                                              │
│                                                      │ query                                        │
│                                                      ▼                                              │
│   ┌──────────────────────────────────────────────────────────────────────────────────────────────┐  │
│   │                                    Athena (athena)                                           │  │
│   │                                                                                              │  │
│   │    ┌──────────────────┐   ┌──────────────────┐   ┌──────────────────┐                       │  │
│   │    │ Finance Analysts │   │  Data Analysts   │   │  Data Engineers  │                       │  │
│   │    │ Workgroup        │   │  Workgroup       │   │  Workgroup       │                       │  │
│   │    │                  │   │                  │   │                  │                       │  │
│   │    │ MNPI + Public    │   │ Public only      │   │ All layers       │                       │  │
│   │    │ Analytics only   │   │ Analytics only   │   │ MNPI + Public    │                       │  │
│   │    │ MFA required     │   │                  │   │ MFA required     │                       │  │
│   │    └──────────────────┘   └──────────────────┘   └──────────────────┘                       │  │
│   └──────────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

**Data Flow:**
1. **PostgreSQL → Debezium**: CDC captures row-level changes
2. **Debezium → MSK**: Publish events to Kafka topics (MNPI/Public separated)
3. **MSK → S3 Sink**: Write to S3 raw layer (time-partitioned)
4. **S3 + Glue**: Glue Catalog stores table metadata for querying
5. **Athena → S3**: Query data directly from S3 using Glue metadata

## Usage

```hcl
module "storage" {
  source = "git::https://github.com/leonlaf66/kraken-demo-module.git//storage?ref=v1.0.0"

  app_name   = "kraken-demo"
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
