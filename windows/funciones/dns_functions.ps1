# Cargar funciones comunes
. "C:\practica4-ssh-refactor\windows\funciones\common.ps1"

# Función para instalar servidor DNS
function Install-DnsServer {
    Write-Host "=== INSTALANDO SERVIDOR DNS (Windows) ===" -ForegroundColor Cyan
    
    Install-WindowsFeatureWrapper -Name "DNS" -Description "Servidor DNS"
    
    if ($?) {
        Iniciar-Servicio -ServiceName "DNS"
        
        # Configurar firewall para DNS
        Configurar-Firewall -Port 53 -RuleName "DNS-Server" -Protocol "TCP"
        Configurar-Firewall -Port 53 -RuleName "DNS-Server-UDP" -Protocol "UDP"
        
        Mostrar-Exito "Servidor DNS instalado correctamente"
        return $true
    }
    return $false
}

# Función para crear zona DNS
function New-DnsZone {
    param(
        [string]$ZoneName,
        [string]$MasterIP
    )
    
    Write-Host "Configurando zona DNS: $ZoneName" -ForegroundColor Yellow
    
    # Verificar si el rol DNS está instalado
    $dnsRole = Get-WindowsFeature -Name DNS
    if (-not $dnsRole.Installed) {
        Write-Host "Primero debe instalar el servidor DNS" -ForegroundColor Red
        return $false
    }
    
    # Crear zona primaria
    Add-DnsServerPrimaryZone -Name $ZoneName -ZoneFile "$ZoneName.dns"
    
    # Agregar registros A
    Add-DnsServerResourceRecordA -ZoneName $ZoneName -Name "@" -IPv4Address $MasterIP
    Add-DnsServerResourceRecordA -ZoneName $ZoneName -Name "ns1" -IPv4Address $MasterIP
    Add-DnsServerResourceRecordA -ZoneName $ZoneName -Name "www" -IPv4Address $MasterIP
    
    # Configurar reenviadores
    Set-DnsServerForwarder -IPAddress "8.8.8.8", "8.8.4.4"
    
    # Reiniciar servicio DNS
    Restart-Service DNS
    
    Mostrar-Exito "Zona DNS $ZoneName configurada correctamente"
    
    # Mostrar configuración
    Write-Host "`nConfiguración de la zona:" -ForegroundColor Cyan
    Get-DnsServerResourceRecord -ZoneName $ZoneName
}

# Función para probar DNS
function Test-DnsResolution {
    param([string]$Domain)
    
    Write-Host "Probando resolución DNS para $Domain..." -ForegroundColor Yellow
    
    $result = Resolve-DnsName -Name $Domain -Server "localhost" -ErrorAction SilentlyContinue
    
    if ($result) {
        Write-Host "✓ Resolución exitosa:" -ForegroundColor Green
        $result | Format-Table Name, IPAddress, Type
        return $true
    } else {
        Write-Host "Error resolviendo $Domain" -ForegroundColor Red
        return $false
    }
}

# Función para verificar estado del DNS
function Get-DnsStatus {
    Write-Host "=== ESTADO DEL SERVIDOR DNS ===" -ForegroundColor Cyan
    Verificar-Servicio -ServiceName "DNS"
    
    Write-Host "`nZonas configuradas:" -ForegroundColor Yellow
    Get-DnsServerZone | Format-Table ZoneName, ZoneType, IsAutoCreated
    
    Write-Host "`nReenviadores configurados:" -ForegroundColor Yellow
    Get-DnsServerForwarder | Select-Object -ExpandProperty IPAddress
}
