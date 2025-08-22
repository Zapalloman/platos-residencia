@echo off
title Sistema de Platos - Residencia Universitaria

echo.
echo ████████████████████████████████████████████████████████████
echo █                                                          █
echo █    🍽️  SISTEMA DE PLATOS - RESIDENCIA UNIVERSITARIA      █  
echo █                                                          █
echo ████████████████████████████████████████████████████████████
echo.

cd /d "%~dp0"

echo 🔍 Detectando IP local...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do (
    for /f "tokens=1" %%b in ("%%a") do (
        set IP=%%b
        goto :found
    )
)
:found

echo 🌐 IP detectada: %IP%
echo 📱 Acceso móvil: http://%IP%:5173
echo 🖥️  Acceso local: http://localhost:5173
echo.

echo 🚀 Iniciando backend...
start /min "Backend - Residencia Platos" cmd /k "cd backend && echo Backend iniciado - Logs aparecerán aquí && npm run start:dev"

echo ⏳ Esperando 8 segundos para que inicie el backend...
timeout /t 8 /nobreak >nul

echo 🚀 Iniciando frontend...
echo    (Los logs aparecerán en esta ventana)
echo.

cd frontend
npm run dev -- --host

echo.
echo 🛑 Cerrando servidor...
taskkill /f /im node.exe >nul 2>&1
echo ✅ Servidor cerrado
pause
