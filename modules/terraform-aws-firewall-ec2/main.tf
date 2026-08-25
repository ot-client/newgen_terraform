locals {
  common_tags    = { for k, v in var.tags : k => v if k != "Name" }
  eip_mode_count = (var.create_new_eip ? 1 : 0) + (var.existing_eip_allocation_id != "" ? 1 : 0)

  firewall_routes = {
    for route in flatten([
      for route_table_id in var.route_table_ids : [
        for destination in var.route_destination_cidr_blocks : {
          key              = "${route_table_id}-${replace(replace(destination, "/", "_"), ".", "_")}"
          route_table_id   = route_table_id
          destination_cidr = destination
        }
      ]
    ]) : route.key => route
  }
}

resource "tls_private_key" "firewall_key" {
  count = var.create_key_pair ? 1 : 0

  algorithm = var.private_key_algorithm
  rsa_bits  = var.private_key_rsa_bits
}

resource "aws_key_pair" "firewall_key_pair" {
  count = var.create_key_pair ? 1 : 0

  key_name   = var.key_name
  public_key = tls_private_key.firewall_key[0].public_key_openssh

  tags = merge(
    {
      Name = "${var.name}-key"
    },
    local.common_tags
  )
}

resource "local_file" "firewall_private_key" {
  count = var.create_key_pair && var.private_key_output_path != "" ? 1 : 0

  content         = tls_private_key.firewall_key[0].private_key_pem
  filename        = var.private_key_output_path
  file_permission = "0400"

  depends_on = [aws_key_pair.firewall_key_pair]
}

resource "aws_instance" "firewall" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = var.associate_public_ip_address
  key_name                    = var.create_key_pair ? aws_key_pair.firewall_key_pair[0].key_name : var.key_name
  iam_instance_profile        = var.iam_instance_profile
  disable_api_termination     = var.termination_protection
  source_dest_check           = var.source_dest_check
  user_data                   = var.user_data

  metadata_options {
    http_endpoint               = var.metadata_options.http_endpoint
    http_tokens                 = var.metadata_options.http_tokens
    http_put_response_hop_limit = var.metadata_options.http_put_response_hop_limit
  }

  root_block_device {
    volume_size           = var.root_block_device.size
    volume_type           = var.root_block_device.type
    throughput            = var.root_block_device.throughput
    iops                  = var.root_block_device.iops
    encrypted             = var.root_block_device.encrypted
    delete_on_termination = var.root_block_device.delete_on_termination
  }

  tags = merge(
    {
      Name = var.name
    },
    local.common_tags
  )

  lifecycle {
    precondition {
      condition     = local.eip_mode_count <= 1
      error_message = "Use either create_new_eip or existing_eip_allocation_id, not both."
    }
  }
}

resource "aws_ebs_volume" "additional_firewall_volumes" {
  for_each = {
    for idx, volume in var.additional_volumes : idx => volume
  }

  availability_zone = aws_instance.firewall.availability_zone
  size              = each.value.size
  type              = each.value.type
  throughput        = each.value.throughput
  iops              = each.value.iops
  encrypted         = each.value.encrypted

  tags = merge(
    {
      Name       = "${var.name}-vol-${each.key}"
      DeviceName = each.value.device_name
    },
    local.common_tags
  )
}

resource "aws_volume_attachment" "additional_firewall_volume_attachments" {
  for_each = aws_ebs_volume.additional_firewall_volumes

  device_name = each.value.tags_all["DeviceName"]
  volume_id   = each.value.id
  instance_id = aws_instance.firewall.id
}

resource "aws_eip" "new_firewall_eip" {
  count = var.create_new_eip ? 1 : 0

  instance = aws_instance.firewall.id
  domain   = "vpc"

  tags = merge(
    {
      Name = "${var.name}-eip"
    },
    local.common_tags
  )
}

resource "aws_eip_association" "existing_firewall_eip" {
  count = var.existing_eip_allocation_id != "" ? 1 : 0

  allocation_id        = var.existing_eip_allocation_id
  network_interface_id = aws_instance.firewall.primary_network_interface_id
  allow_reassociation  = true
}

resource "aws_route" "firewall_route_table_entries" {
  for_each = var.create_route_table_entries ? local.firewall_routes : {}

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr
  network_interface_id   = aws_instance.firewall.primary_network_interface_id
}
