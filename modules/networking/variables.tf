# variables.tf
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "alb_config" {
  description = "ALB configuration for each environment"
  type = map(object({
    name                 = string
    internal            = bool
    deletion_protection = bool
    az_count            = number
  }))
  default = {
    dev = {
      name                 = "dev"
      internal            = false
      deletion_protection = false
      az_count            = 2
    }
    staging = {
      name                 = "staging"
      internal            = false
      deletion_protection = false
      az_count            = 3
    }
    prod = {
      name                 = "prod"
      internal            = false
      deletion_protection = true
      az_count            = 3
    }
  }
}

variable "target_groups" {
  description = "Target group configuration for each environment"
  type = map(object({
    name              = string
    port              = number
    health_check_path = string
  }))
  default = {
    dev = {
      name              = "dev"
      port              = 80
      health_check_path = "/health"
    }
    staging = {
      name              = "staging"
      port              = 80
      health_check_path = "/health"
    }
    prod = {
      name              = "prod"
      port              = 80
      health_check_path = "/health"
    }
  }
}

variable "security_group_config" {
  description = "Security group configuration for each environment"
  type = map(object({
    name           = string
    description    = string
    ingress_rules  = map(object({
      port        = number
      cidr_blocks = list(string)
    }))
  }))
  default = {
    dev = {
      name        = "dev"
      description = "Security group for Dev ALB"
      ingress_rules = {
        http = {
          port        = 80
          cidr_blocks = ["0.0.0.0/0"]
        }
        https = {
          port        = 443
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }

    dev = {
      name        = "staging"
      description = "Security group for Dev ALB"
      ingress_rules = {
        http = {
          port        = 80
          cidr_blocks = ["0.0.0.0/0"]
        }
        https = {
          port        = 443
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }

    dev = {
      name        = "prod"
      description = "Security group for Dev ALB"
      ingress_rules = {
        http = {
          port        = 80
          cidr_blocks = ["0.0.0.0/0"]
        }
        https = {
          port        = 443
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }
}

variable "bastion_host" {
  description = "Bastion host configuration"
  type = object({
    ami           = string
    instance_type = string
    key_name      = string
  })
  default = {
    ami           = "ami-12345"
    instance_type = "t2.micro"
    key_name      = "key"
  }
}

