#!/usr/bin/env bash
# Instala o Claude Code (binário nativo oficial) em /usr/bin/claude.
# O instalador oficial (claude.ai/install.sh) instala por usuário em ~/.local;
# aqui o binário vem na imagem e é atualizado a cada build. O SHA-256 é
# conferido com o manifest oficial da versão. A atualização automática é
# desligada (DISABLE_AUTOUPDATER), pois /usr é somente leitura.
set -oue pipefail

BASE_URL=https://downloads.claude.ai/claude-code-releases
case "$(uname -m)" in
  x86_64) PLATFORM=linux-x64 ;;
  aarch64) PLATFORM=linux-arm64 ;;
  *) echo "Arquitetura não suportada: $(uname -m)" >&2; exit 1 ;;
esac

VERSION=$(curl -fsSL --retry 3 "$BASE_URL/latest")
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]] || { echo "Versão inválida: $VERSION" >&2; exit 1; }
echo "Claude Code ${VERSION}"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

CHECKSUM=$(curl -fsSL --retry 3 "$BASE_URL/$VERSION/manifest.json" \
  | jq -r --arg p "$PLATFORM" '.platforms[$p].checksum // empty')
[[ "$CHECKSUM" =~ ^[a-f0-9]{64}$ ]] || { echo "Checksum não encontrado no manifest" >&2; exit 1; }

curl -fsSL --retry 3 -o "$tmp/claude" "$BASE_URL/$VERSION/$PLATFORM/claude"
echo "${CHECKSUM}  $tmp/claude" | sha256sum -c -
install -Dm755 "$tmp/claude" /usr/bin/claude
