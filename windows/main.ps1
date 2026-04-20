# =========================
# SISTEMA DE ADMINISTRACIÓN REMOTA WINDOWS SERVER
# =========================

# Cargar módulos de forma PORTABLE (NO rutas fijas)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

. "$ScriptDir\funciones\common.ps1"
. "$ScriptDir\funciones\dns_functions.ps1"
. "$ScriptDir\funciones\dhcp_functions.ps1"

# =========================
# VARIABLES GLOBALES
# =========================
$script:Opcion = ""

# =========================
# MENÚ PRINCIPAL
# =========================
function Mostrar-Menu {
    Clear-Host
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "   SISTEMA DE ADMINISTRACIÓN REMOTA" -ForegroundColor Green
    Write-Host "           WINDOWS SERVER" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "1) Instalar y configurar DNS" -ForegroundColor Cyan
    Write-Host "2) Instalar y configurar DHCP" -ForegroundColor Cyan
    Write-Host "3) Verificar servicios" -ForegroundColor Cyan
    Write-Host "4) Configuración de Firewall" -ForegroundColor Cyan
    Write-Host "5) Salir" -ForegroundColor Cyan
    Write-Host ""
    $script:Opcion = Read-Host "Seleccione una opción [1-5]"
}

# =========================
# DNS
# =========================
function Opcion-DNS {
    Write-Host ""

    $dominio = Read-Host "Ingrese el dominio (ej: sistemas.local)"
    $ipServidor = Read-Host "Ingrese la IP del servidor"

    if (Validar-IP -IP $ipServidor) {

        Install-DnsServer
        New-DnsZone -ZoneName $dominio -MasterIP $ipServidor
        Test-DnsResolution -Domain $dominio

    } else {
        Mostrar-Error "IP inválida, no se configuró DNS"
    }

    Read-Host "Presione Enter para continuar..."
}

# =========================
# DHCP
# =========================
function Opcion-DHCP {
    Write-Host ""
    Write-Host "=== CONFIGURACIÓN DHCP ===" -ForegroundColor Yellow

    $scopeName   = Read-Host "Nombre del alcance"
    $subnet      = Read-Host "Subred (ej: 192.168.100.0)"
    $netmask     = Read-Host "Máscara (ej: 255.255.255.0)"
    $startRange  = Read-Host "Inicio del rango"
    $endRange    = Read-Host "Fin del rango"
    $gateway     = Read-Host "Gateway"
    $dnsServer   = Read-Host "Servidor DNS"

    Install-DhcpServer

    New-DhcpScope `
        -ScopeName $scopeName `
        -Subnet $subnet `
        -Netmask $netmask `
        -StartRange $startRange `
        -EndRange $endRange `
        -Gateway $gateway `
        -DnsServer $dnsServer

    # Excluir IPs opcional
    $excluir = Read-Host "¿Desea excluir IPs? (s/n)"
    if ($excluir -eq "s") {
        $startExcluir = Read-Host "IP inicio exclusión"
        $endExcluir   = Read-Host "IP fin exclusión"

        Add-DhcpExclusion `
            -Subnet $subnet `
            -StartIP $startExcluir `
            -EndIP $endExcluir
    }

    Get-DhcpStatus

    Read-Host "Presione Enter para continuar..."
}

# =========================
# VERIFICAR SERVICIOS
# =========================
function Opcion-Verificar {
    Write-Host ""
    Write-Host "=== VERIFICACIÓN DE SERVICIOS ===" -ForegroundColor Cyan

    Verificar-Servicio -ServiceName "sshd"
    Verificar-Servicio -ServiceName "DNS"
    Verificar-Servicio -ServiceName "DHCPServer"

    Write-Host ""
    Write-Host "=== PUERTOS EN ESCUCHA ===" -ForegroundColor Cyan

    Get-NetTCPConnection -State Listen |
        Where-Object { $_.LocalPort -in @(22, 53, 67, 68) } |
        Format-Table LocalPort, LocalAddress, State

    Read-Host "Presione Enter para continuar..."
}

# =========================
# FIREWALL
# =========================
function Opcion-Firewall {
    Write-Host ""
    Write-Host "=== FIREWALL ===" -ForegroundColor Cyan
    Write-Host "1) SSH (22)"
    Write-Host "2) DNS (53)"
    Write-Host "3) DHCP (67/68)"
    Write-Host "4) Ver reglas"
    Write-Host "5) Volver"

    $fw = Read-Host "Opción"

    switch ($fw) {

        "1" {
            Configurar-Firewall -Port 22 -RuleName "SSH-Server"
        }

        "2" {
            Configurar-Firewall -Port 53 -RuleName "DNS-TCP" -Protocol "TCP"
            Configurar-Firewall -Port 53 -RuleName "DNS-UDP" -Protocol "UDP"
        }

        "3" {
            Configurar-Firewall -Port 67 -RuleName "DHCP-Server" -Protocol "UDP"
            Configurar-Firewall -Port 68 -RuleName "DHCP-Client" -Protocol "UDP"
        }

        "4" {
            Get-NetFirewallRule |
                Where-Object { $_.DisplayName -match "SSH|DNS|DHCP" } |
                Format-Table DisplayName, Direction, Action, Enabled

            Read-Host "Enter para continuar..."
        }

        "5" { return }
    }
}

# =========================
# VALIDAR ADMIN
# =========================
function Main {

    if (-not (Verificar-Administrador)) {
        Write-Host "Debe ejecutar como Administrador" -ForegroundColor Red
        exit 1
    }

    do {
        Mostrar-Menu

        switch ($script:Opcion) {

            "1" { Opcion-DNS }
            "2" { Opcion-DHCP }
            "3" { Opcion-Verificar }
            "4" { Opcion-Firewall }
            "5" {
                Mostrar-Exito "Saliendo del sistema..."
                exit 0
            }
            default {
                Mostrar-Error "Opción inválida"
                Start-Sleep 1
            }
        }

    } while ($true)
}

# =========================
# EJECUCIÓN
# =========================
Main