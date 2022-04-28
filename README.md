# apparatus
All of my dotfiles in a single repo.

`make` + `git` + `stow` = L.F.E. <3

This repo uses `stow` to manage the dotfiles and create symbolic links to the required dirs.


1. Install `make`, `git` and `stow`
1. Install any of the tools of this repo
1. If you're using `vim`, run the following to install all of its submodules (plugins):```zsh
$ git submodule update --init --recursive
```
1. Run the following command to put every dotfile in place:```zsh
$ make stow
```
1. Have fun!

If you just want to stow specific dotfiles, have a look at the Makefile and invoke `stow` for the specific package.

## Tools Used
- [zsh](https://www.zsh.org/)
  - [zsh completions](https://oliverspryn.medium.com/adding-git-completion-to-zsh-60f3b0e7ffbc)
  - [oh my zsh!](https://ohmyz.sh/)
  - [git-zsh-completion](https://oliverspryn.medium.com/adding-git-completion-to-zsh-60f3b0e7ffbc)
- [direnv](https://direnv.net/)
- [fzf](https://github.com/junegunn/fzf)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [tig](https://github.com/jonas/tig)
- [bat](https://github.com/sharkdp/bat)
- [jq](https://stedolan.github.io/jq/)
- [visidata](https://www.visidata.org/)
- [tree-sitter](https://tree-sitter.github.io/tree-sitter/)
- [kitty](https://sw.kovidgoyal.net/kitty/)
- [GNU stow](https://www.gnu.org/software/stow/)
- [karabiner](https://karabiner-elements.pqrs.org/)

You can run `tool.sh` to get a list of all the tools that are installed and their versions.

### Old configurations
- [iTerm2](https://iterm2.com/)
- tmux

## Configuration
### Fonts
```
$ brew tap homebrew/cask-fonts
$ brew install --cask font-jetbrains-mono-nerd-font
$ brew install --cask font-fira-code-nerd-font
```

Here are all the casks: https://github.com/Homebrew/homebrew-cask-fonts/tree/master/Casks
### kitty
To choose a theme, use `kitty +kitten themes`.
