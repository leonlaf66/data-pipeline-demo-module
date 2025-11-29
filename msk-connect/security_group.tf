resource "aws_security_group" "this" {
  name        = "${var.connector_name}-sg"
  description = "Security group for MSK Connect ${var.connector_name}"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.connector_name}-sg"
    }
  )
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.this.id
  description       = "Allow all outbound traffic"
  
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}