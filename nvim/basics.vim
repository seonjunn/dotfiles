" Load vimrc
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

" Encoding
set encoding=UTF-8

" Share clipboard with system
set clipboard^=unnamed,unnamedplus

" Colorscheme
colorscheme tokyonight-moon

" Faster window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

