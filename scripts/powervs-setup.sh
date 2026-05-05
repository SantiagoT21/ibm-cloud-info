#!/bin/bash
#
# PowerVS Instance Setup Script
# This script is executed via cloud-init/user-data when the instance boots
# It installs and configures nginx to serve the IBM Cloud Info application
#

set -e  # Exit on any error

# Variables
APP_PORT=${app_port}
WEB_ROOT="/usr/share/nginx/html"
LOG_FILE="/var/log/powervs-setup.log"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "=== Starting PowerVS Instance Setup ==="
log "Application Port: $APP_PORT"

# Update system
log "Updating system packages..."
dnf update -y >> "$LOG_FILE" 2>&1

# Install required packages
log "Installing nginx and required tools..."
dnf install -y nginx firewalld >> "$LOG_FILE" 2>&1

# Create web content
log "Creating web application content..."
cat > "$WEB_ROOT/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>IBM Cloud - Soluciones Empresariales</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'IBM Plex Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            line-height: 1.6;
            color: #161616;
            background: linear-gradient(135deg, #0f62fe 0%, #001d6c 100%);
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }

        header {
            background: rgba(255, 255, 255, 0.98);
            padding: 2rem;
            border-radius: 8px;
            margin-bottom: 2rem;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }

        h1 {
            color: #0f62fe;
            font-size: 2.5rem;
            margin-bottom: 0.5rem;
            font-weight: 600;
        }

        .subtitle {
            color: #525252;
            font-size: 1.2rem;
            margin-bottom: 1rem;
        }

        .deployment-badge {
            display: inline-block;
            background: linear-gradient(135deg, #8a3ffc 0%, #0f62fe 100%);
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-size: 0.9rem;
            font-weight: 600;
            margin-top: 1rem;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .card {
            background: white;
            padding: 1.5rem;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.15);
        }

        .card-icon {
            font-size: 2.5rem;
            margin-bottom: 1rem;
        }

        .card h3 {
            color: #0f62fe;
            margin-bottom: 0.5rem;
            font-size: 1.3rem;
        }

        .card p {
            color: #525252;
            font-size: 0.95rem;
        }

        .card ul {
            margin-top: 0.5rem;
            padding-left: 1.2rem;
            color: #525252;
        }

        .card li {
            margin-bottom: 0.3rem;
        }

        footer {
            background: rgba(255, 255, 255, 0.98);
            padding: 1.5rem;
            border-radius: 8px;
            text-align: center;
            color: #525252;
        }

        .tech-stack {
            display: flex;
            justify-content: center;
            gap: 1rem;
            flex-wrap: wrap;
            margin-top: 1rem;
        }

        .tech-badge {
            background: #f4f4f4;
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-size: 0.85rem;
            color: #161616;
        }

        @media (max-width: 768px) {
            h1 {
                font-size: 2rem;
            }
            
            .grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>🚀 IBM Cloud - Soluciones Empresariales</h1>
            <p class="subtitle">Plataforma de nube híbrida líder para empresas modernas</p>
            <p class="hero-description">
                Descubre cómo IBM Cloud impulsa la transformación digital con IA, seguridad empresarial 
                y escalabilidad global para tu negocio.
            </p>
            <div class="deployment-badge">
                ⚡ Desplegado en IBM PowerVS - Arquitectura POWER
            </div>
        </header>

        <div class="grid">
            <div class="card">
                <div class="card-icon">🔒</div>
                <h3>Seguridad Empresarial</h3>
                <p>Protección de nivel empresarial con certificaciones globales</p>
                <ul>
                    <li>Certificaciones ISO 27001, SOC 2, HIPAA</li>
                    <li>Cifrado end-to-end</li>
                    <li>Identity and Access Management (IAM)</li>
                    <li>Cumplimiento normativo global</li>
                </ul>
            </div>

            <div class="card">
                <div class="card-icon">📈</div>
                <h3>Escalabilidad Global</h3>
                <p>Infraestructura distribuida en todo el mundo</p>
                <ul>
                    <li>60+ zonas de disponibilidad</li>
                    <li>Auto-scaling inteligente</li>
                    <li>Balanceo de carga global</li>
                    <li>CDN integrado</li>
                </ul>
            </div>

            <div class="card">
                <div class="card-icon">🤖</div>
                <h3>IA y Machine Learning</h3>
                <p>Herramientas avanzadas de inteligencia artificial</p>
                <ul>
                    <li>Watson AI y Watson Studio</li>
                    <li>AutoML y MLOps</li>
                    <li>Procesamiento de lenguaje natural</li>
                    <li>Computer Vision</li>
                </ul>
            </div>

            <div class="card">
                <div class="card-icon">💰</div>
                <h3>Optimización de Costos</h3>
                <p>Modelos de precios flexibles y transparentes</p>
                <ul>
                    <li>Pay-as-you-go</li>
                    <li>Reservas con descuento</li>
                    <li>Herramientas de gestión de costos</li>
                    <li>Calculadora de precios</li>
                </ul>
            </div>

            <div class="card">
                <div class="card-icon">🔄</div>
                <h3>Nube Híbrida</h3>
                <p>Integración perfecta entre on-premise y cloud</p>
                <ul>
                    <li>Red Hat OpenShift</li>
                    <li>Kubernetes gestionado</li>
                    <li>Conectividad Direct Link</li>
                    <li>Migración simplificada</li>
                </ul>
            </div>

            <div class="card">
                <div class="card-icon">⚡</div>
                <h3>PowerVS - POWER Architecture</h3>
                <p>Rendimiento empresarial en arquitectura POWER</p>
                <ul>
                    <li>Procesadores IBM POWER9/POWER10</li>
                    <li>Alto rendimiento para cargas críticas</li>
                    <li>Compatibilidad AIX e IBM i</li>
                    <li>Migración de workloads legacy</li>
                </ul>
            </div>
        </div>

        <footer>
            <p><strong>Tecnologías utilizadas en este despliegue:</strong></p>
            <div class="tech-stack">
                <span class="tech-badge">IBM PowerVS</span>
                <span class="tech-badge">Rocky Linux 9</span>
                <span class="tech-badge">Nginx</span>
                <span class="tech-badge">Terraform</span>
                <span class="tech-badge">POWER Architecture</span>
            </div>
            <p style="margin-top: 1rem; font-size: 0.9rem;">
                © 2024 IBM Cloud - Infraestructura desplegada con Terraform en PowerVS
            </p>
        </footer>
    </div>
</body>
</html>
EOF

# Set proper permissions
log "Setting file permissions..."
chown -R nginx:nginx "$WEB_ROOT"
chmod -R 755 "$WEB_ROOT"

# Configure nginx
log "Configuring nginx..."
cat > /etc/nginx/nginx.conf << 'NGINX_EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  _;
        root         /usr/share/nginx/html;

        location / {
            index index.html;
        }

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
}
NGINX_EOF

# Configure SELinux for nginx
log "Configuring SELinux..."
setsebool -P httpd_can_network_connect 1 >> "$LOG_FILE" 2>&1 || true
restorecon -R "$WEB_ROOT" >> "$LOG_FILE" 2>&1 || true

# Configure firewall
log "Configuring firewall..."
systemctl enable firewalld >> "$LOG_FILE" 2>&1
systemctl start firewalld >> "$LOG_FILE" 2>&1

# Allow HTTP, HTTPS, and SSH
firewall-cmd --permanent --add-service=http >> "$LOG_FILE" 2>&1
firewall-cmd --permanent --add-service=https >> "$LOG_FILE" 2>&1
firewall-cmd --permanent --add-service=ssh >> "$LOG_FILE" 2>&1
firewall-cmd --reload >> "$LOG_FILE" 2>&1

# Enable and start nginx
log "Starting nginx service..."
systemctl enable nginx >> "$LOG_FILE" 2>&1
systemctl start nginx >> "$LOG_FILE" 2>&1

# Verify nginx is running
if systemctl is-active --quiet nginx; then
    log "✓ Nginx is running successfully"
else
    log "✗ ERROR: Nginx failed to start"
    systemctl status nginx >> "$LOG_FILE" 2>&1
    exit 1
fi

# Display status
log "=== Setup Complete ==="
log "Application is now available on port $APP_PORT"
log "Nginx status: $(systemctl is-active nginx)"
log "Firewall status: $(systemctl is-active firewalld)"

# Create a status file
cat > /root/setup-status.txt << STATUS_EOF
PowerVS Instance Setup - Completed Successfully
================================================
Date: $(date)
Application Port: $APP_PORT
Nginx Status: $(systemctl is-active nginx)
Firewall Status: $(systemctl is-active firewalld)

Services:
- nginx: $(systemctl is-enabled nginx)
- firewalld: $(systemctl is-enabled firewalld)

Firewall Rules:
$(firewall-cmd --list-all)

Log file: $LOG_FILE
STATUS_EOF

log "Setup status saved to /root/setup-status.txt"
log "=== PowerVS Instance Setup Completed Successfully ==="

exit 0

# Made with Bob
