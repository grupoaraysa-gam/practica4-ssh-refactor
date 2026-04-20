#!/bin/bash

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para verificar si es root
verificar_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Error: Este script debe ejecutarse como root${NC}"
        echo -e "${YELLOW}Ejecuta: sudo $0${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Verificado: usuario root${NC}"
}

# Función para instalar paquetes
instalar_paquete() {
    local paquete=$1
    echo -e "${YELLOW}Instalando $paquete...${NC}"
    apt update -qq
    apt install -y "$paquete"
    echo -e "${GREEN}✓ $paquete instalado correctamente${NC}"
}

# Función para verificar si un servicio está activo
verificar_servicio() {
    local servicio=$1
    if systemctl is-active --quiet "$servicio"; then
        echo -e "${GREEN}✓ $servicio está activo${NC}"
        return 0
    else
        echo -e "${RED}✗ $servicio no está activo${NC}"
        return 1
    fi
}

# Función para habilitar e iniciar un servicio
iniciar_servicio() {
    local servicio=$1
    echo -e "${YELLOW}Configurando $servicio...${NC}"
    systemctl enable "$servicio" >/dev/null 2>&1
    systemctl start "$servicio"
    verificar_servicio "$servicio"
}

# Función para validar IP
validar_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo -e "${GREEN}✓ IP válida: $ip${NC}"
        return 0
    else
        echo -e "${RED}✗ IP inválida: $ip${NC}"
        return 1
    fi
}

# Función para mostrar mensajes de éxito
mostrar_exito() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Función para mostrar mensajes de error
mostrar_error() {
    echo -e "${RED}cat > ~/practica4-ssh-refactor/linux/funciones/common.sh << 'EOF'
#!/bin/bash

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para verificar si es root
verificar_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Error: Este script debe ejecutarse como root${NC}"
        echo -e "${YELLOW}Ejecuta: sudo $0${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Verificado: usuario root${NC}"
}

# Función para instalar paquetes
instalar_paquete() {
    local paquete=$1
    echo -e "${YELLOW}Instalando $paquete...${NC}"
    apt update -qq
    apt install -y "$paquete"
    echo -e "${GREEN}✓ $paquete instalado correctamente${NC}"
}

# Función para verificar si un servicio está activo
verificar_servicio() {
    local servicio=$1
    if systemctl is-active --quiet "$servicio"; then
        echo -e "${GREEN}✓ $servicio está activo${NC}"
        return 0
    else
        echo -e "${RED}✗ $servicio no está activo${NC}"
        return 1
    fi
}

# Función para habilitar e iniciar un servicio
iniciar_servicio() {
    local servicio=$1
    echo -e "${YELLOW}Configurando $servicio...${NC}"
    systemctl enable "$servicio" >/dev/null 2>&1
    systemctl start "$servicio"
    verificar_servicio "$servicio"
}

# Función para validar IP
validar_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo -e "${GREEN}✓ IP válida: $ip${NC}"
        return 0
    else
        echo -e "${RED}✗ IP inválida: $ip${NC}"
        return 1
    fi
}

# Función para mostrar mensajes de éxito
mostrar_exito() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Función para mostrar mensajes de error
mostrar_error() {
    echo -e "${RED}❌ $1${NC}"
}
EOF $1${NC}"
}
