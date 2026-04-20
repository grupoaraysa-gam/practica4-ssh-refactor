# Cargar funciones comunes
. "C:\practica4-ssh-refactor\windows\funciones\common.ps1"

# Función para instalar servidor DHCP
function Install-DhcpServer {
    Write-Host "=== INSTALANDO SERVIDOR DHCP (Windows) ===" -ForegroundColor Cyan
    
    # Instalar rol DHCP
    Install-WindowsFeatureWrapper -Name "DHCP" -Description "Servidor DHCP"
    
    if ($?) {
        # Configurar firewall para DHCP
        Configurar-Firewall -Port 67 -RuleName "DHCP-Server" -Protocol "UDP"
        
        # Autorizar servidor DHCP en AD (para dominio)
        try {
            Add-DhcpServerInDC -DnsName $env:COMPUTERNAME
            Write-Host "✓ Servidor DHCP autorizado en el dominio" -ForegroundColor Green
        } catch {
            Write-Host "Nota: No se pudo autorizar DHCP (entorno sin dominio)" -ForegroundColor Yellow
        }
        
        Iniciar-Servicio -ServiceName "DHCPServer"
        
        Mostrar-Exito "Servidor DHCP instalado correctamente"
        return $true
    }
    return $false
}

# Función para crear alcance DHCP (Scope)
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
    Write-Host "  Subred: $Subnet" -ForegroundColor Gray
    Write-Host "  Rango: $StartRange - $EndRange" -ForegroundColor Gray
    
    # Crear el alcance
    Add-DhcpServerv4Scope -Name $ScopeName -StartRange $StartRange -EndRange $EndRange -SubnetMask $Netmask
    
    # Configurar opciones del alcance
    Set-DhcpServerv4OptionValue -ScopeId $Subnet -Router $Gateway
    Set-DhcpServerv4OptionValue -ScopeId $Subnet -DnsServer $DnsServer
    Set-DhcpServerv4OptionValue -ScopeId $Subnet -DnsDomain "sistemas.local"
    
    # Activar el alcance
    Set-DhcpServerv4Scope -ScopeId $Subnet -State Active
    
    Mostrar-Exito "Alcance DHCP configurado correctamente"
    
    # Mostrar configuración
    Write-Host "`nConfiguración del alcance:" -ForegroundColor Cyan
    Get-DhcpServerv4Scope -ScopeId $Subnet | Format-Table ScopeId, SubnetMask, Name, State
}

# Función para excluir direcciones IP del rango DHCP
function Add-DhcpExclusion {
    param(
        [string]$Subnet,
        [string]$StartIP,
        [string]$EndIP
    )
    
    Write-Host "Excluyendo IPs: $StartIP - $EndIP" -ForegroundColor Yellow
    Add-DhcpServerv4ExclusionRange -ScopeId $Subnet -StartRange $StartIP -EndRange $EndIP
    Mostrar-Exito "Rango excluido correctamente"
}

# Función para verificar estado del DHCP
function Get-DhcpStatus {
    Write-Host "=== ESTADO DEL SERVIDOR DHCP ===" -ForegroundColor Cyan
    Verificar-Servicio -ServiceName "DHCPServer"
    
    Write-Host "`nAlcances configurados:" -ForegroundColor Yellow
    Get-DhcpServerv4Scope | Format-Table ScopeId, SubnetMask, Name, State, StartRange, EndRange
    
    Write-Host "`nConcesiones activas:" -ForegroundColor Yellow
    Get-DhcpServerv4Lease | Format-Table IPAddress, ClientId, HostName, LeaseExpiryTime
}

# Función para respaldar configuración DHCP
function Backup-DhcpConfig {
    param([string]$BackupPath = "C:\practica4-ssh-refactor\windows\configs\dhcp_backup")
    
    Write-Host "Respaldando configuración DHCP..." -ForegroundColor Yellow
    Backup-DhcpServer -Path $BackupPath
    Mostrar-Exito "Respaldo guardado en: $BackupPath"
}
