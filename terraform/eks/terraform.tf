terraform {
  required_version = "1.1.5"
  backend "s3" {
    bucket         = "tf-ss-rampup-state"
    key            = "eks/main"
    region         = "eu-central-1"
    dynamodb_table = "tf-lock"
  }
}
