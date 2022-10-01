resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_policy"
  role   = aws_iam_role.lambda_event_role.id
  policy = file("iam/lambda-policy.json")
}

resource "aws_iam_role" "lambda_event_role" {
  name               = "lambda_event_role"
  assume_role_policy = file("iam/lambda-role.json")
}