# :nut_and_bolt: apparatus
Apparatus is a monorepo containing all the dotfiles for my setup, which is based on zsh, neovim and kitty, among other tools.

You can use the installation script to install every tool of the toolchain and place the dotfiles where they need to be. The install script performs the following:
- it detects the platform/OS that executes it
- it will install all the necessary tools, fonts, etc. for the supported platforms
- it will place the dotfiles where they need to be, depending on the platform

The script currently only supports MacOS, and Fedora Server and Workstation are work in progress.

Originally forked from [michailpanagiotis/apparatus](https://github.com/michailpanagiotis/apparatus).

## Requirements
The script requires `bash` and `curl` only; it will install everything else it needs (e.g. `brew`, `git`).

## Installation
To check if your platform is supported, run the following command:
```
curl -fsSL https://raw.githubusercontent.com/liouk/apparatus/master/install.sh | bash /dev/stdin --check-support
```
The script will print whether the current OS is supported or not.

To install everything, run the following command:
```
curl -fsSL https://raw.githubusercontent.com/liouk/apparatus/master/install.sh | bash /dev/stdin
```

## Toolchain
#### Terminal & Shell
- [zsh](https://www.zsh.org/)
- [kitty](https://sw.kovidgoyal.net/kitty/)
- [powerlevel10k](https://github.com/romkatv/powerlevel10k)

#### CLI Tools
- [fzf](https://github.com/junegunn/fzf)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [direnv](https://direnv.net/)
- [bat](https://github.com/sharkdp/bat)
- [jq](https://stedolan.github.io/jq/)
- [visidata](https://www.visidata.org/)
- [GNU stow](https://www.gnu.org/software/stow/)
- [navi](https://github.com/denisidoro/navi)
- [btop](https://github.com/aristocratos/btop)
- [mmv](https://github.com/itchyny/mmv)

#### Editor
- [neovim](https://neovim.io/)

#### VCS
- [git](https://git-scm.com/)
- [tig](https://github.com/jonas/tig)

#### MacOS
- [Homebrew](https://brew.sh/)
- [karabiner](https://karabiner-elements.pqrs.org/)

## Theme
This config currently uses the [catppuccin](https://github.com/catppuccin/catppuccin) theme, in the following places that apparatus controls:
- kitty
- neovim
- sway
- waybar
- mako
- tig
- swaylock
