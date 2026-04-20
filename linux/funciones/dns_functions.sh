#!/bin/bash

source ~/practica4-ssh-refactor/linux/funciones/common.sh

# Función para instalar servidor DNS
instalar_dns() {
    echo -e "${YELLOW}=== INSTALANDO SERVIDOR DNS ===${NC}"
    instalar_paquete "bind9"
    instalar_paquete "dnsutils"
    iniciar_servicio "named"
}

# Función para crear zona DNS
crear_zona() {
    local dominio=$1
    local ip_servidor=$2
    
    echo -e "${YELLOW}Configurando zona para $dominio...${NC}"
    
    # Configurar opciones globales
    cat > /etc/bind/named.conf.options << OPTIONS
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
OPTIONS

    # Agregar zona al archivo de configuración
    cat >> /etc/bind/named.conf.local << ZONA
zone "$dominio" {
    type master;
    file "/etc/bind/db.$dominio";
};
ZONA

    # Crear archivo de zona
    cat > /etc/bind/db.$dominio << REGISTROS
\$TTL    604800
@       IN      SOA     ns1.$dominio. admin.$dominio. (
                  2026041901  ; Serial
                  604800      ; Refresh
                  86400       ; Retry
                  2419200     ; Expire
                  604800 )    ; Negative Cache TTL
;
@       IN      NS      ns1.$dominio.
@       IN      A       $ip_servidor
ns1     IN      A       $ip_servidor
www     IN      A       $ip_servidor
REGISTROS

    # Reiniciar servicio
    systemctl restart named
    mostrar_exito "Zona $dominio configurada correctamente"
}

# Función para probar DNS
probar_dns() {
    local dominio=$1
    echo -e "${YELLOW}Probando resolución DNS para $dominio...${NC}"
    nslookup "$dominio" localhost
}
