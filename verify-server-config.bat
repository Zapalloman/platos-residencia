@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
title Verificación Servidor 24/7

cls
echo.
echo ===============================================
echo 🔍 VERIFICACIÓN CONFIGURACIÓN SERVIDOR 24/7
echo ===============================================
echo.

echo 🔍 Verificando configuración de energía...
echo.

REM Verificar configuración de tapa cerrada
echo 🔒 Acción al cerrar la tapa:
for /f "tokens=*" %%i in ('powercfg -query SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 ^| findstr "Configuración actual de CA\|Configuración actual de CC"') do (
    echo    %%i
)

echo.

REM Verificar configuración de suspensión
echo ⚡ Configuración de suspensión:
for /f "tokens=*" %%i in ('powercfg -query SCHEME_CURRENT ^| findstr "Suspender después de\|Hibernar después de"') do (
    echo    %%i
)

echo.

REM Verificar reglas de firewall
echo 🔥 Reglas de firewall:
netsh advfirewall firewall show rule name="Residencia Backend" >nul 2>&1
if !errorlevel! == 0 (
    echo    ✅ Regla Backend (puerto 3000): CONFIGURADA
) else (
    echo    ❌ Regla Backend (puerto 3000): NO ENCONTRADA
)

netsh advfirewall firewall show rule name="Residencia Frontend" >nul 2>&1
if !errorlevel! == 0 (
    echo    ✅ Regla Frontend (puerto 5173): CONFIGURADA
) else (
    echo    ❌ Regla Frontend (puerto 5173): NO ENCONTRADA
)

echo.

REM Verificar Node.js
echo 📦 Verificando dependencias:
node --version >nul 2>&1
if !errorlevel! == 0 (
    for /f "tokens=*" %%i in ('node --version') do echo    ✅ Node.js: %%i
) else (
    echo    ❌ Node.js: NO ENCONTRADO
)

npm --version >nul 2>&1
if !errorlevel! == 0 (
    for /f "tokens=*" %%i in ('npm --version') do echo    ✅ npm: %%i
) else (
    echo    ❌ npm: NO ENCONTRADO
)

echo.

REM Verificar estructura del proyecto
echo 📁 Verificando estructura del proyecto:
if exist "backend\" (
    echo    ✅ Carpeta backend: ENCONTRADA
    if exist "backend\package.json" (
        echo    ✅ package.json backend: ENCONTRADO
    ) else (
        echo    ❌ package.json backend: NO ENCONTRADO
    )
    if exist "backend\node_modules\" (
        echo    ✅ node_modules backend: INSTALADO
    ) else (
        echo    ⚠️  node_modules backend: NO INSTALADO
    )
) else (
    echo    ❌ Carpeta backend: NO ENCONTRADA
)

if exist "frontend\" (
    echo    ✅ Carpeta frontend: ENCONTRADA
    if exist "frontend\package.json" (
        echo    ✅ package.json frontend: ENCONTRADO
    ) else (
        echo    ❌ package.json frontend: NO ENCONTRADO
    )
    if exist "frontend\node_modules\" (
        echo    ✅ node_modules frontend: INSTALADO
    ) else (
        echo    ⚠️  node_modules frontend: NO INSTALADO
    )
) else (
    echo    ❌ Carpeta frontend: NO ENCONTRADA
)

echo.

REM Verificar información de red
echo 🌐 Información de red:
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4" ^| findstr "192.168\|10\.\|172\." ^| head -n 1') do (
    set "ip=%%a"
    set "ip=!ip: =!"
    echo    ✅ IP local detectada: !ip!
    echo    📱 URL móvil: http://!ip!:5173
    echo    🖥️  URL local: http://localhost:5173
    echo    🔗 API Backend: http://!ip!:3000
    goto :ip_found
)

echo    ⚠️  IP local no detectada automáticamente
echo    🔍 Ejecuta manualmente: ipconfig

:ip_found
echo.

REM Test de conectividad (si hay servidores corriendo)
echo 🔌 Verificando conectividad:
netstat -an | findstr ":3000.*LISTENING" >nul 2>&1
if !errorlevel! == 0 (
    echo    ✅ Backend escuchando en puerto 3000
) else (
    echo    ⚠️  Backend no está corriendo en puerto 3000
)

netstat -an | findstr ":5173.*LISTENING" >nul 2>&1
if !errorlevel! == 0 (
    echo    ✅ Frontend escuchando en puerto 5173
) else (
    echo    ⚠️  Frontend no está corriendo en puerto 5173
)

echo.

REM Resumen final
echo ===============================================
echo 🎯 RESUMEN DE VERIFICACIÓN
echo ===============================================
echo.

echo 📋 CHECKLIST SERVIDOR 24/7:
echo    🔒 Configuración de tapa cerrada
echo    ⚡ Configuración de energía
echo    🔥 Reglas de firewall
echo    📦 Dependencias instaladas
echo    🌐 Red configurada
echo.

echo 📱 INSTRUCCIONES DE PRUEBA:
echo    1. Inicia el servidor: start-server-simple.bat
echo    2. Verifica acceso local: http://localhost:5173
echo    3. Verifica acceso móvil: http://[IP]:5173
echo    4. 🔒 CIERRA LA TAPA de la laptop
echo    5. Prueba desde móvil - debe seguir funcionando
echo.

echo 🎉 Si todo está ✅, tu laptop está lista para funcionar 24/7
echo    con la tapa cerrada sin problemas.
echo.

echo Presiona cualquier tecla para cerrar...
pause >nul
