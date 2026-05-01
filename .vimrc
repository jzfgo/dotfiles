set guicursor=
set scrolloff=8
set number
set relativenumber
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent

" Plugins
call plug#begin()
Plug 'tpope/vim-sensible'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'tribela/vim-transparent'
Plug 'itchyny/lightline.vim'
Plug 'drewtempelmeyer/palenight.vim'
call plug#end()
" End Plugins

" Theme
set termguicolors
set background=dark
colorscheme palenight
" End Theme

" --- General Settings ---
" Set the leader key to Space (easier on the thumbs)
let mapleader = " "

" --- File Navigation & Exploration ---
" Open the project explorer (Netrw) in a vertical split
nnoremap <leader>pv :Vex<CR>

" Search for files tracked by Git (requires fzf.vim)
nnoremap <C-p> :GFiles<CR>

" Search for all files in the current directory (requires fzf.vim)
nnoremap <leader>pf :Files<CR>

" --- System Integration ---
" Source (reload) the vimrc file to apply changes instantly
nnoremap <leader><CR> :so ~/.vimrc<CR>

" --- Clipboard Operations ---
" Paste over selected text without overwriting the default register with the deleted text
vnoremap <leader>p "_dP

" Copy (yank) selected text directly to the system clipboard
vnoremap <leader>y "+y

" Copy (yank) current motion/line to the system clipboard
nnoremap <leader>y "+y

" Copy (yank) the entire file contents to the system clipboard
nnoremap <leader>Y gg"+yG

" --- Quickfix Navigation ---
" Navigate to the next item in the quickfix list
nnoremap <C-j> :cnext<CR>

" Navigate to the previous item in the quickfix list
nnoremap <C-k> :cprev<CR>

" --- Visual Mode Line Manipulation ---
" Move the selected block of text down one line and re-indent
vnoremap J :m '>+1<CR>gv=gv

" Move the selected block of text up one line and re-indent
vnoremap K :m '<-2<CR>gv=gv
