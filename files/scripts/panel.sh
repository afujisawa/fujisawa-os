#!/usr/bin/env bash
# Painéis do COSMIC. Roda depois do dnf: a configuração padrão é do pacote
# cosmic-panel.
#  - remove a dock: fica só o painel superior. Os apps ficam no
#    cosmic-launcher (Mod+D) e no cosmic-app-library (Mod+Shift+D).
#  - botão das Configurações do COSMIC no painel superior, antes do menu de
#    energia (a dock tinha o atalho; applet em
#    usr/share/applications/com.fujisawa.PanelSettingsButton.desktop)
set -oue pipefail

ENTRIES=/usr/share/cosmic/com.system76.CosmicPanel/v1/entries
WINGS=/usr/share/cosmic/com.system76.CosmicPanel.Panel/v1/plugins_wings
SETTINGS_BUTTON=com.fujisawa.PanelSettingsButton

grep -q '"Dock"' "$ENTRIES" # padrão esperado: ["Panel","Dock"]
printf '["Panel"]\n' >"$ENTRIES"

test -f "/usr/share/applications/${SETTINGS_BUTTON}.desktop"
test -f /usr/share/applications/com.system76.CosmicSettings.desktop
sed -i "s|\"com.system76.CosmicAppletPower\"|\"${SETTINGS_BUTTON}\", &|" "$WINGS"
grep -qF "\"${SETTINGS_BUTTON}\", \"com.system76.CosmicAppletPower\"" "$WINGS"
