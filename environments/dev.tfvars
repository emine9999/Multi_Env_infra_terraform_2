# # terraform.tfvars
# aws_region = "us-east-1"
# vpc_id     = "vpc-xxxxx"
# subnet_ids = ["subnet-xxxx1", "subnet-xxxx2", "subnet-xxxx3"]

# # Optionally override default node_groups configuration
# node_groups = {
#   dev = {
#     name          = "dev-node-group"
#     instance_type = "t3.medium"
#     desired_size  = 2
#     min_size      = 2
#     max_size      = 3
#     az_count      = 2
#   }
#   # ... staging and prod configurations
# }