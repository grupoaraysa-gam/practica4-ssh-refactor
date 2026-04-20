#!/bin/bash

# =========================
# COLORES
# =========================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =========================
# LOGGING BÁSICO
# =========================
mostrar_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

mostrar_exito() {
    echo -e "${GREEN}[OK]${NC} $1"
}

mostrar_advertencia() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

mostrar_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# =========================
# VALIDAR ROOT
# =========================
verificar_root() {
    if [[ $EUID -ne 0 ]]; then
        mostrar_error "Este script debe ejecutarse como root"
        mostrar_advertencia "Ejecuta: sudo $0"
        exit 1
    fi
    mostrar_exito "Usuario root verificado"
}

# =========================
# INSTALAR PAQUETES
# =========================
instalar_paquete() {
    local paquete=$1

    if [[ -z "$paquete" ]]; then
        mostrar_error "No se especificó paquete"
        return 1
    fi

    mostrar_info "Instalando $paquete..."
    apt update -qq
    apt install -y "$paquete"

    if [[ $? -eq 0 ]]; then
        mostrar_exito "$paquete instalado correctamente"
    else
        mostrar_error "Falló la instalación de $paquete"
        return 1
    fi
}

# =========================
# SERVICIOS
# =========================
verificar_servicio() {
    local servicio=$1

    if systemctl is-active --quiet "$servicio"; then
        mostrar_exito "$servicio está activo"
        return 0
    else
        mostrar_error "$servicio no está activo"
        return 1
    fi
}

iniciar_servicio() {
    local servicio=$1

    mostrar_info "Configurando $servicio..."

    systemctl enable "$servicio" >/dev/null 2>&1
    systemctl start "$servicio"

    verificar_servicio "$servicio"
}

# =========================
# VALIDACIÓN DE IP
# =========================
validar_ip() {
    local ip=$1

    if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        mostrar_exito "IP válida: $ip"
        return 0
    else
        mostrar_error "IP inválida: $ip"
        return 1
    fi
}

# =========================
# UTILIDADES
# =========================
pausar() {
    read -p "Presiona ENTER para continuar..."
}