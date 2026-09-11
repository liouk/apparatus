#!/bin/sh

default_install_dir="$HOME/workspace/apparatus"
bash_candidates="/opt/homebrew/bin/bash /usr/local/bin/bash"
bash_hint="On macOS, install Homebrew Bash with: brew install bash"

bootstrap_prepare() {
  local brew_path brew_prefix

  if ! command -v brew > /dev/null 2>&1; then
    if ! (exec 3<>/dev/tty) 2>/dev/null; then
      apparatus_warning "Homebrew is required for the macOS bootstrap."
      apparatus_warning "Install it from https://brew.sh and rerun."
      exit 1
    fi
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" < /dev/tty
  fi

  if [ -x /opt/homebrew/bin/brew ]; then
    brew_path=/opt/homebrew/bin/brew
  elif [ -x /usr/local/bin/brew ]; then
    brew_path=/usr/local/bin/brew
  else
    apparatus_warning "Homebrew installation completed, but brew was not found."
    exit 1
  fi

  eval "$("$brew_path" shellenv)"
  brew_prefix="$("$brew_path" --prefix)"
  bash_candidates="$brew_prefix/bin/bash /opt/homebrew/bin/bash /usr/local/bin/bash"
  if ! find_modern_bash > /dev/null 2>&1; then
    if ! (exec 3<>/dev/tty) 2>/dev/null; then
      apparatus_warning "Homebrew Bash is required for the macOS bootstrap."
      apparatus_warning "Install it with: brew install bash"
      exit 1
    fi
    "$brew_path" install bash < /dev/tty
  fi
}
