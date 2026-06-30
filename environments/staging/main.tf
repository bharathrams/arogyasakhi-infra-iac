locals {
  name_prefix = "${var.project}-${var.environment}"
}

module "network" {
  source = "../../modules/network"
  name   = local.name_prefix
}

# Shared SG attached to all app tasks; DB/Redis allow ingress from it.
resource "aws_security_group" "apps" {
  name   = "${local.name_prefix}-apps-sg"
  vpc_id = module.network.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${local.name_prefix}-apps-sg" }
}

module "media_bucket" {
  source      = "../../modules/s3"
  bucket_name = "${local.name_prefix}-media"
}

module "redis" {
  source                     = "../../modules/redis"
  name                       = local.name_prefix
  vpc_id                     = module.network.vpc_id
  subnet_ids                 = module.network.private_subnet_ids
  allowed_security_group_ids = [aws_security_group.apps.id]
  node_type                  = var.redis_node_type
}

module "postgres" {
  source                     = "../../modules/rds-postgres"
  name                       = local.name_prefix
  vpc_id                     = module.network.vpc_id
  subnet_ids                 = module.network.private_subnet_ids
  allowed_security_group_ids = [aws_security_group.apps.id]
  db_name                    = "arogya"
  instance_class             = var.db_instance_class
  multi_az                   = var.db_multi_az
}

module "ecs" {
  source = "../../modules/ecs-cluster"
  name   = local.name_prefix
}

# Example services. The remaining microservices follow this same module call.
module "api_gateway" {
  source                   = "../../modules/ecs-service"
  name                     = "${local.name_prefix}-api-gateway"
  cluster_arn              = module.ecs.cluster_arn
  vpc_id                   = module.network.vpc_id
  subnet_ids               = module.network.private_subnet_ids
  region                   = var.region
  image                    = var.api_gateway_image
  container_port           = 3000
  desired_count            = var.service_desired_count
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn
  extra_security_group_ids = [aws_security_group.apps.id]
  environment              = { NODE_ENV = var.environment }
}

module "beneficiary_service" {
  source                   = "../../modules/ecs-service"
  name                     = "${local.name_prefix}-beneficiary"
  cluster_arn              = module.ecs.cluster_arn
  vpc_id                   = module.network.vpc_id
  subnet_ids               = module.network.private_subnet_ids
  region                   = var.region
  image                    = var.beneficiary_image
  container_port           = 3001
  desired_count            = var.service_desired_count
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn
  extra_security_group_ids = [aws_security_group.apps.id]
  environment              = { NODE_ENV = var.environment }
}
