# ===============================================
# 🚀 SETUP AUTOMÁTICO - SERVIDOR RESIDENCIA
# ===============================================
# Script para configurar automáticamente Windows
# como servidor para el sistema de residencia
# ===============================================

# Verificar si se ejecuta como administrador para algunas funciones
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "🏠 CONFIGURADOR SERVIDOR RESIDENCIA" -ForegroundColor Cyan  
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

if ($isAdmin) {
    Write-Host "✅ Ejecutándose como Administrador" -ForegroundColor Green
} else {
    Write-Host "⚠️  No se ejecuta como Administrador" -ForegroundColor Yellow
    Write-Host "   Algunas funciones avanzadas no estarán disponibles" -ForegroundColor Gray
}
Write-Host ""

# 1. Configurar energía para mantener laptop activa
Write-Host "⚡ Configurando energía para servidor 24/7..." -ForegroundColor Yellow

try {
    if ($isAdmin) {
        # Configurar para que no se suspenda ni hiberne
        powercfg -change -monitor-timeout-ac 0
        powercfg -change -disk-timeout-ac 0  
        powercfg -change -standby-timeout-ac 0
        powercfg -change -hibernate-timeout-ac 0
        
        # También configurar para USB (opcional)
        powercfg -change -monitor-timeout-dc 0
        powercfg -change -disk-timeout-dc 0
        powercfg -change -standby-timeout-dc 0
        powercfg -change -hibernate-timeout-dc 0
        
        Write-Host "✅ Configuración de energía aplicada" -ForegroundColor Green
        Write-Host "   - Monitor: Nunca se apaga" -ForegroundColor Gray
        Write-Host "   - Discos: Nunca se suspenden" -ForegroundColor Gray  
        Write-Host "   - Sistema: Nunca hiberna/suspende" -ForegroundColor Gray
    } else {
        Write-Host "⚠️  Configuración de energía requiere permisos de administrador" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Error configurando energía: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# 2. Configurar firewall
Write-Host "🔥 Configurando firewall..." -ForegroundColor Yellow

try {
    if ($isAdmin) {
        # Crear reglas de firewall para puertos 3000 y 5173
        New-NetFirewallRule -DisplayName "Residencia Backend (Puerto 3000)" -Direction Inbound -Protocol TCP -LocalPort 3000 -Action Allow -ErrorAction SilentlyContinue
        New-NetFirewallRule -DisplayName "Residencia Frontend (Puerto 5173)" -Direction Inbound -Protocol TCP -LocalPort 5173 -Action Allow -ErrorAction SilentlyContinue
        
        Write-Host "✅ Reglas de firewall configuradas" -ForegroundColor Green
        Write-Host "   - Puerto 3000: Backend API" -ForegroundColor Gray
        Write-Host "   - Puerto 5173: Frontend web" -ForegroundColor Gray
    } else {
        Write-Host "⚠️  Configuración de firewall requiere permisos de administrador" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Error configurando firewall: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# 3. Verificar Node.js
Write-Host "🔍 Verificando Node.js..." -ForegroundColor Yellow

try {
    $nodeVersion = node --version 2>$null
    $npmVersion = npm --version 2>$null
    
    if ($nodeVersion -and $npmVersion) {
        Write-Host "✅ Node.js detectado" -ForegroundColor Green
        Write-Host "   - Node.js: $nodeVersion" -ForegroundColor Gray
        Write-Host "   - npm: $npmVersion" -ForegroundColor Gray
    } else {
        throw "Node.js no encontrado"
    }
} catch {
    Write-Host "❌ Node.js no está instalado" -ForegroundColor Red
    Write-Host "   📥 Descárgalo desde: https://nodejs.org/" -ForegroundColor Yellow
    Write-Host "   🔄 Reinicia la terminal después de instalar" -ForegroundColor Yellow
}
Write-Host ""

# 4. Mostrar información de red
Write-Host "🌐 Información de red:" -ForegroundColor Yellow

try {
    $networkConfig = Get-NetIPConfiguration | Where-Object {$_.IPv4DefaultGateway -ne $null}
    
    if ($networkConfig) {
        $ip = $networkConfig.IPv4Address.IPAddress
        Write-Host "✅ Red detectada" -ForegroundColor Green
        Write-Host "   - IP local: $ip" -ForegroundColor Gray
        Write-Host "   - Gateway: $($networkConfig.IPv4DefaultGateway.NextHop)" -ForegroundColor Gray
    } else {
        Write-Host "⚠️  No se detectó conexión de red" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Error obteniendo información de red" -ForegroundColor Red
    $ip = $null
}
Write-Host ""

# 5. Verificar dependencias del proyecto
Write-Host "📦 Verificando dependencias..." -ForegroundColor Yellow

# Verificar si existen las carpetas del proyecto
if (Test-Path ".\backend" -PathType Container) {
    Write-Host "✅ Carpeta backend encontrada" -ForegroundColor Green
    
    if (Test-Path ".\backend\package.json") {
        Write-Host "✅ package.json del backend encontrado" -ForegroundColor Green
    } else {
        Write-Host "⚠️  package.json del backend no encontrado" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ Carpeta backend no encontrada" -ForegroundColor Red
}

if (Test-Path ".\frontend" -PathType Container) {
    Write-Host "✅ Carpeta frontend encontrada" -ForegroundColor Green
    
    if (Test-Path ".\frontend\package.json") {
        Write-Host "✅ package.json del frontend encontrado" -ForegroundColor Green
    } else {
        Write-Host "⚠️  package.json del frontend no encontrado" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ Carpeta frontend no encontrada" -ForegroundColor Red
}
Write-Host ""

# 6. Resumen y próximos pasos
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "🎯 CONFIGURACIÓN COMPLETADA" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Próximos pasos:" -ForegroundColor Yellow
Write-Host "   1. Ejecuta: .\start-server.ps1" -ForegroundColor White
Write-Host "   2. O doble clic en: start-server.bat" -ForegroundColor White
Write-Host "   3. ¡Cierra la tapa y listo!" -ForegroundColor White
Write-Host ""
Write-Host "📱 Los estudiantes podrán acceder desde:" -ForegroundColor Yellow
if ($ip) {
    Write-Host "   http://$ip`:5173" -ForegroundColor White
} else {
    Write-Host "   http://[TU-IP]:5173" -ForegroundColor White
}
Write-Host ""

pause
