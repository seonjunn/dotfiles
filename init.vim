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
"   coc 
Plug 'neoclide/coc.nvim',{'branch':'release'}

call plug#end()

" ocaml indent
au BufEnter *.ml setf ocaml
au BufEnter *.mli setf ocaml
au FileType ocaml call FT_ocaml()
function FT_ocaml()
    set textwidth=120
   " set colorcolumn=80
    set shiftwidth=2
    set tabstop=2
    " ocp-indent with ocp-indent-vim
    let opamshare=system("opam config var share | tr -d '\n'")
    execute "autocmd FileType ocaml source".opamshare."/vim/syntax/ocp-indent.vim"
    filetype indent on
    filetype plugin indent on
endfunction
