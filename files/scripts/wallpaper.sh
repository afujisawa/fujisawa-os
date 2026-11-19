#!/usr/bin/env bash
# Define o papel de parede padrão do COSMIC (vale também para a sessão
# COSMIC on niri, onde o fundo é desenhado pelo cosmic-bg).
# Roda depois do dnf: o arquivo de configuração é do pacote cosmic-bg.
set -oue pipefail

WALLPAPER=/usr/share/backgrounds/fujisawa-os/samurai-warrior-night-by-lake.jpg
CONFIG=/usr/share/cosmic/com.system76.CosmicBackground/v1/all

test -r "$WALLPAPER"
sed -i "s|^\(\s*source:\s*\)Path(\"[^\"]*\"),|\1Path(\"${WALLPAPER}\"),|" "$CONFIG"
grep -qF "source: Path(\"${WALLPAPER}\")," "$CONFIG"

# O arquivo do cosmic-bg (1.11) traz "filter_by_theme: #true", que não é RON
# válido: a leitura falha e o cosmic-bg cai no fundo embutido (a nebulosa),
# ignorando este arquivo. Corrige para "true".
sed -i 's#^\(\s*filter_by_theme:\s*\)\#\(true\|false\),#\1\2,#' "$CONFIG"
if grep -q '#' "$CONFIG"; then
  echo "wallpaper: $CONFIG ainda tem '#', o cosmic-bg não vai conseguir ler" >&2
  exit 1
fi
