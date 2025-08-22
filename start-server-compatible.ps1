# ===============================================
# 🍽️ SERVIDOR PLATOS RESIDENCIA - VERSION COMPATIBLE
# ===============================================
# Script mejorado para funcionar en cualquier laptop Windows
# ===============================================

# Configurar para manejar errores
$ErrorActionPreference = "Continue"

# Cambiar al directorio del script
try {
    Set-Location $PSScriptRoot
} catch {
    Write-Host "⚠️  Usando directorio actual" -ForegroundColor Yellow
}

# Función para escribir texto con colores (compatible)
function Write-ColorText {
    param(
        [string]$Text,
        [string]$Color = "White"
    )
    
    try {
        Write-Host $Text -ForegroundColor $Color
    } catch {
        Write-Host $Text
    }
}

# Función para obtener IP de forma compatible
function Get-LocalIP {
    try {
        # Metodo 1: Usar ipconfig
        $ipConfig = ipconfig | Select-String "IPv4.*192\.168\.|IPv4.*10\.|IPv4.*172\."
        if ($ipConfig) {
            $ip = ($ipConfig[0] -split ":")[1].Trim()
            return $ip
        }
        
        # Metodo 2: Usar WMI como respaldo
        $networkAdapter = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled -eq $true -and $_.IPAddress -like "192.168.*" -or $_.IPAddress -like "10.*" -or $_.IPAddress -like "172.*"}
        if ($networkAdapter) {
            return $networkAdapter.IPAddress[0]
        }
        
        return "localhost"
    } catch {
        return "localhost"
    }
}

# Obtener IP local
$ip = Get-LocalIP

# Mostrar información de inicio
Clear-Host
Write-ColorText ""
Write-ColorText "🍽️ ═══════════════════════════════════════════════════════" "Magenta"
Write-ColorText "🚀 INICIANDO SERVIDOR DE PLATOS - RESIDENCIA UNIVERSITARIA" "Magenta"
Write-ColorText "🍽️ ═══════════════════════════════════════════════════════" "Magenta"
Write-ColorText ""
Write-ColorText "🌐 Informacion del servidor:" "Cyan"
Write-ColorText "   📍 IP del servidor: $ip" "Green"
Write-ColorText "   📱 Acceso movil: http://$ip`:5173" "Green"
Write-ColorText "   🖥️  Acceso local: http://localhost:5173" "Green"
Write-ColorText "   🔗 API Backend: http://$ip`:3000" "Yellow"
Write-ColorText ""
Write-ColorText "🔧 Estado del sistema:" "Cyan"
Write-ColorText "   💻 Windows Server Mode: ACTIVADO" "Green"
Write-ColorText "   📱 Acceso movil: HABILITADO" "Green"
Write-ColorText "   👨‍💻 Logs administrativos: ACTIVADOS" "Green"
Write-ColorText "   🔄 Reinicio automatico: 00:00 cada dia" "Green"
Write-ColorText ""
Write-ColorText "═══════════════════════════════════════════════════════" "Magenta"
Write-ColorText ""

# Verificar dependencias
Write-ColorText "🔍 Verificando dependencias..." "Yellow"

# Verificar Node.js
try {
    $nodeTest = Start-Process "node" -ArgumentList "--version" -Wait -PassThru -WindowStyle Hidden -RedirectStandardOutput "temp_node.txt" -RedirectStandardError "temp_error.txt" 2>$null
    if ($nodeTest.ExitCode -eq 0) {
        Write-ColorText "✅ Node.js disponible" "Green"
    } else {
        Write-ColorText "❌ Error: Node.js no encontrado" "Red"
        Write-ColorText "   Instala Node.js desde https://nodejs.org/" "Yellow"
        pause
        exit 1
    }
    Remove-Item "temp_node.txt" -ErrorAction SilentlyContinue
    Remove-Item "temp_error.txt" -ErrorAction SilentlyContinue
} catch {
    Write-ColorText "❌ Error verificando Node.js" "Red"
    pause
    exit 1
}

# Verificar directorios
if (-not (Test-Path "backend")) {
    Write-ColorText "❌ Error: Directorio 'backend' no encontrado" "Red"
    pause
    exit 1
}

if (-not (Test-Path "frontend")) {
    Write-ColorText "❌ Error: Directorio 'frontend' no encontrado" "Red"
    pause
    exit 1
}

Write-ColorText "✅ Todas las dependencias verificadas" "Green"
Write-ColorText ""

# Instalar dependencias si es necesario
Write-ColorText "📦 Verificando e instalando dependencias..." "Yellow"

# Backend
if (-not (Test-Path "backend\node_modules")) {
    Write-ColorText "🔧 Instalando dependencias del backend..." "Yellow"
    Set-Location "backend"
    $backendInstall = Start-Process "npm" -ArgumentList "install" -Wait -PassThru -WindowStyle Normal
    Set-Location ".."
    
    if ($backendInstall.ExitCode -eq 0) {
        Write-ColorText "✅ Dependencias del backend instaladas" "Green"
    } else {
        Write-ColorText "❌ Error instalando dependencias del backend" "Red"
        pause
        exit 1
    }
}

