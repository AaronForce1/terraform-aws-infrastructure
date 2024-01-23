module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  for_each = {
    for idx in range(0, var.hsm.hsm_count > 0 && var.hsm.hsm_init ? 1 : 0) : "${var.app_name}-${var.app_namespace}-${var.tfenv}-init-ec2-${idx}" => idx
  }

  name = "${var.app_name}-${var.app_namespace}-${var.tfenv}-init-instance"

  create_iam_instance_profile = true
  iam_role_description        = "IAM Role for HSM Activation EC2 Instance"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  instance_type          = "t2.micro"
  key_name               = "user1"
  monitoring             = true
  vpc_security_group_ids = []
  subnet_id              = local.subnet_ids[0]

  tags = local.base_tags
}

module "security_group_instance" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  for_each = {
    for idx in range(0, var.hsm.hsm_count > 0 && var.hsm.hsm_init ? 1 : 0) : "${var.app_name}-${var.app_namespace}-${var.tfenv}-init-sg-${idx}" => idx
  }

  name        = "${var.app_name}-${var.app_namespace}-${var.tfenv}}-init-instance"
  description = "Security Group for EC2 Instance Egress for HSM Activation EC2 Instance"

  vpc_id = var.vpc_id

  egress_rules = ["https-443-tcp"]

  tags = local.base_tags
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.0"

  for_each = {
    for idx in range(0, var.hsm.hsm_count > 0 && var.hsm.hsm_init ? 1 : 0) : "${var.app_name}-${var.app_namespace}-${var.tfenv}-init-vpce-${idx}" => idx
  }

  vpc_id = var.vpc_id

  endpoints = { for service in toset(["ssm", "ssmmessages", "ec2messages"]) :
    replace(service, ".", "_") =>
    {
      service             = service
      subnet_ids          = [local.subnet_ids[0]]
      private_dns_enabled = true
      tags = merge(
        { Name = "${local.name_prefix}-${service}" },
        local.base_tags
      )
    }
  }

  create_security_group      = true
  security_group_name_prefix = "${local.name_prefix}-vpc-endpoints-"
  security_group_description = "VPC endpoint security group for HSM Activation EC2 Instance"
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from subnets"
      cidr_blocks = var.subnet_ids
    }
  }

  tags = local.base_tags
}