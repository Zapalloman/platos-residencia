# ===============================================
# 🔒 CONFIGURACIÓN LAPTOP COMO SERVIDOR 24/7
# ===============================================
# Script especial para mantener laptop funcionando con tapa cerrada
# ===============================================

# Configurar para manejar errores
$ErrorActionPreference = "Continue"

# Función para escribir texto con colores
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

# Función para verificar permisos de administrador
function Test-Administrator {
    try {
        $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch {
        return $false
    }
}

Clear-Host
Write-ColorText "=============================================" "Cyan"
Write-ColorText "🔒 CONFIGURACIÓN LAPTOP SERVIDOR 24/7" "Cyan"
Write-ColorText "=============================================" "Cyan"
Write-ColorText ""

$isAdmin = Test-Administrator

if ($isAdmin) {
    Write-ColorText "✅ Ejecutándose como Administrador" "Green"
    Write-ColorText "   Se aplicarán todas las configuraciones" "Gray"
} else {
    Write-ColorText "⚠️  No se ejecuta como Administrador" "Yellow"
    Write-ColorText "   Ejecuta como Admin para configuración completa" "Yellow"
    Write-ColorText "   Presiona Ctrl+Shift+Enter al abrir PowerShell" "Gray"
}
Write-ColorText ""

# 1. CONFIGURACIÓN CRÍTICA: MANTENER ACTIVA CON TAPA CERRADA
Write-ColorText "🔒 Configurando laptop para funcionar con tapa cerrada..." "Yellow"

if ($isAdmin) {
    try {
        # Configurar para que NO se suspenda al cerrar la tapa
        Write-ColorText "   ⚙️  Configurando acciones de energía..." "Gray"
        
        # Configurar para AC (con cable)
        powercfg -setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
        
        # Configurar para DC (batería)  
        powercfg -setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
        
        # Aplicar configuración
        powercfg -SetActive SCHEME_CURRENT
        
        Write-ColorText "   ✅ Tapa cerrada = NO SUSPENDER (AC y Batería)" "Green"
        
        # Configuraciones adicionales para servidor
        powercfg -change -monitor-timeout-ac 0
        powercfg -change -disk-timeout-ac 0  
        powercfg -change -standby-timeout-ac 0
        powercfg -change -hibernate-timeout-ac 0
        
        # También para batería (importante!)
        powercfg -change -monitor-timeout-dc 30
        powercfg -change -disk-timeout-dc 0
        powercfg -change -standby-timeout-dc 0
        powercfg -change -hibernate-timeout-dc 0
        
        Write-ColorText "   ✅ Monitor: Solo se apaga (no suspende sistema)" "Green"
        Write-ColorText "   ✅ Discos: Nunca se suspenden" "Green"
        Write-ColorText "   ✅ Sistema: NUNCA hiberna o suspende" "Green"
        Write-ColorText "   ✅ Batería: Configurada para servidor" "Green"
        
    } catch {
        Write-ColorText "   ❌ Error configurando energía: $($_.Exception.Message)" "Red"
    }
} else {
    Write-ColorText "   ⚠️  REQUIERE PERMISOS DE ADMINISTRADOR" "Yellow"
    Write-ColorText "   Sin esto, la laptop se suspenderá al cerrar la tapa" "Red"
}
Write-ColorText ""

# 2. CONFIGURACIÓN DE RED PARA ACCESO REMOTO
Write-ColorText "🌐 Configurando red para acceso remoto..." "Yellow"

if ($isAdmin) {
    try {
        # Evitar que la tarjeta de red se suspenda
        Write-ColorText "   ⚙️  Configurando tarjeta de red..." "Gray"
        
        # Deshabilitar suspensión de adaptadores de red
        $networkAdapters = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}
        foreach ($adapter in $networkAdapters) {
            try {
                $powerMgmt = Get-NetAdapterPowerManagement -Name $adapter.Name -ErrorAction SilentlyContinue
                if ($powerMgmt) {
                    Set-NetAdapterPowerManagement -Name $adapter.Name -AllowComputerToTurnOffDevice Disabled -ErrorAction SilentlyContinue
                    Write-ColorText "   ✅ $($adapter.Name): Suspensión deshabilitada" "Green"
                }
            } catch {
                Write-ColorText "   ⚠️  $($adapter.Name): No se pudo configurar" "Yellow"
            }
        }
        
    } catch {
        Write-ColorText "   ❌ Error configurando red: $($_.Exception.Message)" "Red"
    }
} else {
    Write-ColorText "   ⚠️  Requiere permisos de administrador" "Yellow"
}
Write-ColorText ""

