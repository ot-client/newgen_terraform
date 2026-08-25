# terraform-aws-firewall-ec2

Creates a dedicated firewall EC2 instance in its own Terraform state boundary.

This module is intended for firewall replacement or migration workflows where
the existing shared compute state must not be changed.

## What It Manages

- One EC2 firewall instance
- Optional generated AWS key pair and local PEM file
- Optional additional EBS volumes
- Optional new EIP allocation and association
- Optional route-table entries targeting the firewall primary ENI

## Route Table Note

AWS VPC route tables do not use an Elastic IP as a route target. Firewall
routes should target the firewall instance primary network interface ID. The
EIP is used for public reachability or preserving a public source identity.

## Old EIP Cutover

Do not manage the old firewall EIP in this module while it is still managed by
the old compute state. For cutover, first stop managing or disassociate it from
the old state, then import or associate it under the intended owner.
