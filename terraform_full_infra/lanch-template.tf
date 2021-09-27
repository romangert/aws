resource "aws_lb_target_group" "web" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.mlm.id
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_lb" "web" {
  #name_prefix = "webAlb"
  name               = "webAlb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]#aws_subnet.public.*.id

  #enable_deletion_protection = true

  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.bucket
  #   prefix  = "test-lb"
  #   enabled = true
  # }


  tags = {
    Name = "mlm web"
    Owner = "Roman"
    Environment = "production"
  }
}

resource "aws_autoscaling_group" "web" {
  name = "ASG-${aws_launch_template.web.name}"
  vpc_zone_identifier = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  min_elb_capacity    = 1
  health_check_type   = "ELB"
  target_group_arns = [ aws_lb_target_group.web.id ]
  
  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "mlm web"
    propagate_at_launch = true
  }

  depends_on = [
    aws_lb.web
  ]
}

resource "aws_launch_template" "web" {
  #name                                 = "mlm-web"
  name_prefix = "mlm-"
  image_id                             = data.aws_ami.amzn2.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = "t2.micro"
  vpc_security_group_ids               = [aws_security_group.web.id]
  key_name                             = "ireland-KP"
  default_version                      = "1"
  description                          = "mlm web server"

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "test"
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  user_data = filebase64("user_data.sh")

  #   user_data = (base64encode(<<EOF
  # echo 'rrrrr'
  # EOF
  #   ))


  #   block_device_mappings {
  #     device_name = "/dev/sda1"

  #     ebs {
  #       volume_size = 20
  #     }
  #   }


  #   cpu_options {
  #     core_count       = 4
  #     threads_per_core = 2
  #   }

  #   metadata_options {
  #     http_endpoint               = "enabled"
  #     http_tokens                 = "required"
  #     http_put_response_hop_limit = 1
  #   }

  #   monitoring {
  #     enabled = true
  #   }

  #   network_interfaces {
  #     associate_public_ip_address = true
  #   }
}

output "laod_balancer_url" {
  value = aws_lb.web.dns_name
}
