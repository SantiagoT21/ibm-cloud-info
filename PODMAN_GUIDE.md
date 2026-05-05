# 🐳 Guía de Deployment con Podman

Si usas Podman en lugar de Docker, sigue esta guía.

## 📦 Verificar Podman

```bash
# Verificar que Podman está instalado
podman --version

# Si no está instalado, instálalo:
# macOS: brew install podman
# Linux: sudo apt install podman (Ubuntu/Debian)
# Linux: sudo dnf install podman (Fedora/RHEL)
```

## 🚀 Deployment con Podman

### Paso 1: Instalar Plugins de IBM Cloud

```bash
# Instalar plugins necesarios
ibmcloud plugin install container-registry -f
ibmcloud plugin install code-engine -f

# Verificar instalación
ibmcloud plugin list
```

### Paso 2: Configurar IBM Cloud y Container Registry

```bash
# Login a IBM Cloud
ibmcloud login --apikey zLn7cRyoBQReEVI1YcrtZJL_vkxiT6RjEiikqjQWbGil

# Configurar región
ibmcloud cr region-set us-south

# Verificar/crear namespace
ibmcloud cr namespace-list
ibmcloud cr namespace-add test_icr  # Si no existe
```

### Paso 3: Build y Push con Podman

```bash
# Build de la imagen con Podman
podman build -t icr.io/test_icr/ibm-cloud-info:latest .

# Login a IBM Container Registry con Podman
# Usa 'iamapikey' como usuario y tu API Key como password
podman login icr.io -u iamapikey -p zLn7cRyoBQReEVI1YcrtZJL_vkxiT6RjEiikqjQWbGil

# Push de la imagen
podman push icr.io/test_icr/ibm-cloud-info:latest

# Verificar que la imagen se subió
ibmcloud cr image-list
```

### Paso 5: Deploy con Terraform

```bash
# Ir al directorio de Terraform
cd terraform

# Inicializar Terraform
terraform init

# Ver plan
terraform plan

# Aplicar (escribe 'yes' cuando pregunte)
terraform apply

# Obtener URL de la aplicación
terraform output application_url
```

## 🧪 Test Local con Podman

```bash
# Build de la imagen
podman build -t ibm-cloud-info:test .

# Ejecutar localmente
podman run -p 8080:8080 ibm-cloud-info:test

# Abrir http://localhost:8080 en tu navegador
# Presiona Ctrl+C para detener
```

## ⚡ Comandos Rápidos con Podman

```bash
# Setup completo en un solo bloque
ibmcloud login --apikey zLn7cRyoBQReEVI1YcrtZJL_vkxiT6RjEiikqjQWbGil && \
ibmcloud cr region-set us-south && \
podman build -t icr.io/test_icr/ibm-cloud-info:latest . && \
podman login icr.io -u iamapikey -p zLn7cRyoBQReEVI1YcrtZJL_vkxiT6RjEiikqjQWbGil && \
podman push icr.io/test_icr/ibm-cloud-info:latest && \
cd terraform && \
terraform init && \
terraform apply -auto-approve

# Ver URL de la aplicación
cd terraform && terraform output application_url
```

## 🔄 Alternativa: Usar ibmcloud cr build

IBM Cloud CLI puede hacer el build y push por ti sin necesidad de Docker/Podman:

```bash
# Login a IBM Cloud
ibmcloud login --apikey zLn7cRyoBQReEVI1YcrtZJL_vkxiT6RjEiikqjQWbGil

# Configurar región
ibmcloud cr region-set us-south

# Build y push en un solo comando (IBM Cloud hace el build por ti)
ibmcloud cr build -t icr.io/test_icr/ibm-cloud-info:latest .

# Verificar
ibmcloud cr image-list

# Continuar con Terraform
cd terraform
terraform init
terraform apply
```

## 🎯 Opción Recomendada: ibmcloud cr build

Esta es la forma más simple y no requiere Docker ni Podman:

```bash
# 1. Login
ibmcloud login --apikey zLn7cRyoBQReEVI1YcrtZJL_vkxiT6RjEiikqjQWbGil

# 2. Configurar región
ibmcloud cr region-set us-south

# 3. Build y push (IBM Cloud hace todo)
ibmcloud cr build -t icr.io/test_icr/ibm-cloud-info:latest .

# 4. Deploy con Terraform
cd terraform
terraform init
terraform apply
```

## 📊 Comparación de Métodos

| Método | Ventajas | Desventajas |
|--------|----------|-------------|
| **Docker** | Más común, mucha documentación | Requiere Docker Desktop |
| **Podman** | Sin daemon, más seguro | Menos común, algunos comandos diferentes |
| **ibmcloud cr build** | No requiere Docker/Podman, más simple | Build remoto (puede ser más lento) |

## 🆘 Troubleshooting con Podman

### Error: "permission denied"

```bash
# Ejecutar Podman sin sudo (configurar rootless)
podman system migrate

# O usar sudo
sudo podman build -t icr.io/test_icr/ibm-cloud-info:latest .
```

### Error: "login failed"

```bash
# Verificar credenciales
ibmcloud iam api-keys

# Intentar login nuevamente
podman login icr.io -u iamapikey -p TU_API_KEY
```

### Error: "push failed"

```bash
# Verificar que el namespace existe
ibmcloud cr namespace-list

# Verificar que estás logueado
podman login icr.io -u iamapikey -p TU_API_KEY

# Intentar push nuevamente
podman push icr.io/test_icr/ibm-cloud-info:latest
```

## 💡 Recomendación Final

**Usa `ibmcloud cr build`** - Es la forma más simple y no requiere Docker ni Podman:

```bash
# Todo en un comando
ibmcloud cr build -t icr.io/test_icr/ibm-cloud-info:latest .
```

Esto hace el build en los servidores de IBM Cloud y sube la imagen automáticamente.

---

**Siguiente paso**: Una vez que la imagen esté en Container Registry, continúa con el deployment de Terraform (Paso 5).