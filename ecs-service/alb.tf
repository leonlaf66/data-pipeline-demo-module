################################################################################
# Application Load Balancers (one per service that needs ALB)
################################################################################

resource "aws_lb" "this" {
  for_each = local.services_with_alb

  name               = substr("${var.app_name}-${var.environment}-${each.key}", 0, 32)
  load_balancer_type = "application"
  internal           = each.value.alb_internal
  security_groups    = [aws_security_group.alb[each.key].id]
  subnets            = var.private_subnet_ids
  idle_timeout       = each.value.alb_idle_timeout

  enable_deletion_protection = false

  tags = merge(
    local.default_tags,
    {
      Name    = "${var.app_name}-${var.environment}-${each.key}-alb"
      Service = each.key
    }
  )
}

################################################################################
# Target Groups
################################################################################

resource "aws_lb_target_group" "this" {
  for_each = local.services_with_alb

  name        = substr("${var.app_name}-${var.environment}-${each.key}-tg", 0, 32)
  port        = each.value.container_port
  protocol    = "HTTP"  # Always HTTP to container
  vpc_id      = var.vpc_id
  target_type = "ip"

  deregistration_delay = each.value.alb_deregistration_delay

  health_check {
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = each.value.health_check_path
    port                = each.value.health_check_port
    protocol            = "HTTP"
    matcher             = each.value.alb_health_check_matcher
  }

  tags = merge(
    local.default_tags,
    {
      Name    = "${var.app_name}-${var.environment}-${each.key}-tg"
      Service = each.key
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# ALB Listeners - HTTPS (when certificate provided)
################################################################################

resource "aws_lb_listener" "https" {
  for_each = local.use_https ? local.services_with_alb : {}

  load_balancer_arn = aws_lb.this[each.key].arn
  port              = each.value.alb_listener_port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.key].arn
  }

  tags = merge(
    local.default_tags,
    {
      Name    = "${var.app_name}-${var.environment}-${each.key}-https"
      Service = each.key
    }
  )
}

################################################################################
# ALB Listeners - HTTP (when no certificate, or as redirect)
################################################################################

resource "aws_lb_listener" "http" {
  for_each = local.use_https ? {} : local.services_with_alb

  load_balancer_arn = aws_lb.this[each.key].arn
  port              = each.value.alb_listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.key].arn
  }

  tags = merge(
    local.default_tags,
    {
      Name    = "${var.app_name}-${var.environment}-${each.key}-http"
      Service = each.key
    }
  )
}
