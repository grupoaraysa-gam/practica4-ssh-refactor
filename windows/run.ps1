@'
# Script de inicio rápido

Write-Host "INICIANDO SISTEMA DE ADMINISTRACIÓN REMOTA" -ForegroundColor Green
Write-Host "------------------------------------------------" -ForegroundColor Green

# Obtener ruta dinámica del script
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Ejecutar script principal
& "$ScriptDir\main.ps1"
'@ | Out-File -FilePath "$PSScriptRoot\run.ps1" -Encoding UTF8