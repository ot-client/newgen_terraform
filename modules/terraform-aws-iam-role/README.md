# AWS IAM roles and policies


Terraform module for creating IAM roles and policies. An IAM role is an IAM identity that you can create in your account that has specific permissions. An IAM role is similar to an IAM user, in that it is an AWS identity with permission policies that determine what the identity can and cannot do in AWS. However, instead of being uniquely associated with one person, a role is intended to be assumable by anyone who needs it. Also, a role does not have standard long-term credentials such as a password or access keys associated with it. Instead, when you assume a role, it provides you with temporary security credentials for your role session.


## Providers

| Name                                              | Version  |
|---------------------------------------------------|----------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.82.2   |
| <a name="terraform_module"></a> [Terraform](Terraform\module) | >= 1.12.1|


---

## Diagram

![image](https://github.com/user-attachments/assets/1db2db9d-8706-4d01-b98a-d55afa4a95b1)

---

## Requirements

What does this module do ?
1. Create AWS IAM policy. Take policy statement as a string input. 
2. Can create policy based on policy template documents. 
3. Create AWS IAM roles of type assume role, service roles and other.
4. Maps policies and roles together.

What does this module does not do ?
1. This module should not be used for IAM roles Anywhere.


## Modules

Design Considerations
1. Create templates for policies.
2. Create policies and role.
3. Map policies with role.

## Considerations
While creating the policy there are two option.
* Using policy template

    In case of policy template use "policy_template_file" for template file location and "policy_template_vars" for passing values to template.
* Using policy statement

    In case of policy statement use "policy_statement" parameter for passing string converted json formatted aws policy.


## Usage

```

module "assume_role" {
  source = "git@github.com:OT-CLOUD-KIT/terraform-aws-iam-role.git?ref=feature"

  env = "d"
  app = "bp"
  bu  = "ot"

  policies_tags = {
    Environment = "d"
    Application = "bp"
    BusinessUnit = "ot"
    Program = "edcil"
    Team = "lspl"
    Region = "us-east-1"
  }

  roles_tags = {
    Environment = "d"
    Application = "bp"
    BusinessUnit = "ot"
    Program = "edcil"
    Team = "lspl"
    Region = "us-east-1"
  }

  create_iam_roles       = true
  create_iam_policies    = true
  attach_policy_arns     = true
  attach_inline_policies = true


  policies = [
  {
    name                 = "ec2-access"
    path                 = null
    desc                 = "Allows full access to all EC2 resources and actions."
    policy_template_file = "policy-documents/ec2-full-access-policy.tpl"
  },

  {
    name                 = "s3-access"
    path                 = null
    desc                 = "Allows full access to all S3 buckets and related actions."
    policy_template_file = "policy-documents/s3-policy.tpl"
  }
]
roles = [
  {
    name = "ec2-access"
    path = "/"
    desc = "IAM role that can be assumed by IAM user 'Mohit' to manage EC2 and S3 resources."
    trust_policy = {
      policy_template_file = "policy-documents/assume-role-trust.tpl"
      policy_template_vars = {
        assume_type = "user"           # or "role"
        assume_name = "Mohit"
        account_id  = "509633460021"
      }
    }
    policies    = ["ec2-access", "s3-access"]
    policy_arns = [ "arn:aws:iam::aws:policy/ReadOnlyAccess" ]
  },

  {
    name = "s3-access"
    path = "/"
    desc = "IAM role that can be assumed by role 'demo-a' to access S3 resources with limited (read-only) permissions."
    trust_policy = {
      policy_template_file = "policy-documents/assume-role-trust.tpl"
      policy_template_vars = {
        assume_type = "role"
        assume_name = "demo-a"
        account_id  = "509633460021"
      }
    }
    policies    = ["s3-access"]
    policy_arns = [ "arn:aws:iam::aws:policy/ReadOnlyAccess" ]
  }
]

}

```

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.roles](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.inline_policy_attachments](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.policy_arn_attachments](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.policy_attachments](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_force_detach_policies"></a> [force\_detach\_policies](#input\_force\_detach\_policies) | Specifies to force detaching any policies the role has before destroying it. | `bool` | `true` | no |
| <a name="input_max_session_duration"></a> [max\_session\_duration](#input\_max\_session\_duration) | The maximum session duration (in seconds) that you want to set for the specified role. This setting can have a value from 1 hour to 12 hours specified in seconds. | `string` | `"3600"` | no |
| <a name="input_permissions_boundaries"></a> [permissions\_boundaries](#input\_permissions\_boundaries) | A map of strings containing ARN's of policies to attach as permissions boundaries to roles. | `map(string)` | `{}` | no |
| <a name="input_policies"></a> [policies](#input\_policies) | A list of dictionaries defining all roles. | <pre>list(object({<br>    name = string      # Name of the policy<br>    path = string      # Defaults to 'var.policy_path' variable is set to null<br>    desc = string      # Defaults to 'var.policy_desc' variable is set to null<br>    file = string      # Path to json or json.tmpl file of policy<br>    vars = map(string) # Policy template variables {key: val, ...}<br>  }))</pre> | `[]` | no |
| <a name="input_policy_desc"></a> [policy\_desc](#input\_policy\_desc) | The default description of the policy. | `string` | `"Managed by Terraform"` | no |
| <a name="input_policy_path"></a> [policy\_path](#input\_policy\_path) | The default path under which to create the policy if not specified in the policies list. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division\_abc/subdivision\_xyz/product\_1234/engineering/ to match your company's organizational structure. | `string` | `"/"` | no |
| <a name="input_role_desc"></a> [role\_desc](#input\_role\_desc) | The description of the role. | `string` | `"Managed by Terraform"` | no |
| <a name="input_role_path"></a> [role\_path](#input\_role\_path) | The path under which to create the role. You can use a single path, or nest multiple paths as if they were a folder structure. For example, you could use the nested path /division\_abc/subdivision\_xyz/product\_1234/engineering/ to match your company's organizational structure. | `string` | `"/"` | no |
| <a name="input_roles"></a> [roles](#input\_roles) | A list of dictionaries defining all roles. | <pre>list(object({<br>    name              = string       # Name of the role<br>    path              = string       # Defaults to 'var.role_path' variable is set to null<br>    desc              = string       # Defaults to 'var.role_desc' variable is set to null<br>    trust_policy      = object({<br>      file = string      # Path to json or json.tmpl file of policy<br>      vars = map(string) # Policy template variables {key = val, ...}<br>    })<br>    policies          = list(string) # List of names of policies (must be defined in var.policies)<br>    inline_policies = list(object({<br>      name = string      # Name of the inline policy<br>      file = string      # Path to json or json.tmpl file of policy<br>      vars = map(string) # Policy template variables {key = val, ...}<br>    }))<br>    policy_arns = list(string) # List of existing policy ARN's<br>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value mapping of tags for the IAM role. | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_policies"></a> [policies](#output\_policies) | ARN of the IAM policies |
| <a name="output_roles"></a> [roles](#output\_roles) | ARN of the IAM role |


## Contributors

- [Piyush Upadhyay](https://github.com/piiiyuushh)
- [Nikita Joshi](https://github.com/jnikita19)
