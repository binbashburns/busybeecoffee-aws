variable "vpc_cidr_block" {
  type    = string
  default = "172.16.0.0/16"
}

variable "publicA_subnet_cidr_block" {
  type    = string
  default = "172.16.1.0/24"
}

variable "publicB_subnet_cidr_block" {
  type    = string
  default = "172.16.2.0/24"
}

variable "publicC_subnet_cidr_block" {
  type    = string
  default = "172.16.3.0/24"
}

variable "appA_subnet_cidr_block" {
  type    = string
  default = "172.16.4.0/24"
}

variable "appB_subnet_cidr_block" {
  type    = string
  default = "172.16.5.0/24"
}

variable "appC_subnet_cidr_block" {
  type    = string
  default = "172.16.6.0/24"
}

variable "az1a" {
  type    = string
  default = "us-east-1a"
}

variable "az1b" {
  type    = string
  default = "us-east-1b"
}

variable "az1c" {
  type    = string
  default = "us-east-1c"
}

variable "AlbSG" {
  type = string
}

variable "sourceCodeBucketArn" {
  type = string
}

variable "dbAsub" {
  description = "Subnet of Database A"
}

variable "dbBsub" {
  description = "Subnet of Database B"
}

variable "dbCsub" {
  description = "Subnet of Database C"
}