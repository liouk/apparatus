#!/usr/bin/env zsh

function nas_mount {
  osascript <<EOF
  mount volume "smb://ilias@readynas/ilias"
EOF
}

nas_mount > /dev/null
