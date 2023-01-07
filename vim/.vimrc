" pathogen
execute pathogen#infect()

" enable filetype plugin
filetype plugin on
filetype on

" indentation
set autoindent
set smartindent
set smarttab
set expandtab
set shiftwidth=2
set softtabstop=2
set tabstop=2
set encoding=utf8
set fillchars=vert:│

" key timeouts
set ttimeoutlen=0

" highlighting
syntax on
"set cursorline
"set colorcolumn=80
highlight ColorColumn ctermbg=DarkGrey
highlight Comment cterm=italic gui=italic
set hlsearch

" show trailing whitespace
highlight ExtraWhitespace ctermbg=darkblue guibg=#344011
autocmd BufEnter * exe ':2match ExtraWhitespace /\s\+$\| \+\ze\t\|\t\+\ze /'

" misc
set showcmd
set number
set nocompatible
set incsearch
set backspace=indent,eol,start
set noswapfile

" kitty
" vim hardcodes background color erase even if the terminfo file does
" not contain bce (not to mention that libvte based terminals
" incorrectly contain bce in their terminfo files). This causes
" incorrect background rendering when using a color theme with a
" background color.
let &t_ut=''
