#!/bin/bash

# 🍽️ Script de Instalación Automática - Sistema de Platos Residencia
# Para Arch Linux

set -e  # Salir si hay errores

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${PURPLE}"
echo "🍽️ ═══════════════════════════════════════════════════════"
echo "   INSTALADOR AUTOMÁTICO - SISTEMA DE PLATOS"
echo "   Residencia Universitaria - Arch Linux"
echo "🍽️ ═══════════════════════════════════════════════════════"
echo -e "${NC}"

# Función para imprimir pasos
print_step() {
    echo -e "${BLUE}[PASO $1]${NC} $2"
}

# Función para verificar éxito
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Función para advertencias
print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Función para errores
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 1. Verificar si estamos en Arch Linux
print_step "1" "Verificando sistema operativo..."
if ! command -v pacman &> /dev/null; then
    print_error "Este script está diseñado para Arch Linux (pacman no encontrado)"
    exit 1
fi
print_success "Sistema Arch Linux detectado"

# 2. Actualizar el sistema
print_step "2" "Actualizando el sistema..."
sudo pacman -Syu --noconfirm
print_success "Sistema actualizado"

# 3. Instalar Node.js y npm
print_step "3" "Instalando Node.js y npm..."
sudo pacman -S --noconfirm nodejs npm
print_success "Node.js $(node --version) y npm $(npm --version) instalados"

# 4. Verificar estructura del proyecto
print_step "4" "Verificando estructura del proyecto..."
if [ ! -d "backend" ] || [ ! -d "frontend" ]; then
    print_error "Este script debe ejecutarse desde el directorio raíz del proyecto"
    print_error "Asegúrate de que existan las carpetas 'backend' y 'frontend'"
    exit 1
fi
print_success "Estructura del proyecto verificada"

# 5. Instalar dependencias del backend
print_step "5" "Instalando dependencias del backend..."
cd backend
npm install
print_success "Dependencias del backend instaladas"

# 6. Instalar dependencias del frontend
print_step "6" "Instalando dependencias del frontend..."
cd ../frontend
npm install
print_success "Dependencias del frontend instaladas"

# 7. Compilar backend para producción
print_step "7" "Compilando backend para producción..."
cd ../backend
npm run build
print_success "Backend compilado"

# 8. Obtener IP local
print_step "8" "Detectando IP local..."
LOCAL_IP=$(ip route get 1.1.1.1 | awk '{print $7; exit}')
print_success "IP local detectada: $LOCAL_IP"

# 9. Configurar firewall si está activo
print_step "9" "Configurando firewall..."
if command -v ufw &> /dev/null && ufw status | grep -q "Status: active"; then
    print_warning "UFW detectado y activo, configurando puertos..."
    sudo ufw allow 3000/tcp comment "Residencia Backend"
    sudo ufw allow 5173/tcp comment "Residencia Frontend"
    print_success "Puertos configurados en UFW"
elif command -v firewall-cmd &> /dev/null; then
    print_warning "Firewalld detectado, configurando puertos..."
    sudo firewall-cmd --permanent --add-port=3000/tcp
    sudo firewall-cmd --permanent --add-port=5173/tcp
    sudo firewall-cmd --reload
    print_success "Puertos configurados en firewalld"
else
    print_warning "No se detectó firewall activo o no es compatible"
fi

# 10. Preguntar método de ejecución
echo
echo -e "${YELLOW}¿Cómo quieres ejecutar el sistema?${NC}"
echo "1) 📘 Ejecución simple (dos terminales)"
echo "2) 🔧 Con PM2 (proceso en background)"
echo "3) 🖥️  Como servicio systemd (inicio automático)"
echo "4) ⏭️  Solo instalar (ejecutar manualmente después)"

read -p "Selecciona una opción (1-4): " option

case $option in
    1)
        print_step "10" "Configurando ejecución simple..."
        cd ..
        echo
        print_success "¡Instalación completada!"
        echo
        echo -e "${GREEN}🚀 Para ejecutar el sistema:${NC}"
        echo -e "${BLUE}Terminal 1:${NC} cd $(pwd)/backend && npm run start:dev"
        echo -e "${BLUE}Terminal 2:${NC} cd $(pwd)/frontend && npm run dev -- --host"
        echo
        echo -e "${GREEN}🌐 URLs de acceso:${NC}"
        echo -e "${BLUE}Local:${NC} http://localhost:5173"
        echo -e "${BLUE}Red:${NC} http://$LOCAL_IP:5173"
        ;;
    
    2)
        print_step "10" "Instalando PM2..."
        sudo npm install -g pm2
        
        cd ..
        cat > ecosystem.config.js << EOF
