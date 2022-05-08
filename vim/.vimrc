" pathogen
execute pathogen#infect()

" enable filetype plugin
filetype plugin on
filetype on

" haproxy vim syntax
autocmd BufRead,BufNewFile haproxy*.cfg* set ft=haproxy

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

" colors
set background=dark
colorscheme gruvbox

" highlighting
syntax on
"set cursorline
"set colorcolumn=80
highlight ColorColumn ctermbg=DarkGrey
highlight Comment cterm=italic gui=italic
set hlsearch

" cursor
" steady underline in insert mode
let &t_SI = "\e[4 q"
" block everywhere else
let &t_EI = "\e[2 q"

" show trailing whitespace
highlight ExtraWhitespace ctermbg=darkblue guibg=#344011
autocmd BufEnter * exe ':2match ExtraWhitespace /\s\+$\| \+\ze\t\|\t\+\ze /'

" define leader key
let mapleader = ","
nnoremap <leader>a :cclose<CR>:lclose<CR>

" misc
set showcmd
set number
set nocompatible
set incsearch
set backspace=indent,eol,start
set noswapfile

" copy to clipboard
nmap <leader>y "*y

" paste
nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>

" tabline
set showtabline=2

" Ctrl+R replaces all occurences of selected text in visual mode
vnoremap <C-r> "hy:%s/<C-r>h//g<left><left>

" auto-complete brackets
inoremap {<CR>  {<CR>}<Esc>O
inoremap {{     {
inoremap {}     {}

" insert new line at the cursor without entering insert mode
nnoremap <S-Enter> i<CR><Esc>

" bring search result to mid screen
nnoremap n nzz
nnoremap N Nzz

"
" Plugin specific configuration
"

" NERDTree
nnoremap <leader>d :NERDTreeToggle<cr>
let NERDTreeMinimalUI=1
let NERDTreeShowHidden=1
let g:NERDTreeDirArrows=0
let g:NERDTreeDirArrowExpandable="+"
let g:NERDTreeDirArrowCollapsible="~"

" vim-commentary
nnoremap <C-/> <Plug>CommentaryLine
vnoremap <C-/> <Plug>Commentary

" vim-airline
let g:airline_extensions = [ "tabline", "branch" ]
let g:airline_detect_modified=1
set laststatus=2
let g:airline_theme='gruvbox'
let g:airline_left_sep=''
let g:airline_right_sep=''

" gitgutter
set signcolumn=yes
let g:gitgutter_max_signs = 200
autocmd BufWritePost * GitGutter

" rg
command! -bang -nargs=* Rg
  \ call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1,
    \   fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), <bang>0)

nmap <leader>f :Rg<CR>

" fzf
set rtp+=/usr/local/opt/fzf
nnoremap <C-p> :Files<CR>
nmap <leader>e :Buffers<CR>
let g:fzf_layout = { 'down': '~30%' }
let g:fzf_preview_window = []
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" syntastic
nnoremap <leader>s :SyntasticCheck<CR>
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_mode_map = { 'passive_filetypes': ['go', 'java'] }
let g:gruvbox_contrast_dark = "hard"

" startify
let g:startify_change_to_dir = 0
let g:startify_change_to_vcs_root = 1

" kitty
" vim hardcodes background color erase even if the terminfo file does
" not contain bce (not to mention that libvte based terminals
" incorrectly contain bce in their terminfo files). This causes
" incorrect background rendering when using a color theme with a
" background color.
let &t_ut=''
