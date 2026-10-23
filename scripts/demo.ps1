# Demostracion guiada de Podman (Windows / PowerShell).
# Ejecutar desde la carpeta raiz del proyecto:
#   powershell -ExecutionPolicy Bypass -File .\scripts\demo.ps1
# En cada paso muestra el comando, espera ENTER y lo ejecuta.

$ErrorActionPreference = "Continue"
$raiz = Split-Path -Parent $PSScriptRoot
Set-Location $raiz

function Paso($titulo, $comando) {
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor DarkGray
    Write-Host " $titulo" -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor DarkGray
    Write-Host "PS> $comando" -ForegroundColor Yellow
    Read-Host "   (ENTER para ejecutar)" | Out-Null
    Invoke-Expression $comando
}

# 0. Verificar que Podman exista y que la maquina virtual este encendida
if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    Write-Host "Podman no esta instalado. Ver docs\02-instalacion.md" -ForegroundColor Red
    exit 1
}
podman info *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "La maquina de Podman no responde, intentando iniciarla..." -ForegroundColor Yellow
    podman machine start
}

# Limpieza previa por si la demo se ejecuto antes
podman pod rm -f expo-pod expo-pod-kube *> $null

Paso "1. Version de Podman (cliente en Windows + servidor en la VM)" "podman version"

Paso "2. Primer contenedor: hola mundo" "podman run --rm quay.io/podman/hello"

Paso "3. Construir la imagen de la app a partir del Containerfile" "podman build -t expo-app:1.0 .\app"

Paso "4. Ver las imagenes locales" "podman images"

Paso "5. Crear un POD (grupo de contenedores que comparten red) publicando el puerto 8080" "podman pod create --name expo-pod -p 8080:5000"

Paso "6. Arrancar Redis DENTRO del pod" "podman run -d --pod expo-pod --name expo-redis docker.io/library/redis:7-alpine"

Paso "7. Arrancar la app DENTRO del pod (encuentra Redis en localhost)" "podman run -d --pod expo-pod --name expo-app -e REDIS_HOST=localhost localhost/expo-app:1.0"

Paso "8. Ver pods y contenedores (el contenedor 'infra' mantiene la red del pod)" "podman ps -a --pod"

Start-Sleep -Seconds 2
# Se usa 127.0.0.1 y no "localhost": en Windows "localhost" resuelve primero a IPv6 (::1)
# y el reenvio de puertos de Podman/WSL cierra esas conexiones sin responder.
Paso "9. Probar la app desde Windows" "curl.exe -s http://127.0.0.1:8080/health"

Write-Host ""
Write-Host "Abriendo el navegador en http://127.0.0.1:8080 (recarga para ver el contador subir)" -ForegroundColor Green
Start-Process "http://127.0.0.1:8080"

Paso "10. Seguridad: la app NO corre como root dentro del contenedor" "podman exec expo-app id"

Paso "11. Rootless: usuario dentro del contenedor vs usuario real en el host" "podman top expo-app user huser"

Paso "12. Logs de la app" "podman logs expo-app"

Paso "13. Generar YAML de Kubernetes a partir del pod en ejecucion" "podman kube generate expo-pod | Tee-Object -FilePath .\kube\generado.yaml"

Paso "14. Detener y borrar el pod (y sus contenedores)" "podman pod rm -f expo-pod"

Paso "15. Levantar todo de nuevo desde un YAML de Kubernetes (puerto 8081)" "podman kube play .\kube\pod-demo.yaml"

Start-Sleep -Seconds 3
Paso "16. Probar el pod creado desde YAML" "curl.exe -s http://127.0.0.1:8081/health"

Paso "17. Estado final" "podman pod ps"

Write-Host ""
Write-Host "Demo terminada. Para limpiar todo: .\scripts\limpiar.ps1" -ForegroundColor Green
