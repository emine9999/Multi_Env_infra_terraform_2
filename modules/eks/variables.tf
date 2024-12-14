
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.27"
}

variable "vpc_id" {
  description = "VPC ID where EKS will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for EKS"
  type        = list(string)
}

variable "node_groups" {
  description = "Map of node group configurations"
  type = map(object({
    name          = string
    instance_type = string
    desired_size  = number
    min_size      = number
    max_size      = number
    az_count      = number
  }))
  default = {
    dev = {
      name          = "dev-node-group"
      instance_type = "t3.medium"
      desired_size  = 2
      min_size      = 2
      max_size      = 3
      az_count      = 2
    }
    staging = {
      name          = "staging-node-group"
      instance_type = "t2.medium"
      desired_size  = 3
      min_size      = 3
      max_size      = 4
      az_count      = 2
    }
    prod = {
      name          = "prod-node-group"
      instance_type = "t2.medium"
      desired_size  = 4
      min_size      = 3
      max_size      = 5
      az_count      = 3
    }
  }
}
