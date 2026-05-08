# GitHub Actions para PowerVS Deployment

## 🎯 Descripción General

Workflow completo de CI/CD para desplegar la aplicación IBM Cloud Info en IBM PowerVS usando Terraform, aplicando todas las mejores prácticas aprendidas.

## 🚀 Características del Workflow

### 3 Jobs Principales

1. **Validate** - Validación de Terraform
2. **Plan** - Planificación del deployment
3. **Apply** - Deployment a PowerVS
4. **Destroy** - Eliminación de recursos (manual)

### Mejoras Implementadas

- ✅ **Validación automática** de formato y sintaxis
- ✅ **Plan en PRs** con comentarios automáticos
- ✅ **SSH key generado** automáticamente
- ✅ **Artifacts** para plan y SSH keys
- ✅ **Environments** de GitHub para aprobaciones
- ✅ **Health checks** de la aplicación
- ✅ **Summaries detallados** con toda la info
- ✅ **Timeouts configurados** (15-30 min)
- ✅ **Cleanup automático** de archivos sensibles

## 📋 Configuración de Secrets

### Secrets Requeridos

| Secret | Descripción | Ejemplo |
|--------|-------------|---------|
| `IBM_CLOUD_API_KEY` | API Key de IBM Cloud | `abc123...` |
| `IBM_CLOUD_REGION` | Región de IBM Cloud | `us-south` |
| `IBM_CLOUD_RESOURCE_GROUP` | Resource Group | `Default` |

**Nota**: El SSH key se genera automáticamente en cada deployment.

## 🎮 Uso del Workflow

### Opción 1: Push Automático

```bash
# Hacer cambios en PowerVS Terraform
vim terraform/powervs/instance.tf

# Commit y push
git add terraform/powervs/
git commit -m "feat: update PowerVS configuration"
git push origin main
```

El workflow:
1. ✅ Valida Terraform
2. ✅ Genera plan
3. ✅ Despliega automáticamente

### Opción 2: Pull Request (Recomendado)

```bash
# Crear branch
git checkout -b feature/powervs-update

# Hacer cambios
vim terraform/powervs/variables.tf

# Push a branch
git push origin feature/powervs-update

# Crear PR en GitHub
```

El workflow:
1. ✅ Valida Terraform
2. ✅ Genera plan
3. ✅ Comenta el plan en el PR
4. ⏸️ Espera aprobación
5. ✅ Despliega al hacer merge

### Opción 3: Manual con Opciones

1. Ve a **Actions** → **Deploy to IBM PowerVS**
2. Click **Run workflow**
3. Selecciona:
   - **Action**: plan / apply / destroy
   - **PowerVS Zone**: dal12, lon06, tok04, etc.
4. Click **Run workflow**

## 📊 Flujo Completo

```
Push/PR
    ↓
Job 1: Validate (2-3 min)
    ├─ Format check
    ├─ Init (no backend)
    └─ Validate syntax
    ↓
Job 2: Plan (3-5 min)
    ├─ Generate SSH key
    ├─ Create tfvars
    ├─ Terraform init
    ├─ Terraform plan
    ├─ Comment on PR (if PR)
    ├─ Upload artifacts
    └─ Summary
    ↓
Job 3: Apply (15-30 min)
    ├─ Download artifacts
    ├─ Terraform apply
    ├─ Wait for app (2 min)
    ├─ Health check
    ├─ Get outputs
    └─ Deployment summary
    ↓
✅ App running on PowerVS
```

## 🔐 Environments de GitHub

El workflow usa GitHub Environments para control adicional:

### Configurar Environment

1. Ve a **Settings** → **Environments**
2. Crea environment: `powervs-production`
3. Configura:
   - ✅ **Required reviewers**: Agrega aprobadores
   - ✅ **Wait timer**: 5 minutos (opcional)
   - ✅ **Deployment branches**: Solo `main`

### Beneficios

- 🛡️ Aprobación manual antes de apply
- 📊 Historial de deployments
- 🔒 Secrets específicos por environment
- ⏱️ Wait timers configurables

## 📦 Artifacts Generados

### 1. terraform-plan-powervs

Contiene:
- `tfplan` - Plan binario de Terraform
- `plan_output.txt` - Plan en texto legible

**Retención**: 30 días

### 2. ssh-key-powervs

Contiene:
- `powervs_key` - SSH private key
- `powervs_key.pub` - SSH public key

