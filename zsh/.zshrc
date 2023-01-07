# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Configure zsh prompt
source ~/.zsh/.zsh_prompt
precmd() { eval "$PROMPT_COMMAND" }

export VISUAL="nvim"
export EDITOR="nvim"

# Futurae
export PATH="$GOPATH/bin:$PATH"
export FUTURAE="/Users/ilias/Workspace/futurae"

[[ -s "/Users/ilias/.gvm/scripts/gvm" ]] && source "/Users/ilias/.gvm/scripts/gvm"

# Misc
export LC_ALL=en_US.UTF-8
KEYTIMEOUT=1
bindkey -e

# Load Git completion
zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
fpath=(~/.zsh $fpath)

autoload -Uz compinit && compinit

# brew
BREW_PATH=/usr/local/Homebrew
if [[ $(uname -m) == 'arm64' ]]; then
  BREW_PATH=/opt/homebrew
fi
eval $($BREW_PATH/bin/brew shellenv)
export PATH="BREW_PATH/bin:$PATH"

# direnv
eval "$(direnv hook zsh)"

# GNU make
export PATH="/usr/local/opt/make/libexec/gnubin:$PATH"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='find .'
export FZF_CTRL_T_COMMAND='find .'

# navi (widget used with ctrl+G)
eval "$(navi widget zsh)"

# keybindings
bindkey \^U backward-kill-line

# Aliases
source ~/.zsh/.zsh_aliases

# helper funcs
source ~/.zsh/.zsh_funcs
source /usr/local/opt/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
