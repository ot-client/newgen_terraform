{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListAllMyBuckets",      // List buckets
        "s3:ListBucket",            // List objects in a bucket
        "s3:GetBucketLocation",     // See where bucket is hosted
        "s3:GetObject",             // Read objects
        "s3:GetBucketPolicyStatus", // View bucket policy
        "s3:GetBucketAcl",          // View bucket ACL
        "s3:GetObjectAcl"           // View object ACL
      ],
      "Resource": "*"
    }
  ]
}
