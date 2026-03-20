{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowDocumenetDBCreation",
      "Effect": "Allow",
      "Action": [
        "rds:CreateDBCluster",
        "rds:CreateDBInstance",
        "rds:DescribeDBClusters",
        "rds:DescribeDBInstances",
        "rds:DeleteDBCluster",
        "rds:DeleteDBInstance",
        "rds:ModifyDBCluster",
        "rds:ModifyDBInstance",
        "rds:ListTagsForResource",
        "rds:AddTagsToResource",
        "rds:RemoveTagsFromResource",
        "ec2:DescribeVpcs",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:CreateSecurityGroup",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:AuthorizeSecurityGroupEgress",
        "cloudwatch:PutMetricData",
        "cloudwatch:GetMetricData",
        "cloudwatch:ListMetrics",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "kms:DescribeKey",
        "kms:ListKeys",
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey",
        "iam:PassRole",
        "iam:GetRole",
        "iam:CreateRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy"
      ],
      "Resource": "*"
    }
  ]
}
