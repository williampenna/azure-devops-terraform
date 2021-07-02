# SECRETS, PLEASE PROVIDE THESE VALUES IN A TFVARS FILE
variable "SUBSCRIPTION_ID" {}
variable "TENANT_ID" {}
variable "AZURE_DEVOPS_PERSONAL_TOKEN" {}
variable "AZURE_DEVOPS_ORG_SERVICE_URL" {}

# GLOBAL VARIABLES
variable "RESOURCE_GROUP" {
  default = "testwill-dev-rg"
}
variable "LOCATION" {
  default = "eastus2"
}

variable "SERVICE_PRINCIPAL_ID" {
  description = "Service Principal Id"
  type        = string
}
variable "SERVICE_PRINCIPAL_KEY" {
  description = "Service Principal Password"
  type        = string
}