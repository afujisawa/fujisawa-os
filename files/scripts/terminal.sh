#!/usr/bin/env bash
# Alacritty como terminal do sistema, no lugar do COSMIC Terminal.
# O pacote cosmic-term não pode ser removido (o cosmic-session depende dele),
# então ele é escondido dos menus/launcher e substituído nos atalhos e no dock.
set -oue pipefail

ACTIONS=/usr/share/cosmic/com.system76.CosmicSettings.Shortcuts/v1/system_actions
FAVORITES=/usr/share/cosmic/com.system76.CosmicAppList/v1/favorites
COSMIC_TERM_DESKTOP=/usr/share/applications/com.system76.CosmicTerm.desktop

# Atalho "Abrir terminal" (Super+T na sessão COSMIC) -> alacritty
sed -i 's|^\(\s*Terminal:\s*\)"cosmic-term",|\1"alacritty",|' "$ACTIONS"
grep -q 'Terminal: "alacritty",' "$ACTIONS"

# Dock: troca o COSMIC Terminal pelo Alacritty
sed -i 's|"com.system76.CosmicTerm"|"Alacritty"|' "$FAVORITES"
grep -q '"Alacritty"' "$FAVORITES"
! grep -q 'CosmicTerm' "$FAVORITES"

# Esconde o COSMIC Terminal dos menus e do launcher
if ! grep -q '^NoDisplay=true' "$COSMIC_TERM_DESKTOP"; then
  sed -i '0,/^\[Desktop Entry\]$/s//[Desktop Entry]\nNoDisplay=true/' "$COSMIC_TERM_DESKTOP"
fi
grep -q '^NoDisplay=true' "$COSMIC_TERM_DESKTOP"

# O Alacritty precisa existir com esse nome de atalho
test -f /usr/share/applications/Alacritty.desktop
