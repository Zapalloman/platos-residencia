@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
title Configuración Laptop Servidor 24/7

cls
echo.
echo =============================================
echo 🔒 CONFIGURACIÓN LAPTOP SERVIDOR 24/7
echo =============================================
echo.

REM Verificar permisos de administrador
net session >nul 2>&1
if %errorLevel% == 0 (
    echo ✅ Ejecutándose como Administrador
    echo    Se aplicarán todas las configuraciones
    set "isAdmin=true"
) else (
    echo ⚠️  No se ejecuta como Administrador
    echo    Ejecuta como Admin para configuración completa
    echo    Click derecho en el archivo ^> "Ejecutar como administrador"
    set "isAdmin=false"
)
echo.

REM 1. CONFIGURACIÓN CRÍTICA: TAPA CERRADA
echo 🔒 Configurando laptop para funcionar con tapa cerrada...

if "%isAdmin%"=="true" (
    echo    ⚙️  Configurando acciones de energía...
    
    REM Configurar para que NO se suspenda al cerrar la tapa
    REM SCHEME_CURRENT = esquema actual
    REM 4f971e89-eebd-4455-a8de-9e59040e7347 = GUID para configuración de botones y tapa
    REM 5ca83367-6e45-459f-a27b-476b1d01c936 = GUID para acción de cerrar tapa
    REM 0 = No hacer nada (no suspender)
    
    powercfg -setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0 >nul 2>&1
    powercfg -setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0 >nul 2>&1
    powercfg -SetActive SCHEME_CURRENT >nul 2>&1
    
    if !errorlevel! == 0 (
        echo    ✅ Tapa cerrada = NO SUSPENDER ^(AC y Batería^)
    ) else (
        echo    ⚠️  Error configurando acción de tapa cerrada
    )
    
    REM Configuraciones adicionales para servidor
    powercfg -change -monitor-timeout-ac 0 >nul 2>&1
    powercfg -change -disk-timeout-ac 0 >nul 2>&1
    powercfg -change -standby-timeout-ac 0 >nul 2>&1
    powercfg -change -hibernate-timeout-ac 0 >nul 2>&1
    
    REM También para batería
    powercfg -change -monitor-timeout-dc 30 >nul 2>&1
    powercfg -change -disk-timeout-dc 0 >nul 2>&1
    powercfg -change -standby-timeout-dc 0 >nul 2>&1
    powercfg -change -hibernate-timeout-dc 0 >nul 2>&1
    
    echo    ✅ Monitor: Solo se apaga ^(no suspende sistema^)
    echo    ✅ Discos: Nunca se suspenden
    echo    ✅ Sistema: NUNCA hiberna o suspende
    echo    ✅ Batería: Configurada para servidor
    
) else (
    echo    ⚠️  REQUIERE PERMISOS DE ADMINISTRADOR
    echo    Sin esto, la laptop se suspenderá al cerrar la tapa
)
echo.

REM 2. CONFIGURAR FIREWALL
echo 🔥 Configurando firewall para acceso externo...

if "%isAdmin%"=="true" (
    netsh advfirewall firewall add rule name="Residencia Backend" dir=in action=allow protocol=TCP localport=3000 >nul 2>&1
    netsh advfirewall firewall add rule name="Residencia Frontend" dir=in action=allow protocol=TCP localport=5173 >nul 2>&1
    
    if !errorlevel! == 0 (
        echo    ✅ Reglas de firewall aplicadas
        echo    ✅ Puerto 3000: Backend API
        echo    ✅ Puerto 5173: Frontend web
    ) else (
        echo    ⚠️  Algunas reglas pueden no haberse aplicado
    )
) else (
    echo    ⚠️  Requiere permisos de administrador
)
echo.

REM 3. CONFIGURACIÓN ADICIONAL PARA SERVIDOR
echo ⚙️  Configuraciones adicionales para servidor...

