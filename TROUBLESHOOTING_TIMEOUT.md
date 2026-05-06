# Solución al Error de Timeout en Code Engine

## Error Encontrado

```
Error: timeout while waiting for state to become 'ready, failed, warning'
(last state: 'deploying', timeout: 10m0s)
```

La aplicación se queda en estado "deploying" por más de 10 minutos y Terraform falla.

## Causas Comunes

### 1. **Imagen no accesible** (Más común)
   - La imagen no existe en el registry
   - El secret de registry no está configurado correctamente
   - La API key no tiene permisos para acceder al registry
   - El path de la imagen es incorrecto

### 2. **Aplicación no inicia correctamente**
   - El contenedor falla al iniciar
   - La aplicación no escucha en el puerto configurado
   - Faltan variables de entorno necesarias
   - Health checks fallan

### 3. **Problemas de recursos**
   - CPU/memoria insuficiente
   - Límites de cuota alcanzados
   - Región sin capacidad disponible

## Soluciones Implementadas

### 1. Timeout Aumentado a 20 minutos

El archivo `terraform/code_engine.tf` ahora incluye:

```hcl
resource "ibm_code_engine_app" "app" {
  # ... configuración ...
  
  timeouts {
    create = "20m"
    update = "20m"
  }
}
```

### 2. Configuración de Escala Completa

Ahora se incluyen todas las variables de escala:

```hcl
scale_cpu_limit       = var.cpu
scale_memory_limit    = var.memory
scale_min_instances   = var.min_scale
scale_max_instances   = var.max_scale
scale_request_timeout = var.request_timeout
```

### 3. Script de Diagnóstico

Creado `scripts/diagnose-codeengine.sh` para identificar problemas.

## Pasos para Resolver el Error

### Paso 1: Ejecutar Diagnóstico

```bash
./scripts/diagnose-codeengine.sh
```

Este script verificará:
- ✅ Autenticación a IBM Cloud
- ✅ Acceso al Container Registry
- ✅ Existencia de la imagen
- ✅ Estado del proyecto de Code Engine
- ✅ Configuración del registry secret
- ✅ Estado de la aplicación
- ✅ Permisos IAM

### Paso 2: Verificar la Imagen Manualmente

```bash
# Login al registry
ibmcloud cr login

# Listar imágenes en tu namespace
ibmcloud cr images --restrict test_icr

# Verificar que tu imagen existe
ibmcloud cr images --restrict test_icr/ibm-cloud-info
```

**Resultado esperado:**
```
Listing images...

Repository                              Tag      Digest         Namespace   Created        Size     Security status
icr.io/test_icr/ibm-cloud-info         latest   sha256:abc...  test_icr    2 hours ago    50 MB    No Issues
```

Si la imagen NO aparece:
```bash
# Construir y subir la imagen
docker build -t icr.io/test_icr/ibm-cloud-info:latest .
docker push icr.io/test_icr/ibm-cloud-info:latest
```

### Paso 3: Verificar el Registry Secret

```bash
# Seleccionar el proyecto
ibmcloud ce project select --name ibm-cloud-info

# Ver el secret
ibmcloud ce secret get --name icr-secret
```

**Resultado esperado:**
```
Name:          icr-secret
Format:        registry
Server:        icr.io
Username:      iamapikey
```

Si el secret no existe o está mal configurado:
```bash
# Eliminar el secret existente
ibmcloud ce secret delete --name icr-secret --force

# Recrear con Terraform
cd terraform
terraform apply -target=ibm_code_engine_secret.registry_secret
```

### Paso 4: Verificar Logs de la Aplicación

```bash
# Seleccionar proyecto
ibmcloud ce project select --name ibm-cloud-info

# Ver eventos de la app
ibmcloud ce app events --app ibm-cloud-info-app

# Ver logs de la app
ibmcloud ce app logs --app ibm-cloud-info-app --tail 100
```

**Buscar errores como:**
- `ImagePullBackOff` - No puede descargar la imagen
- `CrashLoopBackOff` - La aplicación falla al iniciar
- `UNAUTHORIZED` - Problema de autenticación
- `Not Found` - Imagen no existe

### Paso 5: Probar la Imagen Localmente

```bash
# Login al registry
ibmcloud cr login

# Descargar la imagen
docker pull icr.io/test_icr/ibm-cloud-info:latest

# Ejecutar localmente
docker run -p 8080:8080 icr.io/test_icr/ibm-cloud-info:latest

# Probar en otra terminal
curl http://localhost:8080
```

Si la imagen funciona localmente pero no en Code Engine, el problema es de autenticación.

### Paso 6: Verificar Permisos de la API Key

```bash
# Ver tus API keys
ibmcloud iam api-keys

# Ver políticas de acceso
ibmcloud iam user-policies <tu-email>
```

**Permisos necesarios:**
- `Viewer` en Container Registry
- `Editor` en Code Engine
- `Reader` en el Resource Group

Si faltan permisos:
```bash
# Agregar rol de Viewer en Container Registry
ibmcloud iam user-policy-create <tu-email> \
  --service-name container-registry \
  --roles Viewer
```

### Paso 7: Limpiar y Reintentar

Si todo lo anterior está correcto, intenta limpiar y recrear:

```bash
# Opción A: Usar el script de gestión
./scripts/manage-codeengine-app.sh
# Selecciona opción 5 (Eliminar y aplicar)

# Opción B: Manual
ibmcloud ce project select --name ibm-cloud-info
ibmcloud ce app delete --name ibm-cloud-info-app --force --wait

cd terraform
terraform plan -out=tfplan
terraform apply -auto-approve -input=false tfplan
```

## Verificaciones Específicas

