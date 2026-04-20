@'
# Script de inicio rápido
Write-Host "?? INICIANDO SISTEMA DE ADMINISTRACIÓN REMOTA" -ForegroundColor Green
Write-Host "------------------------------------------------" -ForegroundColor Green

# Ejecutar script principal
& "C:\practica4-ssh-refactor\windows\main.ps1"
'@ | Out-File -FilePath "C:\practica4-ssh-refactor\windows\run.ps1" -Encoding UTF8