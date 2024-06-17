output "public_dns" {
  description = "DNS publico asignado a la instancia virtual"
  value = try(
    aws_instance.app_server.public_dns,
    null,
  )
}

