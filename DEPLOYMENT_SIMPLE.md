# 🚀 Deployment Simple - SIN Docker ni Podman

La forma más simple de desplegar tu aplicación **sin necesidad de Docker o Podman**.

## ✅ Método Recomendado: ibmcloud cr build

IBM Cloud puede hacer el build de tu imagen Docker en sus servidores, sin necesidad de tener Docker o Podman instalado localmente.

## 📋 Pasos Completos

### 1. Verificar que tienes los plugins instalados

```bash
# Verificar plugins
ibmcloud plugin list

# Si no están instalados:
ibmcloud plugin install container-registry -f
ibmcloud plugin install code-engine -f
```

### 2. Login y Configuración

```bash
# Login a IBM Cloud
ibmcloud login --apikey ibm-cloud-api-key

# Configurar región
ibmcloud cr region-set us-south

# Verificar namespace (debe existir: test_icr)
ibmcloud cr namespace-list
```

### 3. Build y Push de la Imagen (SIN Docker/Podman)

```bash
# Este comando hace el build en los servidores de IBM Cloud
# No necesitas Docker ni Podman instalado
ibmcloud cr build -t icr.io/test_icr/ibm-cloud-info:latest .

# Espera unos minutos mientras IBM Cloud hace el build...
# Verás el progreso en la terminal
```

### 4. Verificar que la Imagen se Creó

```bash
# Listar imágenes en Container Registry
ibmcloud cr image-list

# Deberías ver: icr.io/test_icr/ibm-cloud-info:latest
```

### 5. Deploy con Terraform

```bash
# Ir al directorio de Terraform
cd terraform

# Inicializar Terraform (solo la primera vez)
terraform init

# Ver el plan de deployment
terraform plan

# Aplicar los cambios
terraform apply

# Cuando pregunte "Do you want to perform these actions?", escribe: yes
```

### 6. Obtener la URL de tu Aplicación

```bash
# Ver la URL de la aplicación
terraform output application_url

# O ver todos los outputs
terraform output
```

## ⚡ Comando Todo-en-Uno

Si quieres hacer todo en un solo comando:

```bash
ibmcloud login --apikey ibm-cloud-api-key && \
ibmcloud cr region-set us-south && \
ibmcloud cr build -t icr.io/test_icr/ibm-cloud-info:latest . && \
cd terraform && \
terraform init && \
terraform apply -auto-approve && \
echo "==================================" && \
echo "URL de tu aplicación:" && \
terraform output application_url && \
echo "=================================="
```

## 📊 Tiempo Estimado

- Build de imagen: 3-5 minutos
- Terraform apply: 5-10 minutos
- **Total: ~10-15 minutos**

## ✅ Verificación del Deployment

Una vez completado:

```bash
# Ver estado de la aplicación
ibmcloud ce application get --name ibm-cloud-info-app

# Ver logs
ibmcloud ce application logs --name ibm-cloud-info-app --follow

# Ver URL
cd terraform && terraform output application_url
```

## 🔄 Para Actualizar el HTML

Cuando quieras actualizar el contenido:

```bash
# 1. Editar el HTML
nano src/index.html

# 2. Rebuild la imagen
ibmcloud cr build -t icr.io/test_icr/ibm-cloud-info:latest .

# 3. Terraform detectará el cambio y actualizará
cd terraform
terraform apply -auto-approve
```

## 🆘 Troubleshooting

### Error: "Namespace not found"

```bash
# Crear el namespace
ibmcloud cr namespace-add test_icr
```

### Error: "Build failed"

```bash
# Verificar que estás en el directorio correcto (donde está el Dockerfile)
pwd
ls -la Dockerfile

# Intentar nuevamente
ibmcloud cr build -t icr.io/test_icr/ibm-cloud-info:latest .
```

### Error: "Resource group not found"

```bash
# Listar resource groups disponibles
ibmcloud resource groups

# Actualizar terraform/terraform.tfvars con el nombre correcto
```

### La aplicación no responde

```bash
# Ver logs para diagnosticar
ibmcloud ce application logs --name ibm-cloud-info-app --follow

# Ver eventos
ibmcloud ce application events --name ibm-cloud-info-app
```

## 💡 Ventajas de Este Método

- ✅ **No requiere Docker ni Podman**
- ✅ **No requiere configurar máquinas virtuales**
- ✅ **Build en servidores de IBM Cloud**
- ✅ **Más rápido** (servidores potentes)
- ✅ **Sin problemas de permisos locales**
- ✅ **Funciona en cualquier sistema operativo**

## 🎯 Resumen

1. **Login**: `ibmcloud login --apikey TU_API_KEY`
2. **Build**: `ibmcloud cr build -t icr.io/test_icr/ibm-cloud-info:latest .`
3. **Deploy**: `cd terraform && terraform init && terraform apply`
4. **URL**: `terraform output application_url`

## 📚 Documentación Adicional

- **INSTALL_PLUGINS.md**: Instalación de plugins
- **QUICK_START.md**: Guía rápida general
- **SETUP_GUIDE.md**: Guía detallada completa
- **README.md**: Documentación del proyecto

---

**Este es el método más simple y recomendado para deployment** 🚀

**No necesitas Docker, Podman, ni configurar nada adicional. IBM Cloud hace todo el trabajo pesado por ti.**