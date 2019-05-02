""""""""""""""""
" Dependencies "
""""""""""""""""

" For everything:
" - NeoVim (not Vim)
" For Plugins
" - vim-plug installed (https://github.com/junegunn/vim-plug)
" For Deoplete:
" - Neovim Python3 provider (pip3 install pynvim)
" - Neovim installed from HEAD
" For LanguageClient_Neovim:
" - ElixirLS built and available in $PATH (https://github.com/JakeBecker/elixir-ls) or (https://github.com/elixir-lsp/elixir-ls)
" For the FZF plugin:
" - FZF installed (https://github.com/junegunn/fzf) in the path specified in the plugin definition below

""""""""""""""""
" Key Bindings "
""""""""""""""""

" Shortcut to FZF :Files with <leader>f
nnoremap <leader>f :Files<cr>

" Shortcut to FZF :Buffers with <leader>b
nnoremap <leader>b :Buffers<cr>

" Shortcut to FZF :Lines with <leader>l
nnoremap <leader>l :Lines<cr>

" Use the LanguageClient Neovim key bindings in Elixir file buffers only to avoid
" breaking normal functionality
augroup ElixirLSBindings
  autocmd!
  autocmd FileType elixir nnoremap <buffer> <silent> K :call LanguageClient#textDocument_hover()<CR>
  autocmd FileType elixir nnoremap <buffer> <silent> gd :call LanguageClient#textDocument_definition()<CR>
  autocmd FileType elixir nnoremap <buffer> <silent> <F2> :call LanguageClient#textDocument_rename()<CR>
augroup END

"""""""""""
" Plugins "
"""""""""""

" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.local/share/nvim/plugged')

" Installed plugins
Plug 'elixir-lang/vim-elixir'
Plug 'tpope/vim-endwise'
Plug 'scrooloose/nerdcommenter'
Plug 'airblade/vim-gitgutter'
Plug 'alvan/vim-closetag'
Plug '~/.fzf'
Plug 'junegunn/fzf.vim'
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-fugitive'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'autozimu/LanguageClient-neovim', { 'branch': 'next', 'do': './install.sh' }
Plug 'tpope/vim-dispatch'
Plug 'janko-m/vim-test'
Plug 'Yggdroot/indentLine'
Plug 'zchee/deoplete-jedi'
Plug 'altercation/vim-colors-solarized'
" Plug 'SirVer/ultisnips'

" Initialize plugin system
call plug#end()

"""""""""""
" General "
"""""""""""

" Turn syntax highlighting on
syntax enable

" Set the background to dark (required for colors)
set background=dark

" Enable the Solarized colorscheme
colorscheme solarized

" Fix backspace so that it works normally
set backspace=indent,eol,start

" Show existing tab with 2 spaces width
set tabstop=2

" when indenting with '>', use 2 spaces width
set shiftwidth=2

" On pressing tab, insert 2 spaces
set expandtab

" Turn case sensitive search off and smartcase search on
set ignorecase
set smartcase

" Turn on line numbers
set number

" Allow buffer switching without saving
set hidden

" Fold based on syntax
set foldmethod=syntax

" Don't fold files by default
set nofoldenable

""""""""""""""
" Automation "
""""""""""""""

" Automatically quit Vim if quickfix is the last open window
autocmd BufEnter * call MyLastWindow()
function! MyLastWindow()
  " if the window is quickfix go on
  if &buftype=="quickfix"
    " if this window is last on screen quit without warning
    if winbufnr(2) == -1
      quit!
    endif
  endif
endfunction

" Automatically update folds on file open and after leaving insert mode
" in order to fix folding in Elixir files
augroup ElixirFixFolds
  autocmd!
  autocmd FileType elixir normal! zXzR
  autocmd FileType elixir autocmd InsertLeave * normal! zXzR
augroup END

" Automatically close the Deoplete preview window after completion
" (https://github.com/Shougo/deoplete.nvim/issues/115)
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

""""""""""""""""""
" NERD Commenter "
""""""""""""""""""

" Add a space for all comments
let NERDSpaceDelims=1

""""""""""""""""
" Vim Closetag "
""""""""""""""""

