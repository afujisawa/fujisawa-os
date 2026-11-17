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
