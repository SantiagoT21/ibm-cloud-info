# Guía de Configuración Paso a Paso

Esta guía te llevará a través del proceso completo de configuración y deployment del proyecto IBM Cloud Info.

## 📋 Checklist de Pre-requisitos

Antes de comenzar, asegúrate de tener:

- [ ] Cuenta de IBM Cloud activa
- [ ] IBM Cloud CLI instalado
- [ ] Terraform instalado (>= 1.0)
- [ ] Docker instalado
- [ ] Git instalado
- [ ] Cuenta de GitHub

## 🚀 Paso 1: Configuración de IBM Cloud

### 1.1 Crear API Key

```bash
# Login a IBM Cloud
ibmcloud login

# Crear API Key
ibmcloud iam api-key-create terraform-key -d "API key for Terraform deployment"

# Guardar el API Key mostrado - lo necesitarás después
```

### 1.2 Crear Namespace en Container Registry

```bash
# Configurar región
ibmcloud cr region-set us-south

# Crear namespace (debe ser único globalmente)
ibmcloud cr namespace-add YOUR_UNIQUE_NAMESPACE

# Verificar namespace
ibmcloud cr namespace-list
```

### 1.3 Verificar Resource Group

```bash
# Listar resource groups disponibles
ibmcloud resource groups

# Si necesitas crear uno nuevo
ibmcloud resource group-create my-resource-group
```

## 📦 Paso 2: Configuración del Repositorio

### 2.1 Fork o Clonar el Repositorio

```bash
# Opción A: Clonar directamente
git clone https://github.com/YOUR_USERNAME/ibm-cloud-info.git
cd ibm-cloud-info

# Opción B: Fork en GitHub primero, luego clonar tu fork
```

### 2.2 Configurar Git

```bash
# Configurar tu información
git config user.name "Tu Nombre"
git config user.email "tu@email.com"

# Verificar remote
git remote -v
```

## 🔐 Paso 3: Configuración de GitHub Secrets

Ve a tu repositorio en GitHub:

1. Click en **Settings**
2. En el menú lateral, click en **Secrets and variables** > **Actions**
3. Click en **New repository secret**

Agrega los siguientes secrets uno por uno:

### Secret 1: IBM_CLOUD_API_KEY
- **Name**: `IBM_CLOUD_API_KEY`
- **Value**: Tu API Key de IBM Cloud (del paso 1.1)

### Secret 2: IBM_CLOUD_REGION
- **Name**: `IBM_CLOUD_REGION`
- **Value**: `us-south` (o tu región preferida)

### Secret 3: IBM_CLOUD_RESOURCE_GROUP
- **Name**: `IBM_CLOUD_RESOURCE_GROUP`
- **Value**: `Default` (o el nombre de tu resource group)

### Secret 4: ICR_NAMESPACE
- **Name**: `ICR_NAMESPACE`
- **Value**: Tu namespace de Container Registry (del paso 1.2)

## 🏗️ Paso 4: Configuración Local (Opcional)

Si quieres hacer deployment local antes de usar GitHub Actions:

### 4.1 Configurar Terraform

```bash
cd terraform

# Copiar archivo de ejemplo
cp terraform.tfvars.example terraform.tfvars

# Editar con tus valores
nano terraform.tfvars
```

Contenido de `terraform.tfvars`:
```hcl
ibmcloud_api_key    = "TU_API_KEY_AQUI"
region              = "us-south"
resource_group_name = "Default"
container_image     = "icr.io/TU_NAMESPACE/ibm-cloud-info:latest"
```

### 4.2 Test Local con Docker

```bash
# Volver al directorio raíz
cd ..

# Build de la imagen
docker build -t ibm-cloud-info:test .

# Ejecutar localmente
docker run -p 8080:8080 ibm-cloud-info:test

# Abrir en navegador: http://localhost:8080
# Presiona Ctrl+C para detener
```

## 🚢 Paso 5: Primer Deployment

### Opción A: Deployment Automático (Recomendado)

```bash
# 1. Hacer un pequeño cambio para trigger el workflow
echo "# IBM Cloud Info Project" > test.txt
git add test.txt
git commit -m "Initial commit - trigger deployment"
git push origin main

# 2. Ir a GitHub > Actions para ver el progreso
# 3. Esperar a que ambos workflows completen (5-10 minutos)
# 4. La URL de la aplicación aparecerá en el summary del workflow
```

### Opción B: Deployment Manual Local

```bash
# 1. Build y push de imagen Docker
docker build -t icr.io/TU_NAMESPACE/ibm-cloud-info:latest .
ibmcloud cr login
docker push icr.io/TU_NAMESPACE/ibm-cloud-info:latest

# 2. Deployment con Terraform
cd terraform
terraform init
terraform plan
terraform apply

# 3. Obtener URL
terraform output application_url
```

## ✅ Paso 6: Verificación

### 6.1 Verificar Deployment

```bash
# Verificar proyecto de Code Engine
ibmcloud ce project list

# Verificar aplicación
ibmcloud ce application list

# Ver detalles de la aplicación
ibmcloud ce application get --name ibm-cloud-info-app
```

### 6.2 Acceder a la Aplicación

