{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateVpc",
        "ec2:DescribeVpcs",
        "ec2:ModifyVpcAttribute",
        "ec2:DeleteVpc",
        "ec2:CreateSubnet",
        "ec2:DescribeSubnets",
        "ec2:DeleteSubnet",
        "ec2:CreateRouteTable",
        "ec2:AssociateRouteTable",
        "ec2:DescribeRouteTables",
        "ec2:DeleteRouteTable",
        "ec2:CreateRoute",
        "ec2:ReplaceRoute",
        "ec2:DeleteRoute",
        "route53:CreateHostedZone",
        "route53:ListHostedZones",
        "route53:DeleteHostedZone",
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets"
      ],
      "Resource": "*"
    }
  ]
}
