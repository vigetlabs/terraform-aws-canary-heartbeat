#=====================================
# IAM role
#=====================================
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${module.this.id}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

#=====================================
# IAM policies
#=====================================
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.artifacts_bucket.arn}/*"
    ]
  }

  statement {
    actions = [
      "s3:GetBucketLocation"
    ]
    resources = [
      aws_s3_bucket.artifacts_bucket.arn
    ]
  }
}

resource "aws_iam_policy" "s3_policy" {
  name        = "${module.this.id}-s3-policy"
  description = "${module.this.id} S3 policy"
  policy      = data.aws_iam_policy_document.s3_policy.json
}

data "aws_iam_policy_document" "logs_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup"
    ]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/cwsyn-${module.this.id}"
    ]
  }
}

resource "aws_iam_policy" "logs_policy" {
  name        = "${module.this.id}-logs-policy"
  description = "${module.this.id} logs policy"
  policy      = data.aws_iam_policy_document.logs_policy.json
}

data "aws_iam_policy_document" "xray_policy" {
  statement {
    actions = [
      "s3:ListAllMyBuckets",
      "xray:PutTraceSegments"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "xray_policy" {
  name        = "${module.this.id}-xray-policy"
  description = "${module.this.id} X-Ray policy"
  policy      = data.aws_iam_policy_document.xray_policy.json
}

data "aws_iam_policy_document" "metrics_policy" {
  statement {
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "StringEquals"
      variable = "cloudwatch:namespace"

      values = [
        "CloudWatchSynthetics"
      ]
    }
  }
}

resource "aws_iam_policy" "metrics_policy" {
  name        = "${module.this.id}-metrics-policy"
  description = "${module.this.id} CloudWatch metrics policy"
  policy      = data.aws_iam_policy_document.metrics_policy.json
}

#=====================================
# Policy attachments
#=====================================
resource "aws_iam_role_policy_attachment" "role_s3" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "role_logs" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.logs_policy.arn
}

resource "aws_iam_role_policy_attachment" "role_xray" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.xray_policy.arn
}

resource "aws_iam_role_policy_attachment" "role_metrics" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.metrics_policy.arn
}
