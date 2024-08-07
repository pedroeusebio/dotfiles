filetype off
set nocompatible

" Keep Plug commands between plug#begin() and plug#end()
let mapleader=" "
let maplocalleader=" "

call plug#begin('~/.local/share/nvim/site/plugged')

Plug 'lambdalisue/fern.vim'

Plug 'pangloss/vim-javascript'    " JavaScript support
Plug 'leafgarland/typescript-vim' " TypeScript syntax
Plug 'maxmellon/vim-jsx-pretty'   " JS and JSX syntax
Plug 'jparise/vim-graphql'        " GraphQL syntax
Plug 'sheerun/vim-polyglot'

"Plug 'python-mode/python-mode', { 'for': 'python', 'branch': 'develop' }
Plug 'davidhalter/jedi-vim'
Plug 'ttibsi/pre-commit.nvim'     " Adding pre-commit commands

Plug 'airblade/vim-gitgutter'     " Show git diff of lines edited
Plug 'tpope/vim-fugitive'         " :Gblame
Plug 'tpope/vim-rhubarb'          " :GBrowse
Plug 'jreybert/vimagit'           " Magit to improve git experience

Plug 'vim-airline/vim-airline'

Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'puremourning/vimspector'    " Debug mode

Plug 'szw/vim-maximizer'          " Maximize plugin
Plug 'tpope/vim-sleuth'           " auto-detect tab/space styling of workspace

Plug 'preservim/nerdcommenter'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } " Search in the project
Plug 'junegunn/fzf.vim'

Plug 'gruvbox-community/gruvbox'
Plug 'wakatime/vim-wakatime'     " Wakatime

Plug 'prettier/vim-prettier', { 
      \ 'do': 'yarn install --frozen-lockfile --production',
      \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html', 'typescriptreact', 'javascriptreact']}
Plug 'w0rp/ale'                  " Async lint Engine

Plug 'dbeniamine/cheat.sh-vim'

Plug 'nvim-lua/plenary.nvim'
Plug 'andythigpen/nvim-coverage'

call plug#end()
filetype plugin indent on


syntax enable
set background=dark

" Enable mouse mode in all modes
set mouse=a

set scrolloff=8

set signcolumn=yes
set colorcolumn=100
autocmd FileType python set colorcolumn=120

" Numbers
set nu
set relativenumber
set ruler

" Remove error bells
set noerrorbells

" Some servers have issues with backup files
set nobackup
set nowritebackup
set noswapfile

set ignorecase " Ignore case when searching
set smartcase  " When searching try to be smart about cases
set nohlsearch " Don't highlight search term
set incsearch  " Jumping search

" On pressing tab, insert 2 spaces
set expandtab
" show existing tab with 2 spaces width
set tabstop=2
set softtabstop=2
" when indenting with '>', use 2 spaces width
set shiftwidth=2

" Always show the status line
set laststatus=2

" Allow copy and paste from system clipboard
set clipboard=unnamed

" Set internal encoding of vim
set encoding=utf-8

" Set slipts to create always below(for horizontal slipt) and right ( for
" vertical split)
set splitbelow splitright

" Removes pipes | that act as separators  on splits
set fillchars+=vert:\ 

colorscheme gruvbox

" Fern config
let g:fern#default_hidden=1

noremap <silent> <Leader>f :Fern . -drawer -reveal=% -toggle -width=35<CR><C-w>=

function! FernInit() abort
  nmap <buffer><expr>
        \ <Plug>(fern-my-open-expand-collapse)
        \ fern#smart#leaf(
        \   "\<Plug>(fern-action-open:select)",
        \   "\<Plug>(fern-action-expand)",
        \   "\<Plug>(fern-action-collapse)",
        \ )
  nmap <buffer> <2-LeftMouse> <Plug>(fern-my-open-expand-collapse)
  nmap <buffer> n <Plug>(fern-action-new-path)
  nmap <buffer> d <Plug>(fern-action-remove)
  nmap <buffer> m <Plug>(fern-action-move)
  nmap <buffer> M <Plug>(fern-action-rename)
  nmap <buffer> r <Plug>(fern-action-reload)
  nmap <buffer> b <Plug>(fern-action-open:split)
  nmap <buffer> v <Plug>(fern-action-open:vsplit)
  nmap <buffer><nowait> < <Plug>(fern-action-leave)
  nmap <buffer><nowait> > <Plug>(fern-action-enter)
  nmap <buffer> <C-L> <C-W><C-L>
  nmap <buffer> <C-H> <C-W><C-H>
