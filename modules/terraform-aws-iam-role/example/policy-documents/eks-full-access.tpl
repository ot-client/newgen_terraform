{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "eks:ListClusters",
        "eks:DescribeCluster",
        "eks:CreateCluster",
        "eks:DeleteCluster",
        "eks:UpdateClusterConfig",
        "eks:ListNodegroups",
        "eks:DescribeNodegroup",
        "eks:CreateNodegroup",
        "eks:DeleteNodegroup",
        "eks:UpdateNodegroupConfig"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:PassRole"
      ],
      "Resource": "arn:aws:iam::*:role/eks-*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeRouteTables",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    }
  ]
}
