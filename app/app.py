# Aplicacion de ejemplo para la exposicion de Podman.
# Un contador de visitas: Flask muestra la pagina y Redis guarda el numero.
import os
import socket

import redis
from flask import Flask, jsonify

app = Flask(__name__)

# Dentro de un pod de Podman todos los contenedores comparten la red,
# por eso Redis se encuentra en "localhost" sin configurar nada mas.
REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
db = redis.Redis(host=REDIS_HOST, port=6379, decode_responses=True)

PAGINA = """<!doctype html>
<html lang="es">
<head><meta charset="utf-8"><title>Expo Podman</title>
<style>
  body {{ font-family: system-ui, sans-serif; background:#1e1e2e; color:#cdd6f4;
         display:flex; align-items:center; justify-content:center; height:100vh; margin:0; }}
  .card {{ background:#313244; padding:2.5rem 3.5rem; border-radius:16px; text-align:center; }}
  h1 {{ color:#89b4fa; margin-top:0; }}
  .num {{ font-size:4rem; font-weight:700; color:#a6e3a1; }}
  small {{ color:#9399b2; }}
</style></head>
<body><div class="card">
  <h1>Hola desde un contenedor Podman</h1>
  <p>Esta pagina ha sido visitada</p>
  <div class="num">{visitas}</div>
  <p>veces</p>
  <small>Contenedor: {host} &middot; Usuario: {usuario}</small>
</div></body></html>"""


@app.route("/")
def index():
    try:
        visitas = db.incr("visitas")
    except redis.RedisError:
        visitas = "Redis no disponible"
    return PAGINA.format(visitas=visitas, host=socket.gethostname(), usuario=os.getenv("USER", "appuser"))


@app.route("/health")
def health():
    try:
        db.ping()
        estado_redis = "ok"
    except redis.RedisError:
        estado_redis = "caido"
    return jsonify(app="ok", redis=estado_redis, host=socket.gethostname())


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
