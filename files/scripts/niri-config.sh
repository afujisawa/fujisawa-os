#!/usr/bin/env bash
# Gera /etc/niri/config.kdl (config padrão do sistema) a partir da config
# padrão da versão do niri instalada, adaptada para rodar sob o COSMIC:
#  - inicia o cosmic-ext-alternative-startup (em vez do waybar)
#  - Mod+D abre o cosmic-launcher, Mod+Shift+D o cosmic-app-library
#  - Super+Alt+L bloqueia a tela com o cosmic-greeter
#  - cores do anel de foco e das bordas na paleta Tokyo Night Storm
#  - cursor Bibata Modern Ice
# O niri usa /etc/niri/config.kdl enquanto o usuário não tiver
# ~/.config/niri/config.kdl.
set -oue pipefail

SRC=/usr/share/doc/niri/default-config.kdl
DEST=/etc/niri/config.kdl
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

if [[ -r "$SRC" ]]; then
  cp "$SRC" "$tmp"
else
  # Imagem sem /usr/share/doc: baixa a config da mesma versão do niri
  NIRI_VERSION=$(rpm -q --qf '%{VERSION}' niri)
  curl -fsSL -o "$tmp" \
    "https://raw.githubusercontent.com/niri-wm/niri/v${NIRI_VERSION}/resources/default-config.kdl"
fi

sed -i \
  -e 's|^// This line starts waybar, a commonly used bar for Wayland compositors\.$|// Avisa o cosmic-session que o niri está pronto (inicia painel, dock etc.)|' \
  -e 's|^spawn-at-startup "waybar"$|spawn-at-startup "cosmic-ext-alternative-startup"|' \
  -e 's|^\(\s*\)Mod+D hotkey-overlay-title="[^"]*" { spawn "fuzzel"; }|\1Mod+D hotkey-overlay-title="Run an Application: cosmic-launcher" { spawn "cosmic-launcher"; }\n\1Mod+Shift+D hotkey-overlay-title="App Library: cosmic-app-library" { spawn "cosmic-app-library"; }|' \
  -e 's|^\(\s*\)Super+Alt+L hotkey-overlay-title="[^"]*" { spawn "swaylock"; }|\1Super+Alt+L hotkey-overlay-title="Lock the Screen: cosmic-greeter" { spawn "cosmic-greeter"; }|' \
  -e 's|active-color "#7fc8ff"|active-color "#7aa2f7"|' \
  -e 's|active-color "#ffc87f"|active-color "#bb9af7"|' \
  -e 's|inactive-color "#505050"|inactive-color "#414868"|g' \
  -e 's|urgent-color "#9b0000"|urgent-color "#f7768e"|' \
  "$tmp"

# Falha o build se alguma substituição não aconteceu (config padrão mudou)
for expected in \
  'spawn-at-startup "cosmic-ext-alternative-startup"' \
  'spawn "cosmic-launcher"' \
  'spawn "cosmic-app-library"' \
  'spawn "cosmic-greeter"' \
  'active-color "#7aa2f7"' \
  'active-color "#bb9af7"' \
  'inactive-color "#414868"' \
  'urgent-color "#f7768e"'; do
  grep -qF "$expected" "$tmp" || { echo "niri-config: não encontrei '$expected'" >&2; exit 1; }
done
if grep -qE '^spawn-at-startup "waybar"|spawn "(fuzzel|swaylock)"' "$tmp"; then
  echo "niri-config: ainda há referências a waybar/fuzzel/swaylock" >&2
  exit 1
fi

# Tema de cursor (Bibata Modern Ice, instalado por cursor.sh). O niri também
# exporta XCURSOR_THEME/XCURSOR_SIZE para os programas que inicia.
if grep -qE '^cursor \{' "$tmp"; then
  echo "niri-config: a config padrão já tem um bloco cursor" >&2
  exit 1
fi
cat >>"$tmp" <<'CURSOR_EOF'

// Tema de cursor padrão do Fujisawa OS
cursor {
    xcursor-theme "Bibata-Modern-Ice"
    xcursor-size 24
}
CURSOR_EOF

install -Dm644 "$tmp" "$DEST"
niri validate -c "$DEST"
