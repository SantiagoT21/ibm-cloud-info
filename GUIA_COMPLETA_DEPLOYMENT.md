# Guía Completa de Deployment - IBM Cloud Code Engine

## 🎯 Resumen Ejecutivo

Esta guía te llevará paso a paso desde la construcción de la imagen Docker hasta el deployment completo en IBM Cloud Code Engine usando Terraform.

## 📋 Prerequisitos

Antes de comenzar, asegúrate de tener instalado:

- ✅ IBM Cloud CLI (`ibmcloud`)
- ✅ Code Engine plugin (`ibmcloud plugin install code-engine`)
- ✅ Container Registry plugin (`ibmcloud plugin install container-registry`)
- ✅ Terraform (`terraform`)
- ✅ Docker o Podman
- ✅ Git (opcional)

## 🚀 Proceso Completo de Deployment

### Paso 1: Construir y Subir la Imagen

```bash
# Ejecutar el script de build y push
./scripts/build-and-push-image.sh
```

**Este script hará:**
1. ✅ Detectar si usas Docker o Podman
2. ✅ Verificar autenticación a IBM Cloud
3. ✅ Login al Container Registry
4. ✅ Verificar/crear el namespace
5. ✅ Construir la imagen
6. ✅ Probar la imagen localmente (opcional)
7. ✅ Subir la imagen al registry
8. ✅ Verificar que la imagen esté disponible
9. ✅ Escanear vulnerabilidades (opcional)

**Tiempo estimado:** 5-10 minutos

### Paso 2: Resolver Proyecto Deshabilitado (Si Aplica)

Si tu proyecto de Code Engine está deshabilitado:

```bash
./scripts/fix-disabled-project.sh
```

Selecciona **Opción 5: Full automated fix**

**Este script hará:**
1. ✅ Eliminar el proyecto deshabilitado
2. ✅ Limpiar el state de Terraform
3. ✅ Recrear el proyecto con Terraform
4. ✅ Crear el registry secret
5. ✅ Desplegar la aplicación
6. ✅ Verificar el deployment

**Tiempo estimado:** 5-10 minutos

### Paso 3: Deployment con Terraform (Si el Proyecto Está Activo)

Si tu proyecto ya está activo o acabas de crearlo:

```bash
cd terraform
terraform plan -out=tfplan
terraform apply -auto-approve -input=false tfplan
```

**Tiempo estimado:** 5-15 minutos

### Paso 4: Verificar el Deployment

```bash
# Ver la URL de la aplicación
cd terraform
terraform output app_url

# Probar la aplicación
curl $(terraform output -raw app_url)

# O abrir en el navegador
open $(terraform output -raw app_url)
```

## 📝 Flujo de Trabajo Recomendado

### Para Primera Vez

```bash
# 1. Construir y subir imagen
./scripts/build-and-push-image.sh

# 2. Desplegar con Terraform
cd terraform
terraform init
terraform plan -out=tfplan
terraform apply -auto-approve -input=false tfplan

# 3. Verificar
terraform output app_url
curl $(terraform output -raw app_url)
```

### Para Actualizaciones

```bash
# 1. Reconstruir imagen con cambios
./scripts/build-and-push-image.sh

# 2. Actualizar deployment
cd terraform
terraform plan -out=tfplan
terraform apply -auto-approve -input=false tfplan
```

### Para Resolver Problemas

```bash
# 1. Ejecutar diagnóstico
./scripts/diagnose-codeengine.sh

# 2. Si el proyecto está deshabilitado
./scripts/fix-disabled-project.sh
# Selecciona opción 5

# 3. Si la app existe y causa conflictos
./scripts/manage-codeengine-app.sh
# Selecciona opción 5 o 6
```

## 🛠️ Scripts Disponibles

### 1. `build-and-push-image.sh` - Construcción y Push de Imagen

**Uso:**
```bash
./scripts/build-and-push-image.sh
```

