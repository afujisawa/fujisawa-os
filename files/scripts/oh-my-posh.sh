#!/usr/bin/env bash
# Instala o oh-my-posh oficial (release do GitHub) com os temas, e a fonte
# Symbols Nerd Font (só ícones), usada automaticamente como reserva para os
# ícones do prompt. O pacote do Fedora é antigo e não traz os temas.
set -oue pipefail

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

latest_tag() {
  curl -fsSLI --retry 3 -o /dev/null -w '%{url_effective}' "https://github.com/$1/releases/latest" \
    | sed 's|.*/tag/||'
}

# --- oh-my-posh -------------------------------------------------------------
POSH_TAG=$(latest_tag JanDeDobbeleer/oh-my-posh)
POSH_URL="https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/${POSH_TAG}"
echo "oh-my-posh ${POSH_TAG}"

curl -fsSL --retry 3 -o "$tmp/posh-linux-amd64" "$POSH_URL/posh-linux-amd64"
curl -fsSL --retry 3 -o "$tmp/checksums.txt" "$POSH_URL/checksums.txt"
(cd "$tmp" && grep -E ' posh-linux-amd64$' checksums.txt | sha256sum -c -)
install -Dm755 "$tmp/posh-linux-amd64" /usr/bin/oh-my-posh

curl -fsSL --retry 3 -o "$tmp/themes.zip" "$POSH_URL/themes.zip"
rm -rf /usr/share/oh-my-posh/themes
mkdir -p /usr/share/oh-my-posh/themes
unzip -q "$tmp/themes.zip" -d /usr/share/oh-my-posh/themes
chmod -R a+rX /usr/share/oh-my-posh
test -r /usr/share/oh-my-posh/themes/tokyonight_storm.omp.json

# --- Symbols Nerd Font (só ícones) ------------------------------------------
NF_TAG=$(latest_tag ryanoasis/nerd-fonts)
NF_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${NF_TAG}"
echo "nerd-fonts ${NF_TAG}"

curl -fsSL --retry 3 -o "$tmp/NerdFontsSymbolsOnly.tar.xz" "$NF_URL/NerdFontsSymbolsOnly.tar.xz"
curl -fsSL --retry 3 -o "$tmp/SHA-256.txt" "$NF_URL/SHA-256.txt"
(cd "$tmp" && grep -E ' NerdFontsSymbolsOnly\.tar\.xz$' SHA-256.txt | sha256sum -c -)
mkdir -p /usr/share/fonts/symbols-nerd-font
tar -xJf "$tmp/NerdFontsSymbolsOnly.tar.xz" -C /usr/share/fonts/symbols-nerd-font --wildcards '*.ttf'
fc-cache -f /usr/share/fonts/symbols-nerd-font
fc-list : family | grep -q 'Symbols Nerd Font'
