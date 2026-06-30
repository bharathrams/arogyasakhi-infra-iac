# Remote state in S3 with a DynamoDB lock table. Bootstrap these once before init.
terraform {
  backend "s3" {
    bucket         = "arogya-sakhi-tfstate"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "arogya-sakhi-tflock"
    encrypt        = true
  }
}
