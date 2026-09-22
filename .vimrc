filetype off
set nocompatible

" Keep Plug commands between plug#begin() and plug#end()
let mapleader=" "
let maplocalleader=" "

" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

call plug#begin('~/.local/share/nvim/site/plugged')

Plug 'lambdalisue/fern.vim'

" Treesitter: highlight/indent/textobjects. Substitui o vim-polyglot (sem
" manutencao desde 2023 e historicamente conflitante com indent e LSP).
Plug 'nvim-treesitter/nvim-treesitter', { 'branch': 'master', 'do': ':TSUpdate' }
Plug 'nvim-treesitter/nvim-treesitter-textobjects', { 'branch': 'master' }

"Plug 'python-mode/python-mode', { 'for': 'python', 'branch': 'develop' }
" jedi-vim removido: conflitava com coc-pyright (sequestrava K/omnifunc em .py)
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
Plug 'tpope/vim-surround'         " cs"' ysiw( dst
Plug 'tpope/vim-repeat'           " faz o . repetir surround/gitgutter

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } " Search in the project
Plug 'junegunn/fzf.vim'

Plug 'gruvbox-community/gruvbox'
Plug 'wakatime/vim-wakatime'     " Wakatime

Plug 'prettier/vim-prettier', { 
      \ 'do': 'yarn install --frozen-lockfile --production',
      \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html', 'typescriptreact', 'javascriptreact']}
Plug 'w0rp/ale'                  " Async lint Engine

Plug 'dbeniamine/cheat.sh-vim'

Plug 'vim-test/vim-test'          " roda pytest do buffer atual no container

Plug 'nvim-lua/plenary.nvim'
Plug 'andythigpen/nvim-coverage'

call plug#end()
filetype plugin indent on


syntax enable
set background=dark

" Truecolor: sem isso o gruvbox roda em 256 cores degradadas
if has('termguicolors')
  set termguicolors
endif

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

" Undo persistente entre sessoes (o dir e criado sozinho pelo nvim)
set undofile
set undodir=~/.local/share/nvim/undodir

" Evita o texto pular quando abre/fecha split (diagnostics, Fern, terminal)
set splitkeep=screen

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

" Recomendado pelo coc.nvim: buffers em background, diagnostics/gitgutter rapidos
set hidden
set updatetime=100
set shortmess+=c

" Allow copy and paste from system clipboard
" unnamedplus = registrador +, que e o Ctrl-C/Ctrl-V do X11/Wayland.
" 'unnamed' (registrador *) e a selecao do mouse, nao a area de transferencia.
set clipboard=unnamedplus

" Set internal encoding of vim
set encoding=utf-8

" Set slipts to create always below(for horizontal slipt) and right ( for
" vertical split)
set splitbelow splitright

" Removes pipes | that act as separators  on splits
set fillchars+=vert:\ 


let g:python3_host_prog = '/usr/bin/python3'

" Config especifica da maquina/projeto (nao versionada)
if filereadable(expand('~/.vimrc.local'))
  execute 'source' expand('~/.vimrc.local')
endif

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
" O coc (pyright/tsserver) ja faz diagnostics; ALE fica so como fixer do eslint
let g:ale_disable_lsp = 1
let g:ale_linters_explicit = 1
let g:ale_linters = {}

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
function! OpenTerminal() abort
  split term://zsh
  call TermEscapeMap()
endfunction
nnoremap <silent><leader>t :call OpenTerminal()<CR>
" Search in the project (grep incremental: o rg reroda a cada tecla)
nnoremap <silent><C-a> :LiveGrep<CR>
" Busca a palavra sob o cursor
nnoremap <silent><leader>* :execute 'LiveGrep ' . expand('<cword>')<CR>

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

" +++ Busca de arquivos e de conteudo (fzf) +++

" Listagem de arquivos: respeita .gitignore automaticamente.
" Fallback para find caso rg/fd nao estejam instalados na maquina.
if executable('rg')
  let $FZF_DEFAULT_COMMAND = "rg --files --hidden --follow --glob '!.git/'"
elseif executable('fd')
  let $FZF_DEFAULT_COMMAND = "fd --type f --hidden --follow --exclude .git"
else
  let $FZF_DEFAULT_COMMAND = 'find . -type f ! -path "./.git/*" ! -path "./node_modules/*" ! -path "./htmlcov/*" ! -path "./.mypy_cache/*" ! -path "./.pytest_cache/*"'
endif

let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }

nnoremap <silent><C-p> :Files<CR>

