#resource "aws_internet_gateway" "internet_gateway" {
#  vpc_id = var.vpc_id
#}
#
#resource "aws_route_table" "public" {
#  vpc_id = var.vpc_id
#
#  route {
#    cidr_block = "0.0.0.0/0"
#    gateway_id = aws_internet_gateway.internet_gateway.id
#  }
#}
#
#resource "aws_route_table_association" "route_table_association" {
#  subnet_id      = var.public_subnets[1]
#  route_table_id = aws_route_table.public.id
#}

resource "aws_security_group" "ecs_sg" {
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 3306
    to_port         = 3306
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.ecs_sg.id]
  }

  egress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}