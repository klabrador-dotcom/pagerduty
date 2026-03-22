environment          = "prod"
project_name         = "pagerduty-csg"
vpc_cidr             = "10.20.0.0/16"
public_subnet_cidrs  = ["10.20.1.0/24", "10.20.2.0/24"]
private_subnet_cidrs = ["10.20.11.0/24", "10.20.12.0/24"]
db_name              = "appdb"
db_username          = "appuser"
