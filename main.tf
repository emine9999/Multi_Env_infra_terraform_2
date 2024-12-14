module "eks" {
  source = "./modules/eks"
  vpc_id      = module.networking.vpc_id
  subnet_ids  = module.networking.private_subnet_ids
  
}

module "networking" {
  source = "./modules/networking"
  vpc_cidr           = var.vpc_cidr
  availability_zones = data.aws_availability_zones.available.names

}

module "s3_logs" {
  source = "./modules/s3"
}