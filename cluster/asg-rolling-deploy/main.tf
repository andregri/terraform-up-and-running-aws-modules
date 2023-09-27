data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_launch_template" "web" {
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_http.id]

  user_data = var.user_data

  tags = {
    Name = var.cluster_name
    Env  = terraform.workspace
  }
}

resource "aws_autoscaling_group" "web" {
  # Explicitly depends on the launch configuration name so each time it's
  # replaced, this ASG is also replaced.
  name = "${var.cluster_name}-${aws_launch_template.web.name}-${aws_launch_template.web.latest_version}"

  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id = aws_launch_template.web.id
    version = aws_launch_template.web.latest_version
  }

  target_group_arns = var.target_group_arns
  health_check_type = var.health_check_type

  min_size = var.min_size
  max_size = 10

  min_elb_capacity = var.min_size

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = var.cluster_name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each            = var.custom_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_security_group" "allow_http" {
  name        = "server_allow_http_${terraform.workspace}"
  description = "Allow HTTP inbound traffic"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = var.cluster_name
    Env  = terraform.workspace
  }
}