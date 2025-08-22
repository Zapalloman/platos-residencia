# 🍽️ Sistema de Gestión de Platos Sobrantes - Residencia Universitaria

Un sistema web minimalista y elegante para gestionar los platos de comida que sobran en la residencia universitaria.

## 🎯 Características

- **📝 Registro de platos disponibles**: Los estudiantes pueden registrar cuando no van a comer
- **🍽️ Visualización por categorías**: Almuerzo y cena separados con indicadores visuales
- **🙋 Sistema de reclamación**: Otros estudiantes pueden reclamar los platos disponibles
- **📱 Acceso móvil**: Funciona perfectamente en dispositivos móviles
- **🔄 Reinicio automático**: Se limpia automáticamente cada día a medianoche
- **📊 Logs administrativos**: Monitoreo completo de actividad en la consola del servidor
- **🕐 Sistema de tiempo real**: Muestra estadísticas y tiempo restante del día

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

# 🐧 Instalación en Arch Linux

## 📋 Prerrequisitos

```bash
# Actualizar el sistema
sudo pacman -Syu

# Instalar Node.js y npm
sudo pacman -S nodejs npm

# Verificar instalación
node --version
npm --version
```

## 📂 Configuración del Proyecto

### 1. **Clonar/Copiar el proyecto**
```bash
# Crear directorio para el proyecto
mkdir -p ~/residencia-platos
cd ~/residencia-platos

# Aquí copias todos los archivos del proyecto
```

### 2. **Instalar dependencias del Backend**
```bash
cd ~/residencia-platos/backend

# Instalar dependencias
npm install

# Verificar que se instaló todo correctamente
npm list --depth=0
```

### 3. **Instalar dependencias del Frontend**
```bash
cd ~/residencia-platos/frontend

# Instalar dependencias
npm install

# Verificar instalación
npm list --depth=0
```

### 4. **Configurar base de datos**
```bash
cd ~/residencia-platos/backend

# La base de datos SQLite se crea automáticamente al iniciar
# No necesitas configuración adicional
```

---

# 🚀 Ejecución en Producción

## 📘 Método 1: Ejecución Simple (Recomendado para pruebas)

### Terminal 1 - Backend:
```bash
cd ~/residencia-platos/backend
npm run start:dev
```

### Terminal 2 - Frontend:
```bash
cd ~/residencia-platos/frontend
npm run dev -- --host
```

## 🔧 Método 2: Con PM2 (Recomendado para producción)

### Instalar PM2:
```bash
sudo npm install -g pm2
```

### Configurar PM2:
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

## 🔧 Método 3: Como Servicio del Sistema (systemd)

### Crear servicio para el backend:
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

# Crear servicio para el frontend
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

# 🌐 Configuración de Red

## 🔍 **Encontrar tu IP:**
```bash
# Método 1
ip route | grep default
ip addr show

# Método 2
hostname -I

# Método 3
ifconfig
```

## 🔥 **Configurar Firewall (si está activo):**
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

# 📱 Acceso desde Dispositivos
- **Interfaz moderna**: Diseño minimalista y atractivo con CSS personalizado
- **API robusta**: Backend con NestJS para gestión de datos
- **Selección visual mejorada**: Las opciones seleccionadas se destacan claramente
- **🕛 Reinicio automático diario**: Los platos se limpian automáticamente a las 00:00
- **📅 Fecha actual prominente**: Muestra claramente el día y horarios de comida
- **📊 Estadísticas en tiempo real**: Seguimiento automático de platos del día

## 🚀 Estructura del Proyecto

```
residencia-platos/
├── backend/          # API NestJS
│   ├── src/
│   │   ├── platos/   # Módulo de platos
│   │   ├── main.ts   # Punto de entrada
│   │   └── app.module.ts
│   ├── package.json
│   └── tsconfig.json
├── frontend/         # Aplicación SvelteJS
│   ├── src/
│   │   ├── lib/
│   │   │   ├── components/  # Componentes Svelte
│   │   │   ├── services/    # Servicios API
│   │   │   └── types.ts     # Tipos TypeScript
│   │   ├── routes/
│   │   │   └── +page.svelte # Página principal
│   │   └── app.css         # Estilos personalizados
│   └── package.json
├── start.bat         # Script de inicio para Windows
├── start.sh          # Script de inicio para Linux/Mac
└── README.md
```

