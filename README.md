# IBM Cloud Info - Multi-Platform Deployment

[![Deploy to Code Engine](https://github.com/SantiagoT21/ibm-cloud-info/actions/workflows/terraform-deploy.yml/badge.svg)](https://github.com/SantiagoT21/ibm-cloud-info/actions/workflows/terraform-deploy.yml)
[![Deploy to PowerVS](https://github.com/SantiagoT21/ibm-cloud-info/actions/workflows/powervs-deploy.yml/badge.svg)](https://github.com/SantiagoT21/ibm-cloud-info/actions/workflows/powervs-deploy.yml)

Aplicación web informativa sobre IBM Cloud desplegada automáticamente en múltiples plataformas usando Terraform y GitHub Actions.

## 🚀 Plataformas Soportadas

### 1. IBM Cloud Code Engine (Serverless)
- ✅ **Deployment automático** con cada push
- ✅ **Build de imagen Docker** incluido
- ✅ **Zero downtime** con rolling updates
- ✅ **Tier gratuito** disponible
- ✅ **Escalado automático** 0-10 instancias
- ⏱️ **Tiempo**: ~10-15 minutos

### 2. IBM PowerVS (Bare Metal)
- ✅ **Deployment automático** con GitHub Actions
- ✅ **SSH keys** generados automáticamente
- ✅ **Control total** del sistema
- ✅ **Arquitectura POWER** (AIX/IBM i compatible)
- ✅ **Acceso SSH** completo
- ⏱️ **Tiempo**: ~20-30 minutos

## 📋 Inicio Rápido

### Opción 1: Code Engine (Recomendado para empezar)

```bash
# 1. Configurar secrets en GitHub
# - IBM_CLOUD_API_KEY
# - IBM_CLOUD_REGION
# - IBM_CLOUD_RESOURCE_GROUP
# - ICR_NAMESPACE

# 2. Push a main
git push origin main

# 3. GitHub Actions despliega automáticamente
# 4. Obtén la URL del summary en Actions
```

**Costo**: Gratis (tier gratuito) o ~$0-20/mes

### Opción 2: PowerVS (Para workloads enterprise)

```bash
# 1. Configurar los mismos secrets de Code Engine

# 2. Ejecutar workflow manualmente
# Actions → Deploy to IBM PowerVS → Run workflow

# 3. Esperar ~20-30 minutos
# 4. Descargar SSH key de artifacts
# 5. Conectar: ssh -i powervs_key root@<ip>
```

**Costo**: ~$43-60/mes (configuración mínima)

## 🏗️ Arquitectura

### Code Engine
```
GitHub Push
    ↓
Build Docker Image (2-3 min)
    ↓
Push to IBM Container Registry
    ↓
Terraform Deploy (2 min)
    ↓
Code Engine Rolling Update (3-5 min)
    ↓
✅ App Running (Zero Downtime)
```

### PowerVS
```
GitHub Push/Manual
    ↓
Terraform Validate (2 min)
    ↓
Terraform Plan (3 min)
    ↓
Terraform Apply (15-30 min)
    ├─ Create Workspace
    ├─ Setup Networks
    ├─ Create LPAR
    └─ Install Application
    ↓
✅ App Running on POWER
```

## 📁 Estructura del Proyecto

```
.
├── .github/workflows/
│   ├── terraform-deploy.yml      # Code Engine CI/CD
│   └── powervs-deploy.yml        # PowerVS CI/CD
├── src/
│   └── index.html                # Aplicación web
├── terraform/
│   ├── code_engine.tf            # Code Engine resources
│   ├── main.tf                   # Project configuration
│   ├── variables.tf              # Variables
│   └── powervs/                  # PowerVS module
│       ├── instance.tf
│       ├── network.tf
│       ├── workspace.tf
│       └── ...
├── scripts/
│   ├── build-and-push-image.sh   # Build Docker local
│   ├── manage-codeengine-app.sh  # Gestión de apps
│   ├── diagnose-codeengine.sh    # Diagnóstico
│   ├── fix-disabled-project.sh   # Fix proyectos
│   └── powervs-setup.sh          # Setup PowerVS
├── Dockerfile                     # Imagen Docker
├── nginx.conf                     # Configuración nginx
└── docs/                          # Documentación
```

## 📚 Documentación Completa

### Guías de Deployment

| Documento | Descripción |
|-----------|-------------|
| [GITHUB_ACTIONS_DEPLOYMENT.md](GITHUB_ACTIONS_DEPLOYMENT.md) | Guía completa de Code Engine con GitHub Actions |
| [POWERVS_GITHUB_ACTIONS.md](POWERVS_GITHUB_ACTIONS.md) | Guía completa de PowerVS con GitHub Actions |
| [GUIA_COMPLETA_DEPLOYMENT.md](GUIA_COMPLETA_DEPLOYMENT.md) | Guía general de deployment |
| [DEPLOYMENT_SIMPLE.md](DEPLOYMENT_SIMPLE.md) | Deployment simple paso a paso |

### Troubleshooting y Optimización

| Documento | Descripción |
|-----------|-------------|
| [TERRAFORM_ICR_SETUP.md](TERRAFORM_ICR_SETUP.md) | Configuración de IBM Container Registry |
| [PROYECTO_DESHABILITADO.md](PROYECTO_DESHABILITADO.md) | Resolver proyectos deshabilitados |
| [TROUBLESHOOTING_TIMEOUT.md](TROUBLESHOOTING_TIMEOUT.md) | Resolver timeouts de deployment |
| [MANEJO_APPS_EXISTENTES.md](MANEJO_APPS_EXISTENTES.md) | Gestión de apps existentes |
| [ACTUALIZACION_EFICIENTE.md](ACTUALIZACION_EFICIENTE.md) | Optimización de actualizaciones |

### Deployment Específico

| Documento | Descripción |
|-----------|-------------|
| [DEPLOYMENT_GITHUB.md](DEPLOYMENT_GITHUB.md) | Deployment con GitHub Actions |
| [DEPLOYMENT_POWERVS.md](DEPLOYMENT_POWERVS.md) | Deployment en PowerVS |

## 🛠️ Scripts de Ayuda

### Code Engine

```bash
# Construir y subir imagen
./scripts/build-and-push-image.sh

# Gestionar aplicaciones
./scripts/manage-codeengine-app.sh

# Diagnóstico completo
./scripts/diagnose-codeengine.sh

# Resolver proyecto deshabilitado
./scripts/fix-disabled-project.sh
```

### PowerVS

```bash
# Deployment local
cd terraform/powervs
terraform init
terraform plan
terraform apply

# Ver outputs
terraform output
```

## 🔧 Configuración

### Secrets de GitHub (Requeridos)

```yaml
IBM_CLOUD_API_KEY: "tu-api-key"
IBM_CLOUD_REGION: "us-south"
IBM_CLOUD_RESOURCE_GROUP: "Default"
ICR_NAMESPACE: "test_icr"  # Solo para Code Engine
```

### Variables de Terraform

#### Code Engine (`terraform/terraform.tfvars`)

```hcl
ibmcloud_api_key    = "tu-api-key"
region              = "us-south"
project_name        = "ibm-cloud-info"
app_name            = "ibm-cloud-info-app"
container_image     = "icr.io/test_icr/ibm-cloud-info:latest"
container_port      = 8080
cpu                 = "0.25"
memory              = "0.5G"
min_scale           = 0
max_scale           = 10
```

#### PowerVS (`terraform/powervs/terraform.tfvars`)

```hcl
ibmcloud_api_key      = "tu-api-key"
powervs_zone          = "dal12"
instance_processors   = 0.25
instance_memory       = 2
instance_storage_size = 20
ssh_public_key        = "ssh-rsa AAAA..."
```

## 🎯 Características

### Aplicación Web

- ✅ **Responsive** - Funciona en móvil y desktop
- ✅ **Información completa** sobre IBM Cloud
- ✅ **Diseño moderno** con gradientes
- ✅ **Optimizada** para rendimiento
- ✅ **SEO friendly**

### Infraestructura

- ✅ **Infrastructure as Code** con Terraform
- ✅ **CI/CD completo** con GitHub Actions
- ✅ **Zero downtime** deployments
- ✅ **Rollback fácil** con Git
- ✅ **Monitoreo** integrado
- ✅ **Logs** centralizados

### Seguridad

- ✅ **HTTPS** automático
- ✅ **Secrets** gestionados por GitHub
- ✅ **SSH keys** generados automáticamente
- ✅ **Registry privado** para imágenes
- ✅ **IAM** de IBM Cloud
- ✅ **Scan de vulnerabilidades**

## 💰 Costos

### Code Engine

| Configuración | Costo/Mes |
|---------------|-----------|
| Tier gratuito | $0 |
| Uso ligero | $0-10 |
| Uso moderado | $10-50 |
| Uso intensivo | $50-200 |

### PowerVS

| Configuración | Cores | RAM | Costo/Mes |
|---------------|-------|-----|-----------|
| Mínima | 0.25 | 2GB | $43-60 |
| Pequeña | 0.5 | 4GB | $86-120 |
| Media | 1.0 | 8GB | $172-240 |
| Grande | 2.0 | 16GB | $344-480 |

## 🔄 Workflow de Desarrollo

### Para Cambios en la Aplicación

```bash
# 1. Crear branch
git checkout -b feature/nueva-funcionalidad

# 2. Hacer cambios
vim src/index.html

# 3. Commit y push
git add .
git commit -m "feat: add new section"
git push origin feature/nueva-funcionalidad

# 4. Crear PR en GitHub
# 5. Revisar plan de Terraform en PR
# 6. Aprobar y merge
# 7. Deployment automático a Code Engine
```

### Para Cambios en Infraestructura

```bash
# 1. Crear branch
git checkout -b infra/update-resources

# 2. Modificar Terraform
vim terraform/code_engine.tf

# 3. Push y crear PR
git push origin infra/update-resources

# 4. Revisar plan en PR
# 5. Aprobar y merge
# 6. Terraform apply automático
```

## 🧪 Testing

### Local

```bash
# Build imagen
docker build -t ibm-cloud-info .

# Run localmente
docker run -p 8080:8080 ibm-cloud-info

# Test
curl http://localhost:8080
```

### En GitHub Actions

- ✅ Validación automática en PRs
- ✅ Plan de Terraform visible
- ✅ Health checks post-deployment
- ✅ Rollback automático si falla

## 📊 Monitoreo

### Code Engine

```bash
# Ver logs
ibmcloud ce app logs --app ibm-cloud-info-app --tail 100

# Ver métricas
ibmcloud ce app get --name ibm-cloud-info-app

# Ver eventos
ibmcloud ce app events --app ibm-cloud-info-app
```

### PowerVS

```bash
# Conectar por SSH
ssh -i powervs_key root@<ip>

# Ver logs
journalctl -u ibm-cloud-info -f

# Ver status
systemctl status ibm-cloud-info
```

## 🤝 Contribuir

1. Fork el repositorio
2. Crea una branch (`git checkout -b feature/amazing`)
3. Commit tus cambios (`git commit -m 'Add amazing feature'`)
4. Push a la branch (`git push origin feature/amazing`)
5. Abre un Pull Request

## 📝 Licencia

Este proyecto está bajo la licencia MIT. Ver [LICENSE](LICENSE) para más detalles.

## 👤 Autor

**Santiago Tamayo**
- Email: stamayo@co.ibm.com
- GitHub: [@SantiagoT21](https://github.com/SantiagoT21)

## 🙏 Agradecimientos

- IBM Cloud Team
- Terraform Community
- GitHub Actions Team

## 📞 Soporte

Si tienes problemas:

1. **Revisa la documentación** en la carpeta docs/
2. **Ejecuta diagnóstico**: `./scripts/diagnose-codeengine.sh`
3. **Revisa los logs** en GitHub Actions
4. **Abre un issue** en GitHub
5. **Contacta**: stamayo@co.ibm.com

---

**Made with ❤️ using IBM Cloud, Terraform, and GitHub Actions**

🚀 **Deploy automático** | 🔒 **Seguro** | 📊 **Monitoreado** | 💰 **Optimizado**
