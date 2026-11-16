#!/usr/bin/env bash
# Instala o oh-my-zsh para todos os usuários em /usr/share/oh-my-zsh e define
# o zsh como shell padrão de usuários novos. O .zshrc padrão fica em
# files/system/etc/skel/.zshrc.
set -oue pipefail

OMZ_DIR=/usr/share/oh-my-zsh
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

curl -fsSL --retry 3 https://github.com/ohmyzsh/ohmyzsh/archive/refs/heads/master.tar.gz \
  | tar -xz -C "$tmp"
rm -rf "$OMZ_DIR"
mv "$tmp"/ohmyzsh-master "$OMZ_DIR"
# Sem escrita para grupo/outros: o oh-my-zsh recusa carregar autocompletes
# de diretórios graváveis por outros (aviso "Insecure completion-dependent directories")
chmod -R a+rX,go-w "$OMZ_DIR"
test -r "$OMZ_DIR/oh-my-zsh.sh"

# zsh como shell padrão de usuários novos (useradd/Anaconda)
if grep -q '^SHELL=' /etc/default/useradd; then
  sed -i 's|^SHELL=.*|SHELL=/usr/bin/zsh|' /etc/default/useradd
else
  echo 'SHELL=/usr/bin/zsh' >> /etc/default/useradd
fi
grep -q '^SHELL=/usr/bin/zsh$' /etc/default/useradd

# O pacote zsh traz o próprio /etc/skel/.zshrc; o nosso fica e o dele vira .rpmnew
rm -f /etc/skel/.zshrc.rpmnew
