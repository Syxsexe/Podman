# 3. Explicación del código

El proyecto de demostración es un **contador de visitas** con dos contenedores que viven en el mismo **pod**:

```
                 Windows / host
   navegador ──► 127.0.0.1:8080
                       │
   ┌───────────────────┼──────────── POD "expo-pod" ──────────────┐
   │                   ▼  (red compartida: todos son "localhost")  │
   │  ┌──────────────────────┐        ┌──────────────────────┐    │
   │  │ expo-app  (Flask)    │ ─────► │ expo-redis (Redis)   │    │
   │  │ puerto 5000          │ :6379  │ puerto 6379          │    │
   │  └──────────────────────┘        └──────────────────────┘    │
   │  + contenedor "infra" (mantiene la red del pod)              │
   └──────────────────────────────────────────────────────────────┘
```

- **expo-app**: aplicación web en Python (Flask) que construimos nosotros.
- **expo-redis**: base de datos en memoria; usamos la imagen oficial, no hay que construir nada.

---

## 3.1 `app/app.py` — la aplicación

```python
REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
db = redis.Redis(host=REDIS_HOST, port=6379, decode_responses=True)
```
Lee la dirección de Redis desde una **variable de entorno** (se la pasamos con `-e REDIS_HOST=localhost`). Configurar con variables de entorno es la práctica estándar en contenedores: la misma imagen sirve en cualquier entorno.

**¿Por qué `localhost`?** Porque ambos contenedores están en el mismo pod y **comparten la interfaz de red**. Para la app, Redis está "en su misma máquina".

```python
@app.route("/")
def index():
    try:
        visitas = db.incr("visitas")
    except redis.RedisError:
        visitas = "Redis no disponible"
```
Cada vez que se abre la página, `INCR` suma 1 a la clave `visitas` en Redis y devuelve el nuevo valor. Si Redis no responde, la app no se cae: muestra un mensaje.

```python
return PAGINA.format(visitas=visitas, host=socket.gethostname(), ...)
```
Muestra el número y el **hostname**, que dentro de un contenedor es el nombre del pod/contenedor, demostrando que estamos dentro de él.

```python
@app.route("/health")
```
Endpoint de **salud** que responde JSON (`{"app":"ok","redis":"ok",...}`). Es típico en contenedores para que orquestadores (Kubernetes) sepan si la app funciona.

```python
app.run(host="0.0.0.0", port=5000)
```
`0.0.0.0` es obligatorio: hace que Flask escuche en todas las interfaces. Con `127.0.0.1` no se podría acceder desde fuera del contenedor.

## 3.2 `app/requirements.txt`

Las dependencias de Python con versión fija (`flask`, `redis`), para que la imagen sea **reproducible**.

## 3.3 `app/Containerfile` — la receta de la imagen

`Containerfile` es el nombre "neutral" del `Dockerfile`; Podman acepta ambos y la sintaxis es idéntica.

| Instrucción | Qué hace |
|---|---|
| `FROM docker.io/library/python:3.12-slim` | Parte de una imagen con Python ya instalado. Se usa el **nombre completo** del registro porque Podman no asume Docker Hub por defecto. |
| `WORKDIR /app` | Carpeta de trabajo dentro de la imagen. |
| `COPY requirements.txt .` + `RUN pip install ...` | Instala dependencias **antes** de copiar el código: así, si solo cambia `app.py`, Podman reutiliza esta capa de la caché y la construcción es instantánea. |
| `COPY app.py .` | Copia el código. |
| `RUN useradd ... ` + `USER appuser` | Crea un usuario sin privilegios y ejecuta la app con él. **Seguridad en dos niveles**: no-root dentro del contenedor + rootless de Podman fuera. |
| `EXPOSE 5000` | Documenta el puerto que usa la app. |
| `CMD ["python", "app.py"]` | Comando que se ejecuta al iniciar el contenedor. |

Cada instrucción crea una **capa**; la imagen final es la suma de capas.

## 3.4 `kube/pod-demo.yaml` — el mismo pod en YAML de Kubernetes

```yaml
kind: Pod
spec:
  containers:
    - name: web
      image: localhost/expo-app:1.0
      ports:
        - containerPort: 5000
          hostPort: 8081
    - name: redis
      image: docker.io/library/redis:7-alpine
```
Describe de forma **declarativa** lo que en la demo hacemos con comandos: un pod con dos contenedores. Con `podman kube play kube/pod-demo.yaml` Podman lo crea todo de una vez. Este archivo **también funciona en un clúster de Kubernetes real** (subiendo la imagen a un registro): Podman sirve como puente entre desarrollo local y producción.

`localhost/expo-app:1.0` es como Podman nombra las imágenes construidas localmente.

## 3.5 `scripts/demo.ps1` y `scripts/demo.sh`

Automatizan la demo: para cada paso muestran el título y el comando, esperan **ENTER** y lo ejecutan. Así el expositor controla el ritmo y no comete errores de tipeo. La función clave:

```powershell
function Paso($titulo, $comando) {
    Write-Host " $titulo"
    Write-Host "PS> $comando"
    Read-Host "   (ENTER para ejecutar)"
    Invoke-Expression $comando
}
```

`scripts/limpiar.ps1` elimina pods, contenedores, la imagen y el YAML generado para dejar todo como al inicio.