endfunction

augroup FernGroup
  autocmd!
  autocmd FileType fern call FernInit()
augroup END

" Vimspector config
let g:vimspector_enable_mappings = 'VISUAL_STUDIO'
let g:vimspector_install_gadgets = ['debugpy', 'vscode-node-debug2', 'vscode-node']

" CoC config
let g:coc_global_extensions = ['coc-json', 'coc-git', 'coc-prettier', 'coc-tsserver', 'coc-pyright']

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" ALE config
let g:ale_fixers = {
 \ 'javascript': ['eslint']
 \ }
 
let g:ale_sign_error = '❌'
let g:ale_sign_warning = '⚠️'

let g:ale_fix_on_save = 1

" +++ Shortcuts +++

" Npm run build
nnoremap <silent><leader>nb :!npm run build<CR>
" Open Buffer
nnoremap <silent><leader>l :Buffers<CR>
" Vertically split screen
nnoremap <silent><leader>\ :vs<CR>
" Split screen
nnoremap <silent><leader>_ :split<CR>
" Save file
nnoremap <silent><leader>w :w<CR>
" Quit file
nnoremap <silent><leader>q :q<CR>
" Magit
nnoremap <silent><leader>mg :Magit<CR>
" Git push
nnoremap <silent><leader>gp :Git push<CR>
" Swap between last edited buffer
nnoremap <silent><leader><TAB> :b#<CR>
" Show a terminal
nnoremap <silent><leader>t :split term://zsh<CR>
" Search in the project
nnoremap <silent><C-a> :Ag<CR>

nnoremap <silent><Leader>py <Plug>(Prettier)

" Navigate between the splits
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Debugger remaping
nnoremap <leader>dd :call vimspector#Launch()<CR>
nnoremap <leader>de :call vimspector#Reset()<CR>
if has('nvim')
  " for normal mode - the word under the cursor
  nmap <Leader>di <Plug>VimspectorBalloonEval
  " for visual mode, the visually selected text
  xmap <Leader>di <Plug>VimspectorBalloonEval
endif

nmap <leader>drc <Plug>VimspectorRunToCursor

" FZF mapping
nnoremap <C-p> :call fzf#run({
    \'source': 'find . -type f ! -path "./.git/*" ! -path "./.mypy_cache/*" ! -path "./htmlcov/*" ! -path "./.pytest_cache/*"',
    \'sink': "e",
    \'window': { 'width': 0.9, 'height': 0.6 }, 'color': "always" }
    \)<CR>

" Useful remaps
nnoremap Y y$

" Keeping it centered
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap J mzJ`z

" Undo break points
inoremap , ,<c-g>u
inoremap . .<c-g>u
inoremap ! !<c-g>u
inoremap ? ?<c-g>u

" Jumplist mutations
nnoremap <expr> k (v:count > 5 ? "m'" . v:count : "") . 'k'
nnoremap <expr> j (v:count > 5 ? "m'" . v:count : "") . 'j'

" Moving text
nnoremap <leader>j :m .+1<CR>==
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
inoremap <C-j> <esc>:m .+1<CR>==
inoremap <C-k> <esc>:m .-2<CR>==
nnoremap <leader>k :m .-2<CR>==

" Map Ctrl-Backspace to delete the previous word in insert mode.
noremap! <C-h> <C-w>

" WSL yank support
let s:clip = '/mnt/c/Windows/System32/clip.exe'  " change this path according to your mount point
if executable(s:clip)
    augroup WSLYank
        autocmd!
        autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
    augroup END
endif

:lua require("coverage").setup()
