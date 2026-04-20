# Script Principal - Administración Remota Windows
# Cargar todos los módulos de funciones

. "C:\practica4-ssh-refactor\windows\funciones\common.ps1"
. "C:\practica4-ssh-refactor\windows\funciones\dns_functions.ps1"
. "C:\practica4-ssh-refactor\windows\funciones\dhcp_functions.ps1"

# Variables globales
$script:Opcion = ""

# Función para mostrar el menú
function Mostrar-Menu {
    Clear-Host
    Write-Host "----------------------------------------" -ForegroundColor Green
    Write-Host "    SISTEMA DE ADMINISTRACIÓN REMOTA     " -ForegroundColor Green
    Write-Host "              WINDOWS SERVER              " -ForegroundColor Green
    Write-Host "----------------------------------------" -ForegroundColor Green
    Write-Host ""
    Write-Host "1) Instalar y configurar DNS" -ForegroundColor Cyan
    Write-Host "2) Instalar y configurar DHCP" -ForegroundColor Cyan
    Write-Host "3) Verificar servicios" -ForegroundColor Cyan
    Write-Host "4) Configuración de Firewall" -ForegroundColor Cyan
    Write-Host "5) Salir" -ForegroundColor Cyan
    Write-Host ""
    Write-Host -NoNewline "Seleccione una opción [1-5]: "
}

# Función para instalar DNS
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
    
    Write-Host ""
    Read-Host "Presione Enter para continuar..."
}

# Función para instalar DHCP
function Opcion-DHCP {
    Write-Host ""
    Write-Host "Configuración del alcance DHCP:" -ForegroundColor Yellow
    $scopeName = Read-Host "Nombre del alcance (ej: Red Local)"
    $subnet = Read-Host "Subred (ej: 192.168.1.0)"
    $netmask = Read-Host "Máscara (ej: 255.255.255.0)"
    $startRange = Read-Host "Inicio del rango (ej: 192.168.1.100)"
    $endRange = Read-Host "Fin del rango (ej: 192.168.1.200)"
    $gateway = Read-Host "Gateway (ej: 192.168.1.1)"
    $dnsServer = Read-Host "Servidor DNS (ej: 192.168.1.10)"
    
    Install-DhcpServer
    New-DhcpScope -ScopeName $scopeName -Subnet $subnet -Netmask $netmask `
                  -StartRange $startRange -EndRange $endRange `
                  -Gateway $gateway -DnsServer $dnsServer
    
    # Preguntar si quiere excluir IPs
    $excluir = Read-Host "¿Desea excluir un rango de IPs? (s/n)"
    if ($excluir -eq 's') {
        $startExcluir = Read-Host "IP inicial a excluir"
        $endExcluir = Read-Host "IP final a excluir"
        Add-DhcpExclusion -Subnet $subnet -StartIP $startExcluir -EndIP $endExcluir
    }
    
    Get-DhcpStatus
    
    Write-Host ""
    Read-Host "Presione Enter para continuar..."
}

# Función para verificar servicios
function Opcion-Verificar {
    Write-Host ""
    Write-Host "=== VERIFICACIÓN DE SERVICIOS ===" -ForegroundColor Cyan
    Verificar-Servicio -ServiceName "sshd"
    Verificar-Servicio -ServiceName "DNS"
    Verificar-Servicio -ServiceName "DHCPServer"
    
    Write-Host "`n=== PUERTOS ABIERTOS ===" -ForegroundColor Cyan
    Get-NetTCPConnection -State Listen | Where-Object {$_.LocalPort -in @(22,53,67,68)} | Format-Table LocalPort, LocalAddress, State
    
    Write-Host ""
    Read-Host "Presione Enter para continuar..."
}

# Función para configurar firewall
function Opcion-Firewall {
    Write-Host ""
    Write-Host "=== CONFIGURACIÓN DE FIREWALL ===" -ForegroundColor Cyan
    Write-Host "1) Abrir puerto SSH (22)"
    Write-Host "2) Abrir puerto DNS (53)"
    Write-Host "3) Abrir puerto DHCP (67/68)"
    Write-Host "4) Ver reglas existentes"
    Write-Host "5) Volver al menú principal"
    
    $fwOpcion = Read-Host "Seleccione una opción"
    
    switch ($fwOpcion) {
        "1" { Configurar-Firewall -Port 22 -RuleName "SSH-Server" }
        "2" { 
            Configurar-Firewall -Port 53 -RuleName "DNS-Server-TCP" -Protocol "TCP"
            Configurar-Firewall -Port 53 -RuleName "DNS-Server-UDP" -Protocol "UDP"
        }
        "3" { Configurar-Firewall -Port 67 -RuleName "DHCP-Server" -Protocol "UDP" }
        "4" { 
            Get-NetFirewallRule | Where-Object {$_.DisplayName -match "SSH|DNS|DHCP"} | 
            Format-Table DisplayName, Direction, Action, Enabled
            Read-Host "Presione Enter para continuar..."
        }
        "5" { return }
    }
}

# Función principal
function Main {
    # Verificar si es administrador
    if (-not (Verificar-Administrador)) {
        exit 1
    }
    
    do {
        Mostrar-Menu
        $script:Opcion = Read-Host
        
        switch ($script:Opcion) {
            "1" { Opcion-DNS }
            "2" { Opcion-DHCP }
            "3" { Opcion-Verificar }
            "4" { Opcion-Firewall }
            "5" { 
                Mostrar-Exito "¡Hasta luego!"
                exit 0
            }
            default {
                Mostrar-Error "Opción inválida"
                Start-Sleep -Seconds 1
            }
        }
    } while ($true)
}

# Ejecutar programa principal
Main
