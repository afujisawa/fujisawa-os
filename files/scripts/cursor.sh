#!/usr/bin/env bash
# Tema de cursor padrão: Bibata Modern Ice (release oficial do GitHub).
# A release não publica SHA-256; o hash abaixo foi calculado do arquivo da
# versão fixada. Para atualizar: troque VERSION e SHA256 juntos.
# Onde o tema é aplicado:
#  - /usr/share/icons/default/index.theme: padrão do XCursor (apps sem config)
#  - gschema override: cursor-theme do GTK (org.gnome.desktop.interface)
#  - XCURSOR_THEME/SIZE: start-cosmic-ext-niri e usr/lib/environment.d/60-cursor.conf
#  - niri: bloco cursor em files/system/etc/niri/config.kdl
set -oue pipefail

VERSION=v2.0.7
SHA256=a68cae60c4dc706350e194ebc91c5fe48bc7bc9d59e119555834a2a7ee5078ef
THEME=Bibata-Modern-Ice

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

curl -fsSL --retry 3 -o "$tmp/$THEME.tar.xz" \
  "https://github.com/ful1e5/Bibata_Cursor/releases/download/${VERSION}/${THEME}.tar.xz"
echo "${SHA256}  $tmp/$THEME.tar.xz" | sha256sum -c -

rm -rf "/usr/share/icons/$THEME"
tar -xJf "$tmp/$THEME.tar.xz" -C /usr/share/icons --no-same-owner
test -f "/usr/share/icons/$THEME/cursors/left_ptr"

install -Dm644 /dev/stdin /usr/share/icons/default/index.theme <<THEME_EOF
[Icon Theme]
Name=Default
Comment=Tema de cursor padrão do Fujisawa OS
Inherits=${THEME}
THEME_EOF

install -Dm644 /dev/stdin /usr/share/glib-2.0/schemas/zz1-fujisawa-cursor.gschema.override <<SCHEMA_EOF
[org.gnome.desktop.interface]
cursor-theme='${THEME}'
cursor-size=24
SCHEMA_EOF
glib-compile-schemas /usr/share/glib-2.0/schemas