### Verificar Path de la Imagen

En `terraform/terraform.tfvars`:
```hcl
container_image = "icr.io/test_icr/ibm-cloud-info:latest"
```

**Formato correcto:**
- ✅ `icr.io/namespace/image:tag`
- ✅ `icr.io/test_icr/ibm-cloud-info:latest`
- ✅ `icr.io/test_icr/ibm-cloud-info:v1.0.0`

**Formato incorrecto:**
- ❌ `icr.io/test_icr/ibm-cloud-info` (falta tag)
- ❌ `test_icr/ibm-cloud-info:latest` (falta dominio)
- ❌ `icr.io/ibm-cloud-info:latest` (falta namespace)

### Verificar Puerto del Contenedor

En `terraform/terraform.tfvars`:
```hcl
container_port = 8080
```

**Debe coincidir con el puerto que tu aplicación escucha.**

Para verificar qué puerto usa tu imagen:
```bash
docker inspect icr.io/test_icr/ibm-cloud-info:latest | grep ExposedPorts
```

### Verificar Variables de Entorno

Si tu aplicación necesita variables de entorno, agrégalas en `code_engine.tf`:

```hcl
resource "ibm_code_engine_app" "app" {
  # ... configuración existente ...
  
  run_env_variables {
    type  = "literal"
    name  = "PORT"
    value = "8080"
  }
  
  run_env_variables {
    type  = "literal"
    name  = "NODE_ENV"
    value = "production"
  }
}
```

## Monitoreo Durante el Deployment

Mientras Terraform está aplicando, en otra terminal ejecuta:

```bash
# Terminal 1: Terraform apply
cd terraform
terraform apply -auto-approve -input=false tfplan

# Terminal 2: Monitorear logs en tiempo real
ibmcloud ce project select --name ibm-cloud-info
watch -n 5 'ibmcloud ce app get --name ibm-cloud-info-app'

# Terminal 3: Ver logs
ibmcloud ce app logs --app ibm-cloud-info-app --follow
```

## Solución Rápida (Quick Fix)

Si tienes prisa y necesitas que funcione YA:

```bash
# 1. Verificar que la imagen existe
ibmcloud cr images --restrict test_icr/ibm-cloud-info

# 2. Si no existe, construirla y subirla
docker build -t icr.io/test_icr/ibm-cloud-info:latest .
docker push icr.io/test_icr/ibm-cloud-info:latest

# 3. Limpiar todo y recrear
./scripts/manage-codeengine-app.sh
# Selecciona opción 5

# 4. Si sigue fallando, ejecutar diagnóstico
./scripts/diagnose-codeengine.sh
```

## Prevención Futura

### 1. Validar Imagen Antes de Terraform

Crea un script pre-apply:

```bash
#!/bin/bash
# scripts/pre-apply-check.sh

echo "Verificando imagen antes de Terraform apply..."

# Cargar variables
CONTAINER_IMAGE=$(grep 'container_image' terraform/terraform.tfvars | cut -d'=' -f2 | tr -d ' "')
NAMESPACE=$(echo $CONTAINER_IMAGE | cut -d'/' -f2)
IMAGE_NAME=$(echo $CONTAINER_IMAGE | cut -d'/' -f3)

# Verificar imagen
if ibmcloud cr images --restrict "$NAMESPACE" | grep -q "$IMAGE_NAME"; then
    echo "✓ Imagen encontrada: $CONTAINER_IMAGE"
    exit 0
else
    echo "✗ Imagen NO encontrada: $CONTAINER_IMAGE"
    echo "Construye y sube la imagen primero:"
    echo "  docker build -t $CONTAINER_IMAGE ."
    echo "  docker push $CONTAINER_IMAGE"
    exit 1
fi
```

### 2. CI/CD Pipeline

Asegúrate de que tu pipeline:
1. Construye la imagen
2. La sube al registry
3. Verifica que existe
4. Luego ejecuta Terraform

Ejemplo en `.github/workflows/terraform-deploy.yml`:

```yaml
- name: Build and Push Image
  run: |
    docker build -t icr.io/test_icr/ibm-cloud-info:latest .
    docker push icr.io/test_icr/ibm-cloud-info:latest

- name: Verify Image
  run: |
    ibmcloud cr images --restrict test_icr/ibm-cloud-info

- name: Terraform Apply
  run: |
    cd terraform
    terraform apply -auto-approve -input=false tfplan
```

## Resumen de Comandos Útiles

```bash
# Diagnóstico completo
./scripts/diagnose-codeengine.sh

# Verificar imagen
ibmcloud cr images --restrict test_icr/ibm-cloud-info

# Ver logs de la app
ibmcloud ce app logs --app ibm-cloud-info-app --tail 100

# Ver eventos de la app
ibmcloud ce app events --app ibm-cloud-info-app

# Estado de la app
ibmcloud ce app get --name ibm-cloud-info-app

# Recrear app
./scripts/manage-codeengine-app.sh  # Opción 5

# Importar app existente
./scripts/manage-codeengine-app.sh  # Opción 6
```

## Contacto y Soporte

Si después de seguir todos estos pasos el problema persiste:

1. Ejecuta el diagnóstico completo:
   ```bash
   ./scripts/diagnose-codeengine.sh > diagnostics.log 2>&1
   ```

2. Captura los logs de Terraform:
   ```bash
   TF_LOG=DEBUG terraform apply 2>&1 | tee terraform-debug.log
   ```

3. Revisa los logs de Code Engine:
   ```bash
   ibmcloud ce app logs --app ibm-cloud-info-app > app-logs.log
   ```

Con esta información podrás identificar exactamente dónde está el problema.