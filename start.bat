@echo off
echo 🍽️ Iniciando Sistema de Platos - Residencia Universitaria

REM Verificar si Node.js está instalado
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js no está instalado. Por favor instálalo desde https://nodejs.org/
    pause
    exit /b 1
)

echo 📦 Instalando dependencias del backend...
cd backend
call npm install
if errorlevel 1 (
    echo ❌ Error instalando dependencias del backend
    pause
    exit /b 1
)

echo 📦 Instalando dependencias del frontend...
cd ..\frontend
call npm install
if errorlevel 1 (
    echo ❌ Error instalando dependencias del frontend
    pause
    exit /b 1
)

echo 🚀 Iniciando backend en puerto 3000...
cd ..\backend
start "Backend" cmd /k "npm run start:dev"

echo ⏳ Esperando a que el backend inicie...
timeout /t 5 /nobreak >nul

echo 🎨 Iniciando frontend en puerto 5173...
cd ..\frontend
start "Frontend" cmd /k "npm run dev"

echo.
echo ✅ ¡Sistema iniciado correctamente!
echo.
echo � Acceso local:
echo    Frontend: http://localhost:5173
echo    Backend API: http://localhost:3000
echo.
echo 📱 Acceso desde móvil (misma red WiFi):
echo    1. Encuentra tu IP ejecutando: ipconfig
echo    2. Busca la "Dirección IPv4" (ej: 192.168.1.100)
echo    3. En tu móvil ve a: http://[TU-IP]:5173
echo    Ejemplo: http://192.168.1.100:5173
echo.
echo Para usar el sistema, abre tu navegador en cualquiera de las URLs anteriores
echo Para detener el sistema, cierra las ventanas de terminal que se abrieron
pause
