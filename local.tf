locals {
  aws_region    = data.aws_region.current_region.name
  ec2_instances = yamldecode(file("${path.module}/configuration/ec2.yaml"))


  ec2_sg = tolist(fileset(path.root, "configuration/sg.yaml"))
  ec2_sg_config = {
    for element in local.ec2_sg :
    yamldecode(file("${path.root}/${element}"))["name"] => yamldecode(file("${path.root}/${element}"))
  }

  sg_inbound = distinct(flatten([
    for id, name in local.ec2_sg_config : [
      for sg_inbound in name.sg_inbound : {
        from_port   = sg_inbound.from_port
        to_port     = sg_inbound.to_port
        protocol    = sg_inbound.protocol
        cidr_blocks = try(sg_inbound.cidr_blocks, [])
        description = sg_inbound.description
      }
    ]
    ]
  ))
  sg_outbound = distinct(flatten([
    for id, name in local.ec2_sg_config : [
      for sg_outbound in name.sg_outbound : {
        from_port   = sg_outbound.from_port
        to_port     = sg_outbound.to_port
        protocol    = sg_outbound.protocol
        cidr_blocks = try(sg_outbound.cidr_blocks, [])
        description = sg_outbound.description
      }
    ]
    ]
  ))
}