resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnets"
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "this" {
  name   = "${var.name}-db-sg"
  vpc_id = var.vpc_id

  ingress {
    description     = "PostgreSQL from app services"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.name}-db-sg" }
}

resource "aws_db_instance" "this" {
  identifier     = "${var.name}-postgres"
  engine         = "postgres"
  engine_version = "16"
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.allocated_storage * 4
  storage_encrypted     = true
  kms_key_id            = var.kms_key_arn

  db_name  = var.db_name
  username = "armman_admin"
  # Master password managed by AWS Secrets Manager (no secret in code/state).
  manage_master_user_password = true

  multi_az                = var.multi_az
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.this.id]
  backup_retention_period = 30
  deletion_protection     = true
  skip_final_snapshot     = false
  final_snapshot_identifier = "${var.name}-postgres-final"
}
