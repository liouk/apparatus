#!/bin/sh

default_install_dir="$HOME/liouk/apparatus"

bootstrap_prepare() {
  missing_packages=
  command -v git > /dev/null 2>&1 || missing_packages="$missing_packages git"
  find_modern_bash > /dev/null || missing_packages="$missing_packages bash"
  [ -n "$missing_packages" ] || return 0

  if ! (exec 3<> /dev/tty) 2> /dev/null; then
      apparatus_warning "Missing bootstrap prerequisites:$missing_packages"
      apparatus_warning "Install them with sudo dnf install$missing_packages, then rerun."
    exit 1
  fi
    printf '%s Install missing bootstrap prerequisites with DNF:%s? [y/N] ' \
      "$APPARATUS_PREFIX" "$missing_packages" > /dev/tty
  IFS= read -r answer < /dev/tty
  case "$answer" in
    y|Y|yes)
      # Intentional splitting: only fixed package names from the checks above.
      sudo dnf install -y --setopt=install_weak_deps=False $missing_packages < /dev/tty
      ;;
      *) apparatus_message "Bootstrap cancelled; prerequisites were not installed."; exit 1 ;;
  esac
}