**Características:**
- Detecta automáticamente Docker o Podman
- Lee configuración de `terraform.tfvars`
- Prueba la imagen localmente antes de subir
- Verifica la imagen en el registry
- Escaneo de vulnerabilidades opcional

### 2. `fix-disabled-project.sh` - Resolver Proyecto Deshabilitado

**Uso:**
```bash
./scripts/fix-disabled-project.sh
```

**Opciones:**
1. Verificar estado del proyecto
2. Eliminar proyecto deshabilitado
3. Eliminar y recrear con Terraform
4. Eliminar y recrear manualmente
5. **Fix automatizado completo** (Recomendado)
6. Salir

### 3. `manage-codeengine-app.sh` - Gestión de Aplicaciones

**Uso:**
```bash
./scripts/manage-codeengine-app.sh
```

**Opciones:**
1. Verificar si la app existe
2. Eliminar app existente
3. Importar app a Terraform
4. Ver detalles de la app
5. Eliminar y aplicar Terraform
6. Importar y aplicar Terraform
7. Salir

### 4. `diagnose-codeengine.sh` - Diagnóstico Completo

**Uso:**
```bash
./scripts/diagnose-codeengine.sh
```

**Verifica:**
- Autenticación a IBM Cloud
- Acceso al Container Registry
- Existencia de la imagen
- Estado del proyecto Code Engine
- Configuración del registry secret
- Estado de la aplicación
- Permisos IAM

## 🔧 Configuración

### Archivo `terraform/terraform.tfvars`

```hcl
# IBM Cloud Configuration
ibmcloud_api_key = "tu-api-key-aqui"
region           = "us-south"

# Resource Group
resource_group_name = "Default"

# Code Engine Project
project_name = "ibm-cloud-info"

# Application Configuration
app_name        = "ibm-cloud-info-app"
container_image = "icr.io/test_icr/ibm-cloud-info:latest"
container_port  = 8080

# Scaling Configuration
cpu            = "0.25"
memory         = "0.5G"
min_scale      = 0
max_scale      = 10
request_timeout = 300

# Tags
tags = ["terraform", "code-engine", "ibm-cloud-info"]
```

## 🐛 Troubleshooting

### Error: "Project is in disabled state"

**Solución:**
```bash
./scripts/fix-disabled-project.sh
# Selecciona opción 5
```

**Documentación:** Ver `PROYECTO_DESHABILITADO.md`

### Error: "timeout while waiting for state to become 'ready'"

**Causas comunes:**
1. Imagen no existe en el registry
2. Secret de registry mal configurado
3. Aplicación no inicia correctamente

**Solución:**
```bash
# 1. Verificar imagen
ibmcloud cr images --restrict test_icr/ibm-cloud-info

# 2. Si no existe, construirla
./scripts/build-and-push-image.sh

# 3. Ejecutar diagnóstico
./scripts/diagnose-codeengine.sh

# 4. Reintentar deployment
cd terraform
terraform apply -auto-approve -input=false tfplan
```

**Documentación:** Ver `TROUBLESHOOTING_TIMEOUT.md`

### Error: "Resource already exists"

**Solución:**
```bash
./scripts/manage-codeengine-app.sh
# Selecciona opción 6 (Importar y aplicar)
```

**Documentación:** Ver `MANEJO_APPS_EXISTENTES.md`

### Error: "UNAUTHORIZED: Authorization required"

**Causas:**
- API key incorrecta
- Secret de registry no configurado
- Permisos insuficientes

**Solución:**
```bash
# 1. Verificar API key en terraform.tfvars
# 2. Verificar secret
ibmcloud ce project select --name ibm-cloud-info
ibmcloud ce secret get --name icr-secret

# 3. Recrear secret si es necesario
cd terraform
terraform apply -target=ibm_code_engine_secret.registry_secret
```

**Documentación:** Ver `TERRAFORM_ICR_SETUP.md`

## 📚 Documentación Adicional

