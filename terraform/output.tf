output "vm_ip_address" {
  value = azurerm_public_ip.vm_public_ip.ip_address
}

output "container_registry_url" {
  value = azurerm_container_registry.app_registry.login_server
}

output "registry_username" {
  value = azurerm_container_registry.app_registry.admin_username
}

output "registry_password" {
  value     = azurerm_container_registry.app_registry.admin_password
  sensitive = true
}
