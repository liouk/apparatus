#!/usr/bin/env bash

if [ -e /run/ostree-booted ]; then
  echo "The Fedora platform requires a DNF-based installation, not Fedora Atomic." >&2
  exit 1
fi

case "$(uname -m)" in
  x86_64|aarch64) ;;
  *)
    echo "The Fedora platform's upstream Zed install supports x86_64 and aarch64 only." >&2
    exit 1
    ;;
esac

command -v dnf > /dev/null || {
  echo "dnf is required for the Fedora platform." >&2
  exit 1
}

# User-owned binaries and helper links.
mkdir -p "$HOME/.local/bin"
