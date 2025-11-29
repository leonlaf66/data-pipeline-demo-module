# =============================================================================
# Security Group Ingress Rules Module - Variables
# =============================================================================
# This module creates security group ingress rules after all SGs are created
# to solve the chicken-and-egg dependency problem.
# =============================================================================

variable "ingress_rules" {
  description = <<-EOT
    Map of security group ingress rules.
    
    Each rule must specify either cidr_ipv4 OR referenced_security_group_id (not both).
    
    Example:
    {
      "msk-from-cdc-connector" = {
        description                  = "Allow Debezium CDC to MSK"
        security_group_id            = "sg-msk-xxxxx"
        referenced_security_group_id = "sg-cdc-xxxxx"
        from_port                    = 9096
        to_port                      = 9096
        ip_protocol                  = "tcp"
      }
      "rds-from-vpc" = {
        description       = "Allow PostgreSQL from VPC"
        security_group_id = "sg-rds-xxxxx"
        cidr_ipv4         = "10.0.0.0/16"
        from_port         = 5432
        to_port           = 5432
        ip_protocol       = "tcp"
      }
    }
  EOT

  type = map(object({
    description                  = string
    security_group_id            = string
    from_port                    = number
    to_port                      = number
    ip_protocol                  = string
    cidr_ipv4                    = optional(string, null)
    referenced_security_group_id = optional(string, null)
  }))

  validation {
    condition = alltrue([
      for k, v in var.ingress_rules :
      (v.cidr_ipv4 != null && v.referenced_security_group_id == null) ||
      (v.cidr_ipv4 == null && v.referenced_security_group_id != null)
    ])
    error_message = "Each rule must specify either cidr_ipv4 OR referenced_security_group_id, not both or neither."
  }
}
