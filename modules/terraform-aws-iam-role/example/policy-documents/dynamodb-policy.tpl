{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DynamoDBTableManagement",
      "Effect": "Allow",
      "Action": [
        "dynamodb:CreateTable",
        "dynamodb:DeleteTable",
        "dynamodb:DescribeTable",
        "dynamodb:ListTables",
        "dynamodb:UpdateTable",
        "dynamodb:TagResource",
        "dynamodb:UntagResource",
        "dynamodb:ListTagsOfResource"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DynamoDBItemManagement",
      "Effect": "Allow",
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:DeleteItem",
        "dynamodb:UpdateItem",
        "dynamodb:BatchGetItem",
        "dynamodb:BatchWriteItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DynamoDBIndexManagement",
      "Effect": "Allow",
      "Action": [
        "dynamodb:CreateGlobalTable",
        "dynamodb:UpdateGlobalTable",
        "dynamodb:DescribeGlobalTable",
        "dynamodb:DescribeGlobalTableSettings"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DynamoDBBackupManagement",
      "Effect": "Allow",
      "Action": [
        "dynamodb:CreateBackup",
        "dynamodb:DeleteBackup",
        "dynamodb:DescribeBackup",
        "dynamodb:ListBackups",
        "dynamodb:RestoreTableFromBackup",
        "dynamodb:CreateTableReplica"
      ],
      "Resource": "*"
    }
  ]
}