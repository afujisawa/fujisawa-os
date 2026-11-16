#!/usr/bin/env bash
# Instala o Zed oficial (release do GitHub da Zed Industries) em /usr/lib/zed.app.
# Reproduz o que o instalador oficial (zed.dev/install.sh) faz em ~/.local,
# mas dentro da imagem. O SHA-256 é conferido com o publicado na release.
# O atualizador interno do Zed é desligado via ZED_UPDATE_EXPLANATION
# (files/system/etc/profile.d/zed.sh e usr/lib/environment.d/60-zed.conf):
# o Zed é atualizado junto com a imagem.
set -oue pipefail

case "$(uname -m)" in
  x86_64) ARCH=x86_64 ;;
  aarch64) ARCH=aarch64 ;;
  *) echo "Arquitetura não suportada: $(uname -m)" >&2; exit 1 ;;
esac
ASSET="zed-linux-${ARCH}.tar.gz"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

curl -fsSL --retry 3 -o "$tmp/release.json" \
  https://api.github.com/repos/zed-industries/zed/releases/latest
TAG=$(jq -r '.tag_name' "$tmp/release.json")
URL=$(jq -r --arg a "$ASSET" '.assets[] | select(.name == $a) | .browser_download_url' "$tmp/release.json")
DIGEST=$(jq -r --arg a "$ASSET" '.assets[] | select(.name == $a) | .digest' "$tmp/release.json")
echo "Zed ${TAG}"
[[ "$DIGEST" =~ ^sha256:[a-f0-9]{64}$ ]] || { echo "SHA-256 não publicado para $ASSET" >&2; exit 1; }

curl -fsSL --retry 3 -o "$tmp/$ASSET" "$URL"
echo "${DIGEST#sha256:}  $tmp/$ASSET" | sha256sum -c -

# Desempacota (o tarball contém o diretório zed.app/)
rm -rf /usr/lib/zed.app
tar -xzf "$tmp/$ASSET" -C /usr/lib/
test -x /usr/lib/zed.app/bin/zed
test -x /usr/lib/zed.app/libexec/zed-editor

# Falha o build se faltar alguma biblioteca
missing=$(ldd /usr/lib/zed.app/libexec/zed-editor | sed -n 's/^[[:space:]]*\(.*\) => not found$/\1/p')
if [[ -n "$missing" ]]; then
  echo "Bibliotecas faltando para o Zed:" >&2; echo "$missing" >&2; exit 1
fi

# Comando "zed"
ln -sf /usr/lib/zed.app/bin/zed /usr/bin/zed

# Atalho no menu e ícones (Exec=zed e Icon=zed resolvem pelos caminhos do sistema)
install -Dm644 /usr/lib/zed.app/share/applications/dev.zed.Zed.desktop \
  /usr/share/applications/dev.zed.Zed.desktop
cp -r /usr/lib/zed.app/share/icons/hicolor/. /usr/share/icons/hicolor/
grep -q '^Exec=zed' /usr/share/applications/dev.zed.Zed.desktop
