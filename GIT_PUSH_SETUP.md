# Configurar Git Push con GitHub Token

## 🔐 Problema

Git necesita autenticación para hacer push. GitHub ya no acepta contraseñas, necesitas un Personal Access Token (PAT).

## ✅ Solución Rápida

### Opción 1: GitHub CLI (Recomendado)

```bash
# 1. Instalar GitHub CLI si no lo tienes
brew install gh

# 2. Autenticar
gh auth login

# 3. Selecciona:
# - GitHub.com
# - HTTPS
# - Yes (authenticate Git)
# - Login with a web browser

# 4. Hacer push
git push origin main
```

### Opción 2: Personal Access Token Manual

#### Paso 1: Crear Token en GitHub

1. Ve a: https://github.com/settings/tokens
2. Click **"Generate new token"** → **"Generate new token (classic)"**
3. Configura:
   - **Note**: "Git Push from Terminal"
   - **Expiration**: 90 days (o lo que prefieras)
   - **Scopes**: Selecciona:
     - ✅ `repo` (todos los sub-items)
     - ✅ `workflow`
4. Click **"Generate token"**
5. **COPIA EL TOKEN** (solo se muestra una vez)

#### Paso 2: Configurar Git Credential Helper

```bash
# Configurar credential helper
git config --global credential.helper osxkeychain

# Hacer push (te pedirá credenciales)
cd /Users/stamayo/Library/CloudStorage/OneDrive-IBM/bob
git push origin main

# Cuando te pida:
# Username: SantiagoT21
# Password: [PEGA TU TOKEN AQUÍ]
```

El token se guardará en el keychain de macOS.

### Opción 3: Usar VS Code con GitHub Extension

1. **Instala la extensión** "GitHub Pull Requests and Issues"
2. **Click en el icono de cuenta** (abajo izquierda)
3. **"Sign in to sync settings"** → **"Sign in with GitHub"**
4. **Autoriza** en el navegador
5. Ahora puedes hacer push desde VS Code UI

### Opción 4: SSH Key (Alternativa)

Si prefieres SSH en lugar de HTTPS:

```bash
# 1. Generar SSH key
ssh-keygen -t ed25519 -C "stamayo@co.ibm.com"
# Presiona Enter para ubicación default
# Presiona Enter para sin passphrase (o agrega una)

# 2. Copiar la key pública
cat ~/.ssh/id_ed25519.pub

# 3. Agregar a GitHub
# Ve a: https://github.com/settings/keys
# Click "New SSH key"
# Pega la key pública

# 4. Cambiar remote a SSH
git remote set-url origin git@github.com:SantiagoT21/ibm-cloud-info.git

# 5. Hacer push
git push origin main
```

## 🚀 Después de Configurar

Una vez configurado, simplemente:

```bash
git push origin main
```

Y el workflow de PowerVS se ejecutará automáticamente.

## 📊 Verificar Configuración

```bash
# Ver remote actual
git remote -v

# Ver configuración de credentials
git config --list | grep credential

# Test de autenticación (con gh cli)
gh auth status
```

## 💡 Recomendación

**Usa GitHub CLI (`gh`)** - Es la forma más fácil y segura:

```bash
brew install gh
gh auth login
git push origin main
```

## 🔒 Seguridad

- ✅ Nunca compartas tu token
- ✅ Usa tokens con permisos mínimos necesarios
- ✅ Configura expiración de tokens
- ✅ Revoca tokens viejos regularmente

## ❓ Si Sigues Teniendo Problemas

1. **Verifica que el token tenga permisos** de `repo` y `workflow`
2. **Asegúrate de copiar el token completo** (empieza con `ghp_`)
3. **Limpia credenciales viejas**:
   ```bash
   git credential-osxkeychain erase
   host=github.com
   protocol=https
   [Presiona Enter dos veces]
   ```
4. **Intenta de nuevo** el push

---

**Una vez configurado, el push funcionará y PowerVS se desplegará automáticamente!** 🚀