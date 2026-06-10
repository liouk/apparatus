#!/usr/bin/env bash

# nerd fonts (symbols only)
if [ ! -d "/usr/local/share/fonts/nerd/NerdFontsSymbolsOnly" ]; then
  sudo mkdir -p /usr/local/share/fonts/nerd/NerdFontsSymbolsOnly/
  curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.0/NerdFontsSymbolsOnly.zip --output NerdFontsSymbolsOnly.zip
  sudo unzip NerdFontsSymbolsOnly.zip -d /usr/local/share/fonts/nerd/NerdFontsSymbolsOnly/
  rm NerdFontsSymbolsOnly.zip
  fc-cache -r
fi

# oc (OpenShift CLI)
if ! command -v oc &>/dev/null; then
  curl -LO https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz
  tar xzf oc.tar.gz
  sudo mv oc /usr/local/bin/oc
  rm -f oc.tar.gz kubectl README.md
fi

echo -e "\nSetup complete! Change your shell to zsh by running:\n\tchsh -s \$(which zsh)"
