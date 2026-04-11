######################################
# OIDC Identity Provider
######################################
resource "aws_iam_openid_connect_provider" "this" {
  url             = var.oidc_issuer_url
  client_id_list  = var.oidc_client_id_list
  thumbprint_list = var.oidc_thumbprint_list

  tags = merge(
    { Name = var.oidc_provider_name },
    local.common_tags
  )
}

######################################
# IRSA Roles (Web Identity)
######################################
resource "aws_iam_role" "irsa" {
  for_each = var.irsa_roles

  name = each.key

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.this.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub" = each.value.service_account
          "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:aud" = var.oidc_client_id_list[0]
        }
      }
    }]
  })

  tags = merge(
    { Name = each.key },
    local.common_tags
  )
}

######################################
# Managed Policy Attachments
######################################
resource "aws_iam_role_policy_attachment" "managed" {
  for_each = {
    for item in flatten([
      for role, data in var.irsa_roles : [
        for arn in data.managed_policy_arns : {
          key  = "${role}:${arn}"
          role = role
          arn  = arn
        }
      ]
    ]) : item.key => item
  }

  role       = aws_iam_role.irsa[each.value.role].name
  policy_arn = each.value.arn
}

######################################
# Inline Custom Policies
######################################
resource "aws_iam_policy" "custom" {
  for_each = var.custom_policies

  name        = each.key
  description = each.value.description
  policy      = each.value.policy_json

  tags = merge(
    { Name = each.key },
    local.common_tags
  )
}

resource "aws_iam_role_policy_attachment" "custom" {
  for_each = {
    for item in flatten([
      for role, data in var.irsa_roles : [
        for policy in data.custom_policy_names : {
          key    = "${role}:${policy}"
          role   = role
          policy = policy
        }
      ]
    ]) : item.key => item
  }

  role       = aws_iam_role.irsa[each.value.role].name
  policy_arn = aws_iam_policy.custom[each.value.policy].arn
}
