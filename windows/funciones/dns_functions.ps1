# =========================
# CARGAR FUNCIONES COMUNES
# =========================
. "C:\practica4-ssh-refactor\windows\funciones\common.ps1"

# =========================
# INSTALAR DNS SERVER
# =========================
function Install-DnsServer {
    Write-Host "INSTALANDO SERVIDOR DNS (Windows)" -ForegroundColor Cyan

    Install-WindowsFeatureWrapper -Name "DNS" -Description "Servidor DNS"

    if ($?) {

        Iniciar-Servicio -ServiceName "DNS"

        # Firewall DNS
        Configurar-Firewall -Port 53 -RuleName "DNS-TCP" -Protocol "TCP"
        Configurar-Firewall -Port 53 -RuleName "DNS-UDP" -Protocol "UDP"

        Mostrar-Exito "Servidor DNS instalado correctamente"
        return $true
    }

    return $false
}

# =========================
# CREAR ZONA DNS
# =========================
function New-DnsZone {
    param(
        [string]$ZoneName,
        [string]$MasterIP
    )

    Write-Host "Configurando zona DNS: $ZoneName" -ForegroundColor Yellow

    # Validar que el rol esté instalado
    $dnsRole = Get-WindowsFeature -Name DNS

    if (-not $dnsRole.Installed) {
        Write-Host "El servidor DNS no está instalado" -ForegroundColor Red
        return $false
    }

    # Crear zona primaria
    Add-DnsServerPrimaryZone -Name $ZoneName -ZoneFile "$ZoneName.dns"

    # Registros básicos
    Add-DnsServerResourceRecordA -ZoneName $ZoneName -Name "@" -IPv4Address $MasterIP
    Add-DnsServerResourceRecordA -ZoneName $ZoneName -Name "ns1" -IPv4Address $MasterIP
    Add-DnsServerResourceRecordA -ZoneName $ZoneName -Name "www" -IPv4Address $MasterIP

    # Forwarders públicos
    Set-DnsServerForwarder -IPAddress @("8.8.8.8", "8.8.4.4")

    # Reinicio de servicio
    Restart-Service DNS

    Mostrar-Exito "Zona DNS $ZoneName configurada correctamente"

    Write-Host "`nRegistros de la zona:" -ForegroundColor Cyan

    Get-DnsServerResourceRecord -ZoneName $ZoneName |
        Format-Table HostName, RecordType, RecordData
}

# =========================
# PRUEBA DE RESOLUCIÓN DNS
# =========================
function Test-DnsResolution {
    param([string]$Domain)

    Write-Host "Probando resolución DNS: $Domain" -ForegroundColor Yellow

    $result = Resolve-DnsName -Name $Domain -Server "localhost" -ErrorAction SilentlyContinue

    if ($result) {
        Write-Host "Resolución exitosa" -ForegroundColor Green

        $result | Format-Table Name, IPAddress, Type

        return $true
    }
    else {
        Write-Host "Error en resolución DNS: $Domain" -ForegroundColor Red
        return $false
    }
}

# =========================
# ESTADO DEL DNS
# =========================
function Get-DnsStatus {
    Write-Host "ESTADO DEL SERVIDOR DNS" -ForegroundColor Cyan

    Verificar-Servicio -ServiceName "DNS"

    Write-Host "`nZonas configuradas:" -ForegroundColor Yellow

    Get-DnsServerZone |
        Format-Table ZoneName, ZoneType, IsAutoCreated

    Write-Host "`nReenviadores configurados:" -ForegroundColor Yellow

    Get-DnsServerForwarder |
        Select-Object -ExpandProperty IPAddress
}