**Retención**: 7 días

**⚠️ Importante**: Descarga el SSH key antes de que expire.

### 3. ssh-connection-info

Contiene:
- `ssh_key_info.txt` - Instrucciones de conexión

**Retención**: 30 días

## 🔧 Personalización

### Cambiar Configuración de la Instancia

Edita `.github/workflows/powervs-deploy.yml`:

```yaml
- name: Create terraform.tfvars
  run: |
    cat > terraform.tfvars << EOF
    # Cambiar estos valores
    instance_processors   = 0.5      # De 0.25 a 0.5
    instance_memory       = 4        # De 2 a 4 GB
    instance_storage_size = 50       # De 20 a 50 GB
    instance_sys_type     = "e980"   # De s922 a e980
    EOF
```

### Cambiar Zona de PowerVS

**Opción A**: En el workflow manual
- Selecciona la zona en el dropdown

**Opción B**: En el código
```yaml
powervs_zone = "lon06"  # Cambiar de dal12 a lon06
```

### Zonas Disponibles

| Zona | Ubicación | Latencia |
|------|-----------|----------|
| `dal12` | Dallas, US | Baja (US) |
| `dal13` | Dallas, US | Baja (US) |
| `wdc06` | Washington, US | Baja (US) |
| `wdc07` | Washington, US | Baja (US) |
| `lon06` | Londres, UK | Media (EU) |
| `tok04` | Tokio, JP | Alta (Asia) |
| `syd04` | Sydney, AU | Alta (Oceanía) |
| `syd05` | Sydney, AU | Alta (Oceanía) |
| `sao01` | São Paulo, BR | Media (LATAM) |
| `mon01` | Montreal, CA | Baja (CA) |

## 📈 Monitoreo del Deployment

### Ver Progreso en Tiempo Real

1. Ve a **Actions** en GitHub
2. Click en el workflow en ejecución
3. Observa los jobs:
   - **Validate**: ~2-3 min
   - **Plan**: ~3-5 min
   - **Apply**: ~15-30 min

### Logs Detallados

Cada step muestra:
- ✅ Comandos ejecutados
- ✅ Outputs de Terraform
- ✅ Errores (si los hay)
- ✅ Tiempos de ejecución

### Summary

Al finalizar, verás:
- 🌐 URL de la aplicación
- 🔐 IP pública y privada
- 📊 Detalles de configuración
- 💰 Información de costos
- 🔑 Instrucciones SSH

## 🐛 Troubleshooting

### Error: "Image not available in zone"

**Causa**: Rocky Linux 9 no disponible en la zona seleccionada.

**Solución**: Cambiar la imagen:

```yaml
instance_image_name = "RHEL9-SP2"  # O "CentOS-Stream-9"
```

### Error: "Insufficient capacity"

**Causa**: No hay capacidad en la zona para el tipo de sistema.

**Solución**: 
1. Cambiar zona
2. O cambiar `instance_sys_type`:
   ```yaml
   instance_sys_type = "s922"  # Más disponible
   ```

### Error: "Timeout waiting for instance"

**Causa**: La instancia tarda más de 45 minutos en crearse.

**Solución**: Ya configurado con timeout de 45 min. Si persiste:
1. Verificar estado en IBM Cloud Console
2. Revisar logs de PowerVS
3. Contactar soporte de IBM

### Error: "Application not responding"

**Causa**: El script de setup falló o el servicio no inició.

**Solución**:
1. Descargar SSH key de artifacts
2. Conectar a la instancia:
   ```bash
   ssh -i powervs_key root@<public_ip>
   ```
3. Verificar logs:
   ```bash
   journalctl -u ibm-cloud-info -f
   systemctl status ibm-cloud-info
   ```

### Error: "SSH key not found in artifacts"

**Causa**: El artifact expiró (7 días).

**Solución**:
1. Re-ejecutar el workflow
2. O generar nuevo SSH key y actualizar en PowerVS

## 💰 Gestión de Costos

### Costos Estimados

| Configuración | Cores | RAM | Storage | Costo/Mes |
|---------------|-------|-----|---------|-----------|
| **Mínima** | 0.25 | 2GB | 20GB | ~$43-60 |
| **Pequeña** | 0.5 | 4GB | 50GB | ~$86-120 |
| **Media** | 1.0 | 8GB | 100GB | ~$172-240 |
| **Grande** | 2.0 | 16GB | 200GB | ~$344-480 |

