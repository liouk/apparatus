"---[ main configuration in ~/.vimrc ]----------------------------------------
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

"---[ neovim specifics ]------------------------------------------------------

" lua configurations
lua require('plugins')
lua require('config.alpha')

set guicursor=a:block " block cursor everywhere
set guicursor=i:hor50 " underline in insert mode
