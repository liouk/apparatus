install:
	git submodule update --init --recursive

osx: bash.osx git.osx vim.osx tmux
	$(info osx done!)

bash.osx:
	$(info *** bash ***)
	test -e $(HOME)/.apparatus/bash/bash_prompt      && ln -fs $(HOME)/.apparatus/bash/bash_prompt      $(HOME)/.bash_prompt
	test -e $(HOME)/.apparatus/bash/bash_aliases     && ln -fs $(HOME)/.apparatus/bash/bash_aliases     $(HOME)/.bash_aliases
	test -e $(HOME)/.apparatus/bash/bash_profile     && ln -fs $(HOME)/.apparatus/bash/bash_profile     $(HOME)/.bash_profile

zsh.osx:
	$(info *** zsh ***)
	mkdir -p ~/.zsh
	test -e $(HOME)/.apparatus/bash/zsh_prompt       && ln -fs $(HOME)/.apparatus/bash/zsh_prompt       $(HOME)/.zsh/.zsh_prompt
	test -e $(HOME)/.apparatus/bash/bash_aliases     && ln -fs $(HOME)/.apparatus/bash/bash_aliases     $(HOME)/.zsh/.zsh_aliases
	test -e $(HOME)/.apparatus/bash/zshrc            && ln -fs $(HOME)/.apparatus/bash/zshrc            $(HOME)/.zshrc

git.osx:
	$(info *** git ***)
	test -e $(HOME)/.apparatus/git/gitconfig         && ln -fs $(HOME)/.apparatus/git/gitconfig         $(HOME)/.gitconfig

tig:
	$(info *** tig ***)
	test -e $(HOME)/.apparatus/tig/tigrc             && ln -fs $(HOME)/.apparatus/tig/tigrc             $(HOME)/.tigrc

vim.osx:
	$(info *** vim ***)
	test -e $(HOME)/.apparatus/vim/vimrc             && ln -fs $(HOME)/.apparatus/vim/vimrc             $(HOME)/.vimrc

tmux:
	$(info *** tmux ***)
	test -e $(HOME)/.apparatus/tmux/tmux.conf        && ln -fs $(HOME)/.apparatus/tmux/tmux.conf        $(HOME)/.tmux.conf

screen:
	$(info *** screen ***)
	test -e $(HOME)/.apparatus/screen/screenrc       && ln -fs $(HOME)/.apparatus/screen/screenrc       $(HOME)/.screenrc

# Prevents rules from appearing as 'nothing to change'
.PHONY: bash.osx git.osx vim tmux screen tig
