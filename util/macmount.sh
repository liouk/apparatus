#!/usr/bin/env zsh

function nas_mount {
  osascript <<EOF
  mount volume "smb://ilias@readynas/ilias"
EOF
}

echo "mounting 'smb://ilias@readynas/ilias' onto '/Volumes/ilias/'"
nas_mount > /dev/null
