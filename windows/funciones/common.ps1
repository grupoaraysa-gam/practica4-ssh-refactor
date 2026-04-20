# =========================
# COLORES
# =========================
$RED    = "Red"
$GREEN  = "Green"
$YELLOW = "Yellow"
$CYAN   = "Cyan"

# =========================
# VERIFICAR ADMINISTRADOR
# =========================
function Verificar-Administrador {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)

    if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Usuario Administrador verificado" -ForegroundColor Green
        return $true
    } else {
        Write-Host "ERROR: Ejecuta PowerShell como Administrador" -ForegroundColor Red
        return $false
    }
}

# =========================
# INSTALAR FEATURE WINDOWS
# =========================
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
        Write-Host "ERROR instalando $Name" -ForegroundColor Red
        return $false
    }
}

# =========================
# VERIFICAR SERVICIO
# =========================
function Verificar-Servicio {
    param([string]$ServiceName)

    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

    if ($null -ne $service -and $service.Status -eq "Running") {
        Write-Host "$ServiceName activo" -ForegroundColor Green
        return $true
    } else {
        Write-Host "$ServiceName detenido o no existe" -ForegroundColor Red
        return $false
    }
}

# =========================
# INICIAR SERVICIO
# =========================
function Iniciar-Servicio {
    param([string]$ServiceName)

    Write-Host "Configurando $ServiceName..." -ForegroundColor Yellow

    try {
        Set-Service -Name $ServiceName -StartupType Automatic -ErrorAction Stop
        Start-Service -Name $ServiceName -ErrorAction Stop

        Verificar-Servicio -ServiceName $ServiceName
    }
    catch {
        Write-Host "ERROR al iniciar $ServiceName: $_" -ForegroundColor Red
    }
}

# =========================
# VALIDAR IP
# =========================
function Validar-IP {
    param([string]$IP)

    try {
        [System.Net.IPAddress]::Parse($IP) | Out-Null
        Write-Host "IP válida: $IP" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "IP inválida: $IP" -ForegroundColor Red
        return $false
    }
}

# =========================
# FIREWALL
# =========================
function Configurar-Firewall {
    param(
        [int]$Port,
        [string]$RuleName,
        [string]$Protocol = "TCP"
    )

    Write-Host "Configurando firewall puerto $Port..." -ForegroundColor Yellow

    $existingRule = Get-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue

    if ($existingRule) {
        Remove-NetFirewallRule -DisplayName $RuleName
    }

    New-NetFirewallRule `
        -DisplayName $RuleName `
        -Direction Inbound `
        -Protocol $Protocol `
        -LocalPort $Port `
        -Action Allow

    Write-Host "Firewall configurado: $RuleName" -ForegroundColor Green
}

# =========================
# MENSAJES
# =========================
function Mostrar-Exito {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Green
}

function Mostrar-Error {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Red
}

function Mostrar-Progreso {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Cyan
}