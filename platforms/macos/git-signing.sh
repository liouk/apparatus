#!/usr/bin/env bash
set -euo pipefail

key="$HOME/.ssh/macos-signing/id_ecdsa_sk_rk"
config="$HOME/.config/git/signing.conf"

mkdir -p "$(dirname "$key")" "$HOME/.config/git"
if [[ -e "$key" || -L "$key" || -e "$key.pub" || -L "$key.pub" ]]; then
  if [[ ! -r "$key" || ! -r "$key.pub" ]]; then
    printf 'Signing key pair is incomplete; preserving existing files for %s.\n' "$key" >&2
    exit 1
  fi
else
  (cd "$(dirname "$key")" && /usr/bin/ssh-keygen -w /usr/lib/ssh-keychain.dylib -K)
fi
if [[ ! -r "$key" || ! -r "$key.pub" ]]; then
  printf 'Expected recovered Secure Enclave handle at %s; rename the matching resident key and rerun.\n' "$key" >&2
  exit 1
fi

git config --file "$config" gpg.ssh.program /usr/bin/ssh-keygen
git config --file "$config" user.signingkey "$key.pub"

fingerprint="$(/usr/bin/ssh-keygen -lf "$key.pub" -E sha256 | awk '{print $2}')"
if ! /usr/bin/ssh-add -l -E sha256 2>/dev/null | /usr/bin/grep -Fq "$fingerprint"; then
  /usr/bin/ssh-add -S /usr/lib/ssh-keychain.dylib "$key"
fi
