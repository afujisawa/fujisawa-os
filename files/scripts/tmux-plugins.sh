#!/usr/bin/env bash
# Pré-instala o TPM e os plugins do .tmux.conf padrão em /etc/skel/.tmux/plugins,
# para que usuários novos já tenham o tmux pronto sem rodar "Prefix + I".
# Como ficam na pasta do usuário, "Prefix + U" continua atualizando normalmente.
set -oue pipefail

PLUGINS_DIR=/etc/skel/.tmux/plugins
mkdir -p "$PLUGINS_DIR"

for repo in \
  tmux-plugins/tpm \
  janoamaral/tokyo-night-tmux \
  christoomey/vim-tmux-navigator; do
  name=${repo#*/}
  rm -rf "${PLUGINS_DIR:?}/$name"
  git clone -q --depth 1 "https://github.com/$repo" "$PLUGINS_DIR/$name"
done
test -x "$PLUGINS_DIR/tpm/tpm"
