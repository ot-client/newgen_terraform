resource "aws_iam_policy" "custom" {
  for_each = var.custom_policies

  name        = local.policy_names[each.key]
  description = each.value.description
  policy      = each.value.policy_json
  tags = merge(
    { Name = local.policy_names[each.key] },
    local.common_tags
  )
}

resource "aws_iam_role" "roles" {
  for_each = var.roles

  name = local.role_names[each.key]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = var.assume_role_service
      }
      Action = "sts:AssumeRole"
    }]
  })
  tags = merge(
    { Name = local.role_names[each.key] },
    local.common_tags
  )
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = local.managed_policy_attachments_map

  role       = aws_iam_role.roles[each.value.role].name
  policy_arn = each.value.arn
}

resource "aws_iam_role_policy_attachment" "custom" {
  for_each = local.custom_policy_attachments_map

  role       = aws_iam_role.roles[each.value.role].name
  policy_arn = aws_iam_policy.custom[each.value.policy].arn
}

resource "aws_iam_instance_profile" "this" {
  for_each = aws_iam_role.roles

  name = each.key
  role = each.value.name
}
