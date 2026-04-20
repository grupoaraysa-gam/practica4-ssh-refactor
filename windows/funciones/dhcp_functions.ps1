# =========================
# CARGAR FUNCIONES COMUNES
# =========================
. "C:\practica4-ssh-refactor\windows\funciones\common.ps1"

# =========================
# INSTALAR DHCP SERVER
# =========================
function Install-DhcpServer {
    Write-Host "INSTALANDO SERVIDOR DHCP (Windows)" -ForegroundColor Cyan

    Install-WindowsFeatureWrapper -Name "DHCP" -Description "Servidor DHCP"

    if ($?) {

        # Firewall DHCP
        Configurar-Firewall -Port 67 -RuleName "DHCP-Server" -Protocol "UDP"
        Configurar-Firewall -Port 68 -RuleName "DHCP-Client" -Protocol "UDP"

        # Autorizar en dominio (si aplica)
        try {
            Add-DhcpServerInDC -DnsName $env:COMPUTERNAME
            Write-Host "Servidor DHCP autorizado en el dominio" -ForegroundColor Green
        }
        catch {
            Write-Host "No se pudo autorizar DHCP (entorno sin dominio)" -ForegroundColor Yellow
        }

        Iniciar-Servicio -ServiceName "DHCPServer"

        Mostrar-Exito "Servidor DHCP instalado correctamente"
        return $true
    }

    return $false
}

# =========================
# CREAR SCOPE DHCP
# =========================
function New-DhcpScope {
    param(
        [string]$ScopeName,
        [string]$Subnet,
        [string]$Netmask,
        [string]$StartRange,
        [string]$EndRange,
        [string]$Gateway,
        [string]$DnsServer
    )

    Write-Host "Configurando alcance DHCP..." -ForegroundColor Yellow
    Write-Host "Subred: $Subnet"
    Write-Host "Rango: $StartRange - $EndRange"

    Add-DhcpServerv4Scope `
        -Name $ScopeName `
        -StartRange $StartRange `
        -EndRange $EndRange `
        -SubnetMask $Netmask

    Set-DhcpServerv4OptionValue -ScopeId $Subnet -Router $Gateway
    Set-DhcpServerv4OptionValue -ScopeId $Subnet -DnsServer $DnsServer
    Set-DhcpServerv4OptionValue -ScopeId $Subnet -DnsDomain "sistemas.local"

    Set-DhcpServerv4Scope -ScopeId $Subnet -State Active

    Mostrar-Exito "Alcance DHCP configurado correctamente"

    Get-DhcpServerv4Scope -ScopeId $Subnet |
        Format-Table ScopeId, SubnetMask, Name, State
}

# =========================
# EXCLUSIONES DHCP
# =========================
function Add-DhcpExclusion {
    param(
        [string]$Subnet,
        [string]$StartIP,
        [string]$EndIP
    )

    Write-Host "Excluyendo IPs: $StartIP - $EndIP" -ForegroundColor Yellow

    Add-DhcpServerv4ExclusionRange `
        -ScopeId $Subnet `
        -StartRange $StartIP `
        -EndRange $EndIP

    Mostrar-Exito "Rango excluido correctamente"
}

# =========================
# ESTADO DHCP
# =========================
function Get-DhcpStatus {
    Write-Host "ESTADO DEL SERVIDOR DHCP" -ForegroundColor Cyan

    Verificar-Servicio -ServiceName "DHCPServer"

    Write-Host "`nAlcances configurados:" -ForegroundColor Yellow

    Get-DhcpServerv4Scope |
        Format-Table ScopeId, SubnetMask, Name, State, StartRange, EndRange

    Write-Host "`nConcesiones activas:" -ForegroundColor Yellow

    Get-DhcpServerv4Lease |
        Format-Table IPAddress, ClientId, HostName, LeaseExpiryTime
}

# =========================
# BACKUP DHCP
# =========================
function Backup-DhcpConfig {
    param([string]$BackupPath = "C:\practica4-ssh-refactor\windows\configs\dhcp_backup")

    Write-Host "Respaldando configuración DHCP..." -ForegroundColor Yellow

    Backup-DhcpServer -Path $BackupPath

    Mostrar-Exito "Respaldo guardado en: $BackupPath"
}