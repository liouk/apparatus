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
alias gh-pr='gh pr checkout --force'
alias git-wt='find ~/redhat/repos ~/liouk -maxdepth 3 -name .git -exec sh -c "wt=\"\$(git --git-dir=\"\$1\" worktree list)\"; [ \"\$(echo \"\$wt\" | wc -l)\" -gt 1 ] && echo \"\$wt\" && echo" _ {} \; 2>/dev/null'
alias gh-sync='gh repo sync $(gh repo view --json nameWithOwner -q .nameWithOwner) --branch $(git branch --show-current)'

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
