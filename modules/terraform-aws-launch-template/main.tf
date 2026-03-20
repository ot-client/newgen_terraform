resource "aws_launch_template" "template" {
  region        = var.region
  name          = var.name
  instance_type = var.instance_type
   metadata_options {
    http_endpoint               = var.metadata_http_endpoint
    http_tokens                 = var.metadata_http_tokens
    http_put_response_hop_limit = var.metadata_hop_limit
  }


  block_device_mappings {
    device_name = var.volume_device_name

    ebs {
      volume_size           = var.volume_size
      volume_type           = var.volume_type
      delete_on_termination = var.delete_on_termination
      encrypted             = var.encrypted
      throughput            = var.throughput
    }
  }

   tags = var.tags
}

