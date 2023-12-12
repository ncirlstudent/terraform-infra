data "aws_region" "current_region" {}

data "aws_ami" "ec2_ami" {
  for_each           = local.ec2_instances
  most_recent        = true
  owners             = [each.value.system.ami_owner]
  include_deprecated = true

  filter {
    name   = "name"
    values = [each.value.system.ami_name]
  }
}