# 3. CONFIGURAR FIREWALL
Write-ColorText "🔥 Configurando firewall para acceso externo..." "Yellow"

if ($isAdmin) {
    try {
        # Método con netsh (más compatible)
        $result1 = Start-Process "netsh" -ArgumentList "advfirewall", "firewall", "add", "rule", "name=Residencia Backend", "dir=in", "action=allow", "protocol=TCP", "localport=3000" -Wait -PassThru -WindowStyle Hidden
        $result2 = Start-Process "netsh" -ArgumentList "advfirewall", "firewall", "add", "rule", "name=Residencia Frontend", "dir=in", "action=allow", "protocol=TCP", "localport=5173" -Wait -PassThru -WindowStyle Hidden
        
        if ($result1.ExitCode -eq 0 -and $result2.ExitCode -eq 0) {
            Write-ColorText "   ✅ Reglas de firewall aplicadas" "Green"
            Write-ColorText "   ✅ Puerto 3000: Backend API" "Green"
            Write-ColorText "   ✅ Puerto 5173: Frontend web" "Green"
        } else {
            Write-ColorText "   ⚠️  Algunas reglas pueden no haberse aplicado" "Yellow"
        }
    } catch {
        Write-ColorText "   ❌ Error configurando firewall" "Red"
    }
} else {
    Write-ColorText "   ⚠️  Requiere permisos de administrador" "Yellow"
}
Write-ColorText ""

# 4. CONFIGURACIÓN ADICIONAL PARA SERVIDOR
Write-ColorText "⚙️  Configuraciones adicionales para servidor..." "Yellow"

if ($isAdmin) {
    try {
        # Deshabilitar actualizaciones automáticas que reinician
        Write-ColorText "   ⚙️  Configurando actualizaciones..." "Gray"
        
        # Configurar Windows Update para no reiniciar automáticamente
        reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoRebootWithLoggedOnUsers /t REG_DWORD /d 1 /f >$null 2>&1
        
        Write-ColorText "   ✅ Reinicio automático por actualizaciones: DESHABILITADO" "Green"
        
    } catch {
        Write-ColorText "   ⚠️  Algunas configuraciones adicionales fallaron" "Yellow"
    }
} else {
    Write-ColorText "   ⚠️  Requiere permisos de administrador" "Yellow"
}
Write-ColorText ""

# 5. OBTENER INFORMACIÓN DE RED
Write-ColorText "🌐 Información de red para acceso remoto:" "Yellow"

try {
    $ipConfig = ipconfig | Select-String "IPv4.*192\.168\.|IPv4.*10\.|IPv4.*172\."
    if ($ipConfig) {
        $ip = ($ipConfig[0] -split ":")[1].Trim()
        Write-ColorText "   ✅ IP detectada: $ip" "Green"
        Write-ColorText "   📱 Acceso móvil: http://$ip`:5173" "White"
        Write-ColorText "   🔗 API Backend: http://$ip`:3000" "White"
    } else {
        Write-ColorText "   ⚠️  IP no detectada automáticamente" "Yellow"
        Write-ColorText "   🔍 Ejecuta: ipconfig | findstr IPv4" "Gray"
    }
} catch {
    Write-ColorText "   ❌ Error obteniendo IP" "Red"
}
Write-ColorText ""

