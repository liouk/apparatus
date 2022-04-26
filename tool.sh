#!/usr/bin/env zsh

check_versions () {
  echo "---------------"
  echo "=== toolset ==="
  echo "---------------"
  brew --version | head -1
  zsh --version
  # zsh completions
  # oh my zsh
  git --version
  tig --version | head -1
  stow --version
  echo "direnv $(direnv --version)"
  echo "fzf $(fzf --version)"
  rg --version | head -1
  bat --version
  jq --version
  vd --version
  kitty --version
  echo "karabiner $(/Library/Application\ Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli --version)"
  vim --version | head -1
}

main () {
  check_versions
}

main $@
