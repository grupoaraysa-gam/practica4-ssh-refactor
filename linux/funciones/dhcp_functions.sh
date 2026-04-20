#!/bin/bash

source ~/practica4-ssh-refactor/linux/funciones/common.sh

# Función para instalar servidor DHCP
instalar_dhcp() {
    echo -e "${YELLOW}=== INSTALANDO SERVIDOR DHCP ===${NC}"
    instalar_paquete "isc-dhcp-server"
    iniciar_servicio "isc-dhcp-server"
}

# Función para configurar DHCP
configurar_dhcp() {
    local interface=$1
    local subnet=$2
    local netmask=$3
    local range_start=$4
    local range_end=$5
    local gateway=$6
    local dns=$7
    
    echo -e "${YELLOW}Configurando DHCP en interfaz $interface...${NC}"
    
    # Configurar interfaz en /etc/default/isc-dhcp-server
    sed -i 's/^INTERFACESv4=.*/INTERFACESv4="'$interface'"/' /etc/default/isc-dhcp-server
    
    # Crear configuración DHCP
    cat > /etc/dhcp/dhcpd.conf << DHCPCONF
option domain-name "sistemas.local";
option domain-name-servers $dns;

default-lease-time 600;
max-lease-time 7200;

subnet $subnet netmask $netmask {
    range $range_start $range_end;
    option routers $gateway;
    option subnet-mask $netmask;
    option domain-name-servers $dns;
}
DHCPCONF

    # Reiniciar servicio
    systemctl restart isc-dhcp-server
    mostrar_exito "DHCP configurado correctamente en $interface"
}

# Función para verificar estado de DHCP
verificar_dhcp() {
    verificar_servicio "isc-dhcp-server"
    echo -e "${YELLOW}Puertos DHCP escuchando:${NC}"
    ss -tuln | grep -E ":(67|68)"
}
