#!/usr/bin/env bash
# Confere os padrões do COSMIC copiados de files/overrides/usr/share/cosmic.
# Eles são arquivos completos, baseados nos do COSMIC 1.11.0 do Fedora 44:
# o build falha se algo de que eles dependem mudar ou sumir.
set -oue pipefail

C=/usr/share/cosmic
A=/usr/share/applications

# Papel de parede: a imagem existe e o arquivo não tem "#" (o "#true" do
# pacote cosmic-bg não é RON válido e fazia o cosmic-bg ignorar o arquivo)
test -r /usr/share/backgrounds/fujisawa-os/samurai-warrior-night-by-lake.jpg
grep -q 'samurai-warrior-night-by-lake.jpg' "$C/com.system76.CosmicBackground/v1/all"
! grep -q '#' "$C/com.system76.CosmicBackground/v1/all"

# Painéis: só o superior (sem dock), com o botão das Configurações
grep -qx '\["Panel"\]' "$C/com.system76.CosmicPanel/v1/entries"
grep -q '"com.fujisawa.PanelSettingsButton"' "$C/com.system76.CosmicPanel.Panel/v1/plugins_wings"
test -f "$A/com.fujisawa.PanelSettingsButton.desktop"
test -f "$A/com.system76.CosmicSettings.desktop"

# Applets usados no painel superior existem
for applet in $(grep -o '"com\.system76\.[A-Za-z]*"' "$C/com.system76.CosmicPanel.Panel/v1/plugins_wings" | tr -d '"'); do
  test -f "$A/$applet.desktop" || { echo "cosmic-defaults: applet $applet não encontrado" >&2; exit 1; }
done

# Atalho "Abrir terminal" e favoritos com o Alacritty
grep -q 'Terminal: "alacritty",' "$C/com.system76.CosmicSettings.Shortcuts/v1/system_actions"
grep -q '"Alacritty"' "$C/com.system76.CosmicAppList/v1/favorites"
test -f "$A/Alacritty.desktop"

# Atalho de captura de tela com o Flameshot
grep -q 'Screenshot: "flameshot gui",' "$C/com.system76.CosmicSettings.Shortcuts/v1/system_actions"
test -f "$A/org.flameshot.Flameshot.desktop"
