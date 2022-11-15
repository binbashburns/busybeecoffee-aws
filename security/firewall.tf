resource "aws_security_group" "BastionSG" {
  name        = "BastionSG"
  description = "Allow ssh"
  vpc_id      = var.vpc_id

  tags = {
    Name = "BastionSG"
  }

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "AlbSG" {
  name        = "AlbSG"
  description = "Allow ssh"
  vpc_id      = var.vpc_id

  tags = {
    Name = "AlbSG"
  }

  ingress {
    protocol         = "icmp"
    from_port        = 8
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    protocol         = "tcp"
    from_port        = 443
    to_port          = 443
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "EcsSG" {
  name        = "EcsSG"
  description = "Allow traffic from bastion hosts and ALB"
  vpc_id      = var.vpc_id

  tags = {
    Name = "EcsSG"
  }

  ingress {
    from_port       = "22"
    to_port         = "22"
    protocol        = "TCP"
    security_groups = [aws_security_group.BastionSG.id]
  }

  ingress {
    from_port       = "32768"
    to_port         = "65535"
    protocol        = "TCP"
    security_groups = [aws_security_group.AlbSG.id]
  }

  ingress {
    protocol         = "icmp"
    from_port        = 8
    to_port          = 0
    security_groups = [aws_security_group.AlbSG.id]
  }

  ingress {
    from_port       = "80"
    to_port         = "80"
    protocol        = "TCP"
    security_groups = [aws_security_group.AlbSG.id]
  }

  ingress {
    from_port       = "443"
    to_port         = "443"
    protocol        = "TCP"
    security_groups = [aws_security_group.AlbSG.id]
  }

  ingress {
    from_port       = "3306"
    to_port         = "3306"
    protocol        = "TCP"
    security_groups = [aws_security_group.dbSG.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "AppSG" {
  name        = "AppSG"
  description = "Allow ssh"
  vpc_id      = var.vpc_id

  tags = {
    Name = "AppSG"
  }

  ingress {
    from_port       = "22"
    to_port         = "22"
    protocol        = "TCP"
    security_groups = [aws_security_group.BastionSG.id]
  }

  ingress {
    protocol         = "icmp"
    from_port        = 8
    to_port          = 0
    security_groups = [aws_security_group.AlbSG.id]
  }

  ingress {
    from_port       = "80"
    to_port         = "80"
    protocol        = "TCP"
    security_groups = [aws_security_group.AlbSG.id]
  }

  ingress {
    from_port       = "443"
    to_port         = "443"
    protocol        = "TCP"
    security_groups = [aws_security_group.AlbSG.id]
  }

  ingress {
    from_port       = "80"
    to_port         = "80"
    protocol        = "TCP"
    security_groups = [aws_security_group.AlbSG.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db_access_sg" {
  name        = "db-access-sg"
  vpc_id      = var.vpc_id
  description = "Allow access to RDS"

  tags = {
    "Name" = "db-access-sg"
  }
}

resource "aws_security_group" "dbSG" {
  name        = "dbSG"
  description = "Allow mySQL"
  vpc_id      = var.vpc_id

  tags = {
    Name = "dbSG"
  }

  ingress {
    from_port = 0
    protocol  = "-1"
    self      = true
    to_port   = 0
  }

  ingress {
    from_port       = "3306"
    to_port         = "3306"
    protocol        = "TCP"
    security_groups = [aws_security_group.db_access_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}