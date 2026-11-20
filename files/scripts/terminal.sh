#!/usr/bin/env bash
# Alacritty como terminal do sistema, no lugar do COSMIC Terminal.
# O pacote cosmic-term não pode ser removido (o cosmic-session depende dele),
# então ele é escondido dos menus e do launcher. O atalho "Abrir terminal" e
# os favoritos apontam para o Alacritty nos arquivos de files/overrides.
set -oue pipefail

COSMIC_TERM_DESKTOP=/usr/share/applications/com.system76.CosmicTerm.desktop

if ! grep -q '^NoDisplay=true' "$COSMIC_TERM_DESKTOP"; then
  sed -i '0,/^\[Desktop Entry\]$/s//[Desktop Entry]\nNoDisplay=true/' "$COSMIC_TERM_DESKTOP"
fi
grep -q '^NoDisplay=true' "$COSMIC_TERM_DESKTOP"

# O Alacritty precisa existir com esse nome de atalho
test -f /usr/share/applications/Alacritty.desktop
