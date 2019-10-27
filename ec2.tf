resource "aws_key_pair" "sophie" {
  key_name   = "sophie"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCnm/LgkSpSHk1wS1Nq9o5EeY4eSRNPXfzo+9WXlo0H0UIqhHtBde65RSXjlUCoiLOrk/6J0u9BVOjmU9ahkZ+EayLUi3IGvXGEgXFjEHi1ian9iwRgGTlPPrS+Xt+janJYT4RWWcOGM1HxEonR6kO2J3llF/5ld3OuGuF/w/Dzb7rAXrNfTAZ1pOVh3FsdCfcU4AmSBRSsQJibOBCTPsvyn5YshDzE3x5YgT70N3tfJ4xZLazY3Rp8dt2ItzqCf/gDAgD1YKh9key2wbYIGVvjEusoJS+pCTMQTBiIdyvAqmrEG8XcoDK/Jn28vYcqaCX5sYz5Vl9q9+ILKXLrMwAv"
}

resource "aws_security_group" "lydie" {
  name        = "lydie"
  description = "Lydie"
}

resource "aws_security_group_rule" "lydie_ingress" {
  for_each = {
    http = {
      from_port = 80,
      to_port   = 80,
      protocol  = "tcp",
    },
    https = {
      from_port = 443,
      to_port   = 443,
      protocol  = "tcp",
    },
    ssh = {
      from_port = 22,
      to_port   = 22,
      protocol  = "tcp",
    },
    znc = {
      from_port = 6697,
      to_port   = 6697,
      protocol  = "tcp",
    },
    mosh = {
      from_port = 60000,
      to_port   = 61000,
      protocol  = "udp",
    },
  }

  security_group_id = aws_security_group.lydie.id

  type             = "ingress"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
  from_port        = each.value.from_port
  to_port          = each.value.to_port
  protocol         = each.value.protocol
}

resource "aws_security_group_rule" "lydie_egress" {
  security_group_id = aws_security_group.lydie.id

  type             = "egress"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
  from_port        = 0
  to_port          = 0
  protocol         = "-1"
}