" Escape hatch: lista TUDO, inclusive o que o .gitignore esconde.
" Ainda corta as pastas pesadas, senao volta a ser 130k arquivos.
command! -bang -nargs=? -complete=dir FilesAll
      \ call fzf#vim#files(<q-args>, extend({'source':
      \   "rg --files --hidden --follow --no-ignore"
      \   . " --glob '!.git/' --glob '!node_modules/' --glob '!.claude/'"
      \   . " --glob '!**/__pycache__/' --glob '!htmlcov/' --glob '!coverage/'"
      \   . " --glob '!.venv/' --glob '!.mypy_cache/' --glob '!.pytest_cache/'"},
      \   fzf#vim#with_preview()), <bang>0)

nnoremap <silent><leader>P :FilesAll<CR>

" Grep incremental: a query vai para o rg, nao para o filtro do fzf.
" Evita carregar o repositorio inteiro (~1.8M linhas) na memoria.
if executable('rg')
  command! -nargs=* -bang LiveGrep
        \ call fzf#vim#grep2(
        \   "rg --column --line-number --no-heading --color=always --smart-case -- ",
        \   <q-args>, fzf#vim#with_preview(), <bang>0)
else
  command! -nargs=* -bang LiveGrep call fzf#vim#ag(<q-args>, fzf#vim#with_preview(), <bang>0)
endif

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

" +++ vim-test: roda a suite dentro de um container docker +++
"
" Config especifica da maquina fica em ~/.vimrc.local (fora deste repo):
"   let g:test_container     = '<nome do container>'
"   let g:test_container_cwd = '<path do mount do repo no container>'
"   let g:test_container_env = ['VAR=valor', ...]   " opcional
" Sem isso, cai na strategy padrao do vim-test (roda no host).

let g:test#python#runner = 'pytest'
let g:test#python#pytest#executable = 'python -m pytest'

" Roda o comando do vim-test dentro do container, traduzindo o path do host
" para o path do mount do repo no container.
function! DockerTestStrategy(cmd) abort
  let l:cmd = substitute(a:cmd, '\V' . escape(getcwd(), '\') . '/', '', 'g')
  let l:env = []
  for l:e in get(g:, 'test_container_env', [])
    call extend(l:env, ['-e', l:e])
  endfor
  botright new
  call jobstart(
        \ ['docker', 'exec'] + l:env + [g:test_container,
        \  'bash', '-lc', 'cd ' . get(g:, 'test_container_cwd', '/app') . ' && ' . l:cmd],
        \ {'term': v:true})
  call TermEscapeMap()
  startinsert
endfunction

if !empty(get(g:, 'test_container', ''))
  let g:test#custom_strategies = {'docker': function('DockerTestStrategy')}
  let g:test#strategy = 'docker'
endif

" Prefixo <leader>r (run), e nao <leader>t: <leader>t ja abre o terminal e
" um prefixo <leader>t faria o terminal esperar o timeoutlen a cada uso.
" rn = teste sob o cursor | rf = arquivo | rs = suite | rl = ultimo | rv = visita
nnoremap <silent><leader>rn :TestNearest<CR>
nnoremap <silent><leader>rf :TestFile<CR>
nnoremap <silent><leader>rs :TestSuite<CR>
nnoremap <silent><leader>rl :TestLast<CR>
nnoremap <silent><leader>rv :TestVisit<CR>

" Sai do modo terminal com Esc-Esc. TEM que ser <buffer>: o modal do fzf e um
" buffer de terminal e depende do Esc chegar cru no processo. Um tnoremap
" global transforma <Esc> em prefixo de mapping e quebra o fzf.
function! TermEscapeMap() abort
  tnoremap <buffer> <Esc><Esc> <C-\><C-n>
endfunction

" WSL yank support
let s:clip = '/mnt/c/Windows/System32/clip.exe'  " change this path according to your mount point
if executable(s:clip)
    augroup WSLYank
        autocmd!
        autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
    augroup END
endif

lua << EOF
require("coverage").setup()

require('nvim-treesitter.configs').setup({
  ensure_installed = {
    'python', 'javascript', 'typescript', 'tsx', 'json', 'yaml', 'toml',
    'html', 'css', 'markdown', 'markdown_inline', 'bash', 'sql', 'lua',
    'dockerfile', 'vim', 'vimdoc',
  },
  auto_install = false,
  highlight = { enable = true },
  -- indent do treesitter em python ainda e instavel (continuation lines,
  -- argumentos quebrados). vim-sleuth + indent nativo cuidam do .py.
  indent = { enable = true, disable = { 'python' } },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = { [']m'] = '@function.outer', [']]'] = '@class.outer' },
      goto_previous_start = { ['[m'] = '@function.outer', ['[['] = '@class.outer' },
    },
  },
})
EOF
