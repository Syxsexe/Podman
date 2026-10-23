# 4. Guion de la demostración en vivo

Hay dos formas de hacer la demo:

- **Automática:** `powershell -ExecutionPolicy Bypass -File .\scripts\demo.ps1` (presionas ENTER en cada paso).
- **Manual:** escribir los comandos de abajo uno a uno (más impactante, pero más riesgo de errores).

Todos los comandos se ejecutan **desde la carpeta raíz del proyecto** (`Podman/`).

## Antes de la exposición (checklist)

- [ ] `podman machine start` y `podman info` responden sin error.
- [ ] Ejecutar la demo completa una vez (descarga y cachea las imágenes).
- [ ] Ejecutar `.\scripts\limpiar.ps1` para dejar todo limpio (las imágenes base quedan en caché).
- [ ] Puertos 8080 y 8081 libres.
- [ ] Aumentar el tamaño de letra de la terminal.
- [ ] Tener el navegador abierto.

---

## Paso 1 — Podman está instalado

```powershell
podman version
```
🗣️ *"Vemos dos partes: el cliente (Windows) y el servidor (la máquina virtual Linux con WSL2). En Linux no habría VM: Podman correría directamente."*

## Paso 2 — Primer contenedor

```powershell
podman run --rm quay.io/podman/hello
```
🗣️ *"`run` descarga la imagen si no existe, crea el contenedor y lo ejecuta. `--rm` lo borra al terminar. Fíjense que no hay ningún demonio: es un proceso que nace y muere."*

## Paso 3 — Construir nuestra imagen

```powershell
podman build -t expo-app:1.0 .\app
podman images
```
🗣️ *"Podman lee el Containerfile y ejecuta cada instrucción, creando capas. `-t` le pone nombre y versión. Ahora aparece como `localhost/expo-app`."*

## Paso 4 — Crear un pod

```powershell
podman pod create --name expo-pod -p 8080:5000
```
🗣️ *"Esto es exclusivo de Podman frente a Docker: un pod como en Kubernetes. Publicamos el puerto 8080 de Windows hacia el 5000 del pod. Los puertos se definen en el pod, no en cada contenedor."*

## Paso 5 — Meter dos contenedores en el pod

```powershell
podman run -d --pod expo-pod --name expo-redis docker.io/library/redis:7-alpine
podman run -d --pod expo-pod --name expo-app -e REDIS_HOST=localhost localhost/expo-app:1.0
podman ps -a --pod
```
🗣️ *"`-d` es modo segundo plano. La app busca Redis en `localhost` porque comparten red. En la lista se ven 3 contenedores: los nuestros y el `infra`, que sostiene la red del pod."*

## Paso 6 — Probar

```powershell
curl.exe http://127.0.0.1:8080/health
start http://127.0.0.1:8080
```
> ⚠️ En Windows usar **`127.0.0.1`**, no `localhost`: `localhost` resuelve primero a IPv6 (`::1`) y el reenvío de puertos de Podman con WSL cierra esa conexión sin responder (curl muestra "Empty reply from server" y el navegador no carga).

🗣️ *Recargar varias veces el navegador para que el contador suba. "El número se guarda en Redis, en otro contenedor."*

## Paso 7 — Seguridad (rootless)

```powershell
podman exec expo-app id
podman top expo-app user huser
```
🗣️ *"`exec` ejecuta un comando dentro del contenedor: la app corre como `appuser`, no root. Y `top` muestra el usuario dentro del contenedor (`user`) frente al usuario real en el host (`huser`): incluso el root de un contenedor se mapea a un usuario sin privilegios. Esa es la gran diferencia de seguridad con Docker."*

## Paso 8 — Logs

```powershell
podman logs expo-app
```
🗣️ *"Vemos cada petición que hicimos desde el navegador."*

## Paso 9 — De Podman a Kubernetes

```powershell
podman kube generate expo-pod
```
🗣️ *"Podman convierte el pod que creamos a mano en un YAML de Kubernetes listo para desplegar en un clúster."*

## Paso 10 — De Kubernetes a Podman

```powershell
podman pod rm -f expo-pod
podman kube play .\kube\pod-demo.yaml
curl.exe http://127.0.0.1:8081/health
podman pod ps
```
🗣️ *"Borramos todo y lo levantamos con un solo comando desde un YAML de Kubernetes. Es el mismo archivo que usaríamos en producción."*

## Limpieza

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\limpiar.ps1
```

---

## Plan B (si algo falla en vivo)

| Falla | Qué hacer |
|---|---|
| No hay internet | Si ejecutaste la demo antes, las imágenes ya están en caché: todo funciona offline. |
| `Cannot connect to Podman` | `podman machine start` |
| "name is already in use" | `.\scripts\limpiar.ps1` y repetir. |
| Contador muestra "Redis no disponible" | `podman ps -a --pod` para ver si Redis está corriendo; `podman logs expo-redis`. |
| La página no carga / "Empty reply from server" | Usar `http://127.0.0.1:8080` en vez de `localhost`. |
| Puerto ocupado | Usar otro: `podman pod create --name expo-pod -p 8090:5000`. |
