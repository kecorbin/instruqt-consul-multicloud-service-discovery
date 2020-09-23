provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

// provider "azurerm" {
//   version = "=2.13.0"
//   features {}
// }

data "terraform_remote_state" "networking" {
  backend = "local"

  config = {
    path = "../networking/terraform.tfstate"
  }
}
