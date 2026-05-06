# Solución: Proyecto de Code Engine Deshabilitado

## Error Crítico Identificado

```
FAILED
Project is in disabled state. Access is forbidden.
```

Este es el **problema raíz** que causa el timeout en el deployment. Un proyecto deshabilitado no puede ser usado y **no puede ser re-habilitado**, debe ser eliminado y recreado.

## ¿Por Qué Se Deshabilita un Proyecto?

Los proyectos de Code Engine se deshabilitan por:

1. **Inactividad prolongada** (más de 30 días sin uso)
2. **Problemas de facturación** en la cuenta
3. **Límites de cuota excedidos**
4. **Violación de políticas** de IBM Cloud
5. **Eliminación manual** que no se completó correctamente

## Solución Rápida (Recomendada)

### Opción 1: Script Automatizado (Más Fácil)

```bash
./scripts/fix-disabled-project.sh
```

Selecciona la **Opción 5: Full automated fix** que:
1. ✅ Elimina el proyecto deshabilitado
2. ✅ Limpia el state de Terraform
3. ✅ Recrea el proyecto con Terraform
4. ✅ Despliega todos los recursos (proyecto, secret, app)
5. ✅ Verifica que todo funcione

### Opción 2: Comandos Manuales

```bash
# 1. Eliminar el proyecto deshabilitado
ibmcloud ce project delete --name ibm-cloud-info --force --hard

# 2. Esperar a que se complete la eliminación
sleep 30

# 3. Limpiar el state de Terraform
cd terraform
terraform state rm ibm_code_engine_project.project
terraform state rm ibm_code_engine_secret.registry_secret
terraform state rm ibm_code_engine_app.app

# 4. Recrear todo con Terraform
terraform plan -out=tfplan
terraform apply -auto-approve -input=false tfplan

# 5. Verificar
ibmcloud ce project get --name ibm-cloud-info
```

## Pasos Detallados

### Paso 1: Verificar el Estado del Proyecto

```bash
ibmcloud ce project get --name ibm-cloud-info
```

**Si ves "disabled state"**, el proyecto está deshabilitado y debe ser eliminado.

### Paso 2: Eliminar el Proyecto Deshabilitado

```bash
# Eliminar completamente (hard delete)
ibmcloud ce project delete --name ibm-cloud-info --force --hard
```

**Importante:** Esto eliminará:
- ❌ Todas las aplicaciones
- ❌ Todos los jobs
- ❌ Todos los secrets
- ❌ Todos los configmaps
- ❌ Todo el historial

### Paso 3: Limpiar el State de Terraform

El proyecto eliminado aún existe en el state de Terraform, debemos removerlo:

```bash
cd terraform

# Listar recursos en el state
terraform state list

# Remover el proyecto
terraform state rm ibm_code_engine_project.project

# Remover el secret (si existe)
terraform state rm ibm_code_engine_secret.registry_secret

# Remover la app (si existe)
terraform state rm ibm_code_engine_app.app
```

### Paso 4: Recrear con Terraform

```bash
# Asegurarse de estar en el directorio terraform
cd terraform

# Planificar
terraform plan -out=tfplan

# Aplicar
terraform apply -auto-approve -input=false tfplan
```

Terraform ahora creará:
1. ✅ Nuevo proyecto de Code Engine (activo)
2. ✅ Registry secret con credenciales de ICR
3. ✅ Aplicación con la imagen privada

### Paso 5: Verificar el Deployment

```bash
# Verificar proyecto
ibmcloud ce project get --name ibm-cloud-info

# Seleccionar proyecto
ibmcloud ce project select --name ibm-cloud-info

# Verificar secret
ibmcloud ce secret get --name icr-secret

# Verificar app
ibmcloud ce app get --name ibm-cloud-info-app

# Ver logs
ibmcloud ce app logs --app ibm-cloud-info-app --tail 50
```

## Prevención Futura

### 1. Mantener el Proyecto Activo

Los proyectos se deshabilitan por inactividad. Para evitarlo:

```bash
# Opción A: Mantener al menos 1 app corriendo
# (con min_scale = 1 en lugar de 0)

# Opción B: Ejecutar un job periódicamente
ibmcloud ce job create --name keepalive --image ibmcloud/ibm-cloud-developer-tools
ibmcloud ce jobrun submit --job keepalive
```

