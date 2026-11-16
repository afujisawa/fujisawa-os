#
# .zshrc is sourced in interactive shells.
# It should contain commands to set up aliases,
# functions, options, key bindings, etc.
#

# ============================================================
# oh-my-zsh (instalado na imagem, somente leitura em /usr)
# O compinit é executado pelo próprio oh-my-zsh.
# ============================================================
export ZSH=/usr/share/oh-my-zsh
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/oh-my-zsh"
export ZSH_CUSTOM="${XDG_CONFIG_HOME:-$HOME/.config}/oh-my-zsh/custom"
mkdir -p "$ZSH_CACHE_DIR/completions" "$ZSH_CUSTOM/plugins" "$ZSH_CUSTOM/themes"
zstyle ':omz:update' mode disabled # atualizações vêm com a imagem

ZSH_THEME="" # o prompt é do oh-my-posh
plugins=(sudo z) # sem o plugin git: os aliases de git estão abaixo

source "$ZSH/oh-my-zsh.sh"

#allow tab completion in the middle of a word
setopt COMPLETE_IN_WORD

## keep background processes at full speed
#setopt NOBGNICE
## restart running processes on exit
#setopt HUP

## history
#setopt APPEND_HISTORY
## for sharing history between zsh processes
#setopt INC_APPEND_HISTORY
#setopt SHARE_HISTORY

## never ever beep ever
#setopt NO_BEEP

## automatically decide when to page a list of completions
#LISTMAX=0

## disable mail checking
#MAILCHECK=0

# autoload -U colors
#colors

source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

source /usr/share/fzf/shell/key-bindings.zsh

# Navegação e listagem
alias ll='ls -lah --color=auto'
alias c='clear'

# Git
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add -A'
alias gd='git diff'
alias gds='git diff --staged'
alias gc='git commit -v'
alias gck='git checkout'
alias gcm='git commit -m'
alias gps='git push'
alias gpl='git pull'
alias gl='git log --oneline --graph --decorate -20'
alias gsw='git switch'
alias gb='git branch'
alias gst='git stash'

# Ctrl + Arrow keybindings
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word

# Ctrl + Backspace/Delete Kebindings
bindkey '^H' backward-kill-word
bindkey '^[[3;5~' kill-word

# Alt + Backspace/Delete Keybinds
bindkey "^[[3~" delete-char
bindkey -M emacs '^[[3;3~' kill-word

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt SHARE_HISTORY
setopt autocd

# Allow Bash-style globbing
unsetopt nomatch

if [[ -z "$TMUX" && -n "$PS1" ]]; then
    exec tmux new-session -A -s af
fi

# Tema do oh-my-posh: o do usuário em ~/.config ou, se não existir, o Tokyo Night Storm do sistema
POSH_THEME_FILE="$HOME/.config/oh-my-posh/TokyoNight.omp.json"
[[ -r "$POSH_THEME_FILE" ]] || POSH_THEME_FILE=/usr/share/oh-my-posh/themes/tokyonight_storm.omp.json
eval "$(oh-my-posh init zsh --config "$POSH_THEME_FILE")"
