@echo off
chcp 65001 >nul
echo ===============================================
echo 🏠 CONFIGURADOR SERVIDOR RESIDENCIA
echo ===============================================
echo.

REM Verificar si se ejecuta como administrador
net session >nul 2>&1
if %errorLevel% == 0 (
    echo ✅ Ejecutandose como Administrador
) else (
    echo ⚠️  No se ejecuta como Administrador
    echo    Algunas funciones avanzadas no estaran disponibles
)
echo.

REM 1. Configurar energia
echo ⚡ Configurando energia para servidor 24/7...
if %errorLevel% == 0 (
    powercfg -change -monitor-timeout-ac 0 >nul 2>&1
    powercfg -change -disk-timeout-ac 0 >nul 2>&1
    powercfg -change -standby-timeout-ac 0 >nul 2>&1
    powercfg -change -hibernate-timeout-ac 0 >nul 2>&1
    
    if !errorlevel! == 0 (
        echo ✅ Configuracion de energia aplicada
        echo    - Monitor: Nunca se apaga
        echo    - Sistema: Nunca hiberna/suspende
    ) else (
        echo ⚠️  Error en configuracion de energia
    )
) else (
    echo ⚠️  Configuracion de energia requiere permisos de administrador
)
echo.

REM 2. Configurar firewall
echo 🔥 Configurando firewall...
if %errorLevel% == 0 (
    netsh advfirewall firewall add rule name="Residencia Backend" dir=in action=allow protocol=TCP localport=3000 >nul 2>&1
    netsh advfirewall firewall add rule name="Residencia Frontend" dir=in action=allow protocol=TCP localport=5173 >nul 2>&1
    
    echo ✅ Reglas de firewall configuradas
    echo    - Puerto 3000: Backend API
    echo    - Puerto 5173: Frontend web
) else (
    echo ⚠️  Configuracion de firewall requiere permisos de administrador
)
echo.

REM 3. Verificar Node.js
echo 🔍 Verificando Node.js...
node --version >nul 2>&1
if %errorLevel% == 0 (
    echo ✅ Node.js detectado
    for /f "tokens=*" %%i in ('node --version 2^>nul') do echo    - Node.js: %%i
    for /f "tokens=*" %%i in ('npm --version 2^>nul') do echo    - npm: %%i
) else (
    echo ❌ Node.js no esta instalado
    echo    📥 Descargalo desde: https://nodejs.org/
    echo    🔄 Reinicia la terminal despues de instalar
)
echo.

REM 4. Mostrar informacion de red
echo 🌐 Informacion de red:
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4" ^| findstr "192.168\|10\.\|172\."') do (
    set "ip=%%a"
    set "ip=!ip: =!"
    echo ✅ Red detectada
    echo    - IP local: !ip!
)
echo.

REM 5. Verificar dependencias del proyecto
echo 📦 Verificando dependencias...

if exist "backend\" (
    echo ✅ Carpeta backend encontrada
    if exist "backend\package.json" (
        echo ✅ package.json del backend encontrado
    ) else (
        echo ⚠️  package.json del backend no encontrado
    )
) else (
    echo ❌ Carpeta backend no encontrada
)

if exist "frontend\" (
    echo ✅ Carpeta frontend encontrada
    if exist "frontend\package.json" (
        echo ✅ package.json del frontend encontrado
    ) else (
        echo ⚠️  package.json del frontend no encontrado
    )
) else (
    echo ❌ Carpeta frontend no encontrada
)
echo.

REM 6. Resumen
echo =============================================
echo 🎯 CONFIGURACION COMPLETADA
echo =============================================
echo.
echo 📋 Proximos pasos:
echo    1. Ejecuta: start-server.bat
echo    2. O doble clic en: start-server.bat
echo    3. ¡Cierra la tapa y listo!
echo.
echo 📱 Los estudiantes podran acceder desde:
echo    http://[TU-IP]:5173
echo.

pause
