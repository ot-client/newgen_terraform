data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = "buildpiper"
    storage_account_name = "terraformstatebp"
    container_name       = "state-file"
    key                  = "env/dev/network-skeleton/terraform.tfstate"
  }
}
