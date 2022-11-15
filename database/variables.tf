variable "vpc_id" {
  type = string
}

variable "dbA_subnet_cidr_block" {
  type    = string
  default = "172.16.8.0/24"
}

variable "dbB_subnet_cidr_block" {
  type    = string
  default = "172.16.9.0/24"
}

variable "dbC_subnet_cidr_block" {
  type    = string
  default = "172.16.10.0/24"
}

variable "dbAaz" {
  description = "Database A Availability Zone"
}

variable "dbBaz" {
  description = "Database B Availability Zone"
}

variable "dbCaz" {
  description = "Database C Availability Zone"
}

variable "dbSG" {
  description = "Database Security Group ID"
}