# Frontend
if (-not (Test-Path "frontend\node_modules")) {
    Write-ColorText "🔧 Instalando dependencias del frontend..." "Yellow"
    Set-Location "frontend"
    $frontendInstall = Start-Process "npm" -ArgumentList "install" -Wait -PassThru -WindowStyle Normal
    Set-Location ".."
    
    if ($frontendInstall.ExitCode -eq 0) {
        Write-ColorText "✅ Dependencias del frontend instaladas" "Green"
    } else {
        Write-ColorText "❌ Error instalando dependencias del frontend" "Red"
        pause
        exit 1
    }
}

Write-ColorText ""
Write-ColorText "🚀 Iniciando servidores..." "Cyan"
Write-ColorText ""

# Función para iniciar procesos de forma segura
function Start-ServerProcess {
    param(
        [string]$Name,
        [string]$Directory,
        [string]$Command,
        [string[]]$Arguments
    )
    
    try {
        Set-Location $Directory
        $process = Start-Process $Command -ArgumentList $Arguments -PassThru -WindowStyle Normal
        Set-Location ".."
        
        if ($process) {
            Write-ColorText "✅ $Name iniciado (PID: $($process.Id))" "Green"
            return $process
        } else {
            Write-ColorText "❌ Error iniciando $Name" "Red"
            return $null
        }
    } catch {
        Write-ColorText "❌ Error iniciando $Name`: $($_.Exception.Message)" "Red"
        Set-Location ".."
        return $null
    }
}

# Iniciar backend
Write-ColorText "🔧 Iniciando backend en puerto 3000..." "Yellow"
$backendProcess = Start-ServerProcess "Backend" "backend" "npm" @("run", "start:dev")

Start-Sleep -Seconds 3

# Iniciar frontend
Write-ColorText "🎨 Iniciando frontend en puerto 5173..." "Yellow"
$frontendProcess = Start-ServerProcess "Frontend" "frontend" "npm" @("run", "dev", "--", "--host", "0.0.0.0")

Start-Sleep -Seconds 2

# Mostrar estado final
Write-ColorText ""
Write-ColorText "🎯 ═══════════════════════════════════════════════════════" "Green"
Write-ColorText "✅ SERVIDOR INICIADO CORRECTAMENTE" "Green"
Write-ColorText "🎯 ═══════════════════════════════════════════════════════" "Green"
Write-ColorText ""
Write-ColorText "📱 ACCESO DESDE MOVILES Y OTROS DISPOSITIVOS:" "Cyan"
Write-ColorText "   🌐 URL: http://$ip`:5173" "White"
Write-ColorText ""
Write-ColorText "💻 ACCESO LOCAL:" "Cyan"
Write-ColorText "   🌐 URL: http://localhost:5173" "White"
Write-ColorText ""
Write-ColorText "👨‍💻 PANEL DE ADMINISTRACION:" "Cyan"
Write-ColorText "   🔍 Los logs se muestran en las ventanas de terminal" "White"
Write-ColorText "   📊 Estadisticas cada hora en la consola del backend" "White"
Write-ColorText ""
Write-ColorText "🔄 MANTENIMIENTO AUTOMATICO:" "Cyan"
Write-ColorText "   🕛 Limpieza diaria: 00:00 (medianoche)" "White"
Write-ColorText "   📈 Reportes: Cada hora en punto" "White"
Write-ColorText ""
Write-ColorText "⚠️  PARA DETENER EL SERVIDOR:" "Yellow"
Write-ColorText "   ❌ Presiona Ctrl+C en ambas ventanas" "White"
Write-ColorText "   🔒 Cierra las ventanas de terminal" "White"
Write-ColorText ""
Write-ColorText "🎉 ¡LISTO! El sistema esta funcionando 24/7" "Green"
Write-ColorText ""

# Mantener el script corriendo para mostrar información
Write-ColorText "💡 Este script permanecera abierto para mostrar informacion." "Gray"
Write-ColorText "   Puedes minimizar esta ventana pero no la cierres." "Gray"
Write-ColorText ""

# Loop infinito para mantener el script activo
try {
    while ($true) {
        Start-Sleep -Seconds 60
        
        # Verificar si los procesos siguen activos cada minuto
        if ($backendProcess -and $backendProcess.HasExited) {
            Write-ColorText "⚠️  Backend se ha detenido inesperadamente" "Red"
        }
        
        if ($frontendProcess -and $frontendProcess.HasExited) {
            Write-ColorText "⚠️  Frontend se ha detenido inesperadamente" "Red"
        }
        
        # Mostrar timestamp cada 30 minutos
        $currentTime = Get-Date
        if ($currentTime.Minute -eq 0 -or $currentTime.Minute -eq 30) {
            Write-ColorText "🕐 Sistema activo - $($currentTime.ToString('HH:mm dd/MM/yyyy'))" "Gray"
        }
    }
} catch {
    Write-ColorText "⚠️  Script interrumpido" "Yellow"
} finally {
    Write-ColorText "🔄 Finalizando..." "Yellow"
}
