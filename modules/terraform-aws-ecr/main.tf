#########################
# Private IAM Policies
#########################
data "aws_iam_policy_document" "ecr_private_repo_policy" {
  for_each = local.private_repos

  statement {
    sid    = "PullAccess"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = concat([local.current_account], local.only_pull_accounts)
    }
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]
  }

  statement {
    sid    = "PushAndPullAccess"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = concat([local.current_account], local.push_and_pull_accounts)
    }
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
  }
}

#########################
# Private ECR Repositories
#########################
resource "aws_ecr_repository" "ecr_private_repo" {
  for_each             = local.private_repos
  name                 = each.key
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.encryption_type == "KMS" ? var.kms_key_arn : null
  }

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = merge(
    {
      Name = each.key
    },
    local.common_tags
  )
}

resource "aws_ecr_repository_policy" "ecr_private_repo_policy" {
  for_each   = local.private_repos
  repository = aws_ecr_repository.ecr_private_repo[each.key].name
  policy     = data.aws_iam_policy_document.ecr_private_repo_policy[each.key].json
}

resource "aws_ecr_lifecycle_policy" "ecr_private_repo_lifecycle" {
  for_each = {
    for name, config in local.private_repos :
    name => config if config.max_untagged_image_count != null || config.max_tagged_image_count != null
  }

  repository = aws_ecr_repository.ecr_private_repo[each.key].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images"
        selection = {
          tagStatus   = "untagged"
          countType   = "imageCountMoreThan"
          countNumber = each.value.max_untagged_image_count
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Expire tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = var.tag_prefix_list
          countType     = "imageCountMoreThan"
          countNumber   = each.value.max_tagged_image_count
        }
        action = { type = "expire" }
      }
    ]
  })
}

#########################
# Public ECR Repositories
#########################
resource "aws_ecrpublic_repository" "ecr_public_repo" {
  for_each        = local.public_repos
  repository_name = each.key

  dynamic "catalog_data" {
    for_each = each.value.catalog_data != null ? [each.value.catalog_data] : []
    content {
      about_text        = try(catalog_data.value.about_text, null)
      architectures     = try(catalog_data.value.architectures, null)
      description       = try(catalog_data.value.description, null)
      logo_image_blob   = try(catalog_data.value.logo_image_blob, null)
      operating_systems = try(catalog_data.value.operating_systems, null)
      usage_text        = try(catalog_data.value.usage_text, null)
    }
  }

  tags = merge(
    {
      Name = each.key
    },
    local.common_tags
  )
}

resource "aws_ecrpublic_repository_policy" "ecr_public_repo_policy" {
  for_each        = local.public_repos
  repository_name = aws_ecrpublic_repository.ecr_public_repo[each.key].repository_name

  policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Sid       = "PublicPull"
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "ecr-public:GetRepositoryCatalogData",
          "ecr-public:DescribeImages",
          "ecr-public:GetRepositoryPolicy",
          "ecr-public:GetDownloadUrlForLayer",
          "ecr-public:BatchCheckLayerAvailability",
          "ecr-public:BatchGetImage"
        ]
      }
    ]
  })
}
