terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">=0.1.0"
    }
  }
}

provider "azuredevops" {
  org_service_url       = var.AZURE_DEVOPS_ORG_SERVICE_URL #export AZDO_ORG_SERVICE_URL
  personal_access_token = var.AZURE_DEVOPS_PERSONAL_TOKEN  #export AZDO_PERSONAL_ACCESS_TOKEN
}

resource "azuredevops_project" "project" {
  name               = "Azure_Devops_With_Terraform"
  description        = "Test with azure devops and terraform"
  visibility         = "public"
  version_control    = "Git"
  work_item_template = "Agile"
}

resource "azuredevops_git_repository" "infra_repository" {
  project_id = azuredevops_project.project.id
  name       = "infrastructure"
  initialization {
    init_type = "Clean"
  }
}

resource "azuredevops_variable_group" "vars" {
  project_id   = azuredevops_project.project.id
  name         = "dev-vars"
  description  = "Managed by Terraform"
  allow_access = true

  variable {
    name  = "ENVIRONMENT"
    value = "dev"
  }
}

resource "azuredevops_build_definition" "ci_trigger_build_infra" {
  project_id      = azuredevops_project.project.id
  name            = "Build Definition for cloud resources creation"
  agent_pool_name = "Azure Pipelines"
  ci_trigger {
    use_yaml = true
  }
  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.infra_repository.id
    branch_name = "develop"
    yml_path    = "infra.yml"
  }
  variable_groups = [azuredevops_variable_group.vars.id]
  variable {
    name  = "ENVIRONMENT"
    value = "dev"
  }
}
