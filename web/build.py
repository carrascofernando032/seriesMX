"""Ejecutar desde cualquier carpeta con Python 3 y Pandoc instalados."""
from pathlib import Path
import subprocess
import shutil
import zipfile

web = Path(__file__).resolve().parent
repo = web.parent
github = 'https://github.com/carrascofernando032/seriesMX'
beta = 'https://script.google.com/macros/s/AKfycbzEs5Of2qmzNn_Miol7cf1weCuJE8zjDrFL8KCd7N-YigD8ojBoC7uF480-KDFk2_pigQ/exec'
def page(title, body):
    return f'''<!doctype html><html lang="es-MX"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>{title} · seriesMX</title><link rel="stylesheet" href="/estilo.css"><header><a href="/">seriesMX</a><nav aria-label="Principal"><a href="/proyecto/">Proyecto</a><a href="/buscador/">Buscador beta</a><a href="{github}">GitHub</a></nav></header><main>{body}</main></html>'''

out = web / 'dist'
for sub in ['proyecto','buscador']:
    (out/sub).mkdir(parents=True,exist_ok=True)
(out/'index.html').write_text(page('Inicio','<h1>Series macroeconómicas de México</h1><p>Explora indicadores del INEGI y del Banco de México desde el navegador o incorpóralos a un análisis reproducible en R.</p><p><a class="action" href="/buscador/">Consultar el buscador beta</a></p><h2>¿Cómo funciona seriesMX?</h2><p>Los catálogos permiten localizar una serie antes de pedir sus observaciones a la institución que la publica. El paquete permite descargarla por clave o URL, transformar sus valores y graficarlos.</p><a href="/proyecto/">Conocer el proyecto y los ejemplos en R</a>'),encoding='utf8')
article=subprocess.check_output(['pandoc','-f','gfm','-t','html5','--toc','--standalone','--metadata','title=Guía del paquete','README.md'],cwd=repo,text=True)
article=article.split('<body>',1)[1].split('</body>',1)[0]
(out/'proyecto/index.html').write_text(page('Proyecto',article),encoding='utf8')
shutil.copytree(repo/'README_files',out/'proyecto/README_files',dirs_exist_ok=True)
(out/'buscador/index.html').write_text(page('Buscador beta',f'<h1>Buscador seriesMX beta</h1><p>Localiza indicadores por clave o tema. Para descargar observaciones, utiliza el token de la institución correspondiente.</p><p><a class="action" href="{beta}">Abrir la aplicación en Google Apps Script</a></p>'),encoding='utf8')
shutil.copy(web/'estilo.css',out)
with zipfile.ZipFile(web/'portal.zip','w',zipfile.ZIP_DEFLATED) as z:
    for f in sorted(out.rglob('*')):
        if f.is_file(): z.write(f,f.relative_to(out))
