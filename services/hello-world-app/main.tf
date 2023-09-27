data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_lb_target_group" "web" {
  name     = "hello-world-${var.environment}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path              = "/"
    protocol          = "HTTP"
    matcher           = "200"
    interval          = 15
    timeout           = 3
    healthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "web" {
  listener_arn = module.alb.alb_http_listener_arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = var.db_remote_state_bucket
    key = var.db_remote_state_key
    region = "us-east-1"
  }
}

module "asg" {
  source = "../../cluster/asg-rolling-deploy"

  cluster_name = "hello-world-${var.environment}"
  user_data = base64encode(templatefile("${path.module}/user_data.tftpl", {
    db_address = data.terraform_remote_state.db.outputs.address
    db_port = data.terraform_remote_state.db.outputs.port
    server_text = "Hello, World!"
  }))

  min_size = var.min_size

  subnet_ids = data.aws_subnets.default.ids
  target_group_arns = [aws_lb_target_group.web.arn]
  health_check_type = "ELB"

  custom_tags = var.custom_tags
}

module "alb" {
  source = "../../networking/alb"

  alb_name = "hello-world-${var.environment}"
  subnet_ids = data.aws_subnets.default.ids
}