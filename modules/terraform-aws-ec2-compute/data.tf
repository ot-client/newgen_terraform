data "aws_route_tables" "selected" {
  filter {
    name   = "tag:Name"
    values = var.route_table_names
  }
}

data "aws_security_group" "existing_sg_by_name" {
  for_each = toset([
    for rule_key, rule_value in var.security_group_ports :
    rule_value.source_sg_name
    if rule_value.source_sg_name != null
  ])
  
  filter {
    name   = "group-name"
    values = [each.value]
  }
}
