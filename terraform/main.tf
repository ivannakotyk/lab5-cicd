terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "lab_sg" {
  name        = "lab-terraform-sg"
  description = "Security group for Terraform lab"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_server" {
  ami                    = "ami-0c7217cdde317cfec"
  instance_type          = "t3.micro"
  key_name               = "lab4-key"
  vpc_security_group_ids = [aws_security_group.lab_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y docker.io
              systemctl start docker
              systemctl enable docker

              docker run -d --name lab5-app -p 80:80 ivannakotyk/lab5-cicd:latest

              docker run -d \
                --name watchtower \
                -v /var/run/docker.sock:/var/run/docker.sock \
                containrrr/watchtower \
                --interval 30
              EOF

  tags = {
    Name        = "Lab-Terraform-Instance"
    Environment = "Education"
  }
}

output "instance_public_ip" {
  description = "Публічна IP-адреса створеного сервера"
  value       = aws_instance.web_server.public_ip
}