### 2. Configurar Alertas

Configura alertas para ser notificado si el proyecto se deshabilita:

```bash
# Crear un script de monitoreo
cat > scripts/check-project-status.sh << 'EOF'
#!/bin/bash
PROJECT_NAME="ibm-cloud-info"
STATUS=$(ibmcloud ce project get --name $PROJECT_NAME 2>&1)

if echo "$STATUS" | grep -q "disabled"; then
    echo "ALERT: Project $PROJECT_NAME is DISABLED!"
    # Enviar notificación (email, Slack, etc.)
fi
EOF

chmod +x scripts/check-project-status.sh

# Ejecutar diariamente con cron
# 0 9 * * * /path/to/scripts/check-project-status.sh
```

### 3. Usar min_scale > 0 en Producción

En `terraform/terraform.tfvars`:

```hcl
# Para desarrollo (scale to zero)
min_scale = 0

# Para producción (siempre activo)
min_scale = 1
```

Esto mantiene al menos 1 instancia corriendo, evitando que el proyecto se marque como inactivo.

## Troubleshooting

### Error: "Cannot delete project"

```bash
# Forzar eliminación con hard delete
ibmcloud ce project delete --name ibm-cloud-info --force --hard

# Si aún falla, esperar y reintentar
sleep 60
ibmcloud ce project delete --name ibm-cloud-info --force --hard
```

### Error: "Project name already exists"

El proyecto no se eliminó completamente:

```bash
# Listar todos los proyectos
ibmcloud ce project list

# Si aparece como "deleting", esperar
sleep 120

# Reintentar la creación
cd terraform
terraform apply -auto-approve -input=false tfplan
```

### Error: "Terraform state out of sync"

```bash
# Refrescar el state
cd terraform
terraform refresh

# O recrear el state desde cero
rm -rf .terraform terraform.tfstate*
terraform init
terraform plan -out=tfplan
terraform apply -auto-approve -input=false tfplan
```

## Comparación de Métodos

| Método | Tiempo | Dificultad | Recomendado Para |
|--------|--------|------------|------------------|
| Script automatizado (Opción 5) | 5 min | Fácil | Todos |
| Comandos manuales | 10 min | Media | Usuarios avanzados |
| Script interactivo (Opción 3) | 8 min | Fácil | Paso a paso |

## Resumen de Comandos

```bash
# Solución rápida (todo en uno)
./scripts/fix-disabled-project.sh
# Selecciona opción 5

# O manualmente:
ibmcloud ce project delete --name ibm-cloud-info --force --hard
cd terraform
terraform state rm ibm_code_engine_project.project
terraform state rm ibm_code_engine_secret.registry_secret
terraform state rm ibm_code_engine_app.app
terraform plan -out=tfplan
terraform apply -auto-approve -input=false tfplan
```

## Después de la Solución

Una vez que el proyecto esté recreado y activo:

1. **Verificar que la app funciona:**
   ```bash
   curl $(cd terraform && terraform output -raw app_url)
   ```

2. **Configurar monitoreo:**
   ```bash
   # Agregar a cron para verificación diaria
   crontab -e
   # Agregar: 0 9 * * * /path/to/scripts/check-project-status.sh
   ```

3. **Documentar el incidente:**
   - Fecha de deshabilitación
   - Causa (si se conoce)
   - Tiempo de resolución
   - Medidas preventivas implementadas

## Contacto y Soporte

Si el problema persiste después de seguir estos pasos:

1. Verifica el estado de tu cuenta de IBM Cloud
2. Revisa si hay problemas de facturación
3. Contacta al soporte de IBM Cloud con:
   - Nombre del proyecto
   - Región
   - Trace ID del error
   - Logs de los comandos ejecutados

## Notas Importantes

⚠️ **Un proyecto deshabilitado NO puede ser re-habilitado**
⚠️ **Todos los recursos del proyecto se perderán al eliminarlo**
⚠️ **Terraform recreará todo desde cero**
⚠️ **Asegúrate de tener backups de configuraciones importantes**

✅ **El script automatizado maneja todo esto por ti**
✅ **Terraform mantiene la configuración como código**
✅ **Los secrets se recrean automáticamente**
✅ **La app se redespliega con la misma configuración**