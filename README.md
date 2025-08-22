# 🍽️ Sistema de Gestión de Platos Sobrantes

## Residencia Universitaria

Un sistema web minimalista y elegante para gestionar los platos de comida que sobran en la residencia universitaria.

---

## 🎯 Características

- **📝 Registro de platos disponibles**: Los estudiantes pueden registrar cuando no van a comer
- **🍽️ Visualización por categorías**: Almuerzo y cena separados con indicadores visuales  
- **🙋 Sistema de reclamación**: Otros estudiantes pueden reclamar los platos disponibles
- **📱 Acceso móvil**: Funciona perfectamente en dispositivos móviles
- **🔄 Reinicio automático**: Se limpia automáticamente cada día a medianoche
- **📊 Logs administrativos**: Monitoreo completo de actividad en la consola del servidor
- **🕐 Sistema de tiempo real**: Muestra estadísticas y tiempo restante del día

---

## 🛠️ Tecnologías

### Backend
- **NestJS** + TypeScript
- **SQLite** + TypeORM  
- **Cron Jobs** para limpieza automática
- **CORS** habilitado para acceso móvil

### Frontend
- **SvelteKit** + TypeScript
- **CSS personalizado** (responsive)
- **API dinámica** para acceso en red

---

## 🐧 Instalación en Arch Linux

### 📋 Prerrequisitos

```bash
# Actualizar el sistema
sudo pacman -Syu

# Instalar Node.js y npm
sudo pacman -S nodejs npm

# Verificar instalación
node --version
npm --version
```

### 📂 Configuración del Proyecto

#### 1. Clonar/Copiar el proyecto
```bash
# Crear directorio para el proyecto
mkdir -p ~/residencia-platos
cd ~/residencia-platos

# Aquí copias todos los archivos del proyecto
```

#### 2. Instalar dependencias del Backend
```bash
cd ~/residencia-platos/backend

# Instalar dependencias
npm install

# Verificar que se instaló todo correctamente
npm list --depth=0
```

#### 3. Instalar dependencias del Frontend
```bash
cd ~/residencia-platos/frontend

# Instalar dependencias
npm install

# Verificar instalación
npm list --depth=0
```

#### 4. Configurar base de datos
```bash
cd ~/residencia-platos/backend

# La base de datos SQLite se crea automáticamente al iniciar
# No necesitas configuración adicional
```

---

## 🚀 Ejecución en Producción

### 📘 Método 1: Ejecución Simple (Recomendado para pruebas)

**Terminal 1 - Backend:**
```bash
cd ~/residencia-platos/backend
npm run start:dev
```

**Terminal 2 - Frontend:**
```bash
cd ~/residencia-platos/frontend
npm run dev -- --host
```

### 🔧 Método 2: Con PM2 (Recomendado para producción)

#### Instalar PM2:
```bash
sudo npm install -g pm2
```

#### Configurar PM2:
```bash
cd ~/residencia-platos

# Crear archivo de configuración PM2
cat > ecosystem.config.js << 'EOF'
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

# Compilar backend para producción
cd backend
npm run build

# Iniciar con PM2
cd ..
pm2 start ecosystem.config.js

# Ver estado
pm2 status

# Ver logs
pm2 logs

# Guardar configuración PM2
pm2 save
pm2 startup
```

### 🖥️ Método 3: Como Servicio del Sistema (systemd)

#### Crear servicio para el backend:
```bash
sudo tee /etc/systemd/system/residencia-backend.service > /dev/null << 'EOF'
[Unit]
Description=Residencia Platos Backend
After=network.target

[Service]
Type=simple
User=tu_usuario
WorkingDirectory=/home/tu_usuario/residencia-platos/backend
ExecStart=/usr/bin/npm run start:prod
Restart=always
RestartSec=10
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF
```

#### Crear servicio para el frontend:
```bash
sudo tee /etc/systemd/system/residencia-frontend.service > /dev/null << 'EOF'
[Unit]
Description=Residencia Platos Frontend
After=network.target

[Service]
Type=simple
User=tu_usuario
WorkingDirectory=/home/tu_usuario/residencia-platos/frontend
ExecStart=/usr/bin/npm run dev -- --host
Restart=always
RestartSec=10
Environment=NODE_ENV=development

[Install]
WantedBy=multi-user.target
EOF

# Reemplaza "tu_usuario" con tu nombre de usuario real
sudo systemctl daemon-reload
sudo systemctl enable residencia-backend
sudo systemctl enable residencia-frontend
sudo systemctl start residencia-backend
sudo systemctl start residencia-frontend

# Verificar estado
sudo systemctl status residencia-backend
sudo systemctl status residencia-frontend
```

---

## 🌐 Configuración de Red

### 🔍 Encontrar tu IP:
```bash
# Método 1
ip route | grep default
ip addr show

# Método 2
hostname -I

# Método 3
ifconfig
```

### 🔥 Configurar Firewall (si está activo):
```bash
# Si usas ufw
sudo ufw allow 3000
sudo ufw allow 5173

# Si usas iptables
sudo iptables -A INPUT -p tcp --dport 3000 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 5173 -j ACCEPT

# Si usas firewalld
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --permanent --add-port=5173/tcp
sudo firewall-cmd --reload
```

---

## 📱 Acceso desde Dispositivos

