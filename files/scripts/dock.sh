#!/usr/bin/env bash
# Remove a dock do COSMIC: deixa só o painel superior na lista de painéis.
# Os apps ficam no cosmic-launcher (Mod+D) e no cosmic-app-library (Mod+Shift+D).
# Roda depois do dnf: a configuração padrão é do pacote cosmic-panel.
set -oue pipefail

ENTRIES=/usr/share/cosmic/com.system76.CosmicPanel/v1/entries

grep -q '"Dock"' "$ENTRIES" # padrão esperado: ["Panel","Dock"]
printf '["Panel"]\n' >"$ENTRIES"
