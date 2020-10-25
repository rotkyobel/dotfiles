" Personal Config
set number
set mouse=a
set numberwidth=1
set clipboard=unnamed
syntax enable
set showcmd
set encoding=utf-8
set showmatch
set sw=2
set relativenumber
set laststatus=2
set noshowmode

au FocusGained,BufEnter * :silent! !

call plug#begin('~/.config/nvim/plugged')

" Themes 
Plug 'morhetz/gruvbox'
Plug 'dracula/vim', { 'as': 'dracula' }

" Plugins 
Plug 'easymotion/vim-easymotion'
Plug 'scrooloose/nerdtree'
Plug 'christoomey/vim-tmux-navigator'
Plug 'ryanoasis/vim-devicons'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'mattn/emmet-vim'
" Plug 'frazrepo/vim-rainbow'
Plug 'preservim/nerdcommenter'
Plug 'mhinz/vim-startify'
Plug 'itchyny/lightline.vim'

source $HOME/.config/nvim/plug-config/coc.vim

call plug#end()

" let g:airline_powerline_fonts = 1
let g:lightline = {
  \ 'colorscheme': 'dracula'
\}

set termguicolors
let g:dracula_bold      = 1
let g:dracula_italic    = 1
let g:dracula_underline = 1
let g:dracula_undercurl = 1
let g:dracula_inverse   = 1
let g:dracula_colorterm = 1

colorscheme dracula

" NerdTree
let NERDTreeQuitOnOpen=1

let mapleader=" "
nmap <Leader>s <Plug>(easymotion-s2)
nmap <Leader>n :NERDTreeFind<CR>

nmap <Leader>e :q!<CR>
nmap <Leader>w :w<CR>
nmap <Leader>q :wq<CR>


command! -nargs=0 Prettier :CocCommand prettier.formatFile
nmap <Leader>p :Prettier<CR>

imap jj <Esc>
