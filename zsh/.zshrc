# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# aliases
source ~/.zsh/aliases.zsh

# helper funcs
source ~/.zsh/funcs.zsh

# host specific
export HOST="${HOST%.local}"
source ~/.zsh/host_${HOST}.zsh

# history
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY

# keybindings
export LC_ALL=en_US.UTF-8
KEYTIMEOUT=1
bindkey -e
bindkey '^[' backward-word
bindkey '^]' forward-word

# toggle fg/bg with Ctrl-z
fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line -w
  else
    zle push-input -w
    zle clear-screen -w
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

# git completion
zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
fpath=(~/.zsh $fpath)
autoload -Uz compinit && compinit

# direnv
if type "direnv" > /dev/null; then
  eval "$(direnv hook zsh)"
fi

# fzf
export FZF_DEFAULT_COMMAND='fd .'
export FZF_CTRL_T_COMMAND='fd .'

# default editor
export VISUAL="vim"
export EDITOR="vim"
if type "nvim" > /dev/null; then
  export VISUAL="nvim"
  export EDITOR="nvim"
  alias vim='FZF_DEFAULT_COMMAND="fd . --type file --exclude vendor" nvim'
fi

# navi (widget used with ctrl+G)
if type "navi" > /dev/null; then
  eval "$(navi widget zsh)"
fi

# npm
export PATH=$HOME/.npm-global/bin:$PATH

# plugins

# zsh syntax highlighting and autosuggestions
source "${ZSH_PLUGINS_DIR}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "${ZSH_PLUGINS_DIR}/zsh-autosuggestions/zsh-autosuggestions.zsh"

# powerlevel10k
source "${POWERLEVEL10K_DIR}/powerlevel10k.zsh-theme"
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# additional config files that live outside apparatus
for conf in $(find -L "$HOME/.zsh/conf.d" -type f); do
  source $conf
done
