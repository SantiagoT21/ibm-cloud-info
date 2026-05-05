# PowerVS Deployment Module

Este módulo de Terraform despliega la aplicación IBM Cloud Info en una LPAR de PowerVS con Rocky Linux 9.

## 🚀 Inicio Rápido

```bash
# 1. Generar SSH key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/powervs_key

# 2. Configurar variables
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars con tus valores

# 3. Desplegar
terraform init
terraform plan
terraform apply

# 4. Obtener información
terraform output application_url
terraform output ssh_command
```

## 📋 Requisitos

- IBM Cloud API Key con permisos para PowerVS
- Terraform >= 1.0
- SSH key pair

## 📁 Archivos

- `provider.tf` - Configuración del provider IBM Cloud
- `variables.tf` - Definición de variables
- `data.tf` - Data sources (imágenes, system pools)
- `workspace.tf` - PowerVS Workspace
- `network.tf` - Red privada
- `public_network.tf` - Red pública
- `security.tf` - SSH keys
- `instance.tf` - LPAR configuration
- `outputs.tf` - Outputs del deployment

## ⚙️ Variables Principales

| Variable | Descripción | Default |
|----------|-------------|---------|
| `ibmcloud_api_key` | API Key de IBM Cloud | (requerido) |
| `powervs_zone` | Zona de PowerVS | `dal12` |
| `instance_processors` | CPU cores | `0.25` |
| `instance_memory` | RAM en GB | `2` |
| `instance_storage_size` | Disco en GB | `20` |
| `ssh_public_key` | SSH public key | (requerido) |

## 📊 Recursos Creados

1. PowerVS Workspace
2. Red privada (192.168.0.0/24)
3. SSH Key
4. LPAR con Rocky Linux 9
5. Conexión a red pública

## 💰 Costos Estimados

Configuración mínima (0.25 cores, 2GB RAM, 20GB):
- **~$43-60/mes**

## 📚 Documentación Completa

Ver [DEPLOYMENT_POWERVS.md](../../DEPLOYMENT_POWERVS.md) para la guía completa.

## 🔧 Comandos Útiles

```bash
# Ver estado
terraform show

# Ver outputs
terraform output

# Destruir infraestructura
terraform destroy

# Conectar por SSH
ssh -i ~/.ssh/powervs_key root@$(terraform output -raw instance_public_ip)
```

## ⚠️ Notas Importantes

- PowerVS NO tiene tier gratuito
- El deployment toma 15-30 minutos
- Rocky Linux 9 puede no estar disponible en todas las zonas
- Alternativas: RHEL9-SP2, CentOS-Stream-9