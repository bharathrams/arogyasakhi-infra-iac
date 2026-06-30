output "vpc_id" { value = module.network.vpc_id }
output "db_endpoint" { value = module.postgres.endpoint }
output "db_master_secret_arn" { value = module.postgres.master_secret_arn }
output "redis_endpoint" { value = module.redis.endpoint }
output "media_bucket" { value = module.media_bucket.bucket_id }
output "ecs_cluster" { value = module.ecs.cluster_name }
