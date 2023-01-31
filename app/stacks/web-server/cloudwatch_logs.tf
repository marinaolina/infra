resource "aws_cloudwatch_log_group" "marina-alb-logs" {
  name              = aws_lb.web.name
  retention_in_days = 365
  tags = local.tags
}

module "s3_bucket" {
  source = "cloudposse/lb-s3-bucket/aws"
  name                     = "marina-logs-1395060707969"
  access_log_bucket_name   = "marina-logs-1395060707969"
  access_log_bucket_prefix = "marina-logs-1395060707969"
  force_destroy            = true
  tags = local.tags
}


module "alb_logs_to_cloudwatch" {
  source  = "dasmeta/complete-eks-cluster/aws//modules/aws-load-balancer-controller/terraform-aws-alb-cloudwatch-logs-json"
  version = "1.2.2"
  function_name = "marina-lambda"
  bucket_name    = module.s3_bucket.bucket_domain_name
  log_group_name = aws_cloudwatch_log_group.marina-alb-logs.name
  account_id = "344249076045"
  region = "eu-central-1"


}

resource "aws_lambda_permission" "bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = module.alb_logs_to_cloudwatch.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = module.s3_bucket.bucket_arn
}

resource "aws_s3_bucket_notification" "logs" {
  bucket     = module.s3_bucket.bucket_id
  depends_on = [aws_lambda_permission.bucket]

  lambda_function {
    lambda_function_arn = module.alb_logs_to_cloudwatch.function_arn
    events              = ["s3:ObjectCreated:*"]
  }
}