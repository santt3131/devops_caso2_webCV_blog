import os
import urllib.parse
from http.server import BaseHTTPRequestHandler, HTTPServer

DATA_DIR = "/data"
BLOG_FILE = os.path.join(DATA_DIR, "posts.txt")

def leer_posts() -> str:
    if not os.path.exists(BLOG_FILE):
        return "<li><em>No hay publicaciones en el blog todavía.</em></li>"
    try:
        with open(BLOG_FILE, "r", encoding="utf-8") as f:
            lineas = f.readlines()
            if not lineas:
                return "<li><em>No hay publicaciones en el blog todavía.</em></li>"
            return "".join(f"<li>📝 {linea.strip()}</li>" for linea in reversed(lineas) if linea.strip())
    except Exception:
        return "<li><em>Error leyendo las publicaciones.</em></li>"

def guardar_post(texto: str) -> None:
    os.makedirs(DATA_DIR, exist_ok=True)
    with open(BLOG_FILE, "a", encoding="utf-8") as f:
        f.write(texto + "\n")

PAGINA_HTML = """<!DOCTYPE html>
<html lang="es"><head><meta charset="utf-8">
<title>Caso Práctico 2 · El Blog de Santi</title>
<style>
 body {{ font-family: system-ui, sans-serif; background:#0f172a; color:#f1f5f9;
        display:flex; min-height:100vh; align-items:center; justify-content:center; margin:0; padding:20px; }}
 .card {{ background:#1e293b; border-radius:16px; padding:32px; width:100%; max-width:500px;
         box-shadow:0 10px 30px rgba(0,0,0,.5); }}
 h1 {{ color:#38bdf8; margin:0 0 16px; text-align:center; }}
 form {{ display: flex; gap: 8px; margin-bottom: 24px; }}
 input[type="text"] {{ flex: 1; padding: 10px; border-radius: 8px; border: 1px solid #475569; background: #0f172a; color: white; }}
 button {{ padding: 10px 16px; background: #38bdf8; border: none; color: #0f172a; font-weight: bold; border-radius: 8px; cursor: pointer; }}
 button:hover {{ background: #7dd3fc; }}
 ul {{ list-style: none; padding: 0; max-height: 250px; overflow-y: auto; }}
 li {{ background: #334155; padding: 12px; margin-bottom: 8px; border-radius: 8px; font-size: 0.95em; }}
 .pod {{ color:#94a3b8; font-size:.8em; text-align: center; margin-top: 20px; border-top: 1px solid #334155; padding-top: 10px; }}
</style></head>
<body><div class="card">
 <h1>El Blog de Santi (AKS)</h1>
 <form method="POST" action="/publicar">
   <input type="text" name="post" placeholder="Escribe algo en el blog..." required>
   <button type="submit">Publicar</button>
 </form>
 <h3>Publicaciones Recientes:</h3>
 <ul>{entradas}</ul>
 <div class="pod">Ejecutándose en el pod: {pod}</div>
</div></body></html>"""

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path != "/":
            self.send_response(404)
            self.end_headers()
            return
        entradas = leer_posts()
        cuerpo = PAGINA_HTML.format(entradas=entradas, pod=os.uname().nodename).encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(cuerpo)))
        self.end_headers()
        self.wfile.write(cuerpo)

    def do_POST(self):
        if self.path == "/publicar":
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length).decode('utf-8')
            params = urllib.parse.parse_qs(post_data)
            if 'post' in params:
                texto_post = params['post'][0]
                guardar_post(texto_post)
            
            # Redirección al inicio para ver el post publicado
            self.send_response(303)
            self.send_header('Location', '/')
            self.end_headers()

if __name__ == "__main__":
    print("Blog escuchando en el puerto :8080")
    HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()