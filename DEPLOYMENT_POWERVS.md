# IBM Cloud Info - PowerVS Deployment Guide

Guía completa para desplegar la aplicación IBM Cloud Info en **IBM PowerVS** (Power Virtual Server) usando **Rocky Linux 9** y **Terraform**.

## 📋 Tabla de Contenidos

- [Descripción](#descripción)
- [Arquitectura PowerVS](#arquitectura-powervs)
- [Requisitos Previos](#requisitos-previos)
- [Configuración Inicial](#configuración-inicial)
- [Deployment con Terraform](#deployment-con-terraform)
- [Verificación del Deployment](#verificación-del-deployment)
- [Gestión de la Instancia](#gestión-de-la-instancia)
- [Troubleshooting](#troubleshooting)
- [Costos Estimados](#costos-estimados)
- [Comparación: PowerVS vs Code Engine](#comparación-powervs-vs-code-engine)

## 🎯 Descripción

Este deployment despliega la aplicación web en una **LPAR (Logical Partition)** de PowerVS con las siguientes características:

- ✅ **OS**: Rocky Linux 9 (arquitectura POWER - ppc64le)
- ✅ **Web Server**: Nginx
- ✅ **Infraestructura**: Terraform (IaC)
- ✅ **Red**: IP pública + red privada
- ✅ **Seguridad**: Firewalld + SSH key authentication
- ✅ **Automatización**: Cloud-init script para setup completo

## 🏗️ Arquitectura PowerVS

```
┌─────────────────────────────────────────────────────────┐
│                  IBM Cloud Account                       │
│                                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │         PowerVS Workspace (dal12)              │    │
│  │                                                 │    │
│  │  ┌──────────────────────────────────────┐     │    │
│  │  │   Private Network (192.168.0.0/24)   │     │    │
│  │  │                                       │     │    │
│  │  │   ┌───────────────────────────┐      │     │    │
│  │  │   │  LPAR - Rocky Linux 9     │      │     │    │
│  │  │   │  ├─ 0.25 cores            │      │     │    │
│  │  │   │  ├─ 2GB RAM               │      │     │    │
│  │  │   │  ├─ 20GB Storage          │      │     │    │
│  │  │   │  ├─ Nginx (port 80)       │      │     │    │
│  │  │   │  └─ Firewalld             │      │     │    │
│  │  │   │                            │      │     │    │
│  │  │   │  Private IP: 192.168.0.x   │      │     │    │
│  │  │   └────────┬──────────────────┘      │     │    │
│  │  │            │                          │     │    │
│  │  └────────────┼──────────────────────────┘     │    │
│  │               │                                 │    │
│  │               ▼                                 │    │
│  │   ┌──────────────────────────┐                 │    │
│  │   │   Public Network         │                 │    │
│  │   │   Public IP: x.x.x.x     │                 │    │
│  │   └──────────────────────────┘                 │    │
│  └─────────────────────────────────────────────────┘    │
│                                                          │
└──────────────────────────────────────────────────────────┘
                         │
                         ▼
                  Internet Access
              http://PUBLIC_IP
```

## 📦 Requisitos Previos

### 1. Cuenta de IBM Cloud

- Cuenta activa de IBM Cloud: [Crear cuenta](https://cloud.ibm.com/registration)
- API Key de IBM Cloud con permisos para PowerVS
- Créditos suficientes (PowerVS no tiene tier gratuito)

### 2. Herramientas Locales

```bash
# Terraform >= 1.0
terraform --version

# IBM Cloud CLI
ibmcloud --version

# SSH key pair
ssh-keygen -t rsa -b 4096 -f ~/.ssh/powervs_key
```

### 3. Verificar Disponibilidad de PowerVS

PowerVS no está disponible en todas las regiones. Zonas soportadas:

- **Dallas**: `dal12`, `dal13`
- **Londres**: `lon06`
- **Sydney**: `syd04`, `syd05`
- **Tokyo**: `tok04`
- **Washington**: `wdc06`, `wdc07`
- **São Paulo**: `sao01`
- **Montreal**: `mon01`

## ⚙️ Configuración Inicial

### 1. Clonar el Repositorio

```bash
git clone https://github.com/YOUR_USERNAME/ibm-cloud-info.git
cd ibm-cloud-info
```

### 2. Generar SSH Key

```bash
# Generar nueva SSH key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/powervs_key -C "powervs-access"

# Ver la clave pública (necesaria para terraform.tfvars)
cat ~/.ssh/powervs_key.pub
```

### 3. Configurar Variables de Terraform

```bash
cd terraform/powervs
cp terraform.tfvars.example terraform.tfvars
```

Editar `terraform.tfvars` con tus valores:

```hcl
# IBM Cloud Authentication
ibmcloud_api_key = "YOUR_IBM_CLOUD_API_KEY"

# Region and Zone
region        = "us-south"
powervs_zone  = "dal12"

# Resource Group
resource_group_name = "Default"

# Instance Configuration
instance_name       = "ibm-cloud-info-lpar"
instance_image_name = "Rocky-Linux-9"

# Compute Resources (optimized for cost)
instance_processors = 0.25
instance_memory     = 2
instance_storage_size = 20

# SSH Key (paste your public key)
ssh_key_name   = "ibm-cloud-info-ssh-key"
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC..."
```

### 4. Verificar Imágenes Disponibles

```bash
# Login a IBM Cloud
ibmcloud login --apikey YOUR_API_KEY

# Listar zonas de PowerVS
ibmcloud pi service-list

# Listar imágenes disponibles en una zona
ibmcloud pi workspace target WORKSPACE_ID
ibmcloud pi images
```

## 🚀 Deployment con Terraform

### Paso 1: Inicializar Terraform

```bash
cd terraform/powervs
terraform init
```

### Paso 2: Validar Configuración

```bash
# Validar sintaxis
terraform validate

# Formatear archivos
terraform fmt -recursive
```

### Paso 3: Planificar Deployment

```bash
terraform plan
```

Revisa el plan cuidadosamente. Terraform creará:
- 1 PowerVS Workspace
- 1 Red privada
- 1 SSH Key
- 1 LPAR (instancia)
- Conexión a red pública

### Paso 4: Aplicar Cambios

```bash
terraform apply
```

Confirma con `yes`. El proceso tomará **15-30 minutos**:

1. ⏱️ Crear workspace (5-10 min)
2. ⏱️ Crear red privada (2-3 min)
3. ⏱️ Crear LPAR (10-15 min)
4. ⏱️ Ejecutar script de setup (2-3 min)

### Paso 5: Obtener Información del Deployment

```bash
# Ver todos los outputs
terraform output

# Ver URL de la aplicación
terraform output application_url

# Ver comando SSH
terraform output ssh_command

# Ver resumen completo
terraform output deployment_summary
```

## ✅ Verificación del Deployment

### 1. Verificar Acceso Web

```bash
# Obtener la URL
URL=$(terraform output -raw application_url)
echo "Application URL: $URL"

# Probar con curl
curl -I $URL

# Abrir en navegador
open $URL  # macOS
xdg-open $URL  # Linux
```

### 2. Verificar Acceso SSH

```bash
# Obtener IP pública
PUBLIC_IP=$(terraform output -raw instance_public_ip)

# Conectar por SSH
ssh -i ~/.ssh/powervs_key root@$PUBLIC_IP

# Una vez conectado, verificar servicios
systemctl status nginx
systemctl status firewalld
cat /root/setup-status.txt
```

### 3. Verificar Logs de Setup

```bash
# Conectar por SSH
ssh -i ~/.ssh/powervs_key root@$PUBLIC_IP

# Ver logs de instalación
cat /var/log/powervs-setup.log

# Ver logs de nginx
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

## 🛠️ Gestión de la Instancia

### Comandos Útiles de Terraform

```bash
# Ver estado actual
terraform show

# Refrescar estado
terraform refresh

# Ver outputs
terraform output

# Destruir infraestructura
terraform destroy
```

### Comandos de IBM Cloud CLI

```bash
# Login
ibmcloud login --apikey YOUR_API_KEY

# Listar workspaces
ibmcloud pi service-list

# Target a un workspace
ibmcloud pi workspace target WORKSPACE_ID

# Listar instancias
ibmcloud pi instances

# Ver detalles de instancia
ibmcloud pi instance INSTANCE_ID

# Ver redes
ibmcloud pi networks
```

### Gestión de la Instancia

```bash
# Conectar por SSH
ssh -i ~/.ssh/powervs_key root@PUBLIC_IP

# Reiniciar nginx
systemctl restart nginx

# Ver estado de servicios
systemctl status nginx
systemctl status firewalld

# Actualizar sistema
dnf update -y

# Ver uso de recursos
top
df -h
free -h
```

### Actualizar Contenido Web

```bash
# Conectar por SSH
ssh -i ~/.ssh/powervs_key root@PUBLIC_IP

# Editar el HTML
vi /usr/share/nginx/html/index.html

# Recargar nginx (no necesario para HTML estático)
systemctl reload nginx
```

## 🔍 Troubleshooting

### Error: "Image not found"

**Problema**: La imagen Rocky-Linux-9 no está disponible en la zona seleccionada.

**Solución**:
```bash
# Listar imágenes disponibles
ibmcloud pi workspace target WORKSPACE_ID
ibmcloud pi images

# Actualizar terraform.tfvars con una imagen disponible
instance_image_name = "RHEL9-SP2"  # o "CentOS-Stream-9"
```

### Error: "Workspace creation failed"

**Problema**: La zona de PowerVS no está disponible o no tienes permisos.

**Solución**:
1. Verificar que la zona existe: `ibmcloud regions --service-name power-iaas`
2. Cambiar a otra zona en `terraform.tfvars`
3. Verificar permisos de la API Key

### La aplicación no responde

**Problema**: Nginx no está corriendo o firewall bloqueando.

**Solución**:
```bash
# Conectar por SSH
ssh -i ~/.ssh/powervs_key root@PUBLIC_IP

# Verificar nginx
systemctl status nginx
systemctl restart nginx

# Verificar firewall
firewall-cmd --list-all
firewall-cmd --permanent --add-service=http
firewall-cmd --reload

# Ver logs
tail -f /var/log/powervs-setup.log
tail -f /var/log/nginx/error.log
```

### No puedo conectar por SSH

**Problema**: SSH key incorrecta o firewall bloqueando puerto 22.

**Solución**:
```bash
# Verificar que usas la key correcta
ssh -i ~/.ssh/powervs_key -v root@PUBLIC_IP

# Verificar permisos de la key
chmod 600 ~/.ssh/powervs_key

# Si el problema persiste, usar la consola web de IBM Cloud
# para acceder a la instancia y verificar configuración
```

### Timeout durante terraform apply

**Problema**: La creación de recursos toma más tiempo del esperado.

**Solución**:
```bash
# Los timeouts están configurados en los archivos .tf
# Si necesitas más tiempo, edita los timeouts en:
# - workspace.tf
# - instance.tf

# Ejemplo en instance.tf:
timeouts {
  create = "60m"  # Aumentar de 45m a 60m
}
```

## 💰 Costos Estimados

### Configuración Mínima (0.25 cores, 2GB RAM, 20GB)

| Componente | Costo Mensual (USD) |
|------------|---------------------|
| Compute (0.25 cores) | ~$25-35 |
| Memory (2GB) | ~$10-15 |
| Storage (20GB tier3) | ~$3-5 |
| Public IP | ~$5 |
| **Total Estimado** | **~$43-60/mes** |

### Configuración Media (0.5 cores, 4GB RAM, 30GB)

| Componente | Costo Mensual (USD) |
|------------|---------------------|
| Compute (0.5 cores) | ~$50-70 |
| Memory (4GB) | ~$20-30 |
| Storage (30GB tier3) | ~$5-7 |
| Public IP | ~$5 |
| **Total Estimado** | **~$80-112/mes** |

### Notas sobre Costos

- ⚠️ **PowerVS NO tiene tier gratuito**
- Los costos varían según la zona geográfica
- Storage tier3 es el más económico (tier0 es el más rápido pero más caro)
- Los costos son por hora, facturados mensualmente
- Considera apagar la instancia cuando no la uses para ahorrar en compute

### Optimización de Costos

```bash
# Detener instancia (ahorra en compute, no en storage)
ibmcloud pi instance-stop INSTANCE_ID

# Iniciar instancia
ibmcloud pi instance-start INSTANCE_ID

# Eliminar completamente (ahorra todo)
terraform destroy
```

## 📊 Comparación: PowerVS vs Code Engine

| Característica | PowerVS | Code Engine |
|----------------|---------|-------------|
| **Tipo** | IaaS (VM dedicada) | Serverless (Containers) |
| **Arquitectura** | POWER (ppc64le) | x86_64 |
| **OS** | Rocky Linux 9 | Container (Alpine) |
| **Escalabilidad** | Manual | Auto-scaling (0-10) |
| **Costo Mensual** | $43-60+ | $0-5 |
| **Tiempo Deploy** | 15-30 min | 2-5 min |
| **Control** | Total (root access) | Limitado |
| **Mantenimiento** | Manual (updates, patches) | Automático |
| **Scale-to-Zero** | ❌ No | ✅ Sí |
| **IP Pública** | Fija | Dinámica |
| **Ideal Para** | Workloads enterprise, AIX/IBM i | Apps web, microservicios |

### ¿Cuándo usar PowerVS?

✅ **Usa PowerVS si necesitas**:
- Control total del sistema operativo
- Arquitectura POWER para compatibilidad
- Recursos dedicados y predecibles
- Migración de workloads AIX o IBM i
- Aplicaciones que requieren root access
- Rendimiento consistente

### ¿Cuándo usar Code Engine?

✅ **Usa Code Engine si necesitas**:
- Deployment rápido y simple
- Auto-scaling automático
- Costos mínimos (scale-to-zero)
- Aplicaciones stateless
- Microservicios
- Prototipos y demos

## 📚 Recursos Adicionales

- [IBM PowerVS Documentation](https://cloud.ibm.com/docs/power-iaas)
- [Terraform IBM Provider - PowerVS](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/pi_instance)
- [Rocky Linux Documentation](https://docs.rockylinux.org/)
- [IBM Cloud Pricing Calculator](https://cloud.ibm.com/estimator)

## 🤝 Soporte

Si encuentras problemas:

1. Revisa la sección [Troubleshooting](#troubleshooting)
2. Consulta los logs: `/var/log/powervs-setup.log`
3. Verifica el estado: `cat /root/setup-status.txt`
4. Abre un issue en GitHub

## 📝 Notas Importantes

⚠️ **Consideraciones de Seguridad**:
- Cambia las credenciales por defecto
- Mantén el sistema actualizado: `dnf update -y`
- Configura fail2ban para protección SSH
- Considera usar VPN para acceso administrativo
- Revisa regularmente los logs de acceso

⚠️ **Backup y Recuperación**:
- PowerVS no incluye backups automáticos
- Configura backups manuales si es crítico
- Considera usar IBM Cloud Object Storage para backups

⚠️ **Monitoreo**:
- Configura alertas de uso de recursos
- Monitorea costos regularmente en IBM Cloud Console
- Usa herramientas como Prometheus/Grafana si es necesario

---

**¿Preguntas?** Consulta el [README principal](README.md) o abre un issue en GitHub.