# Deployment con GitHub Actions

## 🎯 Descripción General

El workflow de GitHub Actions ahora maneja automáticamente todo el proceso de deployment:

1. **Build**: Construye la imagen Docker
2. **Push**: Sube la imagen a IBM Container Registry
3. **Deploy**: Despliega con Terraform a Code Engine

## 🚀 Cómo Funciona

### Triggers Automáticos

El workflow se ejecuta automáticamente cuando:

1. **Push a main** con cambios en:
   - `src/**` (archivos HTML/CSS/JS)
   - `Dockerfile`
   - `nginx.conf`
   - `terraform/**`
   - `.github/workflows/terraform-deploy.yml`

2. **Repository Dispatch** con tipo `docker-image-updated`

3. **Manual** desde la interfaz de GitHub Actions

## 📋 Configuración de Secrets

Antes de usar el workflow, configura estos secrets en GitHub:

### Secrets Requeridos

Ve a: **Settings → Secrets and variables → Actions → New repository secret**

| Secret | Descripción | Ejemplo |
|--------|-------------|---------|
| `IBM_CLOUD_API_KEY` | API Key de IBM Cloud | `abc123...` |
| `IBM_CLOUD_REGION` | Región de IBM Cloud | `us-south` |
| `IBM_CLOUD_RESOURCE_GROUP` | Nombre del Resource Group | `Default` |
| `ICR_NAMESPACE` | Namespace en Container Registry | `test_icr` |

### Cómo Obtener los Valores

#### 1. IBM_CLOUD_API_KEY

```bash
# Crear una nueva API key
ibmcloud iam api-key-create github-actions-key -d "Key for GitHub Actions"

# O listar las existentes
ibmcloud iam api-keys
```

#### 2. IBM_CLOUD_REGION

```bash
# Ver regiones disponibles
ibmcloud regions

# Usar: us-south, us-east, eu-de, eu-gb, jp-tok, au-syd, etc.
```

#### 3. IBM_CLOUD_RESOURCE_GROUP

```bash
# Listar resource groups
ibmcloud resource groups

# Usar el nombre (generalmente "Default")
```

#### 4. ICR_NAMESPACE

```bash
# Listar namespaces existentes
ibmcloud cr namespace-list

# O crear uno nuevo
ibmcloud cr namespace-add test_icr
```

## 🎮 Uso del Workflow

### Opción 1: Push Automático (Recomendado)

Simplemente haz push de tus cambios a la rama `main`:

```bash
# Hacer cambios en el código
vim src/index.html

# Commit y push
git add .
git commit -m "Update application content"
git push origin main
```

El workflow se ejecutará automáticamente y:
1. ✅ Construirá la nueva imagen
2. ✅ La subirá al registry
3. ✅ Desplegará con Terraform

### Opción 2: Ejecución Manual

1. Ve a **Actions** en tu repositorio de GitHub
2. Selecciona **Build, Push and Deploy to IBM Cloud**
3. Click en **Run workflow**
4. Selecciona la acción:
   - **build-and-deploy**: Construye imagen y despliega (por defecto)
   - **deploy-only**: Solo despliega (usa imagen existente)
   - **destroy**: Elimina todos los recursos

### Opción 3: API/CLI

```bash
# Trigger manual con GitHub CLI
gh workflow run terraform-deploy.yml \
  --ref main \
  --field action=build-and-deploy
```

## 📊 Monitoreo del Workflow

### Ver el Progreso

1. Ve a **Actions** en GitHub
2. Click en el workflow en ejecución
3. Verás dos jobs:
   - **Build and Push Docker Image** (5-10 min)
   - **Terraform Deploy** (5-15 min)

### Logs Detallados

Cada step muestra logs detallados:
- Build de la imagen
- Push al registry
- Scan de vulnerabilidades
- Plan de Terraform
- Apply de Terraform
- URL de la aplicación desplegada

### Summary

Al finalizar, verás un resumen con:
- ✅ Imagen construida
- ✅ URL de la aplicación
- ✅ Estado del deployment
- ✅ Detalles de configuración

## 🔧 Personalización

### Cambiar Nombres de Proyecto/App

Edita `.github/workflows/terraform-deploy.yml`:

```yaml
- name: Create terraform.tfvars
  run: |
    cat > terraform.tfvars << EOF
    project_name        = "mi-proyecto"        # Cambiar aquí
    app_name            = "mi-app"             # Cambiar aquí
    container_image     = "icr.io/${{ secrets.ICR_NAMESPACE }}/mi-imagen:latest"
    # ... resto de configuración
    EOF
```

### Cambiar Recursos (CPU/Memoria)

```yaml
cpu                 = "0.5"      # Cambiar de 0.25 a 0.5
memory              = "1G"       # Cambiar de 0.5G a 1G
min_scale           = 1          # Cambiar de 0 a 1 (siempre activo)
max_scale           = 20         # Cambiar de 10 a 20
```

### Agregar Tags Personalizados

```yaml
tags = [
  "terraform",
  "code-engine",
  "mi-equipo",
  "produccion"
]
```

## 🐛 Troubleshooting

### Error: "Namespace not found"

**Causa**: El namespace de ICR no existe.

**Solución**: El workflow lo crea automáticamente, pero puedes crearlo manualmente:

