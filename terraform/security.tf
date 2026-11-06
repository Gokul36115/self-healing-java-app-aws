# Security group = firewall attached to the EC2 instance
resource "aws_security_group" "app" {
  name        = "${var.project_name}-app-sg"
  description = "Allow HTTP from my IP only; no SSH (use SSM)"
  vpc_id      = aws_vpc.main.id

  tags = { Name = "${var.project_name}-app-sg" }
}

# Inbound: HTTP 80 from my home IP only
resource "aws_vpc_security_group_ingress_rule" "http_from_me" {
  security_group_id = aws_security_group.app.id
  description       = "HTTP from my IP"
  cidr_ipv4         = var.my_ip_cidr
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# Outbound: allow everything (package downloads, Docker Hub, SSM, CloudWatch)
resource "aws_vpc_security_group_egress_rule" "all_out" {
  security_group_id = aws_security_group.app.id
  description       = "All outbound"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}