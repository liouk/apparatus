"---[ main configuration in ~/.vimrc ]----------------------------------------
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

"---[ neovim specifics ]------------------------------------------------------

" lua configurations
lua require('config.plugins.init')
lua require('config.plugins.alpha')

" block cursor everywhere
set guicursor=a:block
" underline in insert mode
set guicursor=i:hor50
