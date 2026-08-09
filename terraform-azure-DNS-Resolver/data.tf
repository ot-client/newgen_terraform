data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = "Buildpiper-test"
    storage_account_name = "buildpiperstate"
    container_name       = "state-file"
    key                  = "env/dev/network-skeleton/terraform.tfstate"
  }
}
