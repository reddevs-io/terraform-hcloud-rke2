resource "random_password" "db_master_password" {
  length           = 20
  special          = true
  override_special = "@#%^*()-_=+[]{}"
}

locals {
  allowed_cidr = concat(
    var.allowed_cidr,
    ["${hcloud_server.control_plane_first.ipv4_address}/32"],
    [for s in hcloud_server.control_plane_additional : "${s.ipv4_address}/32"]
  )
}

data "aws_availability_zones" "available" {
}

#tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "reddevs-vpc"
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.available.names
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
}

resource "aws_db_subnet_group" "db_subnets" {
  name       = "db_subnets"
  subnet_ids = module.vpc.public_subnets
}

resource "aws_security_group" "rds" {
  name        = "${var.cluster_name}-rds-sg"
  description = "Allow PostgreSQL access"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Postgres"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = local.allowed_cidr
  }

  #tfsec:ignore:aws-ec2-no-public-egress-sgr
  egress {
    description      = "Allow all outbound traffic for RDS connectivity"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}



#tfsec:ignore:builtin.aws.rds.aws0180
#tfsec:ignore:aws-rds-enable-performance-insights
resource "aws_db_instance" "datastore" {
  identifier            = "${var.cluster_name}-datastore"
  engine                = "postgres"
  engine_version        = var.engine_version
  instance_class        = "db.t4g.micro" // Free Tier eligible
  allocated_storage     = var.allocated_storage_gb
  max_allocated_storage = var.allocated_storage_gb // cap to avoid autoscale costs
  storage_type          = "gp3"                    // Free Tier allows gp2 or gp3; gp3 recommended
  username              = var.db_username
  password              = random_password.db_master_password.result
  port                  = 5432
  storage_encrypted     = true

  db_subnet_group_name                = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids              = [aws_security_group.rds.id]
  #tfsec:ignore:aws-rds-no-public-db-access
  publicly_accessible                 = true  
  multi_az                            = false // keep off for Free Tier
  availability_zone                   = null  // let AWS pick
  #tfsec:ignore:builtin.aws.rds.aws0176
  iam_database_authentication_enabled = false 

  backup_retention_period  = 7 // Free Tier includes up to 20GB backups; adjust as needed
  delete_automated_backups = true
  backup_window            = "02:00-03:00"
  maintenance_window       = "sun:05:00-sun:06:00"

  performance_insights_enabled = false // keep off for Free Tier
  monitoring_interval          = 0     // enhanced monitoring off

  auto_minor_version_upgrade = true
  copy_tags_to_snapshot      = true

  apply_immediately = false

  deletion_protection = true
  skip_final_snapshot = true
}

#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${var.cluster_name}-datastore-db-credentials"
  description = "RDS PostgreSQL credentials for ${var.cluster_name} datastore"
}

resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_master_password.result
  })
}
