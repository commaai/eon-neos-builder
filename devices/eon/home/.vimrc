syntax on

" Make sure vim filytpe plugin doesn't override tab size
let g:python_recommended_style=0

set tabstop=2
set shiftwidth=2
set expandtab
set ai
set number
set hlsearch
set ruler
set mouse=
set viminfo=""
highlight Comment ctermfg=green
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
