terraform {
  required_version = "1.1.5"
  backend "s3" {
    bucket         = "tf-ss-rampup-state"
    key            = "networking/main"
    region         = "eu-central-1"
    dynamodb_table = "tf-lock"
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "tf-lock"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
