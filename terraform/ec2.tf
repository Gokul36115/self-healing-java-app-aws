# Latest Amazon Linux 2023 AMI (x86), looked up from AWS's public SSM parameter
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "app" {
  ami                         = data.aws_ssm_parameter.al2023.value
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2.name
  associate_public_ip_address = true

  # Security: require IMDSv2 for the instance metadata service
  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_type = "gp3"
    encrypted   = true
  }

  # Runs once at first boot as root: install Docker and start your container
  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail
    dnf install -y docker
    systemctl enable --now docker
    docker run -d --name selfheal \
      --restart unless-stopped \
      --memory=512m \
      -p 80:8080 \
      --log-driver=awslogs \
      --log-opt awslogs-region=ap-south-1 \
      --log-opt awslogs-group=${aws_cloudwatch_log_group.app.name} \
      --log-opt awslogs-stream=selfheal-app \
      ${var.app_image}
  EOF

  user_data_replace_on_change = true

  tags = { Name = "${var.project_name}-app" }
}