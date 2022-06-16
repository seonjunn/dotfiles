" ESC
inoremap jk <Esc>

" syntax
if has("syntax")
    syntax on
endif

" indent
set smartindent
set autoindent
set cindent
set expandtab
set tabstop=4
set shiftwidth=4
if has("autocmd")
    filetype plugin indent on
endif
" for command mode
nnoremap <S-Tab> <<
" for insert mode
inoremap <S-Tab> <C-d>

" line number
set number relativenumber
augroup numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
    autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

" search
set hlsearch
set incsearch
set nowrapscan
set ignorecase

" plugins
call plug#begin()
"Plug 'vim-python/python-syntax'
call plug#end()

" vim-python/python-syntax
"let g:python_highlight_all = 1
"let g:python_highlight_space_errors = 0

" abbrevation
iabbr <expr> __time strftime("%Y-%m-%d %H:%M:%S")
iabbr <expr> __file expand('%:p')
iabbr <expr> __name expand('%')
iabbr <expr> __pwd expand('%:p:h')
iabbr <expr> __branch system("git rev-parse --abbrev-ref HEAD")
