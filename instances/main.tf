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
  key_name   = "ec2-test-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCBi1ADkcsfGbC4uo5RjXJn5QUB2xBlsHTFetQCJEOjpqtXbo5cdhmYbPCgJA0ONkxhgEzVEL/tD4epx0QkchdQ0vvyCj/RnzbkujNjnjTu0I1jf898HX2ie/24Pnqx3pFlNBaVBRfTN8zfKfpLxDJ+A61PaP8zs/PCM9z4meO1vx0q4fXzw8LWounuUUmanXG9qL1TeivczfgwpGLqayGWMguV/qoqbom67tGAZGNZflRTC1sfuvr3nBCudjkSNgOFc09fNvIUBNKmbdxOBXPM71G8IOfT3yhQ2oBv2KWVR6HHMbjEjZtlttgvr5NicMhqUqa2gc1vLyuZgBHzMBq9"
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