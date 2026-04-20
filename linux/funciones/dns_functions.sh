#!/bin/bash

source ~/practica4-ssh-refactor/linux/funciones/common.sh

# =========================
# INSTALAR DNS SERVER (BIND9)
# =========================
instalar_dns() {
    mostrar_info "=== INSTALANDO SERVIDOR DNS ==="

    instalar_paquete "bind9"
    instalar_paquete "dnsutils"

    iniciar_servicio "bind9"
}

# =========================
# CREAR ZONA DNS
# =========================
crear_zona() {
    local dominio="$1"
    local ip_servidor="$2"

    if [[ -z "$dominio" || -z "$ip_servidor" ]]; then
        mostrar_error "Faltan parámetros: dominio o IP"
        return 1
    fi

    mostrar_info "Configurando zona DNS para $dominio..."

    # =========================
    # BACKUP CONFIG
    # =========================
    cp /etc/bind/named.conf.options /etc/bind/named.conf.options.bak 2>/dev/null
    cp /etc/bind/named.conf.local /etc/bind/named.conf.local.bak 2>/dev/null

    # =========================
    # OPTIONS GLOBAL
    # =========================
    cat > /etc/bind/named.conf.options <<EOF
options {
    directory "/var/cache/bind";

    forwarders {
        8.8.8.8;
        8.8.4.4;
    };

    dnssec-validation auto;

    listen-on { any; };
    allow-query { any; };
};
EOF

    # =========================
    # ZONA LOCAL
    # =========================
    cat >> /etc/bind/named.conf.local <<EOF

zone "$dominio" {
    type master;
    file "/etc/bind/db.$dominio";
};
EOF

    # =========================
    # ARCHIVO DE ZONA
    # =========================
    cat > /etc/bind/db.$dominio <<EOF
\$TTL 604800
@   IN  SOA ns1.$dominio. admin.$dominio. (
        2026042001 ; Serial
        604800     ; Refresh
        86400      ; Retry
        2419200    ; Expire
        604800 )   ; Negative Cache TTL

; Name Servers
@       IN  NS      ns1.$dominio.

; A Records
@       IN  A       $ip_servidor
ns1     IN  A       $ip_servidor
www     IN  A       $ip_servidor
EOF

    # =========================
    # VALIDAR CONFIG
    # =========================
    named-checkconf
    named-checkzone "$dominio" /etc/bind/db.$dominio

    if [[ $? -ne 0 ]]; then
        mostrar_error "Error en configuración DNS"
        return 1
    fi

    # =========================
    # REINICIAR SERVICIO
    # =========================
    systemctl restart bind9

    if systemctl is-active --quiet bind9; then
        mostrar_exito "Zona $dominio configurada correctamente"
    else
        mostrar_error "Falló el servicio DNS"
        systemctl status bind9 --no-pager
        return 1
    fi
}

# =========================
# PROBAR DNS
# =========================
probar_dns() {
    local dominio="$1"

    if [[ -z "$dominio" ]]; then
        mostrar_error "Debes especificar un dominio"
        return 1
    fi

    mostrar_info "Probando resolución DNS para $dominio..."

    nslookup "$dominio" 127.0.0.1
}