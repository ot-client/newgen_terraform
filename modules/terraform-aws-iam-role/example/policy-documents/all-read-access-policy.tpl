{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ReadOnlyAccessAllResources",
      "Effect": "Allow",
      "Action": [
        "*:Get*",
        "*:List*",
        "*:Describe*"
      ],
      "Resource": "*"
    }
  ]
}
