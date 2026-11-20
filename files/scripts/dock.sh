#!/usr/bin/env bash
# Dock do COSMIC oculta por padrão: aparece ao levar o mouse à borda onde
# ela fica. Roda depois do dnf: a configuração padrão é do pacote cosmic-panel.
# Valores aceitos (cosmic-panel 1.11): Never, OnOverlap, Always.
set -oue pipefail

DIR=/usr/share/cosmic/com.system76.CosmicPanel.Dock/v1

test -d "$DIR"
printf 'Always\n' >"$DIR/autohide"
grep -qx 'Always' "$DIR/autohide"
