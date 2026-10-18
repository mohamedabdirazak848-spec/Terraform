# Provider Block
terraform{
  
  #Assumes s3 bucket and dynamodb table already created 
  #backend "s3" {
  #  bucket = "devops-directive-tf-state"
  #  key = "03-basics/webb-app/terraform.tfstate"
  #  region = "eu-west-2"
  #  dynamodb_table = "terraform-state-locking"
  #  encrypt = true
  #}

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws"{
    profile = "default"
    region = "eu-west-2"
}

locals {
  extra_tag = "extra-tag"
}

# Resources Block

resource "aws_instance" "app_server_1" {
  ami           = var.ami # Ubuntu Server
  instance_type = var.ec2_instance_type
  key_name = "moh2"

  vpc_security_group_ids = [aws_security_group.firewall.id]

    user_data = <<-EOF
                #!bin/bash
                apt update -y
                apt install docker.io -y
                docker pull ${var.docker_image_1}
                docker run -d -p 80:80 ${var.docker_image_1}
                EOF

  tags = {
    Name = var.instance_name
  }
}

resource "aws_instance" "app_server_2" {
  ami           = var.ami # Ubuntu Server
  instance_type = var.ec2_instance_type
  key_name = "moh2"

  vpc_security_group_ids = [aws_security_group.firewall.id]

    user_data = <<-EOF
                #!bin/bash
                apt update -y
                apt install docker.io -y
                docker pull ${var.docker_image_1}
                docker run -d -p 80:80 ${var.docker_image_1}
                EOF

  tags = {
    Name = var.instance_name
  }
}


# Firewall Rule
resource "aws_security_group" "firewall" {
      name        = "firewall"
    description = "Allow HTTP and SSH inbound traffic"

    ingress {
        description ="HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

#resource "aws_s3_bucket" "bucket" {
#  bucket = "devops-directive-web-app-data"
#  force_destroy = true
#  versioning {
#    enabled = true
#  }

#  server_side_encryption_configuration {
#    rule {
#      apply_server_side_encryption_by_default {
#        sse_algorithm = "AES256"
#      }
#    }
#  }
#}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

data "aws_vpc" "default_vpc" {
  default = true
}

resource "aws_lb_target_group" "instances" {
  name     = "app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default_vpc.id

  health_check {
    path                = "/"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

resource "aws_lb_target_group_attachment" "app_server_1" {
  target_group_arn = aws_lb_target_group.instances.arn
  target_id        = aws_instance.app_server_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "app_server_2" {
  target_group_arn = aws_lb_target_group.instances.arn
  target_id        = aws_instance.app_server_2.id
  port             = 80
}

resource "aws_lb_listener_rule" "instances" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instances.arn
  }
}

resource "aws_security_group" "alb" {
  name = "alb-security-group"
}

resource "aws_security_group_rule" "allow_alb_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id

  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_alb_http_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.alb.id

  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

data "aws_subnets" "default_subnets" {
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

resource "aws_lb" "load_balancer" {
  name = "web-app-lb"
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb.id]
  subnets = data.aws_subnets.default_subnets.ids
}

# resource "aws_db_instance" "db_instance" {
  #allocated_storage    = 20
  #storage_type         = "standard"
  #engine               = "postgres"
  #engine_version       = "13"
  #instance_class       = "db.t3.micro"
  #db_name              = "mydb"
  #username             = "admin"
  #password             = "password123"
  #skip_final_snapshot  = true
#}