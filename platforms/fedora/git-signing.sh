#!/usr/bin/env bash
set -euo pipefail

key="$HOME/.ssh/id_ed25519_sk_git_signing_personal"
config="$HOME/.config/git/signing.conf"

mkdir -p "$HOME/.ssh" "$HOME/.config/git"
if [[ -e "$key" || -L "$key" || -e "$key.pub" || -L "$key.pub" ]]; then
  if [[ ! -r "$key" || ! -r "$key.pub" ]]; then
    printf 'Signing key pair is incomplete; preserving existing files for %s.\n' "$key" >&2
    exit 1
  fi
else
  (cd "$HOME/.ssh" && ssh-keygen -K)
fi
if [[ ! -r "$key" || ! -r "$key.pub" ]]; then
  printf 'Expected recovered key at %s; rename the matching resident key and rerun.\n' "$key" >&2
  exit 1
fi

git config --file "$config" gpg.ssh.program "$(command -v ssh-keygen)"
git config --file "$config" user.signingkey "$key"
