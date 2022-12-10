"---[ main configuration in ~/.vimrc ]----------------------------------------
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

"---[ neovim specifics ]------------------------------------------------------

" lua configurations
lua require('config')
lua require('plugins')
lua require('plugin_config')
lua require('keymaps')
