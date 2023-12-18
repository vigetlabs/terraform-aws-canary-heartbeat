variable "heartbeat_endpoint" {
  type        = string
  description = "The URL for the canary to check if the site is healthy."
}

variable "take_screenshot" {
  type        = bool
  description = "Take a screenshot of the response when the canary runs."
  default     = true
}

variable "schedule_expression" {
  type        = string
  description = "The schedule expression for the canary to run see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/synthetics_canary#expression."
  default     = "rate(15 minutes)"
}

variable "timeout_in_seconds" {
  type        = number
  description = "The timeout in seconds for the canary to run before it must stop."
  default     = 60
}

variable "artifacts_expiration_days" {
  type        = number
  description = "The number of days to keep artifacts for the canary."
  default     = 30
}