" Add *.eex to the file types in which tags get auto-closed
let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.eex'

" """""""""""
" " Airline "
" """""""""""

" " Setup the Airline symbols dictionary if it doesn't already exist 
" if !exists('g:airline_symbols')
"   let g:airline_symbols = {}
" endif

" " Use Powerline symbols for Airline
" let g:airline_left_sep = ''
" let g:airline_left_alt_sep = ''
" let g:airline_right_sep = ''
" let g:airline_right_alt_sep = ''
" let g:airline_symbols.branch = ''
" let g:airline_symbols.readonly = ''
" let g:airline_symbols.linenr = '☰'
" let g:airline_symbols.maxlinenr = ''

" " Enable the Solarized dark Airline theme
" let g:airline_solarized_bg='dark'
" let g:airline_theme='solarized'

" " Add LanguageClient-Neovim error and warning counts to Airline
" function! AirlineInit()
"   let g:airline_section_warning = airline#section#create(['LC_warning_count'])
"   let g:airline_section_error = airline#section#create(['LC_error_count'])
" endfunction

" silent! call airline#parts#define_function('LC_warning_count', 'LC_warning_count')
" silent! call airline#parts#define_function('LC_error_count', 'LC_error_count')


" autocmd User AirlineAfterInit call AirlineInit()

"""""""""""""
" Lightline "
"""""""""""""

let g:lightline = {
\   'colorscheme': 'solarized',
\   'active': {
\     'left': [ [ 'mode', 'paste' ], 
\               [ 'gitbranch', 'filename', 'modified' ] ],
\     'right': [ [ 'lineinfo' ],
\                [ 'percent' ],
\                [ 'lcnverrors', 'lcnvwarnings', 'filetype' ] ],
\   },
\   'component_function': {
\     'gitbranch': 'fugitive#head',
\     'lcnvwarnings': 'LCNV_warning_count',
\     'lcnverrors': 'LCNV_error_count',
\   },
\ }

function! LCNV_warning_count()
  let current_buf_number = bufnr('%')
  let qflist = getqflist()
  let current_buf_diagnostics = filter(qflist, {index, dict -> dict['bufnr'] == current_buf_number && dict['type'] == 'W'})
  let count = len(current_buf_diagnostics)
  return count > 0 && g:LanguageClient_loaded ? 'W: ' . count : ''
endfunction

function! LCNV_error_count()
  let current_buf_number = bufnr('%')
  let qflist = getqflist()
  let current_buf_diagnostics = filter(qflist, {index, dict -> dict['bufnr'] == current_buf_number && dict['type'] == 'E'})
  let count = len(current_buf_diagnostics)
  return count > 0 && g:LanguageClient_loaded ? 'E: ' . count : ''
endfunction

""""""""""""
" Deoplete "
""""""""""""

" Enable deoplete
let g:deoplete#enable_at_startup = 1

"""""""""""""""""""""""""
" LanguageClient Neovim "
"""""""""""""""""""""""""

" Enable debugging
let g:LanguageClient_loggingLevel = 'DEBUG'

let g:LanguageClient_rootMarkers = {
\   'elixir': ['mix.exs'],
\ }

" Use the ElixirLS shell script from $PATH
let g:LanguageClient_serverCommands = {
\   'elixir': ['elixir-ls.sh'],
\ }

" Customize diangostic displays
let g:LanguageClient_diagnosticsDisplay = { 
\   1: { 
\     'texthl': 'ErrorMsg',
\     "signText": "X",
\     "signTexthl": "ErrorMsg",
\   },
\   2: { 
\     "texthl": "WarningMsg",
\     "signText": "!",
\     "signTexthl": "WarningMsg",
\   },
\ }

""""""""""""
" Vim Test "
""""""""""""

" Tell Vim Test to use Dispatch Vim as the testing strategy
let test#strategy = "dispatch"

""""""""""""""""""""
" # Experimental # "
""""""""""""""""""""
" let g:gitgutter_enabled = 0
" let g:dispatch_compilers = {'elixir': 'exunit'}

" let g:LanguageClient_hasSnippetSupport = 0
