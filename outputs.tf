output "canary_name" {
  value       = aws_synthetics_canary.this.name
  description = "The name of the canary."
}
