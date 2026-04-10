resource "aws_launch_template" "template" {
  for_each = var.launch_templates

  name          = each.key
  instance_type = each.value.instance_type

  metadata_options {
    http_endpoint               = each.value.metadata_http_endpoint
    http_tokens                 = each.value.metadata_http_tokens
    http_put_response_hop_limit = each.value.metadata_hop_limit
  }

  block_device_mappings {
    device_name = each.value.volume_device_name

    ebs {
      volume_size           = each.value.volume_size
      volume_type           = each.value.volume_type
      delete_on_termination = each.value.delete_on_termination
      encrypted             = each.value.encrypted
      throughput            = each.value.throughput
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      { Name = each.key },
      local.common_tags
    )
  }

  tags = merge(
    { Name = each.key },
    local.common_tags
  )
}
