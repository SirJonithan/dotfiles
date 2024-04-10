set number

" Status bar
set laststatus=2

" scroll offset
set scrolloff=4


" stop auto commenting
set formatoptions-=cro

" saves undo
set undofile

syntax on

" ignore case in search
set smartcase 
set nocompatible              " be iMproved, required

filetype on                  
filetype plugin indent on

colorscheme slate
"
" " Enable syntax highlighting
syntax enable
" Highlight search results as you type
set incsearch
set hlsearch

" Enable line wrapping
set wrap
set linebreak
set nolist

" Enable mouse support in all modes
set mouse=a

" Enable clipboard support (requires Vim to be compiled with clipboard support)
set clipboard=unnamedplus

" Enable auto-indentation
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab

" Show matching parentheses
set showmatch

" Enable auto completion as you type
set complete+=kspell

" Display the cursor position in the status line
set ruler

" Enable file type detection
filetype plugin indent on

" Window management hotkeys
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Split windows vertically and horizontally
nnoremap <leader>v :vsp<CR>
nnoremap <leader>s :sp<CR>

" Toggle relative line numbers with leader n
nnoremap <leader>n :set relativenumber! relativenumber?<CR>
