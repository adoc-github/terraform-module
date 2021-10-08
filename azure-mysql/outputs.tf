output "server_name" {
  value = "${azurerm_mysql_server.default.name}.mysql.database.azure.com"
}

output "server_admin_login_name" {
  value = "${var.username}@${azurerm_mysql_server.default.name}"
}
