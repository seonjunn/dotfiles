" Load vimrc
"set runtimepath^=~/.vim runtimepath+=~/.vim/after
"let &packpath = &runtimepath
"source ~/.vimrc

" ESC
inoremap jk <Esc>
inoremap Jk <Esc>
inoremap jK <Esc>
inoremap JK <Esc>

" line number
set number relativenumber
augroup numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
    autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

" search
set nowrapscan
set ignorecase

" remember undo
set undofile
set undodir=~/.nvim/undodir

" Encoding
set encoding=UTF-8

" Share clipboard with system
set clipboard^=unnamed,unnamedplus

" Colorscheme
colorscheme catppuccin-frappe

" Faster window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

