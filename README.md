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

## � Configuración como Servidor en Windows

### 📋 Prerrequisitos

Ya tienes todo instalado, pero para verificar:

```powershell
# Verificar Node.js y npm
node --version
npm --version

# Si no los tienes, descarga Node.js desde: https://nodejs.org/
```

### 🔧 Configuración para Laptop como Servidor

#### 1. Configurar Windows para funcionar con tapa cerrada
```powershell
# Abrir configuración de energía
powercfg.cpl

# O usar GUI: Panel de Control > Opciones de energía > Elegir el comportamiento del cierre de tapa
# Configurar: "Al cerrar la tapa: No hacer nada"
```

#### 2. Configurar para que no entre en suspensión
```powershell
# Configurar para que nunca entre en suspensión
powercfg -change -standby-timeout-ac 0
powercfg -change -standby-timeout-dc 0
powercfg -change -hibernate-timeout-ac 0
powercfg -change -hibernate-timeout-dc 0

# Configurar pantalla (opcional - puede apagarse)
powercfg -change -monitor-timeout-ac 10
powercfg -change -monitor-timeout-dc 10
```

#### 3. Instalar dependencias (si no están instaladas)
```powershell
# En el directorio backend
cd backend
npm install

# En el directorio frontend  
cd ..\frontend
npm install
```

---

## 🚀 Ejecutar como Servidor Windows

### 📘 Método 1: Scripts de PowerShell (Recomendado)

#### Configuración inicial automática:
```powershell
# Ejecutar como ADMINISTRADOR (solo la primera vez)
.\setup-windows-server.ps1
```

#### Iniciar el servidor:
```powershell
# Opción 1: Script completo
.\start-server.ps1

# Opción 2: Script simple (doble clic)
# Doble clic en: start-server.bat
```

### 🔧 Método 2: Como Servicio de Windows con PM2

#### Instalar PM2 para Windows:
```powershell
# Instalar PM2 globalmente
npm install -g pm2
npm install -g pm2-windows-startup

# Configurar PM2 para inicio automático
pm2-startup install
```

#### Configurar PM2:
```powershell
# El archivo ecosystem.config.js ya está creado
# Iniciar con PM2
pm2 start ecosystem.config.js
pm2 save
```

### 🖥️ Método 3: Manual (dos terminales)

#### Terminal 1 - Backend:
```powershell
cd backend
npm run start:dev
```

#### Terminal 2 - Frontend:
```powershell
cd frontend
npm run dev -- --host
```

---

## 🌐 Configuración de Red Windows

### 🔍 Encontrar tu IP:
```powershell
# Método 1 - Simple
ipconfig | findstr "IPv4"

# Método 2 - Más específico
Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Wi-Fi*" | Select-Object IPAddress

# Método 3 - PowerShell avanzado
(Get-NetIPConfiguration | Where-Object {$_.IPv4DefaultGateway -ne $null}).IPv4Address.IPAddress
```

### 🔥 Configurar Firewall Windows:
```powershell
# Permitir puertos en el firewall (ejecutar como administrador)
New-NetFirewallRule -DisplayName "Residencia Backend" -Direction Inbound -Protocol TCP -LocalPort 3000
New-NetFirewallRule -DisplayName "Residencia Frontend" -Direction Inbound -Protocol TCP -LocalPort 5173

# O usar GUI: Panel de Control > Sistema y Seguridad > Firewall de Windows Defender
# Configuración avanzada > Reglas de entrada > Nueva regla > Puerto > TCP > 3000,5173
```

### 💤 Configurar para Laptop cerrada:
```powershell
# Configuración de energía para laptop cerrada
# Panel de Control > Opciones de energía > Elegir el comportamiento del cierre de tapa
# Configurar: "Al cerrar la tapa: No hacer nada" (tanto con batería como conectado)

# También puedes usar:
powercfg -setacvalueindex scheme_current 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
powercfg -setdcvalueindex scheme_current 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
powercfg -setactive scheme_current
```

---

##  Acceso desde Dispositivos

### 💻 Acceso Local:
- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:3000

### 📱 Acceso desde Móvil/Otros Dispositivos:
```powershell
# Tu IP será algo como: 192.168.1.100, 192.168.0.100, etc.
# Frontend: http://TU-IP:5173
# Backend API: http://TU-IP:3000
```

#### Ejemplo:
- Frontend: `http://192.168.1.100:5173`
- Backend: `http://192.168.1.100:3000`

---

## 🛠️ Configuración del Proyecto

### 📂 1. Instalación del Proyecto
```powershell
# Navegar al directorio del proyecto
cd f:\CODING\Residencia\residencia-platos

# Instalar dependencias del Backend
cd .\backend
npm install

# Instalar dependencias del Frontend  
cd ..\frontend
npm install
```

### 📦 2. Configuración de Scripts de Automatización
El proyecto incluye scripts para automatizar la configuración y ejecución:

- `setup-windows-server.ps1` - Configuración automática del servidor
- `start-server.ps1` - Inicio automatizado con detección de IP
- `start-server.bat` - Inicio simple con doble clic

