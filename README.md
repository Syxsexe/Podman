# Exposición: Podman

Material completo para presentar Podman: teoría, instalación, explicación del código y demostración en vivo.

## Contenido de la carpeta

```
Podman/
├── README.md                     ← este archivo (índice y resumen rápido)
├── docs/
│   ├── 01-que-es-podman.md       ← teoría: qué es, arquitectura, Podman vs Docker
│   ├── 02-instalacion.md         ← instalación en Windows, Linux y macOS
│   ├── 03-explicacion-codigo.md  ← explicación línea por línea del proyecto
│   ├── 04-guion-demostracion.md  ← guion paso a paso para la demo en vivo
│   └── 05-chuleta-comandos.md    ← resumen de comandos y preguntas frecuentes
├── app/
│   ├── app.py                    ← app web (Flask) con contador de visitas
│   ├── requirements.txt          ← dependencias de Python
│   └── Containerfile             ← receta para construir la imagen
├── kube/
│   └── pod-demo.yaml             ← el mismo pod descrito en YAML de Kubernetes
└── scripts/
    ├── demo.ps1                  ← demo guiada automática (Windows)
    ├── demo.sh                   ← demo guiada automática (Linux/macOS/WSL)
    └── limpiar.ps1               ← borra todo lo creado por la demo
```

## Orden sugerido de la exposición (≈ 20 min)

| Tiempo | Parte | Material |
|---|---|---|
| 5 min | ¿Qué es Podman y por qué existe? | [docs/01-que-es-podman.md](docs/01-que-es-podman.md) |
| 3 min | Cómo se instala | [docs/02-instalacion.md](docs/02-instalacion.md) |
| 4 min | Explicación del código | [docs/03-explicacion-codigo.md](docs/03-explicacion-codigo.md) |
| 8 min | Demostración en vivo | [docs/04-guion-demostracion.md](docs/04-guion-demostracion.md) |

## Inicio rápido (Windows)

```powershell
# 1. Instalar (una sola vez)
winget install -e --id RedHat.Podman
# cerrar y abrir la terminal, luego:
podman machine init
podman machine start

# 2. Ejecutar la demo guiada desde esta carpeta
powershell -ExecutionPolicy Bypass -File .\scripts\demo.ps1

# 3. Al terminar, limpiar
powershell -ExecutionPolicy Bypass -File .\scripts\limpiar.ps1
```

> **Consejo:** ejecuta la demo completa al menos una vez **antes** de la exposición. La primera vez descarga las imágenes (python, redis), lo que puede tardar varios minutos; después quedan en caché y la demo en vivo es rápida.
