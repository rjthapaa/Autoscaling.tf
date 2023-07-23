#Provider.tf
terraform {
   required_providers {
     aws = {
       source  = "hashicorp/aws"
       version = "~> 4.0"
     }
   }
 }
provider "aws" {
   region = "us-east-1"
}

#vpc.tf
resource "aws_vpc" "main" {
   cidr_block = "10.0.0.0/16"
   tags = {
     Name = "main"
   }
 }

#Subnet.tf
resource "aws_subnet" "public_subnet_1a" {
   vpc_id            = aws_vpc.main.id
   cidr_block        = "10.0.32.0/20"
   availability_zone = "us-east-1a"
   tags = {
     Name = "public subnet 1"
   }
 }

 resource "aws_subnet" "public_subnet_1b" {
   vpc_id            = aws_vpc.main.id
   cidr_block        = "10.0.16.0/20"
   availability_zone = "us-east-1b"
   tags = {
     Name = "public subnet 2"
   }
 }

#Internetgateway.tf
resource "aws_internet_gateway" "gw" {
   vpc_id = aws_vpc.main.id

   tags = {
     Name = "internet-gateway"
   }
 }

#route.tf
resource "aws_route_table" "route_table" {
   vpc_id = aws_vpc.main.id

   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.gw.id
   }

   tags = {
     Name = "route_table"
   }
 }
 resource "aws_route_table_association" "public_subnet_association_1a" {
   subnet_id      = aws_subnet.public_subnet_1a.id
   route_table_id = aws_route_table.route_table.id
 }
 resource "aws_route_table_association" "public_subnet_association_1b" {
   subnet_id      = aws_subnet.public_subnet_1b.id
   route_table_id = aws_route_table.route_table.id
 }

#Security.tf
resource "aws_security_group" "web_server" {
   name        = "web-server-sg"
   description = "Allow SSH and HTTP access from anywhere"
   vpc_id = aws_vpc.main.id
   ingress {
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
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
   }

#EC2
resource "aws_instance" "example" {
  ami           = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"
  key_name      = "rjthapaa"
  subnet_id     = aws_subnet.public_subnet_1a.id
  associate_public_ip_address = true
  security_groups = [
    aws_security_group.web_server.id
  ]
  user_data = filebase64("userdata.sh")
  tags = {
    Name = "EC2web-server"
  }
}

#userdata.sh
 #!/bin/bash
sudo apt-get update -y
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
echo "<!DOCTYPE html>
<html>
<head>
    <title>Introduction</title>
    <style>
        body {
            background-color: #d8e2dc;
            font-family: Arial, sans-serif;
            color: #3c415e;
            text-align: center;
            padding: 50px;
        }
        h1 {
            font-size: 3em;
            margin-bottom: 20px;
            text-shadow: 0 2px 2px rgba(0,0,0,0.1);
        }
        p {
            font-size: 1.5em;
            line-height: 1.5;
            margin-bottom: 30px;
        }
    </style>
</head>
<body>
    <h1>Welcome to terraform</h1>
    <p>Learn DevOps like a Pro</p>
</body>
</html>" > /var/www/html/index.html
sudo systemctl restart apache2

#mainlb.tf
resource "aws_lb" "example" {
  name               = "example-lb"
  internal           = false  # Set to true if you want an internal load balancer
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_server.id]
  subnets            = [aws_subnet.public_subnet_1a.id,aws_subnet.public_subnet_1b.id]  # Replace with your desired subnet IDs
  tags = {
    Name = "example-lb"
  }
}
resource "aws_lb_target_group" "example" {
  name        = "example-tg"
  port        = 80  #The port your instances are listening on
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id  #replace with your VPC ID
  target_type = "instance"
  health_check {
    path = "/"
    port = "traffic-port"
  }
}
resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.example.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.example.arn
    type             = "forward"
  }
}
