resource "aws_security_group" "msk" {
  name        = "${var.app_name}-msk-sg"
  description = "Security group for MSK cluster"
  vpc_id      = var.vpc_id

  tags = var.common_tags
}

resource "aws_vpc_security_group_egress_rule" "msk_outbound" {
  security_group_id = aws_security_group.msk.id
  description       = "Allow all outbound traffic"

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}