# ===============================================
# SETUP SERVIDOR RESIDENCIA - VERSION COMPATIBLE
# ===============================================
# Version mejorada para funcionar en cualquier laptop Windows
# ===============================================

# Configurar para manejar errores sin detener el script
$ErrorActionPreference = "Continue"

# Función para escribir texto con colores (compatible con todas las versiones)
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

# Función para verificar si es administrador
function Test-Administrator {
    try {
        $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch {
        return $false
    }
}

# Función para ejecutar comandos de forma segura
function Invoke-SafeCommand {
    param(
        [string]$Command,
        [string]$SuccessMessage,
        [string]$ErrorMessage
    )
    
    try {
        Invoke-Expression $Command | Out-Null
        Write-ColorText "✅ $SuccessMessage" "Green"
        return $true
    } catch {
        Write-ColorText "❌ $ErrorMessage" "Red"
        return $false
    }
}

# Inicio del script
Clear-Host
Write-ColorText "=============================================" "Cyan"
Write-ColorText "🏠 CONFIGURADOR SERVIDOR RESIDENCIA" "Cyan"
Write-ColorText "=============================================" "Cyan"
Write-ColorText ""

# Verificar permisos de administrador
$isAdmin = Test-Administrator

if ($isAdmin) {
    Write-ColorText "✅ Ejecutandose como Administrador" "Green"
} else {
    Write-ColorText "⚠️  No se ejecuta como Administrador" "Yellow"
    Write-ColorText "   Algunas funciones avanzadas no estaran disponibles" "Gray"
}
Write-ColorText ""

# 1. Configurar energia para mantener laptop activa
Write-ColorText "⚡ Configurando energia para servidor 24/7..." "Yellow"

if ($isAdmin) {
    $energyCommands = @(
        "powercfg -change -monitor-timeout-ac 0",
        "powercfg -change -disk-timeout-ac 0",
        "powercfg -change -standby-timeout-ac 0",
        "powercfg -change -hibernate-timeout-ac 0"
    )
    
    $energySuccess = $true
    foreach ($cmd in $energyCommands) {
        if (-not (Invoke-SafeCommand $cmd "" "")) {
            $energySuccess = $false
        }
    }
    
    if ($energySuccess) {
        Write-ColorText "✅ Configuracion de energia aplicada" "Green"
        Write-ColorText "   - Monitor: Nunca se apaga" "Gray"
        Write-ColorText "   - Sistema: Nunca hiberna/suspende" "Gray"
    }
} else {
    Write-ColorText "⚠️  Configuracion de energia requiere permisos de administrador" "Yellow"
}
Write-ColorText ""

# 2. Configurar firewall (version compatible)
Write-ColorText "🔥 Configurando firewall..." "Yellow"

if ($isAdmin) {
    try {
        # Metodo alternativo para firewall que funciona en mas versiones
        $firewallSuccess = $true
        
        # Intentar con netsh (mas compatible)
        $result1 = Start-Process "netsh" -ArgumentList "advfirewall", "firewall", "add", "rule", "name=Residencia Backend", "dir=in", "action=allow", "protocol=TCP", "localport=3000" -Wait -PassThru -WindowStyle Hidden
        $result2 = Start-Process "netsh" -ArgumentList "advfirewall", "firewall", "add", "rule", "name=Residencia Frontend", "dir=in", "action=allow", "protocol=TCP", "localport=5173" -Wait -PassThru -WindowStyle Hidden
        
        if ($result1.ExitCode -eq 0 -and $result2.ExitCode -eq 0) {
            Write-ColorText "✅ Reglas de firewall configuradas" "Green"
            Write-ColorText "   - Puerto 3000: Backend API" "Gray"
            Write-ColorText "   - Puerto 5173: Frontend web" "Gray"
        } else {
            Write-ColorText "⚠️  Algunas reglas de firewall pueden no haberse aplicado" "Yellow"
        }
    } catch {
        Write-ColorText "⚠️  Error configurando firewall, puede requerir configuracion manual" "Yellow"
    }
} else {
    Write-ColorText "⚠️  Configuracion de firewall requiere permisos de administrador" "Yellow"
}
Write-ColorText ""

# 3. Verificar Node.js (version compatible)
Write-ColorText "🔍 Verificando Node.js..." "Yellow"

try {
    $nodeCheck = Start-Process "node" -ArgumentList "--version" -Wait -PassThru -WindowStyle Hidden -RedirectStandardOutput "node_version.tmp" -RedirectStandardError "node_error.tmp"
    
    if ($nodeCheck.ExitCode -eq 0 -and (Test-Path "node_version.tmp")) {
        $nodeVersion = Get-Content "node_version.tmp" -ErrorAction SilentlyContinue
        Remove-Item "node_version.tmp" -ErrorAction SilentlyContinue
        Remove-Item "node_error.tmp" -ErrorAction SilentlyContinue
        
        if ($nodeVersion) {
            Write-ColorText "✅ Node.js detectado" "Green"
            Write-ColorText "   - Version: $nodeVersion" "Gray"
            
            # Verificar npm
            $npmCheck = Start-Process "npm" -ArgumentList "--version" -Wait -PassThru -WindowStyle Hidden -RedirectStandardOutput "npm_version.tmp" -RedirectStandardError "npm_error.tmp"
            if ($npmCheck.ExitCode -eq 0 -and (Test-Path "npm_version.tmp")) {
                $npmVersion = Get-Content "npm_version.tmp" -ErrorAction SilentlyContinue
                Write-ColorText "   - npm: $npmVersion" "Gray"
                Remove-Item "npm_version.tmp" -ErrorAction SilentlyContinue
            }
            Remove-Item "npm_error.tmp" -ErrorAction SilentlyContinue
        }
    } else {
        throw "Node.js no encontrado"
    }
} catch {
    Write-ColorText "❌ Node.js no esta instalado" "Red"
    Write-ColorText "   📥 Descargalo desde: https://nodejs.org/" "Yellow"
    Write-ColorText "   🔄 Reinicia la terminal despues de instalar" "Yellow"
}
Write-ColorText ""

# 4. Mostrar informacion de red (version compatible)
Write-ColorText "🌐 Informacion de red:" "Yellow"

try {
    # Metodo compatible para obtener IP
    $ipConfig = ipconfig | Select-String "IPv4"
    $localIPs = @()
    
    foreach ($line in $ipConfig) {
        if ($line -match "192\.168\.|10\.|172\.") {
            $ip = ($line -split ":")[1].Trim()
            if ($ip -and $ip -ne "127.0.0.1") {
                $localIPs += $ip
            }
        }
    }
    
    if ($localIPs.Count -gt 0) {
        Write-ColorText "✅ Red detectada" "Green"
        foreach ($ip in $localIPs) {
            Write-ColorText "   - IP local: $ip" "Gray"
        }
        $mainIP = $localIPs[0]
    } else {
        Write-ColorText "⚠️  No se detecto conexion de red local" "Yellow"
        $mainIP = $null
    }
} catch {
    Write-ColorText "❌ Error obteniendo informacion de red" "Red"
    $mainIP = $null
}
Write-ColorText ""

# 5. Verificar dependencias del proyecto
Write-ColorText "📦 Verificando dependencias..." "Yellow"

if (Test-Path "backend" -PathType Container) {
    Write-ColorText "✅ Carpeta backend encontrada" "Green"
    
    if (Test-Path "backend\package.json") {
        Write-ColorText "✅ package.json del backend encontrado" "Green"
    } else {
        Write-ColorText "⚠️  package.json del backend no encontrado" "Yellow"
    }
} else {
    Write-ColorText "❌ Carpeta backend no encontrada" "Red"
}

if (Test-Path "frontend" -PathType Container) {
    Write-ColorText "✅ Carpeta frontend encontrada" "Green"
    
    if (Test-Path "frontend\package.json") {
        Write-ColorText "✅ package.json del frontend encontrado" "Green"
    } else {
        Write-ColorText "⚠️  package.json del frontend no encontrado" "Yellow"
    }
} else {
    Write-ColorText "❌ Carpeta frontend no encontrada" "Red"
}
Write-ColorText ""

# 6. Resumen y proximos pasos
Write-ColorText "=============================================" "Cyan"
Write-ColorText "🎯 CONFIGURACION COMPLETADA" "Cyan"
Write-ColorText "=============================================" "Cyan"
Write-ColorText ""
Write-ColorText "📋 Proximos pasos:" "Yellow"
Write-ColorText "   1. Ejecuta: .\start-server.ps1" "White"
Write-ColorText "   2. O doble clic en: start-server.bat" "White"
Write-ColorText "   3. ¡Cierra la tapa y listo!" "White"
Write-ColorText ""
Write-ColorText "📱 Los estudiantes podran acceder desde:" "Yellow"
if ($mainIP) {
    Write-ColorText "   http://$mainIP`:5173" "White"
} else {
    Write-ColorText "   http://[TU-IP]:5173" "White"
}
Write-ColorText ""

Write-ColorText "Presiona cualquier tecla para continuar..." "Gray"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