## 🛠️ Tecnologías

- **Frontend**: SvelteKit + TypeScript + CSS personalizado
- **Backend**: NestJS + TypeScript + SQLite + TypeORM
- **Comunicación**: REST API

## 📦 Instalación y Uso

### Opción 1: Inicio Automático (Recomendado)

**En Windows:**
```bash
# Doble click en start.bat o ejecuta:
start.bat
```

**En Linux/Mac:**
```bash
chmod +x start.sh
./start.sh
```

### Opción 2: Inicio Manual

**Backend:**
```bash
cd backend
npm install
npm run start:dev
```

**Frontend:**
```bash
cd frontend
npm install
npm run dev
```

## � Acceso a la Aplicación

- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:3000

## �🎨 Diseño

La aplicación cuenta con un diseño minimalista que incluye:
- ✨ Colores suaves y modernos con gradientes elegantes
- 🎯 **Selección visual mejorada**: Las opciones de almuerzo/cena se destacan claramente cuando están seleccionadas
- 🔄 Animaciones sutiles y transiciones suaves
- 📱 Interfaz responsiva para móviles y escritorio
- 🎨 Indicadores visuales claros para el estado de selección

## 🔄 Funcionalidades

### 1. **📅 Información de fecha**
- Muestra de forma compacta la fecha actual del día
- Integrada discretamente en el header de la aplicación
- Indicadores especiales para fines de semana

### 2. **🕛 Sistema de reinicio automático**
- Limpieza automática de platos a las 00:00 cada día
- Solo se muestran platos del día actual
- Contador visual del tiempo restante hasta el reinicio
- Barra de progreso del día transcurrido

### 3. **Registrar plato no consumido**
- Selección visual clara entre almuerzo y cena
- Las opciones seleccionadas se destacan con:
  - Borde de color (amarillo para almuerzo, púrpura para cena)
  - Fondo coloreado
  - Texto de confirmación "✓ Seleccionado"
  - Efecto de escala sutil

### 4. **Ver platos disponibles**
- Lista organizada por categoría con contadores
- Tarjetas con bordes de color distintivos
- Animaciones de entrada suaves

### 5. **Reclamar plato**
- Modal intuitivo con confirmación
- Sistema de un clic para tomar un plato

### 6. **📊 Estadísticas del día**
- Seguimiento automático de platos registrados
- Estadísticas mostradas en consola del servidor
- Contador de platos disponibles en tiempo real

## 🔧 API Endpoints

- `GET /platos/disponibles` - Obtener platos disponibles del día actual
- `GET /platos` - Obtener todos los platos del día actual
- `GET /platos/estadisticas` - Obtener estadísticas del día
- `POST /platos` - Crear nuevo plato
- `PATCH /platos/:id/reclamar` - Reclamar un plato
- `DELETE /platos/:id` - Eliminar un plato

## ⏰ Sistema de Reinicio Automático

El sistema incluye tareas programadas que se ejecutan automáticamente:

- **🕛 00:00 cada día**: Limpieza completa de platos antiguos
- **🧹 Cada 6 horas**: Limpieza de respaldo
- **📊 Cada hora**: Reporte de estadísticas en consola

Los platos se filtran automáticamente por fecha, mostrando solo los del día actual.

## 🚀 Desarrollo

El sistema está diseñado para ser fácil de usar y visualmente atractivo:

- **Feedback visual inmediato**: Cada acción tiene una respuesta visual clara
- **Accesibilidad**: Labels asociados correctamente con controles
- **Performance**: CSS optimizado sin dependencias de frameworks pesados
- **Mantenibilidad**: Código limpio y bien estructurado

## 🎯 Mejoras Implementadas

1. **Selección visual mejorada**: Las opciones de tipo de comida ahora se ven claramente seleccionadas
2. **Estilos optimizados**: CSS personalizado sin dependencias de TailwindCSS v4
3. **Accesibilidad mejorada**: Labels correctamente asociados con inputs
4. **Animaciones sutiles**: Efectos de hover y transiciones suaves

¡El sistema está listo para usar! 🎉
#   p l a t o s - r e s i d e n c i a  
 