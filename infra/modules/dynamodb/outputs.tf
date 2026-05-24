output "table_name" {
  value       = aws_dynamodb_table.pgr_mental.name
  description = "The name of the DynamoDB table"
}

output "table_arn" {
  value       = aws_dynamodb_table.pgr_mental.arn
  description = "The ARN of the DynamoDB table"
}
