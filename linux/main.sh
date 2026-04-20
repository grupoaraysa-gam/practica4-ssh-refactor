#!/bin/bash

# Cargar todos los módulos de funciones
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/funciones/common.sh"
source "$SCRIPT_DIR/funciones/dns_functions.sh"
source "$SCRIPT_DIR/funciones/dhcp_functions.sh"

# Variable global
OPCION=""

# Función para mostrar el menú
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
    echo -n "Seleccione una opción [1-4]: "
}

# Función para instalar DNS
opcion_dns() {
    echo ""
    read -p "Ingrese el dominio (ej: sistemas.local): " dominio
    read -p "Ingrese la IP del servidor: " ip_servidor
    
    validar_ip "$ip_servidor"
    if [ $? -eq 0 ]; then
        instalar_dns
        crear_zona "$dominio" "$ip_servidor"
        probar_dns "$dominio"
    else
        mostrar_error "IP inválida, no se configuró DNS"
    fi
    
    echo ""
    read -p "Presione Enter para continuar..."
}

# Función para instalar DHCP
opcion_dhcp() {
    echo ""
    read -p "Ingrese la interfaz de red (ej: eth0): " interface
    read -p "Ingrese la subred (ej: 192.168.1.0): " subnet
    read -p "Ingrese la máscara (ej: 255.255.255.0): " netmask
    read -p "Ingrese inicio del rango (ej: 192.168.1.100): " range_start
    read -p "Ingrese fin del rango (ej: 192.168.1.200): " range_end
    read -p "Ingrese el gateway: " gateway
    read -p "Ingrese el DNS: " dns
    
    instalar_dhcp
    configurar_dhcp "$interface" "$subnet" "$netmask" "$range_start" "$range_end" "$gateway" "$dns"
    verificar_dhcp
    
    echo ""
    read -p "Presione Enter para continuar..."
}

# Función para verificar servicios
opcion_verificar() {
    echo ""
    echo -e "${YELLOW}=== VERIFICACIÓN DE SERVICIOS ===${NC}"
    verificar_servicio "ssh"
    verificar_servicio "named"
    verificar_servicio "isc-dhcp-server"
    echo ""
    read -p "Presione Enter para continuar..."
}

# Función principal
main() {
    # Verificar si es root (solo si va a instalar cosas)
    if [ "$1" != "verificar" ]; then
        verificar_root
    fi
    
    while true; do
        mostrar_menu
        read OPCION
        
        case $OPCION in
            1) opcion_dns ;;
            2) opcion_dhcp ;;
            3) opcion_verificar ;;
            4) 
                echo -e "${GREEN}¡Hasta luego!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Opción inválida${NC}"
                sleep 1
                ;;
        esac
    done
}

# Ejecutar programa principal
main "$@"
