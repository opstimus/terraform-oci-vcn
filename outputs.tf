output "vcn_id" {
  description = "The ID of the VCN."
  value       = oci_core_vcn.main.id
}

output "vcn_cidr_blocks" {
  description = "The CIDR blocks of the VCN."
  value       = oci_core_vcn.main.cidr_blocks
}

output "public_subnet_cidr_block" {
  description = "The CIDR block of the public subnet."
  value = {
    for name, subnet in oci_core_subnet.public :
    name => subnet.cidr_block
  }
}

output "private_subnet_cidr_block" {
  description = "The CIDR block of the private subnet."
  value = {
    for name, subnet in oci_core_subnet.private :
    name => subnet.cidr_block
  }
}

output "public_route_table_id" {
  description = "The ID of the public route table."
  value       = oci_core_route_table.main.id
}

output "private_route_table_id" {
  description = "The ID of the private route table."
  value = {
    for name, route_table in oci_core_route_table.private :
    name => route_table.id
  }
}
