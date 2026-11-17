#!/usr/bin/env bash
# Ativa o tema de boot "fujisawa": logo do Fujisawa OS sobre fundo preto.
# O logo (watermark.png) e o tema vêm de files/system/usr/share/plymouth/themes/fujisawa;
# o spinner e os ícones da tela de senha são copiados do tema spinner do Fedora.
# O initramfs (onde o tema fica durante o boot) é regenerado pelo módulo
# "initramfs" da recipe.
set -oue pipefail

THEME_DIR=/usr/share/plymouth/themes/fujisawa
for f in /usr/share/plymouth/themes/spinner/*.png; do
  name=$(basename "$f")
  [[ "$name" == watermark.png ]] && continue
  cp "$f" "$THEME_DIR/$name"
done
test -r "$THEME_DIR/watermark.png"
test -r "$THEME_DIR/throbber-0001.png"

plymouth-set-default-theme fujisawa
grep -q '^Theme=fujisawa' /etc/plymouth/plymouthd.conf
