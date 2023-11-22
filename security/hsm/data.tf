data "aws_availability_zones" "available" {}

data "aws_subnet" "hsm_subnet_selections" {
  count = length(var.subnet_ids)

  id = var.hsm.subnet_ids[count.index]
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["679593333241"]

  filter {
    name   = "name"
    values = ["ubuntu-minimal/images/hvm-ssd/ubuntu-focal-20.04-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_ami_copy" "ubuntu_encrypted_ami" {
  name              = "ubuntu-encrypted-ami"
  description       = "An encrypted root ami based off ${data.aws_ami.ubuntu.id}"
  source_ami_id     = data.aws_ami.ubuntu.id
  source_ami_region = var.aws_region
  encrypted         = true

  tags = merge({ Name = "ubuntu-encrypted-ami" }, local.base_tags)
}