```bash
ibmcloud cr namespace-add test_icr
```

### Error: "Authentication failed"

**Causa**: API key incorrecta o expirada.

**Solución**:
1. Verifica el secret `IBM_CLOUD_API_KEY`
2. Crea una nueva API key si es necesario
3. Actualiza el secret en GitHub

### Error: "Project is in disabled state"

**Causa**: El proyecto de Code Engine está deshabilitado.

**Solución**: Ejecuta localmente:

```bash
./scripts/fix-disabled-project.sh
# Selecciona opción 5
```

Luego re-ejecuta el workflow.

### Error: "Timeout waiting for state"

**Causa**: La aplicación tarda más de 20 minutos en desplegarse.

**Solución**:
1. Verifica que la imagen existe en el registry
2. Revisa los logs de Code Engine
3. Ejecuta diagnóstico local:

```bash
./scripts/diagnose-codeengine.sh
```

### Build Falla

**Causa**: Error en el Dockerfile o dependencias.

**Solución**:
1. Prueba el build localmente:
   ```bash
   docker build -t test .
   ```
2. Revisa los logs del workflow
3. Corrige el Dockerfile y vuelve a hacer push

## 📈 Optimizaciones

### Cache de Docker

El workflow usa cache de GitHub Actions para acelerar builds:

```yaml
cache-from: type=gha
cache-to: type=gha,mode=max
```

Esto reduce el tiempo de build en ~50% después del primer build.

### Build Condicional

El job de build solo se ejecuta cuando:
- Hay cambios en código fuente, Dockerfile o nginx.conf
- Se ejecuta manualmente con `build-and-deploy`

Para solo desplegar sin rebuild:
```bash
gh workflow run terraform-deploy.yml --field action=deploy-only
```

### Parallel Jobs

Los jobs se ejecutan en paralelo cuando es posible:
- Build y Push: ~5-10 min
- Terraform Deploy: ~5-15 min (espera a que termine build)

**Tiempo total**: ~10-20 minutos

## 🔐 Seguridad

### Secrets Management

- ✅ Nunca hagas commit de secrets en el código
- ✅ Usa GitHub Secrets para información sensible
- ✅ Rota las API keys regularmente
- ✅ Usa API keys con permisos mínimos necesarios

### Scan de Vulnerabilidades

El workflow escanea automáticamente la imagen:

```yaml
- name: Scan image for vulnerabilities
  run: |
    ibmcloud cr vulnerability-assessment "${{ steps.meta.outputs.tags }}" || true
```

Revisa los resultados en los logs del workflow.

### Permisos Mínimos

La API key necesita estos permisos:
- **Container Registry**: Editor
- **Code Engine**: Editor
- **Resource Group**: Viewer

## 📝 Ejemplo de Workflow Completo

```yaml
# Hacer cambios
vim src/index.html

# Commit
git add .
git commit -m "feat: add new section to homepage"

# Push (trigger automático)
git push origin main

# GitHub Actions:
# 1. ✅ Build Docker image (5 min)
# 2. ✅ Push to ICR (2 min)
# 3. ✅ Scan vulnerabilities (1 min)
# 4. ✅ Terraform plan (2 min)
# 5. ✅ Terraform apply (10 min)
# 6. ✅ Verify deployment (1 min)

# Total: ~20 minutos
# Resultado: App actualizada en Code Engine
```

## 🎓 Mejores Prácticas

### 1. Usa Pull Requests

```yaml
# El workflow comenta el plan de Terraform en PRs
on:
  pull_request:
    branches: [main]
```

Esto te permite revisar los cambios antes de aplicarlos.

### 2. Versionado de Imágenes

En lugar de `:latest`, considera usar tags versionados:

```yaml
IMAGE_TAG="icr.io/${{ secrets.ICR_NAMESPACE }}/ibm-cloud-info:${{ github.sha }}"
```

### 3. Ambientes Separados

Crea workflows separados para dev/staging/prod:

```yaml
# .github/workflows/deploy-dev.yml
project_name = "ibm-cloud-info-dev"

# .github/workflows/deploy-prod.yml
project_name = "ibm-cloud-info-prod"
```

### 4. Notificaciones

Agrega notificaciones de Slack/Teams:

```yaml
- name: Notify Slack
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

## 📚 Recursos Adicionales

- **Documentación de GitHub Actions**: https://docs.github.com/actions
- **IBM Cloud CLI**: https://cloud.ibm.com/docs/cli
- **Terraform IBM Provider**: https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs
- **Code Engine Docs**: https://cloud.ibm.com/docs/codeengine

## ✅ Checklist de Setup

- [ ] Secrets configurados en GitHub
- [ ] API key con permisos correctos
- [ ] Namespace de ICR creado
- [ ] Workflow file actualizado
- [ ] Primera ejecución exitosa
- [ ] URL de la app verificada
- [ ] Monitoreo configurado (opcional)

## 🆘 Soporte

Si tienes problemas:

1. **Revisa los logs del workflow** en GitHub Actions
2. **Ejecuta diagnóstico local**: `./scripts/diagnose-codeengine.sh`
3. **Consulta la documentación**: Ver archivos `*.md` en el repo
4. **Contacta al equipo**: Abre un issue en GitHub

---

**¡Tu aplicación se desplegará automáticamente con cada push a main!** 🚀