#!/usr/bin/env bash

# yay (AUR helper)
if ! command -v yay &>/dev/null; then
  sudo pacman -Sy --noconfirm --needed git base-devel
  git clone https://aur.archlinux.org/yay-bin.git
  cd yay-bin
  makepkg -si --noconfirm
  cd ..
  rm -rf yay-bin
fi
