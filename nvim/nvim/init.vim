"---[ main configuration in ~/.vimrc ]----------------------------------------
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

"---[ neovim specifics ]------------------------------------------------------

" block cursor everywhere
set guicursor=a:block
" underline in insert mode
set guicursor=i:hor50

"---[ plugins ]---------------------------------------------------------------

" leap.nvim
lua require('leap').add_default_mappings()