### 💻 Acceso Local:
- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:3000

### 📱 Acceso desde Móvil/Otros Dispositivos:
```bash
# Tu IP será algo como: 192.168.1.100, 192.168.0.100, etc.
# Frontend: http://TU-IP:5173
# Backend API: http://TU-IP:3000
```

#### Ejemplo:
- Frontend: `http://192.168.1.100:5173`
- Backend: `http://192.168.1.100:3000`

---

## 📊 Logs Administrativos

El sistema muestra logs detallados en la consola del servidor:

### 📝 Tipos de Logs:
- **🍽️ Registro de platos**: Cuando un estudiante registra comida disponible
- **🙋 Reclamos de platos**: Cuando alguien reclama un plato
- **📊 Estadísticas horarias**: Resumen automático cada hora
- **🌙 Reinicio diario**: Limpieza automática a medianoche
- **🐛 Debug**: Información detallada de errores

### 👀 Ejemplo de Logs:
```
🍽️ ═══════════════════════════════════════════════════════
🚀 SISTEMA DE PLATOS - RESIDENCIA UNIVERSITARIA
🍽️ ═══════════════════════════════════════════════════════
🌐 Servidor funcionando en:
   📍 Local: http://localhost:3000
   📍 Red: http://192.168.1.100:3000
📱 Accesible desde dispositivos móviles en la misma red
👨‍💻 Logs administrativos: ACTIVADOS
🔄 Reinicio automático: 00:00 cada día
📊 Reportes horarios: ACTIVADOS

📝 [REGISTRO] 🍽️ ALMUERZO
   👤 Estudiante: Juan Pérez
   🕐 Hora: 12:30:45
   🆔 ID: 1

🍴 [RECLAMADO] 🍽️ ALMUERZO
   👤 Dueño original: Juan Pérez
   🙋 Reclamado por: María González
   🕐 Hora: 13:15:22
   🆔 ID: 1
```

---

## 🔧 Comandos Útiles

### 📦 Gestión con PM2:
```bash
# Ver estado
pm2 status

# Ver logs en tiempo real
pm2 logs

# Reiniciar servicios
pm2 restart all

# Parar servicios
pm2 stop all

# Eliminar servicios
pm2 delete all
```

### 🖥️ Gestión con systemd:
```bash
# Ver estado
sudo systemctl status residencia-backend
sudo systemctl status residencia-frontend

# Ver logs
sudo journalctl -u residencia-backend -f
sudo journalctl -u residencia-frontend -f

# Reiniciar
sudo systemctl restart residencia-backend
sudo systemctl restart residencia-frontend

# Parar
sudo systemctl stop residencia-backend
sudo systemctl stop residencia-frontend
```

### 🔍 Verificar puertos:
```bash
# Ver qué está corriendo en los puertos
sudo netstat -tlnp | grep :3000
sudo netstat -tlnp | grep :5173

# O con ss
ss -tlnp | grep :3000
ss -tlnp | grep :5173
```

---

## ⚠️ Solución de Problemas

### 🐛 Problemas Comunes:

#### 1. Error "EADDRINUSE" (Puerto ocupado):
```bash
# Encontrar qué proceso usa el puerto
sudo lsof -i :3000
sudo lsof -i :5173

# Matar el proceso (reemplaza PID)
kill -9 PID
```

#### 2. No se puede acceder desde móvil:
```bash
# Verificar firewall
sudo ufw status
sudo iptables -L

# Verificar que el servidor esté escuchando en todas las interfaces
netstat -tlnp | grep :5173
# Debe mostrar 0.0.0.0:5173, no 127.0.0.1:5173
```

#### 3. Base de datos no se crea:
```bash
# Verificar permisos en el directorio del proyecto
ls -la ~/residencia-platos/backend/
chmod -R 755 ~/residencia-platos/
```

#### 4. Dependencias faltantes:
```bash
# Reinstalar dependencias
cd ~/residencia-platos/backend
rm -rf node_modules package-lock.json
npm install

cd ~/residencia-platos/frontend
rm -rf node_modules package-lock.json
npm install
```

---

## 🎯 Resumen de Configuración Rápida

```bash
# 1. Instalar Node.js
sudo pacman -S nodejs npm

# 2. Ir al directorio del proyecto
cd ~/residencia-platos

# 3. Instalar dependencias
cd backend && npm install
cd ../frontend && npm install

# 4. Encontrar tu IP
ip route | grep default

# 5. Ejecutar (dos terminales)
# Terminal 1:
cd ~/residencia-platos/backend && npm run start:dev

# Terminal 2:
cd ~/residencia-platos/frontend && npm run dev -- --host

# 6. Acceder desde cualquier dispositivo:
# http://TU-IP:5173
```

---

## 🎉 Información Final

- **Desarrollado por**: Javier
- **Fecha**: Agosto 2025
- **Sistema**: Residencia Universitaria - Gestión de Platos Sobrantes

### ¡El sistema está listo para producción! 🚀

---

## 📞 Notas Adicionales

- Los logs aparecen en tiempo real en la consola del servidor
- El sistema se reinicia automáticamente cada día a medianoche
- Funciona perfectamente en dispositivos móviles
- No requiere autenticación (diseñado para uso interno)
- Base de datos SQLite se crea automáticamente
