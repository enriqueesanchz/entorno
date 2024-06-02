terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.46"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-west-3"
}

resource "aws_security_group" "entorno-sec" {
  name = var.security_group_name
  ingress {
    from_port        = 6901
    to_port          = 6901
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 6901
    to_port          = 6901
    protocol         = "udp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "random_pet" "petname" {
  separator = "-"
  length    = 1
}

resource "aws_s3_bucket" "entorno-s3" {
  bucket = "${var.bucket_prefix}-${random_pet.petname.id}"
}

# Subir el compose.yaml a s3
resource "aws_s3_object" "entorno-s3" {
  bucket = aws_s3_bucket.entorno-s3.id
  key    = var.key_file
  source = var.source_file
}

resource "aws_elastic_beanstalk_application" "entorno" {
  name = var.application
}

resource "aws_elastic_beanstalk_application_version" "entorno-1" {
  name        = var.eb_app_version_name
  application = var.application
  description = "application version"
  bucket      = aws_s3_bucket.entorno-s3.id
  key         = aws_s3_object.entorno-s3.id
}

resource "aws_elastic_beanstalk_environment" "entorno-env" {
  name                = var.eb_env_name
  application         = aws_elastic_beanstalk_application.entorno.name
  solution_stack_name = "64bit Amazon Linux 2 v3.8.1 running Docker"
  version_label       = aws_elastic_beanstalk_application_version.entorno-1.name

  setting {
    name      = "IamInstanceProfile"
    namespace = "aws:autoscaling:launchconfiguration"
    value     = var.ec2_role
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = var.security_group_name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "SingleInstance"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "vpn_user"
    value     = var.vpn_user
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "vpn_password"
    value     = var.vpn_password
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "tigervncpasswd"
    value     = var.tigervncpasswd
  }
}
