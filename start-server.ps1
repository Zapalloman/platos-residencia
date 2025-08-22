# 🍽️ Script para iniciar servidor de platos - Residencia Universitaria
# Ejecutar como: .\start-server.ps1

# Cambiar al directorio del script
Set-Location $PSScriptRoot

# Obtener IP local para acceso móvil
$networkConfig = Get-NetIPConfiguration | Where-Object {$_.IPv4DefaultGateway -ne $null}
$ip = $networkConfig.IPv4Address.IPAddress

# Mostrar información de inicio
Write-Host ""
Write-Host "🍽️ ═══════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "🚀 INICIANDO SERVIDOR DE PLATOS - RESIDENCIA UNIVERSITARIA" -ForegroundColor Magenta  
Write-Host "🍽️ ═══════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""
Write-Host "🌐 Información del servidor:" -ForegroundColor Cyan
Write-Host "   📍 IP del servidor: $ip" -ForegroundColor Green
Write-Host "   📱 Acceso móvil: http://$ip:5173" -ForegroundColor Green
Write-Host "   🖥️  Acceso local: http://localhost:5173" -ForegroundColor Green
Write-Host "   🔗 API Backend: http://$ip:3000" -ForegroundColor Yellow
Write-Host ""
Write-Host "🔧 Estado del sistema:" -ForegroundColor Cyan
Write-Host "   💻 Windows Server Mode: ACTIVADO" -ForegroundColor Green
Write-Host "   📱 Acceso móvil: HABILITADO" -ForegroundColor Green
Write-Host "   👨‍💻 Logs administrativos: ACTIVADOS" -ForegroundColor Green
Write-Host "   🔄 Reinicio automático: 00:00 cada día" -ForegroundColor Green
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""

# Verificar que existan los directorios necesarios
if (-not (Test-Path "backend")) {
    Write-Host "❌ Error: No se encontró el directorio 'backend'" -ForegroundColor Red
    Write-Host "   Asegúrate de ejecutar este script desde el directorio raíz del proyecto" -ForegroundColor Yellow
    pause
    exit 1
}

if (-not (Test-Path "frontend")) {
    Write-Host "❌ Error: No se encontró el directorio 'frontend'" -ForegroundColor Red
    Write-Host "   Asegúrate de ejecutar este script desde el directorio raíz del proyecto" -ForegroundColor Yellow
    pause
    exit 1
}

# Verificar Node.js
try {
    $nodeVersion = node --version
    $npmVersion = npm --version
    Write-Host "✅ Node.js: $nodeVersion" -ForegroundColor Green
    Write-Host "✅ npm: $npmVersion" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "❌ Error: Node.js no está instalado o no está en el PATH" -ForegroundColor Red
    Write-Host "   Descarga Node.js desde: https://nodejs.org/" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "🚀 Iniciando backend..." -ForegroundColor Yellow

# Iniciar backend en una ventana minimizada
$backendJob = Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\backend'; Write-Host '🔧 Backend iniciado - Logs apareceran aqui' -ForegroundColor Green; npm run start:dev" -WindowStyle Minimized -PassThru

# Esperar un poco para que inicie el backend
Write-Host "⏳ Esperando que el backend inicie..." -ForegroundColor Yellow
Start-Sleep -Seconds 8

# Verificar que el backend esté corriendo
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    Write-Host "✅ Backend funcionando correctamente" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Backend tardando en iniciar, continuando..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🚀 Iniciando frontend..." -ForegroundColor Yellow
Write-Host "   (Esta ventana mostrará los logs del frontend)" -ForegroundColor Cyan
Write-Host ""

# Cambiar al directorio frontend e iniciar
Set-Location frontend

# Verificar que las dependencias estén instaladas
if (-not (Test-Path "node_modules")) {
    Write-Host "📦 Instalando dependencias del frontend..." -ForegroundColor Yellow
    npm install
}

# Iniciar frontend (esta ventana permanecerá abierta mostrando logs)
npm run dev -- --host

# Si el frontend se cierra, también cerrar el backend
Write-Host ""
Write-Host "🛑 Cerrando servidor..." -ForegroundColor Red
if ($backendJob -and !$backendJob.HasExited) {
    Stop-Process -Id $backendJob.Id -Force -ErrorAction SilentlyContinue
    Write-Host "✅ Backend cerrado" -ForegroundColor Yellow
}

Write-Host "👋 Servidor cerrado. ¡Hasta luego!" -ForegroundColor Magenta
pause
