resource "random_password" "db" {
  length  = 20
  special = true
}

resource "aws_secretsmanager_secret" "app" {
  name = "${var.project_name}/${var.environment}/app"

  tags = {
    Name = "${var.project_name}-${var.environment}-secret"
  }
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id = aws_secretsmanager_secret.app.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db.result
    dbname   = var.db_name
  })
}
