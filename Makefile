install:
	git submodule update --init --recursive

osx: bash.osx git.osx vim.osx tmux gpsdate.osx
	$(info osx done!)

bash.osx:
	$(info *** bash ***)
	test -e $(HOME)/.apparatus/bash/bash_prompt      && ln -fs $(HOME)/.apparatus/bash/bash_prompt      $(HOME)/.bash_prompt
	test -e $(HOME)/.apparatus/bash/bash_aliases     && ln -fs $(HOME)/.apparatus/bash/bash_aliases     $(HOME)/.bash_aliases
	test -e $(HOME)/.apparatus/bash/bash_extras      && ln -fs $(HOME)/.apparatus/bash/bash_extras      $(HOME)/.bash_extras
	test -e $(HOME)/.apparatus/bash/bash_profile     && ln -fs $(HOME)/.apparatus/bash/bash_profile     $(HOME)/.bash_profile

zsh.osx:
	$(info *** zsh ***)
	test -e $(HOME)/.apparatus/bash/bash_prompt      && ln -fs $(HOME)/.apparatus/bash/bash_prompt      $(HOME)/.zsh_prompt
	test -e $(HOME)/.apparatus/bash/bash_aliases     && ln -fs $(HOME)/.apparatus/bash/bash_aliases     $(HOME)/.zsh_aliases
	test -e $(HOME)/.apparatus/bash/bash_extras      && ln -fs $(HOME)/.apparatus/bash/bash_extras      $(HOME)/.zsh_extras
	test -e $(HOME)/.apparatus/bash/zprofile         && ln -fs $(HOME)/.apparatus/bash/zprofile         $(HOME)/.zprofile

git.osx:
	$(info *** git ***)
	test -e $(HOME)/.apparatus/git/gitconfig         && ln -fs $(HOME)/.apparatus/git/gitconfig         $(HOME)/.gitconfig

tig:
	$(info *** tig ***)
	test -e $(HOME)/.apparatus/tig/tigrc             && ln -fs $(HOME)/.apparatus/tig/tigrc             $(HOME)/.tigrc

vim.osx:
	$(info *** vim ***)
	test -e $(HOME)/.apparatus/vim/vimrcs/vimrc.osx  && ln -fs $(HOME)/.apparatus/vim/vimrcs/vimrc.osx  $(HOME)/.vimrc

tmux:
	$(info *** tmux ***)
	test -e $(HOME)/.apparatus/tmux/tmux.conf        && ln -fs $(HOME)/.apparatus/tmux/tmux.conf        $(HOME)/.tmux.conf

screen:
	$(info *** screen ***)
	test -e $(HOME)/.apparatus/screen/screenrc       && ln -fs $(HOME)/.apparatus/screen/screenrc       $(HOME)/.screenrc

gpsdate.osx:
	$(info *** gpsdate ***)
	test -e $(HOME)/.apparatus/gpsdate/gpsdate       && cp -f $(HOME)/.apparatus/gpsdate/gpsdate        /usr/local/bin/gpsdate

# Prevents rules from appearing as 'nothing to change'
.PHONY: bash.osx git.osx vim tmux screen gpsdate tig
