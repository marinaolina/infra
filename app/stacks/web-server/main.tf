module "ec2_instance" {
  for_each                  = toset(var.private_subnets)
  source                    = "../../modules/ec2"
  name                      = "${local.prefix}-server-${index(var.private_subnets, each.value) + 1}"
  instance_type             = "t2.micro"
  key_name                  = "marina_key_pem"
  default_security_group_id = module.instance_sg.security_group_id
  subnet_id                 = each.value
  tags                      = local.tags
  has_public_ip             = false
  user_data                 = file("${path.module}/user_data.sh")

}

#TODO remove after debug
module "ec2_instance_public" {

  source                    = "../../modules/ec2"
  name                      = "${local.prefix}-server-public-1"
  instance_type             = "t2.micro"
  key_name                  = "marina_key_pem"
  default_security_group_id = module.alb_sg.security_group_id
  subnet_id                 = var.public_subnets[1]
  tags                      = local.tags
  has_public_ip             = true
  user_data                 = file("${path.module}/user_data.sh")

}

# ------------ Create AWS ALB Security Group -----------
module "alb_sg" {
  source       = "terraform-aws-modules/security-group/aws"
  name         = "${local.prefix}-alb-sg"
  description  = "Security group for ALB"
  vpc_id       = var.vpc_id
  egress_rules = ["all-all"]
}


# ------------ Create AWS ALB -----------
resource "aws_lb" "web" {
  name            = "${local.prefix}-alb"
  subnets         = var.public_subnets
  security_groups = [module.alb_sg.security_group_id]
  idle_timeout    = 400
  access_logs {
    bucket  = module.s3_bucket.bucket_id
    enabled = true
  }
  tags = local.tags
}


module "instance_sg" {
  source       = "terraform-aws-modules/security-group/aws"
  name         = "${local.prefix}-server-sg"
  description  = "Security group for web servers"
  vpc_id       = var.vpc_id
  egress_rules = ["all-all"]
  ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.alb_sg.security_group_id # to let alb in
    }
  ]
  tags = local.tags
}


resource "aws_security_group_rule" "for_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${var.bastion_private_ip}/32"]
  security_group_id = module.instance_sg.security_group_id
  description       = "to allow ssh from bastion"
}


resource "aws_lb_target_group" "web" {
  name        = trimsuffix(substr("${local.prefix}-ip-tg", 0, 32), "-")
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }
  tags = local.tags
}

module "web_http_sg" {
  source              = "terraform-aws-modules/security-group/aws"
  create_sg           = false
  security_group_id   = module.alb_sg.security_group_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]
  egress_rules        = ["http-80-tcp"]

  tags = local.tags
}

resource "aws_lb_listener" "web_http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
  tags = local.tags

}

resource "aws_lb_target_group_attachment" "web" {
  for_each = toset(var.private_subnets)

  target_group_arn = aws_lb_target_group.web.arn
  target_id        = module.ec2_instance[each.key].private_ip
  port             = 80

}

