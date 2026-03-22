output "app_secret_arn" {
  value = aws_secretsmanager_secret.app.arn
}

output "db_password" {
  value     = random_password.db.result
  sensitive = true
}

output "db_username" {
  value = var.db_username
}
