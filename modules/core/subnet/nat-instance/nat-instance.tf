# Assume you already have a VPC, public and private subnets, and an Internet Gateway

locals{
    name = "${var.name}-nat-instance"
}

module "nat-instance_sg" {
  source = "../../sg"
  vpc_id = var.vpc_id
  name   = "${var.name}-nat-instance"
  ingress_rules = [{
      port        = -65535
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "allow all inbound traffic"
  }]
}

data "aws_ami" "nat_ami" {
  owners = ["137112412989"] # Amazon
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


module "nat-instance" {
   source = "../../ec2"
   name = var.name
   ami_id                         = data.aws_ami.nat_ami.id
   instance_type               = var.instance_type
   subnet_id                   = var.public_subnet_ids[0]
   source_dest_check            = false
   vpc_id = var.vpc_id
   security_groups       = [module.nat-instance_sg.id]
   key_name                     = var.key_pair_name
   
   user_data_base64 = base64encode("${path.module}/user-data.tpl")
}

# resource "aws_instance" "nat-instance" {
#   ami                         = data.aws_ami.nat_ami.id
#   instance_type               = var.instance_type
#   subnet_id                   = var.public_subnet_ids[0]
#   associate_public_ip_address  = true
#   source_dest_check            = false
#   vpc_security_group_ids       = [module.nat-instance_sg.id]
#   key_name                     = var.key_pair_name

#   tags = {
#     Name = "${local.name}"
#   }
#   # user_data = base64encode(templatefile("${path.module}/user-data.tpl",{
#   #   # project   = var.project
#   # }))
#   user_data = <<-EOF
#               #!/bin/bash
#               # Enable IP forwarding
#               sysctl -w net.ipv4.ip_forward=1
#               # Make it persistent
#               echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

#               # Configure NAT rules
#               iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
#               iptables-save > /etc/sysconfig/iptables
#               EOF
# }

resource "aws_route_table" "private_rt" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = module.nat-instance.primary_network_interface_id
    # network_interface_id = aws_instance.nat-instance.primary_network_interface_id
  }

  tags = {
    Name = "${local.name}-rt"
  }
}

resource "aws_route_table_association" "private_assoc" {
  # for_each       = toset(var.private_subnet_ids)
  for_each       = var.private_subnet_ids
  subnet_id      = each.value
  route_table_id = aws_route_table.private_rt.id
}
