# 🚀 Deployment con GitHub Actions (Recomendado)

La forma más simple de desplegar tu aplicación es usando GitHub Actions, que ya está completamente configurado en este proyecto.

## ✅ Por Qué GitHub Actions es la Mejor Opción

- ✅ **No requiere Docker ni Podman localmente**
- ✅ **Build automático en la nube**
- ✅ **Deployment automático**
- ✅ **Ya está configurado** en el proyecto
- ✅ **Actualizaciones automáticas** al hacer push

## 📋 Pasos para Deployment

### Paso 1: Crear Repositorio en GitHub

1. Ve a [GitHub](https://github.com) y crea un nuevo repositorio
2. Nómbralo: `ibm-cloud-info`
3. Déjalo público o privado (tu elección)
4. **NO** inicialices con README, .gitignore o license

### Paso 2: Configurar GitHub Secrets

Una vez creado el repositorio:

1. Ve a tu repositorio en GitHub
2. Click en **Settings** (Configuración)
3. En el menú lateral, click en **Secrets and variables** > **Actions**
4. Click en **New repository secret**

Agrega estos 4 secrets:

#### Secret 1: IBM_CLOUD_API_KEY
- **Name**: `IBM_CLOUD_API_KEY`
- **Value**: `zLn7cRyoBQReEVI1YcrtZJL_vkxiT6RjEiikqjQWbGil`

#### Secret 2: IBM_CLOUD_REGION
- **Name**: `IBM_CLOUD_REGION`
- **Value**: `us-south`

#### Secret 3: IBM_CLOUD_RESOURCE_GROUP
- **Name**: `IBM_CLOUD_RESOURCE_GROUP`
- **Value**: `ibm-code-engine-test-rg`

#### Secret 4: ICR_NAMESPACE
- **Name**: `ICR_NAMESPACE`
- **Value**: `test_icr`

### Paso 3: Push del Código a GitHub

```bash
# Inicializar git (si no lo has hecho)
git init

# Agregar todos los archivos
git add .

# Hacer commit
git commit -m "Initial commit: IBM Cloud Info project"

# Agregar remote (reemplaza TU_USUARIO con tu usuario de GitHub)
git remote add origin https://github.com/SantiagoT21/ibm-cloud-info.git

# Cambiar a branch main
git branch -M main

# Push a GitHub
git push -u origin main
```

### Paso 4: Ver el Deployment Automático

1. Ve a tu repositorio en GitHub
2. Click en la pestaña **Actions**
3. Verás dos workflows ejecutándose:
   - **Build and Push Docker Image** (3-5 minutos)
   - **Terraform Deploy to IBM Cloud** (5-10 minutos)

4. Espera a que ambos completen (✅ verde)

### Paso 5: Obtener la URL de tu Aplicación

1. En la pestaña **Actions**, click en el workflow **Terraform Deploy**
2. Click en el run más reciente
3. Expande el step **Deployment Summary**
4. Copia la **Application URL**
5. Abre la URL en tu navegador

## 🔄 Actualizaciones Automáticas

Cada vez que hagas cambios al HTML y hagas push, GitHub Actions automáticamente:

```bash
# 1. Editar el HTML
nano src/index.html

# 2. Commit y push
git add src/index.html
git commit -m "Update: descripción de cambios"
git push origin main

# 3. GitHub Actions automáticamente:
#    - Build nueva imagen Docker
#    - Push a Container Registry
#    - Actualiza Code Engine
#    - Nueva versión disponible en ~5 minutos
```

## 📊 Flujo de Trabajo

```
Push a GitHub
    ↓
GitHub Actions detecta cambios
    ↓
Build Docker Image
    ↓
Push a IBM Container Registry
    ↓
Terraform Apply
    ↓
Code Engine actualizado
    ↓
Aplicación disponible
```

## 🎯 Ventajas de Este Método

| Característica | GitHub Actions | Local |
|----------------|----------------|-------|
| Requiere Docker/Podman | ❌ No | ✅ Sí |
| Configuración local | ❌ No | ✅ Sí |
| Build automático | ✅ Sí | ❌ No |
| Deploy automático | ✅ Sí | ❌ No |
| Actualizaciones | ✅ Automáticas | ❌ Manuales |
| Costo | ✅ Gratis | ✅ Gratis |

## 🧪 Test Manual (Opcional)

Si quieres hacer deployment manual después:

```bash
# Ver la URL de la aplicación
cd terraform
terraform output application_url

# Ver logs
ibmcloud ce application logs --name ibm-cloud-info-app --follow

# Ver estado
ibmcloud ce application get --name ibm-cloud-info-app
```

## 🆘 Troubleshooting

### Los workflows fallan

1. **Verifica los secrets**: Asegúrate de que los 4 secrets estén configurados correctamente
2. **Revisa los logs**: En Actions, click en el workflow fallido para ver detalles
3. **Verifica el namespace**: Asegúrate de que `test_icr` existe en Container Registry

### No veo los workflows

1. Asegúrate de haber hecho push del directorio `.github/workflows/`
2. Ve a Actions y habilita los workflows si están deshabilitados

### El deployment tarda mucho

- Es normal, el primer deployment puede tardar 10-15 minutos
- Deployments subsecuentes son más rápidos (5-7 minutos)

## 📝 Comandos Útiles

```bash
# Ver status de git
git status

# Ver remote
git remote -v

# Ver logs de commits
git log --oneline

# Forzar push (si es necesario)
git push -f origin main
```

## 🎉 Resultado Final

Una vez completado el deployment:

1. ✅ Aplicación web desplegada en Code Engine
2. ✅ URL pública con HTTPS
3. ✅ Auto-scaling configurado (0-10 instancias)
4. ✅ Actualizaciones automáticas con cada push
5. ✅ CI/CD completo funcionando

## 🔄 Workflow de Desarrollo

```bash
# 1. Hacer cambios localmente
nano src/index.html

# 2. Probar localmente (opcional)
# Requiere Docker/Podman
docker build -t test . && docker run -p 8080:8080 test

# 3. Commit y push
git add .
git commit -m "Update: descripción"
git push origin main

# 4. GitHub Actions hace el resto automáticamente
# 5. Espera 5-10 minutos
# 6. Refresca tu aplicación en el navegador
```

## 💡 Recomendación

**Este es el método más simple y profesional para deployment.**

No necesitas:
- ❌ Docker instalado localmente
- ❌ Podman configurado
- ❌ Ejecutar comandos de build manualmente
- ❌ Configurar credenciales localmente

Solo necesitas:
- ✅ Cuenta de GitHub
- ✅ Configurar 4 secrets
- ✅ Hacer push de tu código

**GitHub Actions hace todo el trabajo pesado por ti** 🚀

---

## 📚 Próximos Pasos

1. Crea el repositorio en GitHub
2. Configura los 4 secrets
3. Haz push del código
4. Espera a que los workflows completen
5. ¡Disfruta tu aplicación en vivo!

**Ver también:**
- **README.md**: Documentación completa
- **SETUP_GUIDE.md**: Guía detallada
- **QUICK_START.md**: Guía rápida