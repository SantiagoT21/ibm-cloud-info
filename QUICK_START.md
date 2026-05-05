# 🚀 Quick Start Guide

Guía rápida para desplegar tu aplicación IBM Cloud Info en Code Engine.

## ⚠️ IMPORTANTE: Instalar Plugins Primero

Antes de continuar, necesitas instalar los plugins de IBM Cloud CLI:

```bash
# Instalar plugins necesarios
ibmcloud plugin install container-registry -f
ibmcloud plugin install code-engine -f

# Verificar instalación
ibmcloud plugin list
```

**Ver instrucciones detalladas en: [INSTALL_PLUGINS.md](INSTALL_PLUGINS.md)**

---

## ✅ Pre-requisitos Completados

- [x] Archivo `.env` configurado con credenciales
- [x] Archivo `terraform/terraform.tfvars` creado
- [x] IBM Cloud API Key: `zLn7cRy...`
- [x] Region: `us-south`
- [x] Resource Group: `ibm-code-engine-test-rg`
- [x] ICR Namespace: `test_icr`

## 📦 Opción 1: Deployment Local (Recomendado para primera vez)

### Paso 1: Build y Push de la Imagen Docker

```bash
# 1. Login a IBM Cloud
ibmcloud login --apikey zLn7cRyoBQReEVI1YcrtZJL_vkxiT6RjEiikqjQWbGil

# 2. Login a Container Registry
ibmcloud cr login

# 3. Build de la imagen
docker build -t icr.io/test_icr/ibm-cloud-info:latest .

# 4. Push de la imagen
docker push icr.io/test_icr/ibm-cloud-info:latest

# 5. Verificar que la imagen se subió correctamente
ibmcloud cr image-list
```

### Paso 2: Deploy con Terraform

```bash
# 1. Ir al directorio de Terraform
cd terraform

# 2. Inicializar Terraform
terraform init

# 3. Ver el plan de deployment
terraform plan

# 4. Aplicar los cambios
terraform apply

# Cuando pregunte "Do you want to perform these actions?", escribe: yes

# 5. Obtener la URL de tu aplicación
terraform output application_url
```

### Paso 3: Verificar el Deployment

```bash
# Ver el estado de la aplicación
ibmcloud ce application get --name ibm-cloud-info-app

# Ver logs en tiempo real
ibmcloud ce application logs --name ibm-cloud-info-app --follow
```

## 🌐 Opción 2: Deployment con GitHub Actions

### Paso 1: Crear Repositorio en GitHub

```bash
# 1. Crear repositorio en GitHub (desde la web)
# 2. Inicializar git localmente
git init
git add .
git commit -m "Initial commit: IBM Cloud Info project"

# 3. Conectar con GitHub
git remote add origin https://github.com/TU_USUARIO/ibm-cloud-info.git
git branch -M main
git push -u origin main
```

### Paso 2: Configurar GitHub Secrets

Ve a tu repositorio en GitHub:
`Settings > Secrets and variables > Actions > New repository secret`

Agrega estos secrets:

| Secret Name | Value |
|-------------|-------|
| `IBM_CLOUD_API_KEY` | `zLn7cRyoBQReEVI1YcrtZJL_vkxiT6RjEiikqjQWbGil` |
| `IBM_CLOUD_REGION` | `us-south` |
| `IBM_CLOUD_RESOURCE_GROUP` | `ibm-code-engine-test-rg` |
| `ICR_NAMESPACE` | `test_icr` |

### Paso 3: Trigger Deployment

```bash
# Hacer cualquier cambio y push
echo "# Deployment test" >> README.md
git add README.md
git commit -m "Trigger deployment"
git push origin main

# Ve a GitHub > Actions para ver el progreso
```

## 🧪 Opción 3: Test Local Primero

Antes de desplegar a la nube, puedes probar localmente:

```bash
# 1. Build de la imagen
docker build -t ibm-cloud-info:test .

# 2. Ejecutar localmente
docker run -p 8080:8080 ibm-cloud-info:test

# 3. Abrir en navegador
open http://localhost:8080

# 4. Presiona Ctrl+C para detener
```

## 📊 Comandos Útiles Post-Deployment

### Ver información de la aplicación

```bash
# URL de la aplicación
terraform output application_url

# Estado completo
terraform output deployment_summary

# Todos los outputs
terraform output
```

### Monitorear la aplicación

```bash
# Ver logs
ibmcloud ce application logs --name ibm-cloud-info-app --follow

# Ver eventos
ibmcloud ce application events --name ibm-cloud-info-app

# Ver detalles
ibmcloud ce application get --name ibm-cloud-info-app
```

### Actualizar la aplicación

```bash
# Opción A: Actualizar solo el HTML
# 1. Editar src/index.html
# 2. Build y push nueva imagen
docker build -t icr.io/test_icr/ibm-cloud-info:latest .
docker push icr.io/test_icr/ibm-cloud-info:latest

# 3. Terraform detectará el cambio automáticamente
cd terraform
terraform apply

# Opción B: Actualizar configuración de Terraform
# 1. Editar terraform/terraform.tfvars
# 2. Aplicar cambios
terraform apply
```

## 🔍 Verificación del Deployment

Una vez completado el deployment, verifica:

1. **URL de la aplicación**: Copia la URL del output de Terraform
2. **Acceso web**: Abre la URL en tu navegador
3. **Contenido**: Verifica que todas las secciones se muestren:
   - ✅ Seguridad Empresarial
   - ✅ Escalabilidad y Rendimiento
   - ✅ IA y Machine Learning
   - ✅ Optimización de Costos

## ⚠️ Troubleshooting Rápido

### Error: "Authentication failed"
```bash
# Re-login a IBM Cloud
ibmcloud login --apikey zLn7cRyoBQReEVI1YcrtZJL_vkxiT6RjEiikqjQWbGil
```

### Error: "Namespace not found"
```bash
# Verificar namespace
ibmcloud cr namespace-list

# Crear si no existe
ibmcloud cr namespace-add test_icr
```

### Error: "Resource group not found"
```bash
# Verificar resource groups
ibmcloud resource groups

# Actualizar terraform.tfvars con el nombre correcto
```

### La aplicación no responde
```bash
# Ver logs para diagnosticar
ibmcloud ce application logs --name ibm-cloud-info-app --follow
```

## 🧹 Limpieza (Destruir Recursos)

Si quieres eliminar todos los recursos:

```bash
cd terraform
terraform destroy

# Confirma con: yes
```

## 📚 Documentación Adicional

- **README.md**: Documentación completa del proyecto
- **SETUP_GUIDE.md**: Guía detallada paso a paso
- **terraform/**: Todos los archivos de infraestructura

## 🎯 Próximos Pasos

Después del deployment exitoso:

1. ✅ Guarda la URL de tu aplicación
2. ✅ Configura GitHub Actions para deployments automáticos
3. ✅ Personaliza el contenido HTML según tus necesidades
4. ✅ Agrega un dominio personalizado (opcional)
5. ✅ Configura monitoreo y alertas

---

**¿Necesitas ayuda?** Consulta SETUP_GUIDE.md para instrucciones más detalladas.