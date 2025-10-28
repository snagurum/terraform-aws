
resource "aws_security_group" "this" {
  vpc_id      = var.vpc_id
  name        = "${var.name}-sg"
  description = var.description

  dynamic "ingress" {
    for_each = var.ingress_rules // Iterates over the list of objects
    content {
      from_port   = ingress.value.port == -65535 ? 0 : ingress.value.port
      to_port     = ingress.value.port == -65535 ? 65535 : ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  // Egress rule can be static or also dynamic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}