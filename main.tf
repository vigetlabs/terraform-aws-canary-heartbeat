#=====================================
# Canary for heartbeat
#=====================================
locals {
  rendered_file_content = templatefile("${path.module}/templates/heartbeat.py.tftpl", {
    heartbeat_endpoint = var.heartbeat_endpoint
    take_screenshot    = var.take_screenshot
  })

  // use sha256 to make sure the canary is redeployed whenever the rendered templated file is modified.
  zip = "lambda_canary-${sha256(local.rendered_file_content)}.zip"
}

resource "aws_synthetics_canary" "this" {
  name                 = module.this.id
  artifact_s3_location = "s3://${aws_s3_bucket.artifacts_bucket.bucket}"
  zip_file             = "/tmp/${local.zip}"
  execution_role_arn   = aws_iam_role.this.arn
  handler              = "heartbeat_canary.handler"
  runtime_version      = "syn-python-selenium-3.0"
  start_canary         = true

  run_config {
    timeout_in_seconds = var.timeout_in_seconds
  }

  schedule {
    expression = var.schedule_expression
  }

  tags = module.this.tags
}

data "archive_file" "heartbeat_zip" {
  type        = "zip"
  output_path = "/tmp/${local.zip}"

  source {
    content  = local.rendered_file_content
    filename = "python/heartbeat_canary.py"
  }
}


