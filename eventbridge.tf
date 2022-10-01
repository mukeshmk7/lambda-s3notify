resource "aws_cloudwatch_event_rule" "generator_lambda_event_rule" {
  name          = "generator-lambda-event-rule"
  description   = "s3-object-create-trigger"
  event_pattern = <<PATTERN
  {
    "source" : ["aws.s3"],
    "detail-type" : ["Object Created"],
    "detail" : {
      "bucket" : {
        "name" : ["lambda-trigger-02"]
      },
      "object" : {
        "key" : [{
          "prefix" : "event/input"
        }]
      }
    }
  }
PATTERN
}

resource "aws_cloudwatch_event_target" "generator_lambda_target" {
  arn  = aws_lambda_function.s3_lambda.arn
  rule = aws_cloudwatch_event_rule.generator_lambda_event_rule.name
}