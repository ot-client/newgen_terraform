output "instance_ids" {
  description = "EC2 instance IDs"
  value = {
    for k, v in aws_instance.ec2 :
    k => v.id
  }
}

output "instance_arns" {
  description = "ARNs of EC2 instances"
  value = {
    for k, v in aws_instance.ec2 :
    k => v.arn
  }
}

output "elastic_ips" {
  description = "Elastic IPs (if enabled)"
  value = {
    for k, v in aws_eip.eip :
    k => v.public_ip
  }
}

output "instance_eni_ids" {
  description = "Primary network interface IDs of EC2 instances"
  value = {
    for k, v in aws_instance.ec2 :
    k => v.primary_network_interface_id
  }
}
