output "security_groups" {
  description = "Map of all security groups (new and existing) with their IDs"
  value = merge(
    # New security groups
    {
      for k, v in aws_security_group.sg : k => {
        id   = v.id
        name = v.name
        arn  = v.arn
        type = "new"
      }
    },
    # Existing security groups
    {
      for k, v in data.aws_security_group.existing : k => {
        id   = v.id
        name = v.name
        arn  = v.arn
        type = "existing"
      }
    }
  )
}

output "security_group_ids" {
  description = "Map of security group names to IDs (both new and existing)"
  value = merge(
    # New security groups
    {
      for k, v in aws_security_group.sg : k => v.id
    },
    # Existing security groups
    {
      for k, v in data.aws_security_group.existing : k => v.id
    }
  )
}

output "new_security_groups" {
  description = "Map of newly created security groups"
  value = {
    for k, v in aws_security_group.sg : k => {
      id   = v.id
      name = v.name
      arn  = v.arn
    }
  }
}

output "existing_security_groups" {
  description = "Map of existing security groups that had rules added"
  value = {
    for k, v in data.aws_security_group.existing : k => {
      id   = v.id
      name = v.name
      arn  = v.arn
    }
  }
}