packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_name" {
  type    = string
  default = "Ubuntu20-LTS"
}
  
variable "aws_region" {
  type    = string
  default = "${env("AWS_REGION")}"
}
  


locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}
  

source "amazon-ebs" "ubuntu" {
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "us-west-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

  
build {
  sources = ["source.amazon-ebs.ubuntu"]
  
  provisioner "shell" {
    environment_var = [
      "FOO=hello world"
    ]
      inline = [
        "echo Installing Redis",
        "sleep 30",
        "sudo apt-get update",
        "sudo apt-get install -y redis-server",
        "echo \"FOO is $FOO\" > example.txt",
      ]
    }
  }