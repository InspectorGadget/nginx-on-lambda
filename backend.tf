terraform {
  backend "s3" {
    bucket = "nginx-on-lambda"
    key    = "terraform.tfstate"
    region = "ap-southeast-1"
  }
}
