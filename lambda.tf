locals {
  output_folder = "outputs/lambda-app.zip"
}

data "archive_file" "lambda_app" {
  type        = "zip"
  source_file = "lambda-app.py"
  output_path = local.output_folder
}

resource "aws_lambda_function" "s3_lambda" {
  filename      = local.output_folder
  function_name = "s3-notify"
  role          = aws_iam_role.lambda_event_role.arn
  handler       = "lambda-app.lambda_handler"

  #   source_code_hash = "${filebase64sha256(local.output_folder)}"

  runtime = "python3.9"
}

resource "aws_lambda_permission" "allow_trigger" {
  statement_id  = "AllowExecutionFromEventBridgeRule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_lambda.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.generator_lambda_event_rule.arn
}

resource "aws_s3_bucket" "bucket" {
  bucket = "lambda-trigger-02"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket      = aws_s3_bucket.bucket.id
  eventbridge = true
}

