call plug#begin()

" LSP
Plug 'neovim/nvim-lspconfig'
Plug 'glepnir/lspsaga.nvim', { 'branch': 'main' }

" Colorscheme
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }

" Treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" statusline
" Plug 'nvim-lualine/lualine.nvim'
Plug 'kyazdani42/nvim-web-devicons'

" Show Diff
Plug 'lewis6991/gitsigns.nvim'

" file explore
" Plug 'preservim/nerdtree'

" fzf
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

call plug#end()

"lua << END
"END
"
source $HOME/.config/nvim/lua/treesitter.lua
