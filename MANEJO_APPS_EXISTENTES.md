# Manejo de Aplicaciones Existentes en Code Engine con Terraform

## Problema

Cuando ejecutas `terraform apply` y la aplicación ya existe en Code Engine (creada manualmente o por un deployment anterior), Terraform puede fallar con errores como:

```
Error: Application already exists
Error: Resource already exists with the same name
```

## Soluciones Implementadas

### 1. Lifecycle Configuration (Recomendado)

El archivo `terraform/code_engine.tf` ahora incluye configuración de lifecycle que permite:

- **`create_before_destroy = true`**: Crea una nueva versión de la app antes de eliminar la antigua (zero-downtime)
- Actualizaciones sin interrupciones del servicio
- Manejo automático de cambios en la configuración

```hcl
resource "ibm_code_engine_app" "app" {
  # ... configuración ...
  
  lifecycle {
    create_before_destroy = true
  }
}
```

### 2. Script de Gestión Interactivo

Hemos creado `scripts/manage-codeengine-app.sh` que te permite:

1. **Verificar** si la app existe
2. **Eliminar** la app existente antes de aplicar Terraform
3. **Importar** la app existente al state de Terraform
4. **Ver detalles** de la app actual
5. **Flujos automatizados** (eliminar + apply, o importar + apply)

## Uso del Script de Gestión

### Ejecución Básica

```bash
./scripts/manage-codeengine-app.sh
```

El script:
- Lee automáticamente los valores de `terraform/terraform.tfvars`
- Presenta un menú interactivo
- Valida que tengas las herramientas necesarias instaladas

### Opciones del Menú

#### Opción 1: Verificar si la app existe
Comprueba si la aplicación ya está desplegada en Code Engine.

```bash
# Selecciona opción 1
# Output: "App 'ibm-cloud-info-app' exists" o "App does not exist"
```

#### Opción 2: Eliminar app existente
Elimina la aplicación de Code Engine (útil para empezar desde cero).

```bash
# Selecciona opción 2
# Confirma con "yes"
# La app será eliminada
```

#### Opción 3: Importar app a Terraform
Importa una app existente al state de Terraform (evita recrearla).

```bash
# Selecciona opción 3
# La app se importará al state de Terraform
# Terraform ahora la gestionará sin recrearla
```

#### Opción 5: Eliminar y aplicar Terraform (Recomendado para desarrollo)
Flujo completo: elimina la app existente y ejecuta `terraform apply`.

```bash
# Selecciona opción 5
# Confirma con "yes"
# El script:
# 1. Elimina la app existente
# 2. Ejecuta terraform plan
# 3. Ejecuta terraform apply
# 4. Despliega la nueva versión
```

#### Opción 6: Importar y aplicar Terraform (Recomendado para producción)
Flujo completo: importa la app existente y ejecuta `terraform apply`.

```bash
# Selecciona opción 6
# El script:
# 1. Importa la app al state de Terraform
# 2. Ejecuta terraform plan (mostrará cambios)
# 3. Ejecuta terraform apply (actualiza la app)
# 4. Mantiene la app existente, solo actualiza configuración
```

## Estrategias Recomendadas

### Para Desarrollo/Testing
**Usar Opción 5 (Eliminar y aplicar)**

Ventajas:
- ✅ Siempre parte de un estado limpio
- ✅ No hay conflictos con configuraciones anteriores
- ✅ Más rápido para iteraciones rápidas

Desventajas:
- ❌ Breve downtime durante la recreación
- ❌ Se pierde el historial de la app

```bash
./scripts/manage-codeengine-app.sh
# Selecciona: 5
# Confirma: yes
```

### Para Producción
**Usar Opción 6 (Importar y aplicar)**

Ventajas:
- ✅ Zero-downtime (gracias a `create_before_destroy`)
- ✅ Mantiene el historial de la app
- ✅ Actualizaciones graduales

Desventajas:
- ❌ Requiere que la configuración de Terraform coincida con la app existente
- ❌ Puede requerir ajustes manuales si hay diferencias

```bash
./scripts/manage-codeengine-app.sh
# Selecciona: 6
```

## Comandos Manuales (Sin Script)

### Importar App Manualmente

```bash
# 1. Obtener el Project ID
ibmcloud ce project select --name <project_name>
PROJECT_ID=$(ibmcloud ce project current --output json | grep -o '"id":"[^"]*"' | cut -d'"' -f4)

# 2. Importar la app
cd terraform
terraform import ibm_code_engine_app.app "${PROJECT_ID}/<app_name>"

# 3. Verificar el import
terraform state list

# 4. Aplicar cambios
terraform plan -out=tfplan
terraform apply -auto-approve -input=false tfplan
```

