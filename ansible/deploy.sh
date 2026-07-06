#!/bin/bash

# =============================================================================
# SCRIPT DE AUTOMATIZACIÓN - EJECUCIÓN DE PLAYBOOK
# =============================================================================

# Ejecutas Ansible directamente, él leerá 'hosts' y 'group_vars' automáticamente
ansible-playbook -i hosts playbook.yml

echo "✅ Aprovisionamiento finalizado."