
# Create KeyPair for EC2
resource "tls_private_key" "keypair" {
  for_each  = local.ec2_instances
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "keypair" {
  for_each   = local.ec2_instances
  key_name   = each.value.system.keypair_name
  public_key = tls_private_key.keypair[each.key].public_key_openssh
}

#store the private key pair value
resource "aws_ssm_parameter" "private_key_secret" {
  for_each    = local.ec2_instances
  name        = "${each.value.system.keypair_name}"
  description = "The ssh private key value to use to ssh on ec2 instance"
  type        = "SecureString"
  value       = tls_private_key.keypair[each.key].private_key_pem
}