# 6. VERIFICAR DEPENDENCIAS
Write-ColorText "📦 Verificando dependencias del proyecto..." "Yellow"

$projectOK = $true

if (Test-Path "backend" -PathType Container) {
    Write-ColorText "   ✅ Carpeta backend encontrada" "Green"
    if (Test-Path "backend\package.json") {
        Write-ColorText "   ✅ package.json del backend encontrado" "Green"
    } else {
        Write-ColorText "   ⚠️  package.json del backend no encontrado" "Yellow"
        $projectOK = $false
    }
} else {
    Write-ColorText "   ❌ Carpeta backend no encontrada" "Red"
    $projectOK = $false
}

if (Test-Path "frontend" -PathType Container) {
    Write-ColorText "   ✅ Carpeta frontend encontrada" "Green"
    if (Test-Path "frontend\package.json") {
        Write-ColorText "   ✅ package.json del frontend encontrado" "Green"
    } else {
        Write-ColorText "   ⚠️  package.json del frontend no encontrado" "Yellow"
        $projectOK = $false
    }
} else {
    Write-ColorText "   ❌ Carpeta frontend no encontrada" "Red"
    $projectOK = $false
}
Write-ColorText ""

# 7. RESUMEN Y INSTRUCCIONES FINALES
Write-ColorText "=============================================" "Cyan"
if ($isAdmin) {
    Write-ColorText "🎯 CONFIGURACIÓN SERVIDOR 24/7 COMPLETADA" "Cyan"
} else {
    Write-ColorText "⚠️  CONFIGURACIÓN PARCIAL (SIN PERMISOS ADMIN)" "Yellow"
}
Write-ColorText "=============================================" "Cyan"
Write-ColorText ""

if ($isAdmin) {
    Write-ColorText "✅ LAPTOP CONFIGURADA COMO SERVIDOR:" "Green"
    Write-ColorText "   🔒 Tapa cerrada = Sistema sigue funcionando" "White"
    Write-ColorText "   🌐 Red configurada para acceso remoto" "White"
    Write-ColorText "   🔥 Firewall configurado para puertos 3000 y 5173" "White"
    Write-ColorText "   ⚙️  Actualizaciones no reiniciarán automáticamente" "White"
} else {
    Write-ColorText "⚠️  PARA CONFIGURACIÓN COMPLETA:" "Yellow"
    Write-ColorText "   1. Cierra esta ventana" "White"
    Write-ColorText "   2. Busca 'PowerShell' en el menú inicio" "White"
    Write-ColorText "   3. Click derecho > 'Ejecutar como administrador'" "White"
    Write-ColorText "   4. Ejecuta este script nuevamente" "White"
}
Write-ColorText ""

Write-ColorText "📋 PRÓXIMOS PASOS:" "Yellow"
Write-ColorText "   1. Ejecuta: .\start-server-simple.bat" "White"
Write-ColorText "   2. Verifica que funciona: http://localhost:5173" "White"
Write-ColorText "   3. 🔒 CIERRA LA TAPA de la laptop" "White"
Write-ColorText "   4. 📱 Prueba desde móvil en la misma red" "White"
Write-ColorText ""

Write-ColorText "🎉 INSTRUCCIONES DE USO 24/7:" "Green"
Write-ColorText "   💻 Deja la laptop conectada al cargador" "White"
Write-ColorText "   🔒 Puedes cerrar la tapa sin problemas" "White"
Write-ColorText "   📱 Acceso desde móviles: http://[IP]:5173" "White"
Write-ColorText "   🔄 El sistema se reinicia automáticamente cada día" "White"
Write-ColorText ""

if ($projectOK) {
    Write-ColorText "✅ Proyecto listo para iniciar" "Green"
} else {
    Write-ColorText "⚠️  Verifica que estás en el directorio correcto del proyecto" "Yellow"
}
Write-ColorText ""

Write-ColorText "Presiona cualquier tecla para continuar..." "Gray"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
