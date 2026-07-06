# =============================================================================
# variables.tf
# =============================================================================
variable "subscription_id" {
  description = "ID de suscripción. Vacío si usas ARM_SUBSCRIPTION_ID."
  type        = string
  default     = ""
}

variable "location" {
  description = "Región permitida por la UNIR."
  type        = string
  default     = "spaincentral"
}

variable "resource_group_name" {
  type    = string
  default = "rg-casopractico2"
}

variable "acr_name" {
  description = "Nombre del ACR (único global, minúsculas y números)."
  type        = string
  default     = "acrunircp2sbp"
}
