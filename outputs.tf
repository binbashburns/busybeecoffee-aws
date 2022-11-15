output "vpc_id" {
  value       = module.network.vpc_id
  description = "The generated vpc id"
}

output "nacl_id" {
  value       = module.network.nacl_id
  description = "The generated nacl"
}

output "route_table_id" {
  value       = module.network.route_table_id
  description = "The generated route table"
}

output "tenancy" {
  value       = module.network.tenancy
  description = "The default tenancy"
}

output "dhcp_options_id" {
  value       = module.network.dhcp_options_id
  description = "The default dhcp_options_id"
}

output "default_security_group_id" {
  value       = module.network.default_security_group_id
  description = "The default security group id"
}

output "DnsName" {
  value       = module.network.DnsName
  description = "The registered dns name"
}