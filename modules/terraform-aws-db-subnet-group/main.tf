resource "aws_db_subnet_group" "this" {
  name       = var.name
  subnet_ids = var.subnet_ids

  tags = merge(
    {
      Name = var.name
    },
    local.common_tags
  )
}
