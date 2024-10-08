# general
alias grep='grep --color'
alias fgrep='fgrep --color'
alias zed=zeditor
alias z=zeditor

# directory shortcuts
alias ..='cd ..'
alias ...='cd ../../'

# git
alias vimod='vim -p $(git diff --name-only | uniq)'
alias tiga='tig --all'

# docker
alias doc='docker compose'
alias dex='docker exec -it -e COLUMNS="`tput cols`" -e LINES="`tput lines`"'

# kitty SSH compatibility
# https://sw.kovidgoyal.net/kitty/faq/#i-get-errors-about-the-terminal-being-unknown-or-opening-the-terminal-failing-when-sshing-into-a-different-computer
[[ "$TERM" == "xterm-kitty" ]] && { alias ssh='env TERM=xterm-256color ssh' }

alias icat="kitty +kitten icat"

# k8s
alias kc=kubectl
alias kcs=kubectl -n kube-system
