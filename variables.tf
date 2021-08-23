variable "tenantId" {
  description = "Azure Tenant"
  sensitive   = true
}

variable "subscriptionId" {
  description = "Azure subscription"
  sensitive   = true
}

variable "appId" {
  description = "Azure service principal Id"
  sensitive   = true
}

variable "appId_password" {
  description = "Azure service principal password"
  sensitive   = true
}

variable "pg_administrator_login" {
  description = "Postgres admin login"
  sensitive   = true
}

variable "pg_administrator_login_password" {
  description = "Postgres admin login password"
  sensitive   = true
}
