# 🔧 Script de configuración para Windows Server Mode
# Ejecutar como ADMINISTRADOR: .\setup-windows-server.ps1

Write-Host ""
Write-Host "🔧 ═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   CONFIGURACIÓN WINDOWS SERVER MODE" -ForegroundColor Cyan
Write-Host "   Sistema de Platos - Residencia Universitaria" -ForegroundColor Cyan
Write-Host "🔧 ═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Verificar si se está ejecutando como administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "❌ Este script debe ejecutarse como ADMINISTRADOR" -ForegroundColor Red
    Write-Host "   Haz clic derecho en PowerShell y selecciona 'Ejecutar como administrador'" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "✅ Ejecutándose con permisos de administrador" -ForegroundColor Green
Write-Host ""

# 1. Configurar energía para laptop cerrada
Write-Host "🔋 Configurando opciones de energía..." -ForegroundColor Yellow

# Configurar para que no entre en suspensión nunca
powercfg -change -standby-timeout-ac 0
powercfg -change -standby-timeout-dc 0
powercfg -change -hibernate-timeout-ac 0
powercfg -change -hibernate-timeout-dc 0

# Configurar pantalla (puede apagarse después de 10 minutos)
powercfg -change -monitor-timeout-ac 10
powercfg -change -monitor-timeout-dc 10

# Configurar comportamiento de tapa cerrada (no hacer nada)
powercfg -setacvalueindex scheme_current 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
powercfg -setdcvalueindex scheme_current 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
powercfg -setactive scheme_current

Write-Host "✅ Configuración de energía completada" -ForegroundColor Green
Write-Host "   - No entrará en suspensión" -ForegroundColor Gray
Write-Host "   - Al cerrar la tapa: No hacer nada" -ForegroundColor Gray
Write-Host ""

# 2. Configurar firewall
Write-Host "🔥 Configurando firewall de Windows..." -ForegroundColor Yellow

try {
    # Crear reglas de firewall para los puertos del sistema
    New-NetFirewallRule -DisplayName "Residencia Platos - Backend" -Direction Inbound -Protocol TCP -LocalPort 3000 -Action Allow -ErrorAction SilentlyContinue
    New-NetFirewallRule -DisplayName "Residencia Platos - Frontend" -Direction Inbound -Protocol TCP -LocalPort 5173 -Action Allow -ErrorAction SilentlyContinue
    
    Write-Host "✅ Reglas de firewall creadas" -ForegroundColor Green
    Write-Host "   - Puerto 3000 (Backend): Permitido" -ForegroundColor Gray
    Write-Host "   - Puerto 5173 (Frontend): Permitido" -ForegroundColor Gray
} catch {
    Write-Host "⚠️  Error configurando firewall: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "   Configúralo manualmente en Panel de Control > Firewall" -ForegroundColor Gray
}
Write-Host ""

# 3. Configurar política de ejecución de PowerShell
Write-Host "📝 Configurando PowerShell..." -ForegroundColor Yellow

try {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
    Write-Host "✅ Política de ejecución de PowerShell configurada" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Error configurando PowerShell: $($_.Exception.Message)" -ForegroundColor Yellow
}
Write-Host ""

# 4. Verificar Node.js
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

# 5. Mostrar información de red
Write-Host "🌐 Información de red:" -ForegroundColor Yellow

try {
    $networkConfig = Get-NetIPConfiguration | Where-Object {$_.IPv4DefaultGateway -ne $null}
    $ip = $networkConfig.IPv4Address.IPAddress
    $gateway = $networkConfig.IPv4DefaultGateway.NextHop
    
    Write-Host "✅ Configuración de red detectada" -ForegroundColor Green
    Write-Host "   - IP del servidor: $ip" -ForegroundColor Gray
    Write-Host "   - Gateway: $gateway" -ForegroundColor Gray
    Write-Host "   - Acceso móvil: http://$ip:5173" -ForegroundColor Gray
} catch {
    Write-Host "⚠️  No se pudo detectar la configuración de red" -ForegroundColor Yellow
    Write-Host "   Ejecuta 'ipconfig' para ver tu IP manualmente" -ForegroundColor Gray
}
Write-Host ""

# 6. Crear acceso directo en el escritorio (opcional)
Write-Host "🖱️  ¿Crear acceso directo en el escritorio? (y/n): " -ForegroundColor Yellow -NoNewline
$createShortcut = Read-Host

if ($createShortcut -eq 'y' -or $createShortcut -eq 'Y' -or $createShortcut -eq 'yes') {
    try {
        $desktop = [System.Environment]::GetFolderPath('Desktop')
        $shortcutPath = Join-Path $desktop "Sistema Platos Residencia.lnk"
        $targetPath = Join-Path $PSScriptRoot "start-server.bat"
        
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $targetPath
        $shortcut.WorkingDirectory = $PSScriptRoot
        $shortcut.Description = "Sistema de Platos - Residencia Universitaria"
        $shortcut.Save()
        
        Write-Host "✅ Acceso directo creado en el escritorio" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Error creando acceso directo: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "🎉 ═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "   ¡CONFIGURACIÓN COMPLETADA!" -ForegroundColor Green
Write-Host "🎉 ═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Resumen de configuración:" -ForegroundColor Cyan
Write-Host "   ✅ Laptop configurada para funcionar con tapa cerrada" -ForegroundColor Green
Write-Host "   ✅ Firewall configurado para acceso móvil" -ForegroundColor Green
Write-Host "   ✅ PowerShell configurado" -ForegroundColor Green
Write-Host "   ✅ Todo listo para funcionar como servidor 24/7" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 Para iniciar el servidor:" -ForegroundColor Yellow
Write-Host "   1. Ejecuta: .\start-server.ps1" -ForegroundColor White
Write-Host "   2. O doble clic en: start-server.bat" -ForegroundColor White
Write-Host "   3. ¡Cierra la tapa y listo!" -ForegroundColor White
Write-Host ""
Write-Host "📱 Los estudiantes podrán acceder desde:" -ForegroundColor Yellow
if ($ip) {
    Write-Host "   http://$ip:5173" -ForegroundColor White
} else {
    Write-Host "   http://[TU-IP]:5173" -ForegroundColor White
}
Write-Host ""

pause
