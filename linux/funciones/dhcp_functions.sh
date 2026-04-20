#!/bin/bash

source ~/practica4-ssh-refactor/linux/funciones/common.sh

# =========================
# INSTALAR DHCP SERVER
# =========================
instalar_dhcp() {
    mostrar_info "=== INSTALANDO SERVIDOR DHCP ==="

    instalar_paquete "isc-dhcp-server"
    iniciar_servicio "isc-dhcp-server"
}

# =========================
# CONFIGURAR DHCP SERVER
# =========================
configurar_dhcp() {
    local interface="$1"
    local subnet="$2"
    local netmask="$3"
    local range_start="$4"
    local range_end="$5"
    local gateway="$6"
    local dns="$7"

    mostrar_info "Configurando DHCP en interfaz $interface..."

    # Validaciones básicas
    if [[ -z "$interface" || -z "$subnet" || -z "$netmask" ]]; then
        mostrar_error "Faltan parámetros obligatorios"
        return 1
    fi

    # =========================
    # CONFIGURAR INTERFAZ DHCP
    # =========================
    sed -i "s/^INTERFACESv4=.*/INTERFACESv4=\"$interface\"/" /etc/default/isc-dhcp-server

    # =========================
    # BACKUP CONFIG
    # =========================
    cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak 2>/dev/null

    # =========================
    # GENERAR CONFIGURACIÓN DHCP
    # =========================
    cat > /etc/dhcp/dhcpd.conf <<EOF
option domain-name "sistemas.local";
option domain-name-servers $dns;

default-lease-time 600;
max-lease-time 7200;
authoritative;

subnet $subnet netmask $netmask {
    range $range_start $range_end;
    option routers $gateway;
    option subnet-mask $netmask;
    option domain-name-servers $dns;
}
EOF

    # =========================
    # REINICIAR SERVICIO
    # =========================
    systemctl restart isc-dhcp-server

    if systemctl is-active --quiet isc-dhcp-server; then
        mostrar_exito "DHCP configurado correctamente en $interface"
    else
        mostrar_error "Error al iniciar DHCP"
        systemctl status isc-dhcp-server --no-pager
        return 1
    fi
}

# =========================
# VERIFICAR ESTADO DHCP
# =========================
verificar_dhcp() {
    mostrar_info "Estado del servicio DHCP..."

    verificar_servicio "isc-dhcp-server"

    mostrar_info "Puertos DHCP escuchando (67/68):"
    ss -tuln | grep -E ":(67|68)" || mostrar_advertencia "No se detectan puertos DHCP activos"
}