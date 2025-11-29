resource "aws_security_group" "rds" {
  name        = "${var.app_name}-rds-sg-${var.env}"
  description = "Security group for RDS Source DB (CDC enabled)"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.app_name}-rds-sg-${var.env}"
    }
  )
}

resource "aws_vpc_security_group_egress_rule" "rds_egress" {
  security_group_id = aws_security_group.rds.id
  description       = "Allow all outbound traffic"
  
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  tags = {
    Name = "allow-all-outbound"
  }
}
