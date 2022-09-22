stow:
	stow --restow --target="$(HOME)" zsh
	stow --restow --target="$(HOME)" git
	stow --restow --target="$(HOME)" git-templates
	stow --restow --target="$(HOME)" tig
	stow --restow --target="$(HOME)" vim
	stow --restow --target="$(HOME)" tmux --ignore=crontab-tmux-resurrect
	stow --restow --target="$(HOME)/.config" kitty
	stow --restow --target="$(HOME)/.config" karabiner
	stow --restow --target="$(HOME)/.config" nvim
	stow --restow --target="$(HOME)/Library/Application Support/navi" navi

unstow:
	stow --delete --target="$(HOME)" zsh
	stow --delete --target="$(HOME)" git
	stow --delete --target="$(HOME)" git-templates
	stow --delete --target="$(HOME)" tig
	stow --delete --target="$(HOME)" vim
	stow --delete --target="$(HOME)" tmux --ignore=crontab-tmux-resurrect
	stow --delete --target="$(HOME)/.config" kitty
	stow --delete --target="$(HOME)/.config" karabiner
	stow --delete --target="$(HOME)/.config" nvim
	stow --delete --target="$(HOME)/Library/Application Support/navi" navi

install:
	git submodule update --init --recursive

.PHONY: stow unstow install
