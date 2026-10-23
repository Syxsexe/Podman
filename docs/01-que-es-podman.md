# 1. ¿Qué es Podman?

**Podman** (*POD MANager*) es una herramienta de código abierto, creada por **Red Hat**, para crear, ejecutar y administrar **contenedores** e **imágenes** siguiendo el estándar **OCI** (Open Container Initiative). Es compatible con las imágenes de Docker y con casi todos sus comandos.

## Repaso: ¿qué es un contenedor?

Un contenedor es un proceso aislado que lleva consigo **todo lo que necesita para ejecutarse** (código, librerías, runtime). Se crea a partir de una **imagen**, que es una plantilla de solo lectura.

```
 Containerfile ──(podman build)──► Imagen ──(podman run)──► Contenedor
   (receta)                       (plantilla)               (proceso en ejecución)
```

A diferencia de una máquina virtual, un contenedor **no trae un sistema operativo completo**: comparte el kernel del host, por eso arranca en milisegundos y ocupa muy poco.

## Las 4 ideas clave de Podman

### 1. Sin demonio (*daemonless*)
Docker funciona con un servicio central (`dockerd`) que corre siempre como root; todos los contenedores son "hijos" de ese demonio. Si el demonio falla, fallan todos.

Podman **no tiene demonio**: cada comando `podman` lanza el contenedor directamente (usando `conmon` + `crun`/`runc`) y termina. Los contenedores son procesos normales del usuario.

```
DOCKER                                  PODMAN
cliente ─► dockerd (root) ─► contenedor  podman ─► conmon ─► crun ─► contenedor
            (siempre activo)                    (sin servicio central)
```

### 2. Sin root (*rootless*)
Podman puede ejecutar contenedores **como un usuario normal**, sin privilegios de administrador. Usa *user namespaces*: dentro del contenedor el proceso puede creer que es `root`, pero en el host es tu usuario sin privilegios. Si un atacante escapa del contenedor, **no obtiene root en la máquina**.

### 3. Pods
Podman toma el concepto de **pod** de Kubernetes: un grupo de contenedores que **comparten red** (y opcionalmente otros recursos). Dentro de un pod, los contenedores se comunican por `localhost`. Cada pod tiene un pequeño contenedor `infra` que mantiene vivos esos recursos compartidos.

### 4. Integración con Kubernetes y systemd
- `podman kube generate` convierte pods/contenedores en YAML de Kubernetes.
- `podman kube play` ejecuta un YAML de Kubernetes localmente.
- Quadlet / `podman generate systemd` permite que los contenedores arranquen como servicios del sistema en Linux.

## Podman vs Docker

| Característica | Docker | Podman |
|---|---|---|
| Arquitectura | Cliente + demonio (`dockerd`) | Sin demonio |
| Root | Por defecto el demonio es root | Rootless por defecto |
| Pods | No (solo con Compose/Swarm) | Sí, nativos |
| YAML de Kubernetes | No | `kube generate` / `kube play` |
| Imágenes | OCI / Docker | OCI / Docker (las mismas) |
| Comandos | `docker ...` | `podman ...` (casi idénticos) |
| Compose | `docker compose` | `podman compose` / `podman-compose` |
| Licencia | Docker Desktop de pago para empresas grandes | Apache 2.0, gratis siempre |
| Interfaz gráfica | Docker Desktop | Podman Desktop |

> Es tan compatible que muchos usuarios simplemente hacen `alias docker=podman`.

## ¿Cómo funciona en Windows y macOS?

Los contenedores necesitan un kernel **Linux**. En Windows y macOS, Podman crea una pequeña máquina virtual Linux llamada **podman machine** (en Windows usa **WSL2** o Hyper-V; en macOS usa Apple Hypervisor). El comando `podman` de Windows es un cliente que envía órdenes a esa VM, de forma transparente.

## Herramientas del ecosistema

- **Buildah**: construcción de imágenes (Podman la usa internamente en `podman build`).
- **Skopeo**: copiar e inspeccionar imágenes entre registros sin descargarlas.
- **Podman Desktop**: interfaz gráfica para Windows, macOS y Linux.
- **crun / runc**: runtimes de bajo nivel que realmente crean el contenedor.

## Ventajas y desventajas

**Ventajas:** más seguro (rootless, sin demonio root), gratuito, compatible con Docker, pods y YAML de Kubernetes, buena integración con systemd.

**Desventajas:** en Windows/macOS depende de una VM; algunas herramientas asumen el socket de Docker (se soluciona con `podman machine` que expone un socket compatible); rootless tiene limitaciones (p. ej. puertos < 1024 en Linux sin configuración extra).
