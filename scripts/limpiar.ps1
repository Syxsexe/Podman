# Borra todo lo que crea la demostracion (pods, contenedores e imagen de la app).
#   powershell -ExecutionPolicy Bypass -File .\scripts\limpiar.ps1

$raiz = Split-Path -Parent $PSScriptRoot
Set-Location $raiz

podman kube down .\kube\pod-demo.yaml 2>$null
podman pod rm -f expo-pod expo-pod-kube 2>$null
podman rmi -f localhost/expo-app:1.0 2>$null
if (Test-Path .\kube\generado.yaml) { Remove-Item .\kube\generado.yaml }

Write-Host "Limpieza completa." -ForegroundColor Green
podman ps -a --pod
