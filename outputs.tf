output "azuredevops_project_id" {
  description   = "The ID of the project from Azure Devops"
  value         = "${azuredevops_project.project.id}"
}
