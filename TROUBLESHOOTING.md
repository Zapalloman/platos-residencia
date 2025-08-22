# 🔧 GUÍA DE SOLUCIÓN DE PROBLEMAS
## Scripts de Windows para Diferentes Laptops

### 📋 **ARCHIVOS DISPONIBLES:**

1. **`setup-windows-server.ps1`** - Script original de PowerShell
2. **`setup-windows-server-compatible.ps1`** - Versión mejorada de PowerShell  
3. **`setup-windows-server.bat`** - Versión en batch (CMD)
4. **`start-server.ps1`** - Inicio original de PowerShell
5. **`start-server-compatible.ps1`** - Inicio mejorado de PowerShell
6. **`start-server.bat`** - Inicio original en batch
7. **`start-server-simple.bat`** - Inicio simplificado en batch

---

## 🚨 **PROBLEMAS COMUNES Y SOLUCIONES:**

### ❌ **Problema 1: "Scripts de PowerShell no se ejecutan"**

**Síntomas:**
- Error de política de ejecución
- Scripts .ps1 no inician

**Soluciones (en orden de preferencia):**

#### Solución A: Usar archivos .bat
```cmd
# Ejecutar directamente (doble clic):
start-server-simple.bat

# O para configuración:  
setup-windows-server.bat
```

#### Solución B: Habilitar PowerShell temporalmente
```powershell
# En PowerShell como administrador:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Luego ejecutar:
.\setup-windows-server-compatible.ps1
.\start-server-compatible.ps1
```

#### Solución C: Ejecutar sin cambiar políticas
```powershell
# Método bypass:
powershell -ExecutionPolicy Bypass -File .\setup-windows-server-compatible.ps1
powershell -ExecutionPolicy Bypass -File .\start-server-compatible.ps1
```

---

### ❌ **Problema 2: "Error de sintaxis en PowerShell"**

**Síntomas:**
- "Unexpected token" 
- Errores de parsing

**Solución:**
```cmd
# Usar la versión batch que siempre funciona:
start-server-simple.bat
```

---

### ❌ **Problema 3: "No se puede detectar la IP"**

**Síntomas:**
- Scripts no muestran IP local
- Error al obtener configuración de red

**Solución:**
```cmd
# 1. Obtener IP manualmente:
ipconfig | findstr "IPv4"

# 2. Usar localhost si no detecta:
# El frontend será accesible en: http://localhost:5173
# Desde móvil: http://[TU-IP-MANUAL]:5173
```

---

### ❌ **Problema 4: "Node.js no encontrado"**

**Síntomas:**
- "'node' is not recognized"
- Error de dependencias

**Solución:**
```cmd
# 1. Descargar e instalar Node.js:
# https://nodejs.org/

# 2. Reiniciar terminal después de instalar

# 3. Verificar instalación:
node --version
npm --version
```

---

### ❌ **Problema 5: "Puerto ocupado"**

**Síntomas:**
- "EADDRINUSE: address already in use"
- Conflicto de puertos

**Solución:**
```cmd
# Ver qué está usando los puertos:
netstat -ano | findstr :3000
netstat -ano | findstr :5173

# Terminar procesos si es necesario:
taskkill /PID [NUMERO_PROCESO] /F
```

---

### ❌ **Problema 6: "Al cerrar la tapa, el servidor se detiene"**

**Síntomas:**
- Servidor funciona con tapa abierta
- Al cerrar la tapa, se pierde conexión
- Sistema entra en suspensión

**Soluciones:**

#### Solución A: Script Automático (Recomendado)
```cmd
# Ejecutar como Administrador:
setup-laptop-server.bat

# O en PowerShell:
.\setup-laptop-server.ps1
```

#### Solución B: Configuración Manual
```cmd
# 1. Configurar acción de tapa cerrada:
powercfg -setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
powercfg -setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
powercfg -SetActive SCHEME_CURRENT

# 2. Verificar configuración:
powercfg -query SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936
```

#### Solución C: Configuración por Interfaz
1. Panel de Control → Opciones de energía
2. Cambiar la configuración del plan → Cambiar configuración avanzada
3. Botones de alimentación y tapa → Acción de cierre de tapa
4. Establecer "No hacer nada" en AC y Batería

---

### ❌ **Problema 7: "Firewall bloquea conexiones"**

**Síntomas:**
- No se puede acceder desde móvil
- Conexión rechazada

**Solución:**
```cmd
# Método 1: Configurar firewall automáticamente (como admin):
setup-windows-server.bat

# Método 2: Manual en Windows Defender:
# 1. Abrir "Windows Defender Firewall"
# 2. "Configuración avanzada"
# 3. "Reglas de entrada" > "Nueva regla"
# 4. Puerto TCP 3000 y 5173 - Permitir
```

---

## 🏥 **GUÍA DE RECUPERACIÓN RÁPIDA:**

### 🔥 **Si NADA funciona:**

1. **Método Manual Básico:**
```cmd
# Terminal 1:
cd backend
npm install
npm run start:dev

# Terminal 2:  
cd frontend
npm install
npm run dev -- --host 0.0.0.0
```

2. **Método de Emergencia:**
```cmd
# Si PowerShell falla completamente:
cmd /c "start-server-simple.bat"
```

3. **Verificación paso a paso:**
```cmd
# 1. Verificar Node.js:
node --version

# 2. Verificar carpetas:
dir backend
dir frontend

# 3. Instalar dependencias:
cd backend && npm install && cd ..
cd frontend && npm install && cd ..

# 4. Iniciar manualmente
```

---

## 📱 **CONFIGURACIÓN PARA ACCESO MÓVIL:**

### ✅ **Verificación de red:**
```cmd
# 1. Obtener tu IP:
ipconfig | findstr "IPv4"

# 2. Verificar conexión:
ping [TU-IP]

# 3. Probar puertos:
telnet [TU-IP] 3000
telnet [TU-IP] 5173
```

### ✅ **URLs de acceso:**
- **Local:** `http://localhost:5173`
- **Móvil:** `http://[TU-IP]:5173`
- **Ejemplo:** `http://192.168.1.100:5173`

---

## 🎯 **RECOMENDACIONES POR TIPO DE LAPTOP:**

### 🖥️ **Laptops Corporativas/Empresariales:**
```cmd
# Usar exclusivamente archivos .bat:
setup-windows-server.bat
start-server-simple.bat
```

### 🏠 **Laptops Personales:**
```powershell
# Pueden usar PowerShell:
.\setup-windows-server-compatible.ps1
.\start-server-compatible.ps1
```

### 🎓 **Laptops de Universidad:**
```cmd
# Método más seguro:
start-server-simple.bat
# (No requiere permisos especiales)
```

---

## 📞 **VERIFICACIÓN FINAL:**

### ✅ **Checklist de funcionamiento:**
- [ ] Node.js instalado y funcionando
- [ ] Carpetas `backend` y `frontend` presentes
- [ ] Dependencias instaladas (`node_modules` en ambas carpetas)
- [ ] Backend corriendo en puerto 3000
- [ ] Frontend corriendo en puerto 5173
- [ ] Firewall configurado (si usas acceso móvil)
- [ ] IP local detectada correctamente

### 🎉 **Si todo está ✅:**
- **Local:** http://localhost:5173
- **Móvil:** http://[TU-IP]:5173

### 📧 **Logs administrativos:**
- Los logs aparecen en las ventanas de terminal
- Reset automático cada día a las 00:00
- Estadísticas cada hora en la consola del backend
