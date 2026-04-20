#!/bin/bash

# =========================
# CARGA DE MÓDULOS
# =========================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/funciones/common.sh"
source "$SCRIPT_DIR/funciones/dns_functions.sh"
source "$SCRIPT_DIR/funciones/dhcp_functions.sh"

# =========================
# MENÚ PRINCIPAL
# =========================
mostrar_menu() {
    clear
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo -e "${GREEN}    SISTEMA DE ADMINISTRACIÓN REMOTA     ${NC}"
    echo -e "${GREEN}════════════════════════════════════════${NC}"
    echo ""
    echo "1) Instalar y configurar DNS"
    echo "2) Instalar y configurar DHCP"
    echo "3) Verificar servicios"
    echo "4) Salir"
    echo ""
    read -p "Seleccione una opción [1-4]: " OPCION
}

# =========================
# OPCIÓN DNS
# =========================
opcion_dns() {
    echo ""

    read -p "Dominio (ej: reprobados.com): " dominio
    read -p "IP del servidor DNS: " ip_servidor

    validar_ip "$ip_servidor" || {
        mostrar_error "IP inválida, cancelando DNS"
        return 1
    }

    instalar_dns
    crear_zona "$dominio" "$ip_servidor"
    probar_dns "$dominio"

    pausar
}

# =========================
# OPCIÓN DHCP
# =========================
opcion_dhcp() {
    echo ""

    read -p "Interfaz (ej: ens37): " interface
    read -p "Subred (ej: 192.168.100.0): " subnet
    read -p "Máscara (ej: 255.255.255.0): " netmask
    read -p "Rango inicio: " range_start
    read -p "Rango fin: " range_end
    read -p "Gateway: " gateway
    read -p "DNS: " dns

    instalar_dhcp
    configurar_dhcp "$interface" "$subnet" "$netmask" "$range_start" "$range_end" "$gateway" "$dns"
    verificar_dhcp

    pausar
}

# =========================
# VERIFICAR SERVICIOS
# =========================
opcion_verificar() {
    echo ""
    mostrar_info "=== VERIFICACIÓN DE SERVICIOS ==="

    verificar_servicio "ssh"
    verificar_servicio "bind9"
    verificar_servicio "isc-dhcp-server"

    pausar
}

# =========================
# PROGRAMA PRINCIPAL
# =========================
main() {

    # Solo validar root si vas a administrar servicios
    verificar_root

    while true; do
        mostrar_menu

        case $OPCION in
            1)
                opcion_dns
                ;;
            2)
                opcion_dhcp
                ;;
            3)
                opcion_verificar
                ;;
            4)
                mostrar_exito "Saliendo del sistema..."
                exit 0
                ;;
            *)
                mostrar_error "Opción inválida"
                sleep 1
                ;;
        esac
    done
}

# =========================
# EJECUCIÓN
# =========================
main "$@"