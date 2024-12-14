variable "logs_retention_days" {
  description = "Number of days to retain logs per environment"
  type        = map(number)
  default = {
    dev     = 30
    staging = 60
    prod    = 90
  }
}