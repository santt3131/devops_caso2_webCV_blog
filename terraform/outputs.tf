# =============================================================================
# outputs.tf - Exportación de datos dinámicos hacia el script de tu Mac
# =============================================================================
output "acr_login_server" { value = azurerm_container_registry.acr.login_server }
output "acr_admin_username" { value = azurerm_container_registry.acr.admin_username }
output "acr_admin_password" {
  value     = azurerm_container_registry.acr.admin_password
  sensitive = true
}
output "vm_name" { value = azurerm_linux_virtual_machine.vm.name }

# Extrae y muestra la IP pública de la máquina virtual en la terminal
output "vm_public_ip" {
  value       = azurerm_public_ip.pip.ip_address
  description = "La IP publica que Azure le ha asignado a la maquina virtual"
}

# --- GENERACIÓN AUTOMÁTICA DEL INVENTARIO DE ANSIBLE ---
resource "local_file" "ansible_inventory" {
  # Te lo escupe directamente dentro de la carpeta ansible con el nombre 'hosts'
  filename = "${path.module}/../ansible/hosts"
  content  = <<-EOT
    # Generado por Terraform — NO editar a mano.
    [azure_vms]
    cp2-vm-podman ansible_host=${azurerm_public_ip.pip.ip_address} ansible_user=azureuser ansible_ssh_private_key_file=~/.ssh/id_rsa

    [azure_vms:vars]
    ansible_python_interpreter=/usr/bin/python3
    ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
  EOT
}

# --- GENERACIÓN AUTOMÁTICA DE LAS VARIABLES DEL ACR (group_vars) ---
resource "local_file" "ansible_acr_vars" {
  # Crea la carpeta group_vars y guarda el archivo de configuración
  filename = "${path.module}/../ansible/group_vars/all.yml"
  content  = <<-EOT
    # Generado por Terraform — NO editar a mano.
    acr_login_server: "${azurerm_container_registry.acr.login_server}"
    acr_username: "${azurerm_container_registry.acr.admin_username}"
    acr_password: "${azurerm_container_registry.acr.admin_password}"
  EOT
}

# =============================================================================
# OUTPUTS - FASE DE KUBERNETES
# =============================================================================

# [CRITERIO 3]: Comando automatizado para extraer las credenciales del AKS localmente
output "get_credentials_command" {
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.rg.name} --name ${azurerm_kubernetes_cluster.aks.name} --overwrite-existing"
  description = "Comando para configurar kubectl con el clúster AKS desplegado"
}
