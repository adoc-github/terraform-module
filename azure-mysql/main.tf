provider "azurerm" {
  version = "=1.35.0"
}

resource "azurerm_resource_group" "default" {
  name     = "mysql-${var.sandbox_id}-rg"
  location = "westeurope"
}

resource "azurerm_mysql_server" "default" {
  name                = "mysql-${var.sandbox_id}"
  location            = "${azurerm_resource_group.default.location}"
  resource_group_name = "${azurerm_resource_group.default.name}"
  administrator_login          = "${var.username}"
  administrator_login_password = "${var.password}"
  version                      = "5.7"
  ssl_enforcement              = "Enabled"

  sku {
    name     = "B_Gen5_2"
    capacity = 2
    tier     = "Basic"
    family   = "Gen5"
  }

  storage_profile {
    storage_mb            = 5120
    geo_redundant_backup  = "Disabled"
  }
}

resource "azurerm_mysql_database" "default" {
  name                = "${var.db_name}"
  resource_group_name = "${azurerm_resource_group.default.name}"
  server_name         = "${azurerm_mysql_server.default.name}"
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_mysql_firewall_rule" "default" {
  name                = "allow_access"
  resource_group_name = "${azurerm_resource_group.default.name}"
  server_name         = "${azurerm_mysql_server.default.name}"
  start_ip_address    = "0.0.0.0" #Allow access to Azure services
  end_ip_address      = "0.0.0.0"
}
