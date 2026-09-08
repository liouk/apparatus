#!/usr/bin/env bash

# Git signing must also work outside a shell that loads our Homebrew PATH.
git_config="$HOME/.config/git/platform.conf"
if [[ -L "$git_config" || ( -e "$git_config" && ! -f "$git_config" ) ]]; then
  echo "will not modify symlink or non-file: $git_config" >&2
  exit 1
fi
openssh_prefix="$(brew --prefix openssh)"
mkdir -p "$HOME/.config/git"
git config --file "$git_config" gpg.ssh.program "$openssh_prefix/bin/ssh-keygen"
