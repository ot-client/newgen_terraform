resource "aws_eks_node_group" "node_groups" {
  for_each     = var.create_node_group ? var.node_groups : tomap({})
  cluster_name         = var.cluster_name
  node_group_name      = each.key
  node_role_arn        = var.node_role_arn
  subnet_ids           = each.value.subnets

  launch_template {
    id      = each.value.launch_template_id
    version = "$Latest"
  }

  labels               = try(each.value.labels, {})
  capacity_type        = each.value.capacity_type
  force_update_version = var.force_update_version

  scaling_config {
    desired_size = each.value.desired_capacity
    max_size     = each.value.max_capacity
    min_size     = each.value.min_capacity
  }

  dynamic "taint" {
    for_each = try(each.value.taints, [])

    content {
      key    = taint.value.key
      value  = try(taint.value.value, null)
      effect = taint.value.effect
    }
  }

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
    ignore_changes        = [scaling_config.0.desired_size]

  }

}