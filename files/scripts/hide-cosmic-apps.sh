#!/usr/bin/env bash
# Esconde dos menus e do launcher os apps do COSMIC substituídos por outros.
# Os pacotes não podem ser removidos (o cosmic-session depende deles):
#  - COSMIC Terminal   -> Alacritty
#  - COSMIC Screenshot -> Flameshot (atalho Print no niri)
# Os atalhos do COSMIC e os favoritos apontam para os substitutos nos arquivos
# de files/overrides.
set -oue pipefail

hide() {
  local desktop=/usr/share/applications/$1.desktop
  if ! grep -q '^NoDisplay=true' "$desktop"; then
    sed -i '0,/^\[Desktop Entry\]$/s//[Desktop Entry]\nNoDisplay=true/' "$desktop"
  fi
  grep -q '^NoDisplay=true' "$desktop"
}

hide com.system76.CosmicTerm
hide com.system76.CosmicScreenshot

# Os substitutos precisam existir com esses nomes de atalho
test -f /usr/share/applications/Alacritty.desktop
test -f /usr/share/applications/org.flameshot.Flameshot.desktop