- **`TERRAFORM_ICR_SETUP.md`** - Configuración de IBM Container Registry
- **`PROYECTO_DESHABILITADO.md`** - Resolver proyectos deshabilitados
- **`TROUBLESHOOTING_TIMEOUT.md`** - Resolver timeouts de deployment
- **`MANEJO_APPS_EXISTENTES.md`** - Gestión de apps existentes
- **`README.md`** - Información general del proyecto

## ✅ Checklist de Deployment

### Pre-Deployment
- [ ] IBM Cloud CLI instalado y configurado
- [ ] Plugins de Code Engine y Container Registry instalados
- [ ] Terraform instalado
- [ ] Docker o Podman instalado
- [ ] Autenticado en IBM Cloud (`ibmcloud login --sso`)
- [ ] Archivo `terraform.tfvars` configurado con API key

### Build y Push
- [ ] Imagen construida exitosamente
- [ ] Imagen probada localmente
- [ ] Imagen subida al registry
- [ ] Imagen verificada en el registry

### Deployment
- [ ] Proyecto de Code Engine activo (no deshabilitado)
- [ ] Terraform inicializado (`terraform init`)
- [ ] Plan de Terraform revisado (`terraform plan`)
- [ ] Terraform aplicado exitosamente
- [ ] Registry secret creado
- [ ] Aplicación desplegada

### Post-Deployment
- [ ] URL de la aplicación obtenida
- [ ] Aplicación responde correctamente
- [ ] Logs revisados (sin errores)
- [ ] Monitoreo configurado (opcional)

## 🎓 Mejores Prácticas

### 1. Versionado de Imágenes

En lugar de usar `:latest`, usa tags específicos:

```hcl
container_image = "icr.io/test_icr/ibm-cloud-info:v1.0.0"
```

### 2. Variables de Entorno

Usa variables de entorno para configuración:

```bash
export TF_VAR_ibmcloud_api_key="tu-api-key"
```

### 3. State Remoto

Para equipos, usa state remoto:

```hcl
terraform {
  backend "s3" {
    bucket = "mi-bucket-terraform-state"
    key    = "code-engine/terraform.tfstate"
    region = "us-south"
  }
}
```

### 4. CI/CD

Integra los scripts en tu pipeline:

```yaml
# .github/workflows/deploy.yml
- name: Build and Push Image
  run: ./scripts/build-and-push-image.sh

- name: Deploy with Terraform
  run: |
    cd terraform
    terraform init
    terraform plan -out=tfplan
    terraform apply -auto-approve tfplan
```

### 5. Monitoreo

Configura alertas y monitoreo:

```bash
# Verificación diaria del estado
crontab -e
# Agregar: 0 9 * * * /path/to/scripts/diagnose-codeengine.sh
```

## 🆘 Soporte

Si necesitas ayuda:

1. **Ejecuta el diagnóstico:**
   ```bash
   ./scripts/diagnose-codeengine.sh > diagnostics.log 2>&1
   ```

2. **Revisa la documentación específica:**
   - Problemas con imagen: `TERRAFORM_ICR_SETUP.md`
   - Proyecto deshabilitado: `PROYECTO_DESHABILITADO.md`
   - Timeouts: `TROUBLESHOOTING_TIMEOUT.md`
   - Apps existentes: `MANEJO_APPS_EXISTENTES.md`

3. **Contacta al soporte de IBM Cloud** con:
   - Logs de diagnóstico
   - Trace IDs de errores
   - Configuración de Terraform

## 🎉 Resumen

Con esta guía y los scripts proporcionados, puedes:

✅ Construir y subir imágenes al registry fácilmente
✅ Resolver problemas de proyectos deshabilitados automáticamente
✅ Gestionar aplicaciones existentes sin conflictos
✅ Diagnosticar y resolver problemas rápidamente
✅ Desplegar con confianza usando Terraform

**¡Tu aplicación estará corriendo en Code Engine en menos de 15 minutos!**