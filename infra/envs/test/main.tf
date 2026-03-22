data "aws_availability_zones" "available" {}

module "network" {
  source = "../../modules/network"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = slice(data.aws_availability_zones.available.names, 0, 2)
}

module "security" {
  source = "../../modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.network.vpc_id
  app_port     = var.app_port
  db_port      = var.db_port
}

module "secrets" {
  source = "../../modules/secrets"

  project_name = var.project_name
  environment  = var.environment
  db_name      = var.db_name
  db_username  = var.db_username
}

module "rds" {
  source = "../../modules/rds"

  project_name         = var.project_name
  environment          = var.environment
  private_subnet_ids   = module.network.private_subnet_ids
  db_security_group_id = module.security.rds_security_group_id
  db_name              = var.db_name
  db_username          = module.secrets.db_username
  db_password          = module.secrets.db_password
  db_port              = var.db_port
}

module "ecs" {
  source = "../../modules/ecs"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.network.vpc_id
  private_subnet_ids    = module.network.private_subnet_ids
  public_subnet_ids     = module.network.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  ecs_security_group_id = module.security.ecs_security_group_id
  image_uri             = var.image_uri
  app_port              = var.app_port
  app_secret_arn        = module.secrets.app_secret_arn
  db_host               = module.rds.db_endpoint
}

output "alb_dns_name" {
  value = module.ecs.alb_dns_name
}

output "rds_endpoint" {
  value = module.rds.db_endpoint
}
