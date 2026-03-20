env    = "d"
app    = "bp"

permissions_boundaries = {}

policy_desc = "Managed by Terraform"
policy_path = "/"

role_desc = "Managed by Terraform"
role_path = "/"

max_session_duration = 3600
force_detach_policies = true

# -------------------- POLICIES --------------------
policies = [
  {
    name                 = "test-policy"
    path                 = null
    desc                 = "Access to Glue services"
    policy_template_file = "./policy-documents/glue-policy.tpl"
  },

  {
    name                 = "test-policy-2"
    path                 = null
    desc                 = "Inline JSON policy for Glue access"
    policy_template_file = "./policy-documents/test.tpl"
    policy_template_vars = {
      policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "glue:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
    }
  },

  {
    name             = "test-policy-3"
    path             = null
    desc             = "Direct inline statement for Glue access"
    policy_statement = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "glue:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
  }
]

# -------------------- ROLES --------------------
roles = [
  {
    name = "test-1"
    path = "/"
    desc = "Role trusted by external AWS account user"
    trust_policy = {
      policy_template_file = "./policy-documents/assume-role-trust.tpl"
      policy_template_vars = {
        account_id       = "471112675494"
        assume_role_name = "root"
      }
    }
    policies    = ["test-policy-2"]
    policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  },

  {
    name = "test-2"
    path = "/"
    desc = "Role for EC2 service with Glue policy"
    trust_policy = {
      policy_template_file = "./policy-documents/service-role-trust.tpl"
      policy_template_vars = {
        service_name = "ec2.amazonaws.com"
      }
    }
    policies    = ["test-policy"]
    policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  },

  {
    name = "test-3"
    path = "/"
    desc = "EC2 role with direct inline Glue permissions"
    trust_policy = {
      policy_template_file = "./policy-documents/service-role-trust.tpl"
      policy_template_vars = {
        service_name = "ec2.amazonaws.com"
      }
    }
    inline_policies = [{
      name             = "test-policy-5"
      policy_statement = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["glue:*"],
      "Resource": "*"
    }
  ]
}
EOF
    }]
    policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  },

  {
    name = "test-4"
    path = "/"
    desc = "EC2 role with policy template vars for Glue"
    trust_policy = {
      policy_template_file = "./policy-documents/service-role-trust.tpl"
      policy_template_vars = {
        service_name = "ec2.amazonaws.com"
      }
    }
    inline_policies = [{
      name = "test-policy-4"
      policy_template_file = "./policy-documents/test.tpl"
      policy_template_vars = {
        policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["glue:*"],
      "Resource": "*"
    }
  ]
}
EOF
      }
    }]
  },

  {
    name = "test-5"
    path = "/"
    desc = "Basic EC2 role with no policies yet"
    trust_policy = {
      policy_template_file = "./policy-documents/service-role-trust.tpl"
      policy_template_vars = {
        service_name = "ec2.amazonaws.com"
      }
    }
  }
]
