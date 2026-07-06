#!/bin/bash

# =============================================================================
# SCRIPT MAESTRO - AUTOMATIZACIÓN DE EXTREMO A EXTREMO (END-TO-END)
# =============================================================================
# Este script actúa como el orquestador principal del Caso Práctico 2.
# Controla el orden secuencial de Terraform, Podman local y Ansible.
# =============================================================================

# Detener el script si algún comando falla
set -e

echo "====================================================================="
# FASE 1: DESPLIEGUE DE LA INFRAESTRUCTURA CON TERRAFORM
echo "FASE 1: Creando infraestructura en Azure con Terraform..."
echo "====================================================================="
cd terraform
terraform init
terraform apply -auto-approve

# Extraemos la variable del ACR para usarla en la compilación
ACR=$(terraform output -raw acr_login_server)
cd ..


echo "====================================================================="
# FASE 2: COMPILACIÓN Y SUBIDA DE LA IMAGEN (CRITERIO 1)
# Se hace de forma local en mi Mac usando las variables de Terraform
echo "FASE 2: Autenticando en el ACR y subiendo la imagen de la app..."
echo "====================================================================="
# Login explícito usando los outputs de Terraform
podman login $ACR \
  -u "$(cd terraform && terraform output -raw acr_admin_username)" \
  -p "$(cd terraform && terraform output -raw acr_admin_password)"

# Extraemos del archivo cifrado de Ansible Vault el usuario y la clave
WEB_USER=$(ansible-vault view ansible/secretos.yml --vault-password-file .vault_pass | awk '/vault_web_user:/ {print $2}' | tr -d '"' | tr -d "'")
WEB_PASS=$(ansible-vault view ansible/secretos.yml --vault-password-file .vault_pass | awk '/vault_web_pass:/ {print $2}' | tr -d '"' | tr -d "'")

# Compilación pasando los argumentos extraídos del Vault hacia el Dockerfile
podman build --platform=linux/amd64 \
  --build-arg HTTP_USER="$WEB_USER" \
  --build-arg HTTP_PASS="$WEB_PASS" \
  -t $ACR/repo-santi:casopractico2 ./web-nginx-app1

# Envío (Push) de la imagen al Azure Container Registry privado
podman push $ACR/repo-santi:casopractico2



echo "====================================================================="
# FASE 3: APROVISIONAMIENTO Y CONFIGURACIÓN CON ANSIBLE (CRITERIO 2)
# Llama al script interno 'deploy.sh' que exige el formato de la entrega
echo "FASE 3: Invocando la configuración remota mediante Ansible..."
echo "====================================================================="
cd ansible
chmod +x deploy.sh
./deploy.sh
cd ..


echo "====================================================================="
# FASE 4 - CRITERIO 3: Despliegue y configuración del clúster de Kubernetes
# Preparamos las credenciales para poder interactuar con AKS usando kubectl
echo "FASE 4 - CRITERIO 3: Configurando credenciales de acceso para el clúster AKS..."
echo "====================================================================="
# Descargamos dinámicamente las credenciales del AKS usando el output de Terraform
# Dentro get_credentials_command esta la instrucción de Azure CLI para obtener las credenciales del clúster AKS
eval $(cd terraform && terraform output -raw get_credentials_command)


echo "====================================================================="
# FASE 5 - CRITERIO 4: Despliegue de la aplicación sobre Kubernetes
# Compilamos la app del Blog, la subimos al ACR y la desplegamos con kubectl
echo "FASE 5 - CRITERIO 4: Compilando, subiendo al ACR y desplegando la aplicación en AKS..."
echo "====================================================================="
# 1. Compilamos en tu Mac forzando arquitectura de nube (amd64) usando tu carpeta local del blog
podman build --platform=linux/amd64 -t $ACR/web-blog-santi:casopractico2 ./web-blog-k8s
# 2. Subida privada al Azure Container Registry 
podman push $ACR/web-blog-santi:casopractico2


# 3. Invocamos el Playbook de Ansible para desplegar la app persistente
cd ansible
ansible-playbook playbook_k8s.yml --extra-vars "acr_login=$ACR"
cd ..

echo "====================================================================="
echo "🎉 ¡PROCESO COMPLETADO! Infraestructura creada, imagen subida y VM configurada."
echo "====================================================================="