1. Obtén la URL de la aplicación:
   - Desde GitHub Actions: Ve al workflow summary
   - Desde Terraform: `terraform output application_url`
   - Desde CLI: `ibmcloud ce application get --name ibm-cloud-info-app`

2. Abre la URL en tu navegador

3. Verifica que todas las secciones se muestren correctamente:
   - Seguridad Empresarial
   - Escalabilidad y Rendimiento
   - IA y Machine Learning
   - Optimización de Costos

## 🔄 Paso 7: Actualizar Contenido

### 7.1 Modificar HTML

```bash
# Editar el archivo HTML
nano src/index.html

# Hacer tus cambios y guardar
```

### 7.2 Desplegar Cambios

```bash
# Commit y push
git add src/index.html
git commit -m "Update: descripción de tus cambios"
git push origin main

# GitHub Actions automáticamente:
# 1. Build nueva imagen Docker
# 2. Push a Container Registry
# 3. Actualiza Code Engine
# 4. Nueva versión disponible en ~5 minutos
```

## 🐛 Troubleshooting Común

### Error: "Authentication failed"

**Problema**: API Key inválida o expirada

**Solución**:
```bash
# Crear nueva API Key
ibmcloud iam api-key-create new-terraform-key -d "New API key"

# Actualizar en GitHub Secrets y terraform.tfvars
```

### Error: "Namespace not found"

**Problema**: Namespace de Container Registry no existe

**Solución**:
```bash
# Verificar namespaces existentes
ibmcloud cr namespace-list

# Crear si no existe
ibmcloud cr namespace-add YOUR_NAMESPACE
```

### Error: "Resource group not found"

**Problema**: Resource group especificado no existe

**Solución**:
```bash
# Listar resource groups
ibmcloud resource groups

# Usar uno existente o crear nuevo
ibmcloud resource group-create my-new-group
```

### GitHub Actions falla en Docker Build

**Problema**: Permisos o secrets incorrectos

**Solución**:
1. Verifica que todos los secrets estén configurados
2. Verifica que el API Key tenga permisos de Container Registry
3. Revisa los logs detallados en GitHub Actions

### Aplicación no responde después del deployment

**Problema**: Posible error en el contenedor

**Solución**:
```bash
# Ver logs de la aplicación
ibmcloud ce application logs --name ibm-cloud-info-app --follow

# Ver eventos
ibmcloud ce application events --name ibm-cloud-info-app
```

## 📊 Monitoreo y Mantenimiento

### Ver Logs en Tiempo Real

```bash
# Logs de la aplicación
ibmcloud ce application logs --name ibm-cloud-info-app --follow

# Logs de un deployment específico
ibmcloud ce application logs --name ibm-cloud-info-app --instance INSTANCE_NAME
```

### Ver Métricas

```bash
# Estado de la aplicación
ibmcloud ce application get --name ibm-cloud-info-app

# Listar instancias activas
ibmcloud ce application list
```

### Actualizar Configuración

Si necesitas cambiar CPU, memoria, o scaling:

```bash
# Editar terraform/variables.tf o terraform.tfvars
nano terraform/terraform.tfvars

# Aplicar cambios
cd terraform
terraform plan
terraform apply
```

## 🧹 Limpieza (Opcional)

Si quieres eliminar todos los recursos:

### Opción 1: Con Terraform

```bash
cd terraform
terraform destroy
```

### Opción 2: Con GitHub Actions

1. Ve a Actions > Terraform Deploy
2. Click en "Run workflow"
3. Selecciona "destroy"
4. Click en "Run workflow"

### Opción 3: Manual con CLI

```bash
# Eliminar aplicación
ibmcloud ce application delete --name ibm-cloud-info-app

# Eliminar proyecto
ibmcloud ce project delete --name ibm-cloud-info

# Eliminar imagen de Container Registry
ibmcloud cr image-rm icr.io/YOUR_NAMESPACE/ibm-cloud-info:latest
```

## 📚 Próximos Pasos

Ahora que tienes el proyecto funcionando, puedes:

1. **Personalizar el HTML**: Agregar más secciones o información
2. **Agregar Analytics**: Integrar Google Analytics o similar
3. **Agregar Dominio Personalizado**: Configurar un dominio custom
4. **Implementar HTTPS Custom**: Usar certificados propios
5. **Agregar Base de Datos**: Conectar a IBM Cloud Databases
6. **Implementar API**: Agregar endpoints REST
7. **Agregar Autenticación**: Implementar IBM App ID

## 🆘 Soporte

Si tienes problemas:

1. Revisa la sección de Troubleshooting
2. Consulta los logs en GitHub Actions
3. Revisa la documentación de IBM Cloud
4. Abre un issue en el repositorio

## ✨ Mejores Prácticas

1. **Nunca commitees credenciales**: Usa siempre secrets y .gitignore
2. **Usa branches**: Crea branches para features nuevos
3. **Prueba localmente**: Antes de push, prueba con Docker local
4. **Monitorea costos**: Revisa regularmente el dashboard de IBM Cloud
5. **Mantén actualizado**: Actualiza Terraform y providers regularmente
6. **Documenta cambios**: Usa commits descriptivos
7. **Usa tags**: Versiona tus releases con git tags

---

¡Felicitaciones! 🎉 Has completado la configuración del proyecto.