resource "aws_subnet" "dbA" {
  vpc_id            = var.vpc_id
  cidr_block        = var.dbA_subnet_cidr_block
  availability_zone = var.dbAaz

  tags = {
    Name = "DbA"
  }
}

resource "aws_subnet" "dbB" {
  vpc_id            = var.vpc_id
  cidr_block        = var.dbB_subnet_cidr_block
  availability_zone = var.dbBaz

  tags = {
    Name = "DbB"
  }
}

resource "aws_subnet" "dbC" {
  vpc_id            = var.vpc_id
  cidr_block        = var.dbC_subnet_cidr_block
  availability_zone = var.dbCaz

  tags = {
    Name = "DbC"
  }
}

data "aws_secretsmanager_random_password" "db" {
  password_length = 32
  exclude_punctuation = true
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "busybee-rds-subnet-group"
  description = "Subnet Group for RDS instances"
  subnet_ids = [
    "${aws_subnet.dbA.id}",
    "${aws_subnet.dbB.id}",
    "${aws_subnet.dbC.id}"
  ]
  tags = {
    "Name" = "busybee-rds-subnet-group"
  }
}

resource "aws_db_parameter_group" "main" {
  name   = "main"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}


resource "aws_db_instance" "main" {
  identifier        = "busybee-coffee-mysql"
  allocated_storage = 10
  copy_tags_to_snapshot = true
  deletion_protection = false
  engine            = "mysql"
  engine_version    = "8.0.23"
  instance_class    = "db.t3.micro"
  username = "admin"
  password               = data.aws_secretsmanager_random_password.db.random_password
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  port                   = 3306
  publicly_accessible    = false
  skip_final_snapshot    = true
  storage_encrypted = true
  vpc_security_group_ids = [var.dbSG]
  depends_on = [
    data.aws_secretsmanager_random_password.db
  ]
}
