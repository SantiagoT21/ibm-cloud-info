# 🔧 Instalación de Plugins de IBM Cloud CLI

Antes de poder usar Container Registry y Code Engine, necesitas instalar los plugins correspondientes.

## 📦 Plugins Necesarios

### 1. Container Registry Plugin

```bash
# Instalar plugin de Container Registry
ibmcloud plugin install container-registry

# Verificar instalación
ibmcloud plugin list
```

### 2. Code Engine Plugin

```bash
# Instalar plugin de Code Engine
ibmcloud plugin install code-engine

# Verificar instalación
ibmcloud plugin list
```

### 3. Kubernetes Service Plugin (Opcional, pero recomendado)

```bash
# Instalar plugin de Kubernetes
ibmcloud plugin install kubernetes-service

# Verificar instalación
ibmcloud plugin list
```

## ✅ Verificar Plugins Instalados

```bash
# Listar todos los plugins instalados
ibmcloud plugin list

# Deberías ver algo como:
# Plugin Name                            Version   Status   Private endpoints supported   
# container-registry                     1.3.6              false   
# code-engine                            1.49.6             false   
# kubernetes-service                     1.0.540            false
```

## 🚀 Comandos Completos de Setup

Ejecuta estos comandos en orden:

```bash
# 1. Login a IBM Cloud
ibmcloud login --apikey zLn7cRyoBQReEVI1YcrtZJL_vkxiT6RjEiikqjQWbGil

# 2. Instalar plugins necesarios
ibmcloud plugin install container-registry -f
ibmcloud plugin install code-engine -f

# 3. Configurar región de Container Registry
ibmcloud cr region-set us-south

# 4. Verificar namespace (debería existir: test_icr)
ibmcloud cr namespace-list

# 5. Si el namespace no existe, créalo
ibmcloud cr namespace-add test_icr

# 6. Login a Container Registry
ibmcloud cr login

# 7. Verificar que todo funciona
ibmcloud cr info
```

## 🐳 Ahora Sí: Build y Push de Docker

Una vez instalados los plugins:

```bash
# 1. Build de la imagen
docker build -t icr.io/test_icr/ibm-cloud-info:latest .

# 2. Push de la imagen
docker push icr.io/test_icr/ibm-cloud-info:latest

# 3. Verificar que la imagen se subió
ibmcloud cr image-list
```

## 🔄 Actualizar Plugins (Opcional)

Si ya tienes plugins instalados pero son versiones antiguas:

```bash
# Actualizar todos los plugins
ibmcloud plugin update --all

# O actualizar uno específico
ibmcloud plugin update container-registry
ibmcloud plugin update code-engine
```

## ❌ Desinstalar Plugins (Si es necesario)

```bash
# Desinstalar un plugin
ibmcloud plugin uninstall container-registry

# Reinstalar
ibmcloud plugin install container-registry
```

## 🆘 Troubleshooting

### Error: "Plugin not found"

```bash
# Listar plugins disponibles
ibmcloud plugin repo-plugins

# Buscar plugin específico
ibmcloud plugin repo-plugins | grep container-registry
```

### Error: "Permission denied"

```bash
# Usar sudo en Mac/Linux
sudo ibmcloud plugin install container-registry

# O cambiar permisos del directorio de IBM Cloud CLI
sudo chown -R $USER ~/.bluemix
```

### Error: "Plugin already installed"

```bash
# Desinstalar primero
ibmcloud plugin uninstall container-registry

# Reinstalar
ibmcloud plugin install container-registry
```

## 📋 Checklist de Instalación

- [ ] IBM Cloud CLI instalado
- [ ] Login exitoso a IBM Cloud
- [ ] Plugin container-registry instalado
- [ ] Plugin code-engine instalado
- [ ] Región configurada (us-south)
- [ ] Namespace verificado/creado (test_icr)
- [ ] Login a Container Registry exitoso

## ➡️ Siguiente Paso

Una vez completada la instalación de plugins, continúa con **QUICK_START.md** para el deployment.

---

**Nota**: Los plugins solo necesitan instalarse una vez. Después de esto, todos los comandos funcionarán normalmente.