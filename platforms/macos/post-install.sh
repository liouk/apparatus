#!/usr/bin/env bash

agent_label="com.liouk.apparatus.git-signing"
agent_plist="$HOME/Library/LaunchAgents/$agent_label.plist"
domain="gui/$(id -u)"

if [[ -L "$agent_plist" || ( -e "$agent_plist" && ! -f "$agent_plist" ) ]]; then
  apparatus_warning "will not replace symlink or non-file: $agent_plist"
  return 1
fi

mkdir -p "$HOME/Library/LaunchAgents"
cp "$SCRIPT_DIR/platforms/macos/git-signing.plist" "$agent_plist"
/usr/bin/plutil -lint "$agent_plist" >/dev/null

if ! /bin/launchctl print "$domain" >/dev/null 2>&1; then
  apparatus_warning 'warning: no GUI login session; the signing task will load at the next graphical login.'
else
  /bin/launchctl bootout "$domain/$agent_label" >/dev/null 2>&1 || true
  /bin/launchctl bootstrap "$domain" "$agent_plist"
fi
