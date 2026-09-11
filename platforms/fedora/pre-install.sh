#!/usr/bin/env bash

if [ -e /run/ostree-booted ]; then
  apparatus_warning "The Fedora platform requires a DNF-based installation, not Fedora Atomic."
  exit 1
fi

case "$(uname -m)" in
  x86_64|aarch64) ;;
  *)
    apparatus_warning "The Fedora platform's upstream Zed install supports x86_64 and aarch64 only."
    exit 1
    ;;
esac

command -v dnf > /dev/null || {
  apparatus_warning "dnf is required for the Fedora platform."
  exit 1
}

# User-owned binaries and helper links.
mkdir -p "$HOME/.local/bin"