### 🚀 3. Configuración Automática del Servidor
```powershell
# Ejecutar el script de configuración (ejecutar como Administrador)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\setup-windows-server.ps1
```

Este script configurará automáticamente:
- Configuración de energía para mantener la laptop activa
- Reglas de firewall para los puertos 3000 y 5173  
- Configuración de red para acceso externo

---

## 🚀 Ejecución del Servidor

### 🎯 Método 1: Script Automatizado (Recomendado)
```powershell
# Ejecutar el script de inicio
.\start-server.ps1
```

### 📱 Método 2: Inicio Simple
```powershell
# Doble clic en el archivo
start-server.bat
```

### ⚙️ Método 3: Manual
```powershell
# Terminal 1 - Backend
cd .\backend
npm run start:dev

# Terminal 2 - Frontend  
cd .\frontend
npm run dev -- --host 0.0.0.0
```

---

## 🌐 Configuración de Red

### 🔍 Encontrar tu IP en Windows:
```powershell
# Obtener IP de red local
ipconfig | findstr "IPv4"

# O más detallado
Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -like "192.168.*"}
```

### 🔥 Configuración de Firewall:
```powershell
# Los scripts automáticos ya configuran esto, pero manualmente:
New-NetFirewallRule -DisplayName "Residencia Backend" -Direction Inbound -Protocol TCP -LocalPort 3000 -Action Allow
New-NetFirewallRule -DisplayName "Residencia Frontend" -Direction Inbound -Protocol TCP -LocalPort 5173 -Action Allow
```

### ⚡ Configuración de Energía:
```powershell
# Configurar para mantener laptop activa (incluido en scripts)
powercfg -change -monitor-timeout-ac 0
powercfg -change -disk-timeout-ac 0  
powercfg -change -standby-timeout-ac 0
powercfg -change -hibernate-timeout-ac 0
```

---

## 📊 Funciones del Sistema

### 🕛 Reset Automático:
- **Horario**: Todos los días a las 00:00 (medianoche)
- **Función**: Limpia automáticamente todos los platos del día anterior
- **Logs**: Se registra la actividad en la consola del servidor

### 📈 Estadísticas Automáticas:
- **Frecuencia**: Cada hora en punto
- **Información**: Total de platos, platos reclamados, disponibles
- **Visualización**: Solo en consola del servidor (para administración)

### 🗂️ Gestión de Respaldos:
- **Frecuencia**: Cada 6 horas
- **Función**: Limpia respaldos antiguos automáticamente
- **Retención**: Mantiene datos de utilidad para el sistema

---

## 🔧 Administración

### 📋 Ver Logs en Tiempo Real:
Los logs administrativos se muestran directamente en la consola donde ejecutes el servidor. Incluyen:
- Registro de platos agregados
- Registro de platos reclamados  
- Estadísticas por hora
- Proceso de limpieza automática

### 🔄 Reiniciar el Sistema:
```powershell
# Detener el servidor (Ctrl+C en ambas terminales)
# Luego ejecutar nuevamente:
.\start-server.ps1
```

### 💾 Backup Manual de la Base de Datos:
```powershell
# La base de datos está en: .\backend\database.sqlite
# Para hacer backup:
copy .\backend\database.sqlite .\backup-$(Get-Date -Format "yyyy-MM-dd-HH-mm").sqlite
```

---

## 📞 Soporte

### 🐛 Problemas Comunes:

**Error de puerto ocupado:**
```powershell
# Verificar qué está usando el puerto
netstat -ano | findstr :3000
netstat -ano | findstr :5173

# Terminar proceso si es necesario
taskkill /PID [número_de_proceso] /F
```

**No se puede acceder desde móvil:**
1. Verificar que el firewall esté configurado
2. Confirmar que estás en la misma red WiFi
3. Usar la IP correcta mostrada por el script

**El script no se ejecuta:**
```powershell
# Configurar política de ejecución
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 📝 Estructura del Proyecto

```
residencia-platos/
├── backend/                 # Servidor NestJS
│   ├── src/                # Código fuente
│   ├── database.sqlite     # Base de datos SQLite
│   └── package.json        # Dependencias backend
├── frontend/               # Cliente SvelteKit  
│   ├── src/               # Código fuente frontend
│   └── package.json       # Dependencias frontend
├── setup-windows-server.ps1   # Script de configuración
├── start-server.ps1           # Script de inicio automático
├── start-server.bat          # Script de inicio simple
└── README.md                 # Este archivo
```

---

## 🎯 Uso del Sistema

1. **Agregar platos**: Los usuarios pueden agregar platos con descripción, tipo de comida (almuerzo/cena)
2. **Reclamar platos**: Otros usuarios pueden reclamar platos disponibles ingresando su nombre
3. **Ver estado**: El panel muestra el progreso del día con contadores automáticos
4. **Acceso móvil**: Funciona desde cualquier dispositivo en la misma red WiFi

¡El sistema está listo para funcionar 24/7 en tu laptop con Windows! 🚀

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
