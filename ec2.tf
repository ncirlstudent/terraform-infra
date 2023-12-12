#create the EC2 ressource
resource "aws_instance" "ec2_instance" {
  for_each               = local.ec2_instances
  ami                    = data.aws_ami.ec2_ami[each.key].image_id
  instance_type          = each.value.system.instance_type
  subnet_id              = each.value.network.subnet_id
  vpc_security_group_ids = [aws_security_group.ec2_sg[each.value.network.security_group].id]
  key_name               = aws_key_pair.keypair[each.key].key_name
  tags = {
    Name = format("%s", each.key)
  }
}