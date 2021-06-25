terraform {
  required_providers {
    azuredevops = {
      source                = "microsoft/azuredevops"
      version               = ">=0.1.0"
    }
  }
}

provider "azuredevops" {
  org_service_url       = "https://dev.azure.com/williamcezart" #export AZDO_ORG_SERVICE_URL
  personal_access_token = "d37fy4nxruqd3nla7akvensx7qunfakweufpfealxqoamvwj3quq" #export AZDO_PERSONAL_ACCESS_TOKEN
}

resource "azuredevops_project" "project" {
  name               = "Azure_Devops_With_Terraform"
  description        = "Test with azure devops and terraform"
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"
}

resource "azuredevops_git_repository" "infra_repository" {
  project_id = azuredevops_project.project.id
  name       = "Infrastructure Repository"
  initialization {
    init_type = "Clean"
  }
}

resource "azuredevops_git_repository" "backend_repository" {
  project_id = azuredevops_project.project.id
  name       = "Back-end Repository"
  initialization {
    init_type = "Import"
    source_type = "Git"
    source_url = "https://github.com/williampenna/typescript-boilerplate.git"
  }
}