if "%isAdmin%"=="true" (
    echo    ⚙️  Configurando actualizaciones...
    
    REM Deshabilitar reinicio automático por actualizaciones
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoRebootWithLoggedOnUsers /t REG_DWORD /d 1 /f >nul 2>&1
    
    if !errorlevel! == 0 (
        echo    ✅ Reinicio automático por actualizaciones: DESHABILITADO
    ) else (
        echo    ⚠️  No se pudo configurar actualizaciones automáticas
    )
) else (
    echo    ⚠️  Requiere permisos de administrador
)
echo.

REM 4. OBTENER INFORMACIÓN DE RED
echo 🌐 Información de red para acceso remoto:

for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4" ^| findstr "192.168\|10\.\|172\." ^| head -n 1') do (
    set "ip=%%a"
    set "ip=!ip: =!"
    echo    ✅ IP detectada: !ip!
    echo    📱 Acceso móvil: http://!ip!:5173
    echo    🔗 API Backend: http://!ip!:3000
    goto :ip_found
)

echo    ⚠️  IP no detectada automáticamente
echo    🔍 Ejecuta manualmente: ipconfig ^| findstr IPv4

:ip_found
echo.

REM 5. VERIFICAR DEPENDENCIAS
echo 📦 Verificando dependencias del proyecto...

set "projectOK=true"

if exist "backend\" (
    echo    ✅ Carpeta backend encontrada
    if exist "backend\package.json" (
        echo    ✅ package.json del backend encontrado
    ) else (
        echo    ⚠️  package.json del backend no encontrado
        set "projectOK=false"
    )
) else (
    echo    ❌ Carpeta backend no encontrada
    set "projectOK=false"
)

if exist "frontend\" (
    echo    ✅ Carpeta frontend encontrada
    if exist "frontend\package.json" (
        echo    ✅ package.json del frontend encontrado
    ) else (
        echo    ⚠️  package.json del frontend no encontrado
        set "projectOK=false"
    )
) else (
    echo    ❌ Carpeta frontend no encontrada
    set "projectOK=false"
)
echo.

REM 6. RESUMEN Y INSTRUCCIONES FINALES
echo =============================================
if "%isAdmin%"=="true" (
    echo 🎯 CONFIGURACIÓN SERVIDOR 24/7 COMPLETADA
) else (
    echo ⚠️  CONFIGURACIÓN PARCIAL ^(SIN PERMISOS ADMIN^)
)
echo =============================================
echo.

if "%isAdmin%"=="true" (
    echo ✅ LAPTOP CONFIGURADA COMO SERVIDOR:
    echo    🔒 Tapa cerrada = Sistema sigue funcionando
    echo    🌐 Red configurada para acceso remoto
    echo    🔥 Firewall configurado para puertos 3000 y 5173
    echo    ⚙️  Actualizaciones no reiniciarán automáticamente
) else (
    echo ⚠️  PARA CONFIGURACIÓN COMPLETA:
    echo    1. Cierra esta ventana
    echo    2. Click derecho en este archivo
    echo    3. Selecciona "Ejecutar como administrador"
    echo    4. Ejecuta nuevamente
)
echo.

echo 📋 PRÓXIMOS PASOS:
echo    1. Ejecuta: start-server-simple.bat
echo    2. Verifica que funciona: http://localhost:5173
echo    3. 🔒 CIERRA LA TAPA de la laptop
echo    4. 📱 Prueba desde móvil en la misma red
echo.

echo 🎉 INSTRUCCIONES DE USO 24/7:
echo    💻 Deja la laptop conectada al cargador
echo    🔒 Puedes cerrar la tapa sin problemas
echo    📱 Acceso desde móviles: http://[IP]:5173
echo    🔄 El sistema se reinicia automáticamente cada día
echo.

if "%projectOK%"=="true" (
    echo ✅ Proyecto listo para iniciar
) else (
    echo ⚠️  Verifica que estás en el directorio correcto del proyecto
)
echo.

echo Presiona cualquier tecla para continuar...
pause >nul
