provider "azuredevops" {
  org_service_url       = var.AZURE_DEVOPS_ORG_SERVICE_URL #export AZDO_ORG_SERVICE_URL
  personal_access_token = var.AZURE_DEVOPS_PERSONAL_TOKEN  #export AZDO_PERSONAL_ACCESS_TOKEN
}

// Cria um projeto no Azure Devops
resource "azuredevops_project" "project" {
  name               = "Azure_Devops_With_Terraform"
  description        = "Test with azure devops and terraform"
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"
}

// Criar um service endpoint para dar permissão para gerenciar os serviços do Azure Devops
resource "azuredevops_serviceendpoint_azurerm" "endpointazure" {
  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "Sample AzureRM"
  description               = "Permission to manage Azure Devops"
  credentials {
    serviceprincipalid      = var.SERVICE_PRINCIPAL_ID
    serviceprincipalkey     = var.SERVICE_PRINCIPAL_KEY
  }
  azurerm_spn_tenantid      = var.TENANT_ID
  azurerm_subscription_id   = var.SUBSCRIPTION_ID
  azurerm_subscription_name = "Microsoft Azure DEMO"
}

// Cria um repositório
resource "azuredevops_git_repository" "infra_repository" {
  project_id = azuredevops_project.project.id
  name       = "infrastructure"
  initialization {
    init_type = "Clean"
  }
}

resource "azuredevops_git_repository" "typescript_repository" {
  project_id = azuredevops_project.project.id
  name       = "typescript_example"
  initialization {
    init_type = "Import"
    source_type = "Git"
    source_url = "https://github.com/williampenna/typescript-boilerplate.git"
  }
}

// Cria um grupo de variáveis de ambiente
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

// Criar um trigger na branch develop quando alguma alteração é realizada
resource "azuredevops_build_definition" "ci_trigger_build_infra" {
  project_id      = azuredevops_project.project.id
  name            = "infrastructure_ci"
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
    name  = "TF_VAR_ENVIRONMENT"
    value = "dev"
  }

  variable {
    name  = "TF_VAR_SUBSCRIPTION_ID"
    value = var.SUBSCRIPTION_ID
  }

  variable {
    name  = "TF_VAR_TENANT_ID"
    value = var.TENANT_ID
  }

  variable {
    name  = "TF_VAR_PROJECT"
    value = "willtests"
  }

  variable {
    name  = "TF_VAR_LOCATION"
    value = "eastus2"
  }
}

resource "azuredevops_build_definition" "ci_trigger_build_typescript" {
  project_id      = azuredevops_project.project.id
  name            = "typescript_ci"
  agent_pool_name = "Azure Pipelines"
  ci_trigger {
    use_yaml = true
  }
  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.infra_repository.id
    branch_name = "develop"
    yml_path    = "azure_pipelines_pr_build.yml"
  }
  variable_groups = [azuredevops_variable_group.vars.id]
  variable {
    name  = "TF_VAR_ENVIRONMENT"
    value = "dev"
  }

  variable {
    name  = "TF_VAR_SUBSCRIPTION_ID"
    value = var.SUBSCRIPTION_ID
  }

  variable {
    name  = "TF_VAR_TENANT_ID"
    value = var.TENANT_ID
  }

  variable {
    name  = "TF_VAR_PROJECT"
    value = "will_test_typescript"
  }

  variable {
    name  = "TF_VAR_LOCATION"
    value = "eastus2"
  }
}

// Gerencia o direito do usuário no Azure Devops
# resource "azuredevops_user_entitlement" "william_user" {
#   principal_name = "williamcezart@gmail.com"
# }

// Grupo de leitura no projeto
data "azuredevops_group" "project_readers" {
  project_id = azuredevops_project.project.id
  name       = "Readers"
}
// Grupo de contribuinte no projeto
data "azuredevops_group" "project_contributors" {
  project_id = azuredevops_project.project.id
  name       = "Contributors"
}

// Gerencia um grupo no Azure Devops
resource "azuredevops_group" "groups" {
  scope        = azuredevops_project.project.id
  display_name = "Test group"
  description  = "Test description"

  members = [
    data.azuredevops_group.project_readers.descriptor,
    data.azuredevops_group.project_contributors.descriptor
  ]
}

// Gerencia os membros filiados ao grupo
# resource "azuredevops_group_membership" "membership" {
#   group = data.azuredevops_group.project_contributors.descriptor
#   members = [
#     azuredevops_user_entitlement.william_user.descriptor
#   ]
# }

// Gerencia as permissões a um determinado repositório e branch do Azure Repos
# resource "azuredevops_git_permissions" "project_git_branch_permissions" {
#   project_id    = azuredevops_project.project.id
#   repository_id = azuredevops_git_repository.infra_repository.id
#   branch_name   = "develop"
#   principal     = data.azuredevops_group.project_contributors.id
#   permissions   = {
#     RemoveOthersLocks = "Allow"
#     ForcePush         = "Deny"
#   }
# }
