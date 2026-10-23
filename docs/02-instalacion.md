# 2. Instalación de Podman

## Windows 10/11

**Requisito:** WSL2 habilitado (en una terminal de administrador: `wsl --install`, luego reiniciar).
Puedes comprobarlo con `wsl --status`.

### Opción A: línea de comandos (recomendada)

```powershell
# 1. Instalar Podman
winget install -e --id RedHat.Podman

# 2. Cerrar y volver a abrir la terminal para que reconozca el comando, luego:
podman --version

# 3. Crear la máquina virtual Linux (solo la primera vez; descarga ~1 GB)
podman machine init

# 4. Encenderla (cada vez que reinicies el PC)
podman machine start

# 5. Verificar
podman info
podman run --rm quay.io/podman/hello
```

### Opción B: interfaz gráfica (Podman Desktop)

```powershell
winget install -e --id RedHat.Podman-Desktop
```

O descargarlo de <https://podman-desktop.io>. Al abrirlo, el asistente instala Podman y crea la máquina automáticamente.

### Comandos útiles de la máquina virtual

```powershell
podman machine list      # ver máquinas y su estado
podman machine stop      # apagarla (libera RAM)
podman machine ssh       # entrar a la VM Linux
podman machine rm        # borrarla
```

## Linux

Podman viene en los repositorios oficiales; **no necesita máquina virtual**.

```bash
# Ubuntu / Debian
sudo apt update && sudo apt install -y podman

# Fedora / RHEL / CentOS Stream
sudo dnf install -y podman

# Arch Linux
sudo pacman -S podman

# Verificar
podman --version
podman run --rm quay.io/podman/hello
```

## macOS

```bash
brew install podman
podman machine init
podman machine start
podman run --rm quay.io/podman/hello
```

## Extras opcionales

```bash
# Soporte de docker-compose.yml
pip install podman-compose

# Usar "docker" como alias de podman (Linux/macOS)
alias docker=podman
```

En PowerShell: `Set-Alias docker podman`

## Problemas comunes

| Problema | Solución |
|---|---|
| `podman` no se reconoce | Cerrar y abrir la terminal (o reiniciar) tras instalar. |
| `Cannot connect to Podman` | La máquina está apagada: `podman machine start`. |
| Error de WSL al hacer `machine init` | Ejecutar `wsl --update` y reiniciar. |
| `short-name resolution` al descargar imágenes | Usar nombre completo: `docker.io/library/redis` en vez de `redis`. |
| La app no carga en `localhost:8080` pero el contenedor está "Up" | En Windows abrir `http://127.0.0.1:8080`: `localhost` usa IPv6 y el reenvío de WSL no responde por ahí. |
| Puerto ocupado | Cambiar el puerto del host: `-p 8090:5000`. |