### Eliminar App Manualmente

```bash
# 1. Seleccionar proyecto
ibmcloud ce project select --name <project_name>

# 2. Eliminar app
ibmcloud ce app delete --name <app_name> --force --wait

# 3. Aplicar Terraform
cd terraform
terraform plan -out=tfplan
terraform apply -auto-approve -input=false tfplan
```

## Flujo de Trabajo Recomendado

### Primera Vez (App No Existe)

```bash
cd terraform
terraform init
terraform plan -out=tfplan
terraform apply -auto-approve -input=false tfplan
```

### Actualizaciones Subsecuentes (App Ya Existe)

#### Opción A: Con el Script (Recomendado)
```bash
./scripts/manage-codeengine-app.sh
# Selecciona opción 6 (Importar y aplicar)
```

#### Opción B: Manual
```bash
# 1. Importar si no está en el state
terraform import ibm_code_engine_app.app "<project_id>/<app_name>"

# 2. Aplicar cambios
cd terraform
terraform plan -out=tfplan
terraform apply -auto-approve -input=false tfplan
```

## Verificación Post-Deployment

### Verificar Estado de Terraform

```bash
cd terraform
terraform state list
# Debe mostrar:
# ibm_code_engine_project.project
# ibm_code_engine_secret.registry_secret
# ibm_code_engine_app.app
```

### Verificar App en Code Engine

```bash
ibmcloud ce project select --name <project_name>
ibmcloud ce app get --name <app_name>
```

### Verificar URL de la App

```bash
cd terraform
terraform output app_url
# O
curl $(terraform output -raw app_url)
```

## Troubleshooting

### Error: "Resource already exists"

**Solución 1**: Importar la app
```bash
./scripts/manage-codeengine-app.sh
# Selecciona opción 3
```

**Solución 2**: Eliminar y recrear
```bash
./scripts/manage-codeengine-app.sh
# Selecciona opción 2
```

### Error: "App not found in state"

La app existe en Code Engine pero no en el state de Terraform.

**Solución**: Importar la app
```bash
./scripts/manage-codeengine-app.sh
# Selecciona opción 3
```

### Error: "Configuration drift detected"

Terraform detecta diferencias entre el state y la realidad.

**Solución**: Aplicar los cambios
```bash
cd terraform
terraform plan -out=tfplan
terraform apply -auto-approve -input=false tfplan
```

### La app se recrea en cada apply

**Causa**: Algún atributo está cambiando constantemente.

**Solución**: Agregar el atributo a `ignore_changes` en el lifecycle:

```hcl
lifecycle {
  create_before_destroy = true
  ignore_changes = [
    status,  # Ejemplo: ignorar cambios en status
  ]
}
```

## Mejores Prácticas

1. **Usar el script de gestión** para operaciones comunes
2. **Importar apps existentes** en lugar de eliminarlas en producción
3. **Mantener el state de Terraform** sincronizado con Code Engine
4. **Usar `create_before_destroy`** para actualizaciones sin downtime
5. **Verificar el plan** antes de aplicar cambios importantes
6. **Hacer backup del state** antes de operaciones críticas

## Ejemplo Completo: Actualizar Imagen de la App

```bash
# 1. Modificar la variable en terraform.tfvars
echo 'container_image = "icr.io/test_icr/ibm-cloud-info:v2.0.0"' >> terraform/terraform.tfvars

# 2. Usar el script para aplicar cambios
./scripts/manage-codeengine-app.sh
# Selecciona opción 6 (Importar y aplicar)

# 3. Verificar el deployment
ibmcloud ce app get --name ibm-cloud-info-app

# 4. Probar la nueva versión
curl $(cd terraform && terraform output -raw app_url)
```

## Resumen

| Escenario | Solución Recomendada | Comando |
|-----------|---------------------|---------|
| Primera vez | Terraform apply directo | `terraform apply` |
| App existe (dev) | Eliminar y recrear | Script opción 5 |
| App existe (prod) | Importar y actualizar | Script opción 6 |
| Actualizar imagen | Importar y aplicar | Script opción 6 |
| Limpiar todo | Eliminar manualmente | Script opción 2 |

Con estas herramientas y estrategias, puedes manejar eficientemente las aplicaciones de Code Engine con Terraform, evitando conflictos y minimizando el downtime.