### Optimización de Costos

1. **Usar configuración mínima** para desarrollo
2. **Destruir cuando no uses**:
   ```bash
   # Manual en GitHub Actions
   Actions → Deploy to IBM PowerVS → Run workflow → destroy
   ```
3. **Monitorear uso** en IBM Cloud Console
4. **Configurar alertas** de billing

### Destruir Recursos

**Opción 1**: GitHub Actions (Recomendado)
```
Actions → Deploy to IBM PowerVS → Run workflow
Action: destroy
```

**Opción 2**: Terraform local
```bash
cd terraform/powervs
terraform destroy
```

## 🔒 Seguridad

### SSH Keys

- ✅ Generados automáticamente por workflow
- ✅ Únicos por deployment
- ✅ Almacenados en artifacts (encriptados)
- ✅ Expiración automática (7 días)
- ✅ No se commitean al repo

### Secrets

- ✅ Almacenados en GitHub Secrets
- ✅ Enmascarados en logs
- ✅ No expuestos en artifacts
- ✅ Acceso controlado por permisos

### Mejores Prácticas

1. **Rotar API keys** regularmente
2. **Usar environments** para aprobaciones
3. **Revisar PRs** antes de merge
4. **Descargar SSH keys** inmediatamente
5. **Destruir recursos** cuando no se usen

## 📚 Ejemplos de Uso

### Ejemplo 1: Deployment Básico

```bash
# 1. Configurar secrets en GitHub
# 2. Push a main
git push origin main

# 3. Esperar ~20-30 minutos
# 4. Obtener URL del summary
# 5. Acceder a la aplicación
```

### Ejemplo 2: Cambiar Configuración

```bash
# 1. Crear branch
git checkout -b feature/increase-resources

# 2. Editar workflow
vim .github/workflows/powervs-deploy.yml
# Cambiar: instance_processors = 0.5, instance_memory = 4

# 3. Push y crear PR
git push origin feature/increase-resources

# 4. Revisar plan en PR
# 5. Aprobar y merge
# 6. Deployment automático
```

### Ejemplo 3: Conectar por SSH

```bash
# 1. Descargar SSH key de artifacts
# 2. Extraer archivo
unzip ssh-key-powervs.zip

# 3. Ajustar permisos
chmod 600 powervs_key

# 4. Conectar
ssh -i powervs_key root@<public_ip>

# 5. Verificar aplicación
systemctl status ibm-cloud-info
curl http://localhost
```

## 🎓 Comparación con Code Engine

| Aspecto | Code Engine | PowerVS |
|---------|-------------|---------|
| **Tiempo Deploy** | 10-15 min | 20-30 min |
| **Costo Mínimo** | ~$0 (tier gratuito) | ~$43/mes |
| **Escalabilidad** | Automática | Manual |
| **Control** | Limitado | Total |
| **SSH Access** | No | Sí |
| **Arquitectura** | x86 | POWER |
| **Uso Ideal** | Apps web, APIs | Workloads AIX/IBM i |

## 📊 Métricas de Rendimiento

### Tiempos de Deployment

| Fase | Tiempo |
|------|--------|
| Validate | 2-3 min |
| Plan | 3-5 min |
| Apply | 15-30 min |
| **Total** | **20-38 min** |

### Optimizaciones Aplicadas

- ✅ Parallel jobs cuando es posible
- ✅ Artifacts para reutilizar plan
- ✅ Timeouts configurados apropiadamente
- ✅ Health checks automáticos
- ✅ Cleanup automático

## 🎯 Conclusión

Este workflow de GitHub Actions para PowerVS incluye:

- ✅ **Validación automática** de Terraform
- ✅ **Plans en PRs** para revisión
- ✅ **Deployment automático** en merge
- ✅ **SSH keys gestionados** automáticamente
- ✅ **Environments** para control
- ✅ **Artifacts** para plan y keys
- ✅ **Health checks** de la app
- ✅ **Summaries detallados** con toda la info
- ✅ **Destroy controlado** para cleanup

**¡Todo listo para desplegar en PowerVS con un simple push!** 🚀

## 📞 Soporte

Si tienes problemas:
1. Revisa los logs del workflow
2. Consulta esta documentación
3. Verifica la configuración de secrets
4. Contacta al equipo de IBM Cloud

---

**Made with ❤️ using GitHub Actions and Terraform**