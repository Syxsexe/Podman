# 5. Chuleta de comandos y preguntas frecuentes

## Comandos esenciales

| Comando | Qué hace |
|---|---|
| `podman pull IMAGEN` | Descarga una imagen |
| `podman images` | Lista imágenes locales |
| `podman build -t NOMBRE:TAG CARPETA` | Construye una imagen desde un Containerfile |
| `podman run -d -p HOST:CONT --name N IMAGEN` | Crea y arranca un contenedor |
| `podman ps` / `podman ps -a` | Contenedores en ejecución / todos |
| `podman logs N` | Ver la salida del contenedor |
| `podman exec -it N sh` | Abrir una terminal dentro del contenedor |
| `podman stop N` / `podman start N` | Detener / arrancar |
| `podman rm N` / `podman rmi IMAGEN` | Borrar contenedor / imagen |
| `podman inspect N` | Detalles en JSON |
| `podman stats` | Uso de CPU/RAM en vivo |

## Pods

| Comando | Qué hace |
|---|---|
| `podman pod create --name P -p 8080:5000` | Crea un pod |
| `podman run -d --pod P IMAGEN` | Arranca un contenedor dentro del pod |
| `podman pod ps` | Lista pods |
| `podman ps --pod` | Contenedores indicando su pod |
| `podman pod stop P` / `podman pod rm -f P` | Detener / borrar pod con sus contenedores |

## Kubernetes

| Comando | Qué hace |
|---|---|
| `podman kube generate P > archivo.yaml` | Exporta un pod a YAML de Kubernetes |
| `podman kube play archivo.yaml` | Crea pods desde un YAML |
| `podman kube down archivo.yaml` | Elimina lo creado por `kube play` |

## Preguntas frecuentes (para la ronda de preguntas)

**¿Puedo usar mis imágenes de Docker?**
Sí. Ambos usan el estándar OCI; cualquier imagen de Docker Hub funciona.

**¿Puedo usar mis Dockerfiles y docker-compose.yml?**
Sí. `podman build` lee Dockerfiles, y `podman compose` / `podman-compose` leen archivos Compose.

**¿Por qué Podman es más seguro?**
No hay un demonio corriendo como root, y los contenedores corren rootless: aunque un atacante escape del contenedor, solo tiene los permisos de un usuario normal.

**Si no hay demonio, ¿quién vigila los contenedores?**
Un pequeño proceso `conmon` por contenedor, que recoge logs y el código de salida. Para reinicio automático se usa systemd (Quadlet) en Linux.

**¿Qué es el contenedor `infra` de un pod?**
Un contenedor mínimo (imagen `pause`) que crea y mantiene los namespaces compartidos (red, IPC) del pod, para que los demás contenedores puedan reiniciarse sin perder la red.

**¿Podman reemplaza a Kubernetes?**
No. Podman ejecuta contenedores en **una** máquina; Kubernetes orquesta en **muchas**. Podman facilita pasar de uno a otro con `kube generate/play`.

**¿Quién lo usa?**
Es el motor de contenedores por defecto en Red Hat Enterprise Linux, Fedora y CentOS Stream.
