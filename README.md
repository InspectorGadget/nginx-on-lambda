# Nginx on AWS Lambda

## Introduction
This is a sample project to demonstrate how to run nginx on AWS Lambda. This project consists of multiple working parts to get this implementation working on AWS Lambda.

Technologies used:
* AWS Lambda
* AWS API Gateway
* AWS Elastic Container Repository (ECR)
* Terraform
* Docker
    * Nginx

## Prerequisites
* AWS Account
* AWS CLI
* Terraform
* Docker

## Getting Started
1. Clone this repository
2. Create an S3 Bucket, as defined in `backend.tf`
3. Run the following command to initialize Terraform:
    ```bash
    terraform init
    ```
4. Apply the Terraform configuration:
    ```bash
    terraform apply
    ```

