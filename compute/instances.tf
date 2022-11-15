resource "tls_private_key" "tls_connector" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "myKeyPair" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.tls_connector.public_key_openssh
}

data "aws_ami" "linux2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"] # Amazon
}

resource "aws_instance" "BastionHostA" {
  ami                    = data.aws_ami.linux2.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.myKeyPair.key_name
  vpc_security_group_ids = [var.BastionSG]
  subnet_id              = var.publicSubnetA

  tags = {
    Name = "BastionHostA"
  }

  root_block_device {
    delete_on_termination = "true"
  }
}

resource "aws_instance" "BastionHostB" {
  ami                    = data.aws_ami.linux2.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.myKeyPair.key_name
  vpc_security_group_ids = [var.BastionSG]
  subnet_id              = var.publicSubnetB

  tags = {
    Name = "BastionHostB"
  }

  root_block_device {
    delete_on_termination = "true"
  }
}

resource "aws_instance" "BastionHostC" {
  ami                    = data.aws_ami.linux2.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.myKeyPair.key_name
  vpc_security_group_ids = [var.BastionSG]
  subnet_id              = var.publicSubnetC

  tags = {
    Name = "BastionHostC"
  }

  root_block_device {
    delete_on_termination = "true"
  }
}

// resource "aws_instance" "AppServerA" {
//   ami           = data.aws_ami.linux2.id
//   instance_type = "t3.micro"
//   key_name      = aws_key_pair.myKeyPair.key_name
//   vpc_security_group_ids = [var.AppSG]
//   subnet_id     = var.appA

//   tags = {
//     Name = "AppServerA"
//   }

//   root_block_device {
//     delete_on_termination = "true"
//   }
// }

// resource "aws_instance" "AppServerB" {
//   ami           = data.aws_ami.linux2.id
//   instance_type = "t3.micro"
//   key_name      = aws_key_pair.myKeyPair.key_name
//   vpc_security_group_ids = [var.AppSG]
//   subnet_id     = var.appB

//   tags = {
//     Name = "AppServerB"
//   }

//   root_block_device {
//     delete_on_termination = "true"
//   }
// }

// resource "aws_instance" "AppServerC" {
//   ami           = data.aws_ami.linux2.id
//   instance_type = "t3.micro"
//   key_name      = aws_key_pair.myKeyPair.key_name
//   vpc_security_group_ids = [var.AppSG]
//   subnet_id     = var.appC

//   tags = {
//     Name = "AppServerC"
//   }

//   root_block_device {
//     delete_on_termination = "true"
//   }
// }

resource "local_file" "myLabKeyPairFile" {
  content  = tls_private_key.tls_connector.private_key_pem
  filename = "myLabKeyPair.pem"
}