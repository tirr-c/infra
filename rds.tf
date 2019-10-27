resource "aws_db_subnet_group" "public" {
  name = "public"
  subnet_ids = [for subnet in aws_subnet.default: subnet.id]
}

resource "aws_security_group" "rds_private" {
  name = "rds-private"
  description = "Private RDS"
}

resource "aws_security_group_rule" "rds_private_postgres" {
  security_group_id = aws_security_group.rds_private.id

  type = "ingress"
  cidr_blocks = [aws_vpc.default.cidr_block]
  from_port = 5432
  to_port = 5432
  protocol = "tcp"
}

resource "aws_security_group_rule" "rds_private_egress" {
  security_group_id = aws_security_group.rds_private.id

  type = "egress"
  cidr_blocks = [aws_vpc.default.cidr_block]
  from_port = 0
  to_port = 0
  protocol = "-1"
}

resource "aws_db_instance" "pcr" {
  identifier = "pcr"

  storage_type = "gp2"
  allocated_storage = 20
  max_allocated_storage = 0

  engine = "postgres"
  engine_version = "11.4"

  instance_class = "db.t3.micro"
  multi_az = false
  db_subnet_group_name = aws_db_subnet_group.public.name
  vpc_security_group_ids = [aws_security_group.rds_private.id]

  username = "postgres"
  password = "7784a9c031274776f4a922b75a3dad174c36f467dcee4e03"
  iam_database_authentication_enabled = true
}
