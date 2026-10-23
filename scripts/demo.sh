#!/usr/bin/env bash
# Demostracion guiada de Podman (Linux / macOS / WSL).
# Ejecutar desde la carpeta raiz del proyecto:  bash scripts/demo.sh
set -u
cd "$(dirname "$0")/.."

paso() {
    echo
    echo "=================================================="
    echo " $1"
    echo "=================================================="
    echo "\$ $2"
    read -rp "   (ENTER para ejecutar) " _
    eval "$2"
}

command -v podman >/dev/null || { echo "Podman no esta instalado. Ver docs/02-instalacion.md"; exit 1; }
podman pod rm -f expo-pod expo-pod-kube >/dev/null 2>&1

paso "1. Version de Podman"                       "podman version"
paso "2. Primer contenedor: hola mundo"           "podman run --rm quay.io/podman/hello"
paso "3. Construir la imagen de la app"           "podman build -t expo-app:1.0 ./app"
paso "4. Ver las imagenes locales"                "podman images"
paso "5. Crear un POD publicando el puerto 8080"  "podman pod create --name expo-pod -p 8080:5000"
paso "6. Arrancar Redis dentro del pod"           "podman run -d --pod expo-pod --name expo-redis docker.io/library/redis:7-alpine"
paso "7. Arrancar la app dentro del pod"          "podman run -d --pod expo-pod --name expo-app -e REDIS_HOST=localhost localhost/expo-app:1.0"
paso "8. Ver pods y contenedores"                 "podman ps -a --pod"
sleep 2
paso "9. Probar la app"                           "curl -s http://127.0.0.1:8080/health; echo"
paso "10. La app no corre como root"              "podman exec expo-app id"
paso "11. Rootless: usuario contenedor vs host"   "podman top expo-app user huser"
paso "12. Logs de la app"                         "podman logs expo-app"
paso "13. Generar YAML de Kubernetes"             "podman kube generate expo-pod | tee kube/generado.yaml"
paso "14. Borrar el pod"                          "podman pod rm -f expo-pod"
paso "15. Levantar todo desde YAML (puerto 8081)" "podman kube play kube/pod-demo.yaml"
sleep 3
paso "16. Probar el pod creado desde YAML"        "curl -s http://127.0.0.1:8081/health; echo"
paso "17. Estado final"                           "podman pod ps"

echo
echo "Demo terminada. Para limpiar: podman kube down kube/pod-demo.yaml && podman rmi localhost/expo-app:1.0"
