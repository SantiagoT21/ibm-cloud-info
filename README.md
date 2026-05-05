# IBM Cloud Info - Multi-Platform Deployment

[![Build and Push Docker Image](https://github.com/YOUR_USERNAME/ibm-cloud-info/actions/workflows/docker-build.yml/badge.svg)](https://github.com/YOUR_USERNAME/ibm-cloud-info/actions/workflows/docker-build.yml)
[![Terraform Deploy](https://github.com/YOUR_USERNAME/ibm-cloud-info/actions/workflows/terraform-deploy.yml/badge.svg)](https://github.com/YOUR_USERNAME/ibm-cloud-info/actions/workflows/terraform-deploy.yml)

Proyecto de demostración que despliega una aplicación web informativa sobre IBM Cloud con **dos opciones de deployment**:

1. **🚀 Code Engine** (Serverless) - Deployment rápido y económico
2. **⚡ PowerVS** (LPAR) - Control total con arquitectura POWER

Ambos deployments utilizan Terraform para infraestructura como código.

## 📋 Tabla de Contenidos

- [Descripción](#descripción)
- [Opciones de Deployment](#opciones-de-deployment)
- [Arquitectura](#arquitectura)
- [Guías de Deployment](#guías-de-deployment)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Comparación de Plataformas](#comparación-de-plataformas)
- [Recursos Adicionales](#recursos-adicionales)

## 🎯 Descripción

Este proyecto despliega una aplicación web estática que presenta información detallada sobre IBM Cloud y sus ventajas empresariales, incluyendo:

- 🔒 **Seguridad Empresarial**: Certificaciones, cifrado, IAM
- 📈 **Escalabilidad**: Auto-scaling, distribución global
- 🤖 **IA/ML**: Watson AI, AutoML, MLOps
- 💰 **Optimización de Costos**: Modelos de precios, herramientas de gestión

## 🚀 Opciones de Deployment

Este proyecto ofrece **dos opciones de deployment** para diferentes necesidades:

### Opción 1: Code Engine (Serverless) 🚀

**Ideal para**: Aplicaciones web, microservicios, prototipos, demos

**Características**:
- ✅ Deployment en minutos (2-5 min)
- ✅ Auto-scaling automático (0-10 instancias)
- ✅ Scale-to-zero (costo $0 sin tráfico)
- ✅ HTTPS automático
- ✅ CI/CD con GitHub Actions
- ✅ Contenedor Docker con nginx
- 💰 **Costo**: $0-5/mes

**Documentación**: Ver [DEPLOYMENT_GITHUB.md](DEPLOYMENT_GITHUB.md)

### Opción 2: PowerVS (LPAR) ⚡

**Ideal para**: Workloads enterprise, aplicaciones que requieren control total, migración de AIX/IBM i

**Características**:
- ✅ Control total del sistema operativo (root access)
- ✅ Arquitectura IBM POWER (ppc64le)
- ✅ Rocky Linux 9 (gratuito)
- ✅ Recursos dedicados y predecibles
- ✅ IP pública fija
- ✅ Infraestructura como código con Terraform
- 💰 **Costo**: $43-60/mes (configuración mínima)

**Documentación**: Ver [DEPLOYMENT_POWERVS.md](DEPLOYMENT_POWERVS.md)

## 🏗️ Arquitectura

## 🏗️ Arquitectura Multi-Plataforma

Este proyecto soporta dos arquitecturas de deployment diferentes:

### Arquitectura Code Engine (Serverless)

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Repository                         │
│                      (Source Code)                           │
└────────────────────┬────────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
        ▼                         ▼
┌──────────────────┐    ┌──────────────────┐
│ GitHub Actions   │    │ GitHub Actions   │
│ Docker Build     │    │ Terraform Deploy │
└────────┬─────────┘    └────────┬─────────┘
         │                       │
         ▼                       ▼
┌──────────────────┐    ┌──────────────────┐
│ IBM Container    │    │  IBM Cloud       │
│   Registry       │───▶│  Code Engine     │
└──────────────────┘    └────────┬─────────┘
                                 │
                                 ▼
                        ┌──────────────────┐
                        │   Public URL     │
                        │  (HTTPS Auto)    │
                        │  Auto-scaling    │
                        └──────────────────┘
```

### Arquitectura PowerVS (LPAR)

```
┌─────────────────────────────────────────────────────────────┐
│                    Terraform Configuration                   │
│                  (Infrastructure as Code)                    │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              IBM Cloud - PowerVS Workspace                   │
│                                                              │
│  ┌────────────────────────────────────────────────┐         │
│  │         Private Network (192.168.0.0/24)       │         │
│  │                                                 │         │
│  │   ┌─────────────────────────────────────┐      │         │
│  │   │  LPAR - Rocky Linux 9 (POWER)       │      │         │
│  │   │  ├─ 0.25 cores, 2GB RAM, 20GB       │      │         │
│  │   │  ├─ Nginx Web Server                │      │         │
│  │   │  ├─ Firewalld Security              │      │         │
│  │   │  └─ SSH Access                      │      │         │
│  │   │                                      │      │         │
│  │   │  Private IP: 192.168.0.x             │      │         │
│  │   └──────────────┬──────────────────────┘      │         │
│  │                  │                              │         │
│  └──────────────────┼──────────────────────────────┘         │
│                     │                                        │
│                     ▼                                        │
│         ┌──────────────────────┐                            │
│         │   Public Network     │                            │
│         │   Fixed Public IP    │                            │
│         └──────────────────────┘                            │
└─────────────────────────────────────────────────────────────┘
                     │
                     ▼
              Internet Access
            http://PUBLIC_IP

```

## 📚 Guías de Deployment

Selecciona la guía según tu necesidad:

| Plataforma | Guía | Tiempo | Costo Mensual | Complejidad |
|------------|------|--------|---------------|-------------|
| **Code Engine** | [DEPLOYMENT_GITHUB.md](DEPLOYMENT_GITHUB.md) | 5 min | $0-5 | ⭐ Fácil |
| **PowerVS** | [DEPLOYMENT_POWERVS.md](DEPLOYMENT_POWERVS.md) | 30 min | $43-60 | ⭐⭐⭐ Avanzado |

### Inicio Rápido - Code Engine

```bash
# 1. Clonar repositorio
git clone https://github.com/YOUR_USERNAME/ibm-cloud-info.git
cd ibm-cloud-info

# 2. Configurar variables
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars con tu API key

# 3. Desplegar
terraform init
terraform apply
```

### Inicio Rápido - PowerVS

```bash
# 1. Clonar repositorio
git clone https://github.com/YOUR_USERNAME/ibm-cloud-info.git
cd ibm-cloud-info

# 2. Generar SSH key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/powervs_key

# 3. Configurar variables
cd terraform/powervs
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars con tu API key y SSH public key

# 4. Desplegar
terraform init
terraform apply
```


```
## 📁 Estructura del Proyecto

```
ibm-cloud-info/
├── .github/
│   └── workflows/
│       ├── docker-build.yml           # CI/CD para Code Engine
│       └── terraform-deploy.yml       # Deployment automatizado
├── terraform/
│   ├── provider.tf                    # Provider para Code Engine
│   ├── variables.tf                   # Variables de Code Engine
│   ├── main.tf                        # Resource group y proyecto
│   ├── code_engine.tf                 # Aplicación Code Engine
│   ├── outputs.tf                     # Outputs de Code Engine
│   ├── terraform.tfvars.example       # Ejemplo de variables
│   └── powervs/                       # ⚡ NUEVO: Módulo PowerVS
│       ├── provider.tf                # Provider para PowerVS
│       ├── variables.tf               # Variables de PowerVS
│       ├── data.tf                    # Data sources (imágenes, etc)
│       ├── workspace.tf               # PowerVS Workspace
│       ├── network.tf                 # Red privada
│       ├── public_network.tf          # Red pública
│       ├── security.tf                # SSH keys
│       ├── instance.tf                # LPAR configuration
│       ├── outputs.tf                 # Outputs de PowerVS
│       └── terraform.tfvars.example   # Ejemplo de variables
├── scripts/
│   ├── init.sh                        # Script de inicialización
│   └── powervs-setup.sh               # ⚡ NUEVO: Setup de LPAR
├── src/
│   └── index.html                     # Aplicación web
├── Dockerfile                         # Container para Code Engine
├── README.md                          # Este archivo
├── DEPLOYMENT_GITHUB.md               # Guía Code Engine
└── DEPLOYMENT_POWERVS.md              # ⚡ NUEVO: Guía PowerVS
```

## 📊 Comparación de Plataformas

| Característica | Code Engine 🚀 | PowerVS ⚡ |
|----------------|----------------|-----------|
| **Tipo** | Serverless (PaaS) | IaaS (VM dedicada) |
| **Arquitectura** | x86_64 | POWER (ppc64le) |
| **OS** | Container (Alpine) | Rocky Linux 9 |
| **Deployment** | 2-5 minutos | 15-30 minutos |
| **Escalabilidad** | Auto (0-10 instancias) | Manual |
| **Costo Mensual** | $0-5 | $43-60+ |
| **Control** | Limitado | Total (root access) |
| **Mantenimiento** | Automático | Manual |
| **Scale-to-Zero** | ✅ Sí | ❌ No |
| **IP Pública** | Dinámica | Fija |
| **HTTPS** | Automático | Manual |
| **Ideal Para** | Apps web, APIs, demos | Enterprise, AIX, IBM i |

### ¿Cuál elegir?

**Elige Code Engine si**:
- ✅ Necesitas deployment rápido
- ✅ Quieres minimizar costos
- ✅ Tu app es stateless
- ✅ No necesitas acceso root
- ✅ Prefieres mantenimiento automático

**Elige PowerVS si**:
- ✅ Necesitas control total del OS
- ✅ Requieres arquitectura POWER
- ✅ Migras desde AIX o IBM i
- ✅ Necesitas recursos dedicados
- ✅ Requieres IP fija

## 🛠️ Comandos Útiles

### Code Engine

```bash
# Ver aplicaciones
ibmcloud ce application list

# Ver logs
ibmcloud ce application logs --name ibm-cloud-info-app

# Ver detalles
ibmcloud ce application get --name ibm-cloud-info-app
```

### PowerVS

```bash
# Listar workspaces
ibmcloud pi service-list

# Listar instancias
ibmcloud pi instances

# Conectar por SSH
ssh -i ~/.ssh/powervs_key root@PUBLIC_IP
```

### Terraform

```bash
# Code Engine
cd terraform
terraform init
terraform plan
terraform apply

# PowerVS
cd terraform/powervs
terraform init
terraform plan
terraform apply
```

### 2. Configurar Variables de Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Editar `terraform.tfvars` con tus valores:

```hcl
ibmcloud_api_key    = "YOUR_IBM_CLOUD_API_KEY"
region              = "us-south"
resource_group_name = "Default"
container_image     = "icr.io/YOUR_NAMESPACE/ibm-cloud-info:latest"
```

### 3. Configurar GitHub Secrets

Ve a tu repositorio en GitHub: `Settings > Secrets and variables > Actions > New repository secret`

Agrega los siguientes secrets:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `IBM_CLOUD_API_KEY` | Tu IBM Cloud API Key | `abc123...` |
| `IBM_CLOUD_REGION` | Región de IBM Cloud | `us-south` |
| `IBM_CLOUD_RESOURCE_GROUP` | Nombre del Resource Group | `Default` |
| `ICR_NAMESPACE` | Namespace de Container Registry | `my-namespace` |

## 🚀 Deployment Local

### Opción 1: Deployment Completo con Terraform

```bash
# 1. Build de la imagen Docker
docker build -t icr.io/YOUR_NAMESPACE/ibm-cloud-info:latest .

# 2. Login a IBM Container Registry
ibmcloud cr login

# 3. Push de la imagen
docker push icr.io/YOUR_NAMESPACE/ibm-cloud-info:latest

# 4. Inicializar Terraform
cd terraform
terraform init

# 5. Planificar cambios
terraform plan

# 6. Aplicar cambios
terraform apply

# 7. Obtener la URL de la aplicación
terraform output application_url
```

### Opción 2: Test Local con Docker

```bash
# Build de la imagen
docker build -t ibm-cloud-info:local .

# Ejecutar localmente
docker run -p 8080:8080 ibm-cloud-info:local

# Acceder a http://localhost:8080
```

## 🔄 Deployment con GitHub Actions

### Deployment Automático

El deployment se ejecuta automáticamente cuando:

1. **Push a main**: Cualquier cambio en `src/`, `Dockerfile`, o `terraform/`
2. **Pull Request**: Se ejecuta plan de Terraform (sin aplicar)
3. **Manual**: Desde la pestaña Actions en GitHub

### Flujo de Trabajo

```mermaid
graph LR
    A[Push to main] --> B[Docker Build]
    B --> C[Push to ICR]
    C --> D[Trigger Terraform]
    D --> E[Terraform Apply]
    E --> F[App Deployed]
```

### Ejecución Manual

1. Ve a la pestaña **Actions** en GitHub
2. Selecciona el workflow deseado
3. Click en **Run workflow**
4. Selecciona la acción (plan/apply/destroy)

## 📁 Estructura del Proyecto

```
ibm-cloud-info/
├── .github/
│   └── workflows/
│       ├── docker-build.yml      # Build y push de Docker
│       └── terraform-deploy.yml  # Deployment con Terraform
├── terraform/
│   ├── provider.tf               # Configuración del provider
│   ├── variables.tf              # Variables de Terraform
│   ├── main.tf                   # Resource group y proyecto
│   ├── code_engine.tf            # Aplicación Code Engine
│   ├── outputs.tf                # Outputs de Terraform
│   └── terraform.tfvars.example  # Plantilla de variables
├── src/
│   └── index.html                # Aplicación web
├── Dockerfile                    # Configuración de Docker
├── .gitignore                    # Archivos ignorados
├── .env.example                  # Plantilla de variables de entorno
└── README.md                     # Este archivo
```

## 🔄 Actualización del HTML

Para actualizar el contenido de la aplicación:

1. **Editar el HTML**:
   ```bash
   vim src/index.html
   # Hacer tus cambios
   ```

2. **Commit y Push**:
   ```bash
   git add src/index.html
   git commit -m "Update: descripción de cambios"
   git push origin main
   ```

3. **Deployment Automático**:
   - GitHub Actions detecta el cambio
   - Build de nueva imagen Docker
   - Push a IBM Container Registry
   - Terraform actualiza Code Engine
   - Nueva versión disponible en ~5 minutos

## 🛠️ Comandos Útiles

### Terraform

```bash
# Ver estado actual
terraform show

# Ver outputs
terraform output

# Refrescar estado
terraform refresh

# Destruir infraestructura
terraform destroy

# Formatear archivos
terraform fmt -recursive

# Validar configuración
terraform validate
```

### Docker

```bash
# Ver imágenes locales
docker images

# Ver contenedores en ejecución
docker ps

# Ver logs del contenedor
docker logs CONTAINER_ID

# Limpiar imágenes no usadas
docker image prune -a
```

### IBM Cloud CLI

```bash
# Login
ibmcloud login --apikey YOUR_API_KEY

# Ver proyectos de Code Engine
ibmcloud ce project list

# Ver aplicaciones
ibmcloud ce application list

# Ver logs de la aplicación
ibmcloud ce application logs --name ibm-cloud-info-app

# Ver detalles de la aplicación
ibmcloud ce application get --name ibm-cloud-info-app
```

## 🔍 Troubleshooting

### Error: "Failed to authenticate with IBM Cloud"

**Solución**: Verifica que tu API Key sea válida:
```bash
ibmcloud login --apikey YOUR_API_KEY
```

### Error: "Namespace not found in Container Registry"

**Solución**: Crea el namespace:
```bash
ibmcloud cr namespace-add YOUR_NAMESPACE
```

### Error: "Resource group not found"

**Solución**: Lista los resource groups disponibles:
```bash
ibmcloud resource groups
```

### La aplicación no responde

**Solución**: Verifica los logs:
```bash
ibmcloud ce application logs --name ibm-cloud-info-app --follow
```

### GitHub Actions falla

**Solución**: 
1. Verifica que todos los secrets estén configurados
2. Revisa los logs en la pestaña Actions
3. Verifica permisos de la API Key

## 💰 Costos

### Code Engine

- **Nivel Gratuito**: 
  - 100,000 vCPU-segundos/mes
  - 200,000 GB-segundos/mes
  - Suficiente para desarrollo y demos

- **Costos Estimados** (después del nivel gratuito):
  - vCPU: $0.00003/vCPU-segundo
  - Memoria: $0.0000033/GB-segundo
  - Requests: Gratis

### Container Registry

- **Nivel Gratuito**: 
  - 500 MB de almacenamiento
  - 5 GB de tráfico pull/mes

### Estimación Mensual

Para una aplicación de demo con tráfico bajo:
- **Costo estimado**: $0-5 USD/mes
- Con scale-to-zero: ~$0 cuando no hay tráfico

## 📚 Recursos Adicionales

- [IBM Cloud Code Engine Docs](https://cloud.ibm.com/docs/codeengine)
- [Terraform IBM Provider](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs)
- [IBM Container Registry](https://cloud.ibm.com/docs/Registry)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📝 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

## 👤 Autor

Tu Nombre - [@tu_twitter](https://twitter.com/tu_twitter)

Proyecto Link: [https://github.com/YOUR_USERNAME/ibm-cloud-info](https://github.com/YOUR_USERNAME/ibm-cloud-info)

---

⭐ Si este proyecto te fue útil, considera darle una estrella en GitHub!
## 📚 Recursos Adicionales

### Documentación Oficial

- [IBM Cloud Code Engine](https://cloud.ibm.com/docs/codeengine)
- [IBM PowerVS Documentation](https://cloud.ibm.com/docs/power-iaas)
- [Terraform IBM Provider](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs)
- [Rocky Linux Documentation](https://docs.rockylinux.org/)

### Guías Específicas

- **Code Engine**: [DEPLOYMENT_GITHUB.md](DEPLOYMENT_GITHUB.md) - Deployment completo con CI/CD
- **PowerVS**: [DEPLOYMENT_POWERVS.md](DEPLOYMENT_POWERVS.md) - Deployment en LPAR con Rocky Linux
- **Deployment Simple**: [DEPLOYMENT_SIMPLE.md](DEPLOYMENT_SIMPLE.md) - Deployment básico sin GitHub Actions
- **Podman**: [PODMAN_GUIDE.md](PODMAN_GUIDE.md) - Uso de Podman en lugar de Docker

### Calculadoras de Costos

- [IBM Cloud Pricing Calculator](https://cloud.ibm.com/estimator)
- [Code Engine Pricing](https://cloud.ibm.com/docs/codeengine?topic=codeengine-pricing)
- [PowerVS Pricing](https://cloud.ibm.com/docs/power-iaas?topic=power-iaas-pricing-virtual-server)

## 💡 Casos de Uso

### Code Engine - Ideal Para:

1. **Aplicaciones Web Modernas**
   - SPAs (Single Page Applications)
   - APIs RESTful
   - Microservicios

2. **Prototipos y Demos**
   - Deployment rápido
   - Costos mínimos
   - Fácil de compartir

3. **Aplicaciones con Tráfico Variable**
   - Scale-to-zero cuando no hay uso
   - Auto-scaling en picos de tráfico
   - Optimización automática de costos

### PowerVS - Ideal Para:

1. **Migración de Workloads Legacy**
   - Aplicaciones AIX
   - IBM i (AS/400)
   - Aplicaciones que requieren POWER

2. **Aplicaciones Enterprise Críticas**
   - Bases de datos de alto rendimiento
   - ERP y sistemas core
   - Aplicaciones que requieren recursos dedicados

3. **Desarrollo y Testing**
   - Entornos de desarrollo POWER
   - Testing de compatibilidad
   - Laboratorios de capacitación

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📝 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

## 👤 Autor

Tu Nombre - [@tu_twitter](https://twitter.com/tu_twitter)

Proyecto Link: [https://github.com/YOUR_USERNAME/ibm-cloud-info](https://github.com/YOUR_USERNAME/ibm-cloud-info)

---

⭐ Si este proyecto te fue útil, considera darle una estrella en GitHub!