module.exports = {
  apps: [
    {
      name: 'residencia-backend',
      cwd: './backend',
      script: 'npm',
      args: 'run start:prod',
      env: {
        NODE_ENV: 'production'
      }
    },
    {
      name: 'residencia-frontend',
      cwd: './frontend',
      script: 'npm',
      args: 'run dev -- --host',
      env: {
        NODE_ENV: 'development'
      }
    }
  ]
};
EOF
        
        print_step "11" "Iniciando servicios con PM2..."
        pm2 start ecosystem.config.js
        pm2 save
        pm2 startup
        
        print_success "¡Sistema ejecutándose con PM2!"
        echo
        echo -e "${GREEN}🔧 Comandos PM2 útiles:${NC}"
        echo -e "${BLUE}Ver estado:${NC} pm2 status"
        echo -e "${BLUE}Ver logs:${NC} pm2 logs"
        echo -e "${BLUE}Reiniciar:${NC} pm2 restart all"
        echo -e "${BLUE}Parar:${NC} pm2 stop all"
        echo
        echo -e "${GREEN}🌐 URLs de acceso:${NC}"
        echo -e "${BLUE}Local:${NC} http://localhost:5173"
        echo -e "${BLUE}Red:${NC} http://$LOCAL_IP:5173"
        ;;
    
    3)
        print_step "10" "Configurando servicios systemd..."
        USERNAME=$(whoami)
        PROJECT_PATH=$(pwd)
        
        # Crear servicio backend
        sudo tee /etc/systemd/system/residencia-backend.service > /dev/null << EOF
[Unit]
Description=Residencia Platos Backend
After=network.target

[Service]
Type=simple
User=$USERNAME
WorkingDirectory=$PROJECT_PATH/backend
ExecStart=/usr/bin/npm run start:prod
Restart=always
RestartSec=10
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF

        # Crear servicio frontend
        sudo tee /etc/systemd/system/residencia-frontend.service > /dev/null << EOF
[Unit]
Description=Residencia Platos Frontend
After=network.target

[Service]
Type=simple
User=$USERNAME
WorkingDirectory=$PROJECT_PATH/frontend
ExecStart=/usr/bin/npm run dev -- --host
Restart=always
RestartSec=10
Environment=NODE_ENV=development

[Install]
WantedBy=multi-user.target
EOF

        print_step "11" "Habilitando e iniciando servicios..."
        sudo systemctl daemon-reload
        sudo systemctl enable residencia-backend
        sudo systemctl enable residencia-frontend
        sudo systemctl start residencia-backend
        sudo systemctl start residencia-frontend
        
        sleep 3
        
        print_success "¡Sistema configurado como servicio!"
        echo
        echo -e "${GREEN}🖥️  Comandos systemd útiles:${NC}"
        echo -e "${BLUE}Ver estado:${NC} sudo systemctl status residencia-backend"
        echo -e "${BLUE}Ver logs:${NC} sudo journalctl -u residencia-backend -f"
        echo -e "${BLUE}Reiniciar:${NC} sudo systemctl restart residencia-backend"
        echo -e "${BLUE}Parar:${NC} sudo systemctl stop residencia-backend"
        echo
        echo -e "${GREEN}🌐 URLs de acceso:${NC}"
        echo -e "${BLUE}Local:${NC} http://localhost:5173"
        echo -e "${BLUE}Red:${NC} http://$LOCAL_IP:5173"
        ;;
    
    4)
        print_step "10" "Instalación completada sin ejecución automática"
        cd ..
        print_success "¡Instalación completada!"
        echo
        echo -e "${GREEN}📋 Para ejecutar manualmente:${NC}"
        echo -e "${BLUE}Backend:${NC} cd $(pwd)/backend && npm run start:dev"
        echo -e "${BLUE}Frontend:${NC} cd $(pwd)/frontend && npm run dev -- --host"
        echo
        echo -e "${GREEN}🌐 URLs de acceso:${NC}"
        echo -e "${BLUE}Local:${NC} http://localhost:5173"
        echo -e "${BLUE}Red:${NC} http://$LOCAL_IP:5173"
        ;;
    
    *)
        print_error "Opción inválida"
        exit 1
        ;;
esac

echo
echo -e "${PURPLE}"
echo "🍽️ ═══════════════════════════════════════════════════════"
echo "   ¡INSTALACIÓN COMPLETADA EXITOSAMENTE!"
echo "   Sistema de Platos - Residencia Universitaria"
echo "🍽️ ═══════════════════════════════════════════════════════"
echo -e "${NC}"

echo -e "${GREEN}📱 Para acceder desde móvil:${NC}"
echo -e "   1. Conecta tu móvil a la misma red WiFi"
echo -e "   2. Abre el navegador y ve a: ${BLUE}http://$LOCAL_IP:5173${NC}"
echo
echo -e "${GREEN}👨‍💻 Los logs administrativos aparecerán en la consola del servidor${NC}"
echo -e "${GREEN}🔄 El sistema se reinicia automáticamente cada día a medianoche${NC}"
echo
echo -e "${YELLOW}💡 Tip: Guarda esta IP ($LOCAL_IP) para acceso desde otros dispositivos${NC}"
