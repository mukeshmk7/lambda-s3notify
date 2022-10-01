locals {
    output_folder = "outputs/lambda-app.zip"
}

data "archive_file" "lambda_app" {
  type        = "zip"
  source_file = "lambda-app.py"
  output_path = "${local.output_folder}"
}

resource "aws_lambda_function" "s3_lambda" {
  filename      = "${local.output_folder}"
  function_name = "lambda-app"
  role          = "${aws_iam_role.lambda_role.arn}"
  handler       = "lambda-app.lambda_handler"

#   source_code_hash = "${filebase64sha256(local.output_folder)}"

  runtime = "python3.7"
}

resource "aws_lambda_permission" "allow_trigger" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
}

resource "aws_s3_bucket" "bucket" {
  bucket = "lambda-trigger-02"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "exception/"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "input/"
  }

  depends_on = [
    aws_lambda_permission.allow_trigger
  ]
}