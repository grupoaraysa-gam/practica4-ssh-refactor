# Colores para output (PowerShell)
$RED = "Red"
$GREEN = "Green"
$YELLOW = "Yellow"
$CYAN = "Cyan"

# Función para verificar si es administrador
function Verificar-Administrador {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    
    if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Verificado: usuario Administrador" -ForegroundColor Green
        return $true
    } else {
        Write-Host "Error: Este script debe ejecutarse como Administrador" -ForegroundColor Red
        Write-Host "Ejecute PowerShell como Administrador" -ForegroundColor Yellow
        return $false
    }
}

# Función para instalar características de Windows
function Install-WindowsFeatureWrapper {
    param(
        [string]$Name,
        [string]$Description = ""
    )
    
    if ($Description) {
        Write-Host "Instalando $Description..." -ForegroundColor Yellow
    } else {
        Write-Host "Instalando $Name..." -ForegroundColor Yellow
    }
    
    $result = Install-WindowsFeature -Name $Name -IncludeManagementTools
    
    if ($result.Success) {
        Write-Host "$Name instalado correctamente" -ForegroundColor Green
        return $true
    } else {
        Write-Host "Error instalando $Name" -ForegroundColor Red
        return $false
    }
}

# Función para verificar si un servicio está activo
function Verificar-Servicio {
    param([string]$ServiceName)
    
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    
    if ($service -and $service.Status -eq 'Running') {
        Write-Host "✓ $ServiceName está activo" -ForegroundColor Green
        return $true
    } else {
        Write-Host "✗ $ServiceName no está activo" -ForegroundColor Red
        return $false
    }
}

# Función para iniciar y habilitar un servicio
function Iniciar-Servicio {
    param([string]$ServiceName)
    
    Write-Host "Configurando $ServiceName..." -ForegroundColor Yellow
    
    Set-Service -Name $ServiceName -StartupType Automatic
    Start-Service -Name $ServiceName
    
    Verificar-Servicio -ServiceName $ServiceName
}

# Función para validar IP
function Validar-IP {
    param([string]$IP)
    
    $regex = '^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    
    if ($IP -match $regex) {
        Write-Host "✓ IP válida: $IP" -ForegroundColor Green
        return $true
    } else {
        Write-Host "✗ IP inválida: $IP" -ForegroundColor Red
        return $false
    }
}

# Función para configurar firewall
function Configurar-Firewall {
    param(
        [int]$Port,
        [string]$RuleName,
        [string]$Protocol = "TCP"
    )
    
    Write-Host "Configurando regla de firewall para puerto $Port..." -ForegroundColor Yellow
    
    # Verificar si la regla ya existe
    $existingRule = Get-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue
    
    if ($existingRule) {
        Write-Host "Regla $RuleName ya existe, actualizando..." -ForegroundColor Yellow
        Remove-NetFirewallRule -DisplayName $RuleName
    }
    
    # Crear nueva regla
    New-NetFirewallRule -DisplayName $RuleName -Direction Inbound -Protocol $Protocol -LocalPort $Port -Action Allow
    
    Write-Host "✓ Regla de firewall configurada para puerto $Port" -ForegroundColor Green
}

# Función para mostrar mensajes
function Mostrar-Exito {
    param([string]$Message)
    Write-Host "$Message" -ForegroundColor Green
}

function Mostrar-Error {
    param([string]$Message)
    Write-Host "$Message" -ForegroundColor Red
}

function Mostrar-Progreso {
    param([string]$Message)
    Write-Host "$Message" -ForegroundColor Cyan
}
