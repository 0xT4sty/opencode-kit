#!/usr/bin/env bash
# install.sh — instala el harness de OpenCode en un repo.
# Uso:
#   Desde la raíz del repo destino:  bash /ruta/al/kit/install.sh
#   O copia este script + carpeta al repo y ejecútalo.
#
# Es idempotente y NO pisa archivos existentes (hace copia .bak si difieren).
# "Lo más simple que funcione": copia los archivos al sitio correcto y avisa de los TODO.

set -euo pipefail

# Directorio donde vive este script (la fuente del harness)
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Directorio destino = donde se ejecuta (debería ser la raíz del repo)
DEST="$(pwd)"

echo "==> Instalando harness OpenCode"
echo "    Origen:  $SRC"
echo "    Destino: $DEST"
echo ""

if [ "$SRC" = "$DEST" ]; then
  echo "ERROR: ejecuta el script desde la raíz del repo DESTINO, no desde el kit."
  echo "       Ej: cd ~/repos/mi-proyecto && bash $SRC/install.sh"
  exit 1
fi

# Avisar si el destino no parece un repo git (no es bloqueante)
if [ ! -d "$DEST/.git" ]; then
  echo "AVISO: $DEST no parece un repo git. Continúo igualmente."
  echo ""
fi

# copy_safe ORIGEN DESTINO: copia sin pisar; si existe y difiere, deja .bak
copy_safe() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ]; then
    if cmp -s "$src" "$dst"; then
      echo "    = $dst (ya existe, idéntico, omito)"
    else
      cp "$dst" "$dst.bak"
      cp "$src" "$dst"
      echo "    ~ $dst (existía y difería -> guardado $dst.bak)"
    fi
  else
    cp "$src" "$dst"
    echo "    + $dst"
  fi
}

echo "==> Copiando configuración de OpenCode (.opencode/)"
# Recorre todo el .opencode del kit y replica en destino
while IFS= read -r -d '' f; do
  rel="${f#$SRC/}"
  copy_safe "$f" "$DEST/$rel"
done < <(find "$SRC/.opencode" -type f -print0)

echo ""
echo "==> Copiando archivos de raíz (reglas y fachada de build)"
# Solo AGENTS.md (lo auto-carga OpenCode) y Makefile (se ejecuta desde raíz) viven
# en la raíz. El resto del harness (init.sh, memoria) ya viajó dentro de .opencode/.
for f in AGENTS.md Makefile; do
  [ -f "$SRC/$f" ] && copy_safe "$SRC/$f" "$DEST/$f"
done
copy_safe "$SRC/docs/decisions/ADR-template.md" "$DEST/docs/decisions/ADR-template.md"

# .gitignore: el del repo destino es suyo. No lo pisamos: si no existe, lo copiamos;
# si existe, añadimos solo el bloque del harness (una vez, con marcador).
if [ -f "$SRC/.gitignore" ]; then
  MARKER="# >>> harness opencode (.bak, secretos) >>>"
  if [ ! -f "$DEST/.gitignore" ]; then
    cp "$SRC/.gitignore" "$DEST/.gitignore"
    echo "    + $DEST/.gitignore"
  elif grep -qF "$MARKER" "$DEST/.gitignore"; then
    echo "    = $DEST/.gitignore (bloque del harness ya presente, omito)"
  else
    { echo ""; echo "$MARKER"; echo ".env"; echo ".env.*"; echo "*.bak"; \
      echo "# <<< harness opencode <<<"; } >> "$DEST/.gitignore"
    echo "    ~ $DEST/.gitignore (añadido bloque del harness al final)"
  fi
fi

# init.sh ejecutable
[ -f "$DEST/.opencode/init.sh" ] && chmod +x "$DEST/.opencode/init.sh"

echo ""
echo "==> Hecho. Próximos pasos:"
echo "    1. Abre OpenCode en este repo:  opencode"
echo "    2. Proyecto existente:  /adoptar     (rellena AGENTS.md y Makefile)"
echo "       Proyecto vacío:      /nuevo \"...\"  (andamia desde cero)"
echo "    3. Verifica los modelos:  /models     (deben existir en tu plan)"
echo ""
echo "    Revisa los TODO de AGENTS.md y Makefile antes de trabajar en serio."
