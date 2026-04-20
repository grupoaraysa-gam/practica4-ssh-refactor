@'
# Práctica 4 - Implementación SSH y Refactorización

## Descripción
Implementación de acceso remoto SSH en servidores Linux y Windows, con refactorización completa de scripts de prácticas anteriores.

## Arquitectura de Software

### Mapa de Archivos

practica4-ssh-refactor/
│
├── linux/
│ ├── main.sh # Punto de entrada Linux
│ ├── funciones/
│ │ ├── common.sh # Funciones comunes (root, paquetes, servicios)
│ │ ├── dns_functions.sh # Instalación y configuración DNS
│ │ └── dhcp_functions.sh # Instalación y configuración DHCP
│ └── configs/ # Archivos de configuración
│
├── windows/
│ ├── main.ps1 # Punto de entrada Windows
│ ├── funciones/
│ │ ├── common.ps1 # Funciones comunes (admin, firewall)
│ │ ├── dns_functions.ps1 # Instalación DNS Windows Server
│ │ └── dhcp_functions.ps1 # Instalación DHCP Windows Server
│ └── configs/ # Archivos de configuración
│
└── documentacion/
└── README.md # Guía de conexión SSH

text

## Cuadro Comparativo de Refactorización

| Antes (Código Lineal) | Después (Modular) |
|----------------------|-------------------|
| `apt install -y bind9` repetido | `instalar_paquete "bind9"` |
| Código de verificación repetido | `verificar_root()` una sola vez |
| Lógica DNS y DHCP mezclada | Archivos separados por función |
| Sin reutilización entre scripts | Funciones comunes en `common.sh` |

## Guía de Conexión SSH:

Conexión a Servidor Linux
```bash
ssh araysa@IP_LS

Conexión a Servidor Windows
```powershell
ssh araysa@IP_WS