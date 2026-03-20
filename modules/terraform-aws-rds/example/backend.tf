terraform {
  backend "s3" {
    bucket = "ot-cloud-kit-bucket"
    key    = "ot/module/RDS/terraform.tfstate"
    region = "us-east-1"

  }
}