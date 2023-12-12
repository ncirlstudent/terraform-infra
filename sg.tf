resource "aws_security_group" "ec2_sg" {
  for_each = local.ec2_sg_config
  name = format("ec2_sg_%s",
    data.aws_region.current_region.name
  )
  description = "Allow traffic for ec2"
  vpc_id      = each.value.vpc_id

  dynamic "ingress" {
    for_each = toset(local.sg_inbound)
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = toset(local.sg_outbound)
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.description
    }
  }
  tags = { "Name" = format("ec2_sg") }
}
