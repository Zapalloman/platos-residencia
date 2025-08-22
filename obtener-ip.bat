@echo off
echo 🔍 Encontrando tu dirección IP para acceso móvil...
echo.

for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /C:"IPv4"') do (
    set ip=%%a
    set ip=!ip: =!
    if not "!ip!"=="" (
        echo 📱 Accede desde tu móvil a: http://!ip!:5173
        echo 💻 IP de tu computadora: !ip!
        goto :found
    )
)

:found
echo.
echo 📋 Instrucciones:
echo 1. Conecta tu móvil a la misma red WiFi
echo 2. Abre el navegador en tu móvil
echo 3. Ve a la URL mostrada arriba
echo.
pause
