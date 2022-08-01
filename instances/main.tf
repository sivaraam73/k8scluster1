terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket = "sivaraam-k8scluster1-tf-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}


data "aws_subnet" "kube_subnet_id" {
  
  filter {
    name   = "tag:Name"
    values = ["kube_subnet"]
  }

#   most_recent = true
}

data "aws_security_group" "kube_sg_id" {
  
  filter {
    name   = "tag:Name"
    values = ["kube_sg"]
  }

#   most_recent = true
}


resource "aws_key_pair" "kube_cp_key" {
  key_name   = "kube_cp_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDeLst+vpB6nfCIdp8/6JSY7BWwYV323FSdXcnbJRMbCB+vpgTy2x8pdmQdupnBpqdvfHaZg+giD3djsUS3JtiLIgNfzye70+Cago2xvUcHkdu6hZJZw36CoegKN28eAGzZVFujGp9IV2MOHvXbjyojArMdCCEwoWiFxCyB68JCQXbcjc1FQSJ387LrSpYcJxbSNntZyqBXgZ/PM/FKLLtBgmsQeai/KcCPp2LStnbJ+QJJoOzKyLiURg4sAnXjfPevNcsLrMZoTCiuv1d2s0krJerViOwAu7pI79Z4CVzaSqnR+rt+NFyUi0MwGV+FRNDvFVqAsJqX8RZaIPL1VSEH admin@admins-iMac.local"
}


resource "aws_network_interface" "kube_instance_eni" {
  subnet_id       = data.aws_subnet.kube_subnet_id.id
  security_groups = [data.aws_security_group.kube_sg_id.id]

  
}

resource "aws_instance" "kube_dash_instance" {
  ami           = "ami-0e472ba40eb589f49" # us-east-1
  instance_type = "t3.medium"

  network_interface {
    network_interface_id = resource.aws_network_interface.kube_instance_eni.id
    device_index         = 0
  }
  availability_zone = "us-east-1a"
  key_name = resource.aws_key_pair.kube_cp_key.key_name

  tags= {
    Name = "KubeCtrlPlane"
  }

}