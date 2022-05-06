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
