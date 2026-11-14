#!/usr/bin/env bash
# Identifica o sistema como "Fujisawa OS" (instalador, GRUB, configurações).
# Mantém ID=fedora e VERSION_ID: o bootc-image-builder e o dnf dependem deles.
# Não define VARIANT_ID: com ele, o Anaconda trata o sistema como uma variante
# (ex.: Kinoite) e pode esconder a tela de criação de usuário.
set -oue pipefail

OS_RELEASE=$(readlink -f /usr/lib/os-release)

sed -i \
  -e 's|^NAME=.*|NAME="Fujisawa OS"|' \
  -e 's|^PRETTY_NAME="Fedora Linux |PRETTY_NAME="Fujisawa OS |' \
  -e 's|^DEFAULT_HOSTNAME=.*|DEFAULT_HOSTNAME="fujisawa-os"|' \
  -e 's|^HOME_URL=.*|HOME_URL="https://github.com/afujisawa/fujisawa-os"|' \
  -e '/^VARIANT=/d' -e '/^VARIANT_ID=/d' \
  "$OS_RELEASE"

grep -q '^NAME="Fujisawa OS"$' "$OS_RELEASE"
grep -q '^PRETTY_NAME="Fujisawa OS ' "$OS_RELEASE"
grep -q '^ID=fedora$' "$OS_RELEASE"
