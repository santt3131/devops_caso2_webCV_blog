# =============================================================================
# recursos.tf - Redes, VM para Podman y Clúster AKS (Free)
# =============================================================================

# Red Virtual y Subred para interconectar los servicios
resource "azurerm_virtual_network" "vnet" {
  name                = "cp2-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "cp2-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# IP Pública para la VM (Permite que el script le envíe órdenes si es necesario)
resource "azurerm_public_ip" "pip" {
  name                = "cp2-vm-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Firewall (Network Security Group) - Abre SSH (22) y HTTPS (443)
resource "azurerm_network_security_group" "nsg" {
  name                = "cp2-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Tarjeta de red de la VM
resource "azurerm_network_interface" "nic" {
  name                = "cp2-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Máquina Virtual Linux para Podman
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "cp2-vm-podman"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2ats_v2"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  # La infraestructura se autoconfigura internamente de manera LOCAL con Ansible.
  # Esta llave SSH se inyecta exclusivamente como respaldo de seguridad para que 
  # se pueda auditar la máquina vía terminal si fuese necesario
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = {
    environment = "casopractico2"
  }
}

# =============================================================================
# FASE 4: CONFIGURACIÓN DEL CLÚSTER DE KUBERNETES (AKS)
# =============================================================================

resource "azurerm_kubernetes_cluster" "aks" {
  # [CRITERIO 3]: El clúster se desplega como un servicio gestionado en Azure (AKS)
  name                = "aks-santi-casopractico2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "akssantidemo"

  # Evita cargos adicionales con la cuenta de estudiante (Uso de capa Free)
  sku_tier = "Free"

  default_node_pool {
    name    = "default"
    vm_size = "Standard_D2s_v3" # Configuración recomendada en Sesión 3 [source: 3]

    #Sólo es necesario desplegar un único worker
    node_count = 1
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "casopractico2"
    fase        = "Fase4-AKS"
  }
}

# =============================================================================
# CONECTIVIDAD Y CREDENCIALES ACR <-> AKS
# =============================================================================

# [CRITERIO 3]: El clúster de Kubernetes tendrá conectividad hacia el registry privado de ACR.
# [CRITERIO 3]: Se configura las credenciales de acceso al registry para que las aplicaciones puedan autenticarse.
resource "azurerm_role_assignment" "acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id # ¡kubelet!
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}
