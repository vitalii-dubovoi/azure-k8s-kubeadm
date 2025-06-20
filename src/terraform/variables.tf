variable "region" {
  description = "Main region of deployment"
  default     = "westus3"
}

variable "project" {
  description = "Project short name or alias"
  default     = "k8s-hw"
}
variable "personal_clientid" {}
variable "personal_client_secret" {}
variable "personal_tenantid" {}
variable "personal_subscriptionid" {}

variable "enable_telemetry" {
  description = "Is telemetry enabled for azure modules"
  default     = false
}