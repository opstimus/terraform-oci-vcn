data "oci_identity_availability_domains" "main" {
  compartment_id = var.tenancy_id
}

resource "oci_core_vcn" "main" {
  compartment_id = var.compartment_id
  display_name   = "${var.project}-${var.environment}-vcn"
  cidr_blocks    = var.vcn_cidr_blocks
  freeform_tags  = var.tags
}

resource "oci_core_internet_gateway" "main" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  enabled        = true
  display_name   = "${var.project}-${var.environment}-internet-gateway"
  freeform_tags  = var.tags
}

resource "oci_core_security_list" "main" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project}-${var.environment}-security-list"
  freeform_tags  = var.tags

  ingress_security_rules {
    description = "Allow all inbound from anywhere"
    protocol    = "all" # TCP
    source      = oci_core_vcn.main.cidr_blocks[0]
    source_type = "CIDR_BLOCK"
  }

  egress_security_rules {
    description      = "Allow all outbound traffic"
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
}

resource "oci_core_public_ip" "main" {
  compartment_id = var.compartment_id
  lifetime       = "RESERVED"
  display_name   = "${var.project}-${var.environment}-nat-gateway"
  freeform_tags  = var.tags
}

resource "oci_core_nat_gateway" "private" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  block_traffic  = true
  display_name   = "${var.project}-${var.environment}-nat-gateway"
  public_ip_id   = oci_core_public_ip.main.id
  freeform_tags  = var.tags
}

resource "oci_core_route_table" "main" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project}-${var.environment}-public"
  route_rules {
    #Required
    network_entity_id = oci_core_internet_gateway.main.id
    #Optional
    description      = "Internet Access"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
  freeform_tags = var.tags
}

resource "oci_core_subnet" "public" {
  for_each                  = var.public_subnets
  compartment_id            = var.compartment_id
  vcn_id                    = oci_core_vcn.main.id
  display_name              = "${var.project}-${var.environment}-${each.key}"
  cidr_block                = each.value
  prohibit_internet_ingress = false
  route_table_id            = oci_core_route_table.main.id
  freeform_tags             = var.tags
}

resource "oci_core_route_table" "private" {
  for_each       = var.private_subnets
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project}-${var.environment}-${each.key}"

  route_rules {
    #Required
    network_entity_id = oci_core_nat_gateway.private.id
    #Optional
    description      = "NAT Gateway Access"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
  freeform_tags = var.tags
}

resource "oci_core_subnet" "private" {
  for_each                  = var.private_subnets
  compartment_id            = var.compartment_id
  vcn_id                    = oci_core_vcn.main.id
  display_name              = "${var.project}-${var.environment}-${each.key}"
  cidr_block                = each.value
  prohibit_internet_ingress = true
  route_table_id            = oci_core_route_table.private[each.key].id
  security_list_ids         = [oci_core_security_list.main.id]
  freeform_tags             = var.tags
}
