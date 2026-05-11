######################################
# OIDC Identity Provider
######################################
resource "aws_iam_openid_connect_provider" "identity_provider" {
  count           = var.create_oidc_provider ? 1 : 0
  url             = var.oidc_issuer_url
  client_id_list  = var.oidc_client_id_list
  thumbprint_list = var.oidc_thumbprint_list

  tags = merge(
    { Name = var.oidc_provider_name },
    local.common_tags
  )
}

locals {
  # Use existing OIDC provider ARN if provided, otherwise use the one created above
  oidc_provider_arn = var.existing_oidc_provider_arn != null ? var.existing_oidc_provider_arn : aws_iam_openid_connect_provider.identity_provider[0].arn
  oidc_provider_url = var.existing_oidc_provider_arn != null ? replace(var.existing_oidc_provider_arn, "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/", "") : replace(aws_iam_openid_connect_provider.identity_provider[0].url, "https://", "")
}

data "aws_caller_identity" "current" {}

######################################
# IRSA Roles (Web Identity)
######################################
resource "aws_iam_role" "irsa" {
  for_each = var.irsa_roles

  name = each.key

  assume_role_policy = var.custom_trust_policy != null ? var.custom_trust_policy : jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = local.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_provider_url}:sub" = each.value.service_account
          "${local.oidc_provider_url}:aud" = var.oidc_client_id_list[0]
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
