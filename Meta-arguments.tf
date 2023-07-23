################################
Creating Multiple Ec2 instances
################################

terraform {
required_providers {
aws = {
source = "hashicorp/aws"
version = "~> 4.16"
}
}
required_version = ">= 1.2.0"
}

provider "aws" {
region = "us-east-1"
}
resource "aws_instance" "server" {
count = 4
ami = "ami-08c40ec9ead489470"
instance_type = "t2.micro"
tags = {
Name = "Server ${count.index}"
}
}

##############################################
Creating Multiple Ec2 instances with for-each
##############################################

terraform {
required_providers {
aws = {
source = "hashicorp/aws"
version = "~> 4.16"
}
}
required_version = ">= 1.2.0"
}
 
provider "aws" {
region = "us-east-1"
}

locals {
ami_ids = toset([
"ami-0b0dcb5067f052a63",
"ami-08c40ec9ead489470",
])
}

resource "aws_instance" "server" {
for_each = local.ami_ids  
ami = each.key
instance_type = "t2.micro"
tags = {
Name = "Server ${each.key}"
}
}

##################################################
Creating Multiple Ec2 instances with for-each_MAPS
##################################################

terraform {
required_providers {
aws = {
source = "hashicorp/aws"
version = "~> 4.16"
}
}
required_version = ">= 1.2.0"
}
 
provider "aws" {
region = "us-east-1"
}

locals {
ami_ids = {
"linux" :"ami-0b0dcb5067f052a63",
"ubuntu": "ami-08c40ec9ead489470",
}
}

resource "aws_instance" "server" {
for_each = local.ami_ids
  
ami = each.value
instance_type = "t2.micro"
tags = {
Name = "Server ${each.key}"
}
}



