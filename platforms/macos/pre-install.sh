#!/usr/bin/env bash

# install brew
which -s brew &>/dev/null || { /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; }

# cask fonts tap
brew tap homebrew/cask-fonts
