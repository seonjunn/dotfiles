inoremap jk <Esc>

" indent
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab
set cindent

" line number
set number relativenumber
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

" PLUGINS 
call plug#begin('~/.local/share/nvim/plugged')
"   ocp indentation
Plug 'let-def/ocp-indent-vim'
call plug#end()

" TEST
