# general
alias grep='grep --color'
alias fgrep='fgrep --color'
# directory shortcuts
alias ..='cd ..'
alias ...='cd ../../'

# git
alias tiga='tig --all'
alias gh-pr='gh pr checkout --force'
alias gh-sync='gh repo sync $(gh repo view --json nameWithOwner -q .nameWithOwner) --branch $(git branch --show-current)'

# SSH compatibility for remote hosts without Foot terminfo.
[[ "$TERM" == "foot" || "$TERM" == "foot-direct" ]] && { alias ssh='env TERM=xterm-256color ssh' }