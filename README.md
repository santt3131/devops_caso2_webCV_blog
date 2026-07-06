# Caso Práctico 2 - Despliegue Multi-App Automatizado (AKS + VM)

Este repositorio contiene la solución completa para el **Caso Práctico 2**. 
Se ha diseñado un flujo DevSecOps de extremo a extremo que automatiza la creación de infraestructura en Azure, la compilación segura de imágenes y el aprovisionamiento de aplicaciones.

## 🛠️ Cómo desplegar (requisitos + pasos)

Sigue atentamente estas instrucciones para reproducir el entorno completo de extremo a extremo en un solo comando.

### Requisitos Previos
Antes de ejecutar el script orquestador, asegúrate de contar con las siguientes herramientas instaladas y configuradas localmente:
1. **Azure CLI**: Debe estar instalado y autenticado con tu cuenta de estudiante mediante el comando `az login` (con la suscripción activa elegida).
2. **Terraform**: Instala la CLI de Terraform para la provisión de la infraestructura como código.
3. **Podman**: Configurado de forma local para permitir compilaciones nativas orientadas a arquitectura de nube (`linux/amd64`).
4. **Ansible**: Herramienta de configuración encargada de automatizar los despliegues tanto en la Máquina Virtual como en el clúster de Kubernetes.
5. **Colección kubernetes.core de Ansible**: Extensión necesaria en Ansible para poder gestionar y desplegar los manifiestos sobre AKS de forma automatizada.
6. **Git**: Sistema de control de versiones para gestionar el código y subir el repositorio a GitHub.
7. **Python 3**


### Pasos para la Ejecución
Una vez cumplidos los requisitos, sigue estos pasos secuenciales desde tu terminal:

1. **Configurar la clave de Ansible Vault**: 
   Crea un archivo local llamado `.vault_pass` en la raíz del proyecto e introduce la contraseña maestra acordada para desencriptar el archivo `ansible/secretos.yml`


---
## Licencia
Esta obra está sujeta a una licencia de Reconocimiento-CompartirIgual 3.0 España de Creative Commons. 
El código de automatización e infraestructura se distribuye bajo la licencia GPL v3.0.