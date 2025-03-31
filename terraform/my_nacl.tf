resource "aws_network_acl" "my_nacl" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my-nacl"
  }
}

resource "aws_network_acl_rule" "ingress_rule" {
  network_acl_id = aws_network_acl.my_nacl.id
  rule_number    = 100
  protocol       = "6"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
  egress         = false
}

resource "aws_network_acl_rule" "egress_rule" {
  network_acl_id = aws_network_acl.my_nacl.id
  rule_number    = 100
  protocol       = "6"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
  egress         = true
}

