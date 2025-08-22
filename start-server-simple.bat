@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
title Servidor Platos Residencia - SIMPLE

cls
echo.
echo 🍽️ ═══════════════════════════════════════════════════════
echo 🚀 SERVIDOR PLATOS RESIDENCIA - VERSION SIMPLE
echo 🍽️ ═══════════════════════════════════════════════════════
echo.

REM Obtener IP local de forma simple
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4" ^| findstr "192.168"') do (
    set "ip=%%a"
    set "ip=!ip: =!"
    goto :found_ip
)
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4" ^| findstr "10\."') do (
    set "ip=%%a"
    set "ip=!ip: =!"
    goto :found_ip
)
set ip=localhost

:found_ip
echo 🌐 IP detectada: !ip!
echo 📱 Acceso móvil: http://!ip!:5173
echo 💻 Acceso local: http://localhost:5173
echo.

REM Verificar Node.js
node --version >nul 2>&1
if %errorLevel% neq 0 (
    echo ❌ Node.js no encontrado
    echo 📥 Descárgalo desde: https://nodejs.org/
    pause
    exit /b 1
)
echo ✅ Node.js disponible

REM Verificar carpetas
if not exist "backend" (
    echo ❌ Carpeta 'backend' no encontrada
    pause
    exit /b 1
)
if not exist "frontend" (
    echo ❌ Carpeta 'frontend' no encontrada
    pause
    exit /b 1
)
echo ✅ Carpetas verificadas

echo.
echo 🚀 Iniciando servidores...
echo.

REM Instalar dependencias si es necesario (silencioso)
if not exist "backend\node_modules" (
    echo 📦 Instalando dependencias backend...
    cd backend
    npm install --silent
    cd ..
)

if not exist "frontend\node_modules" (
    echo 📦 Instalando dependencias frontend...
    cd frontend
    npm install --silent
    cd ..
)

echo 🔧 Iniciando backend...
cd backend
start "🔧 Backend - Puerto 3000" cmd /k "title Backend-3000 && echo Backend iniciado en puerto 3000 && npm run start:dev"
cd ..

timeout /t 3 /nobreak >nul

echo 🎨 Iniciando frontend...
cd frontend
start "🎨 Frontend - Puerto 5173" cmd /k "title Frontend-5173 && echo Frontend iniciado en puerto 5173 && echo Acceso: http://!ip!:5173 && npm run dev -- --host 0.0.0.0"
cd ..

timeout /t 2 /nobreak >nul

echo.
echo ✅ ═══════════════════════════════════════════════════════
echo ✅ SERVIDORES INICIADOS CORRECTAMENTE
echo ✅ ═══════════════════════════════════════════════════════
echo.
echo 📱 ACCESO DESDE MÓVILES:
echo    http://!ip!:5173
echo.
echo 💻 ACCESO LOCAL:
echo    http://localhost:5173
echo.
echo 🔧 ADMINISTRACIÓN:
echo    - Los logs aparecen en las 2 ventanas que se abrieron
echo    - Reset automático cada día a las 00:00
echo.
echo ⚠️  PARA DETENER:
echo    - Cierra las 2 ventanas de terminal
echo    - O presiona Ctrl+C en ambas
echo.
echo 🎉 Sistema funcionando! Puedes cerrar esta ventana.
echo.

echo Presiona cualquier tecla para cerrar esta ventana...
pause >nul
