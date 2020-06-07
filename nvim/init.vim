""""""""""""""""
" Dependencies "
""""""""""""""""

" For everything:
" - NeoVim (not Vim)
" For Plugins:
" - vim-plug installed (https://github.com/junegunn/vim-plug)
" For Deoplete:
" - Neovim Python3 provider (pip3 install pynvim)
" - Neovim installed from HEAD
" For LanguageClient_Neovim, the following available in $PATH:
" - ElixirLS with `language_server.sh` as `elixir-ls` (https://github.com/elixir-lsp/elixir-ls)
" - PyLS (ideally with all add-ons) available in (https://github.com/palantir/python-language-server)
" - Sourcegraph JavaScript/TypeScript Language Server (https://github.com/sourcegraph/javascript-typescript-langserver)
" - VSCode JSON Language server (https://github.com/vscode-langservers/vscode-json-languageserver)
" - RLS (https://github.com/rust-lang/rls)
" For the FZF plugin:
" - FZF installed (https://github.com/junegunn/fzf) in the path specified in the plugin definition below

" Set the script encoding (for multibyte characters) (http://rbtnn.hateblo.jp/entry/2014/12/28/010913)
scriptencoding utf-8

"""""""""""""""""""""""""
" Environment Variables "
"""""""""""""""""""""""""
if !empty($XDG_CONFIG_HOME)
  let g:xdg_config_home = $XDG_CONFIG_HOME
else
  let g:xdg_config_home = '$HOME/.config'
endif

if !empty($XDG_DATA_HOME)
  let g:xdg_data_home = $XDG_DATA_HOME
else
  let g:xdg_data_home = '$HOME/.local/share'
endif

if !empty($XDG_CACHE_HOME)
  let g:xdg_cache_home = $XDG_CACHE_HOME
else
  let g:xdg_cache_home = '$HOME/.cache'
endif

""""""""""""""""
" Key Bindings "
""""""""""""""""

" Shortcut to FZF :Files with <leader>f
nnoremap <leader>f :Files<cr>

" Shortcut to FZF :Buffers with <leader>b
nnoremap <leader>b :Buffers<cr>

" Shortcut to FZF :Lines with <leader>l
nnoremap <leader>l :Lines<cr>

"""""""""""
" Plugins "
"""""""""""

" Specify a directory for plugins
" - For Neovim: $HOME/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin(g:xdg_data_home.'/nvim/plugged')

" Editing
Plug 'tpope/vim-endwise'
Plug 'scrooloose/nerdcommenter'
Plug 'Yggdroot/indentLine'
Plug 'alvan/vim-closetag'

" Utilities
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug g:xdg_data_home.'/fzf'
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-dispatch'
Plug 'janko-m/vim-test'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'Shougo/echodoc.vim'
Plug 'ncm2/float-preview.nvim'
Plug 'autozimu/LanguageClient-neovim', { 'branch': 'next', 'do': './install.sh' }

" Visual customization
Plug 'itchyny/lightline.vim'
Plug 'jmcantrell/vim-virtualenv'
Plug 'altercation/vim-colors-solarized'

" Language support
Plug 'elixir-lang/vim-elixir'
Plug 'chrisbra/csv.vim'
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'elzr/vim-json'
Plug 'rust-lang/rust.vim'

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

" Don't show the current mode on the last line
" This is not needed as the status line displays the current mode
set noshowmode

" Disable previews for completions
set completeopt-=preview

" Limit the completion menu to 10 entries
set pumheight=10

""""""""""""""
" Automation "
""""""""""""""

" Automatically quit Vim if quickfix is the last open window
autocmd BufEnter * call QuitIfQuickfixLastWindow()
function! QuitIfQuickfixLastWindow()
  if &buftype=="quickfix"
    " If this window is last on screen quit without warning
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
""""""""""""""""""
" NERD Commenter "
""""""""""""""""""

" Add a space for all comments
let g:NERDSpaceDelims=1

""""""""""""""""
" Vim Closetag "
""""""""""""""""

" Add *.eex to the file types in which tags get auto-closed
let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.eex'

"""""""""""""
" Lightline "
"""""""""""""

" Configure Lightline
let g:lightline = {
\   'colorscheme': 'solarized',
\   'active': {
\     'left': [ [ 'mode', 'paste' ], 
\               [ 'gitbranch', 'filename' ],
\               [ 'venv' ] ],
\     'right': [ [ 'lineinfo' ],
\                [ 'percent' ],
\                [ 'lcnverrors', 'lcnvwarnings', 'filetype' ], ],
\   },
\   'component_function': {
\     'filename': 'LightlineFilename',
\     'gitbranch': 'fugitive#head',
\     'lcnvwarnings': 'LCNVWarningCount',
\     'lcnverrors': 'LCNVErrorCount',
\     'venv': 'virtualenv#statusline',
\   },
\ }

" Show the filename and the modified state in a single Lightline component
function! LightlineFilename()
  let l:filename = expand('%:t') !=# '' ? expand('%:t') : '[No Name]'
  let l:modified = &modified ? ' +' : ''
  return l:filename . l:modified
endfunction

" Returns a string with the count of a specific type of LanguageClient-Neovim diagnostic
" This function gets its results from quickfix
" `type` is a string that is either `'W'` (warning) or `'E'` (error)
function! s:LCNVCountType(type)
  let l:current_buf_number = bufnr('%')
  let l:qflist = getqflist()
  let l:current_buf_diagnostics = filter(l:qflist, {index, dict -> dict['bufnr'] == l:current_buf_number && dict['type'] == a:type})
  let l:count = len(l:current_buf_diagnostics)
  return l:count > 0 && g:LanguageClient_loaded ? a:type . ': ' . l:count : ''
endfunction

" Define a function for the LanguageClient-Neovim warning count
function! LCNVWarningCount()
  return s:LCNVCountType('W')
endfunction

" Define a function for the LanguageClient-Neovim error count
function! LCNVErrorCount()
  return s:LCNVCountType('E')
endfunction

""""""""""""
" Deoplete "
""""""""""""

" Enable deoplete
let g:deoplete#enable_at_startup = 1

" Automatically close the Deoplete preview window after completion
" (https://github.com/Shougo/deoplete.nvim/issues/115)
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

" Disable Deoplete for markdown files
autocmd bufread,bufnewfile *.md call deoplete#disable()

"""""""""""
" Echodoc "
"""""""""""

" Use neovim's floating text for documentation
let g:echodoc#enable_at_startup = 1
let g:echodoc#type = 'floating'
" To use a custom highlight for the float window, change Pmenu to your highlight group
highlight link EchoDocFloat Pmenu

"""""""""""""""""
" Float Preview "
"""""""""""""""""

" Dock the preview window to the bottom of the window
let g:float_preview#docked = 1

"""""""""""""""""""""""""
" LanguageClient-Neovim "
"""""""""""""""""""""""""

let g:LanguageClient_loggingFile = expand(g:xdg_cache_home.'/nvim/LanguageClient.log')

" Enable debugging
let g:LanguageClient_loggingLevel = 'DEBUG'

let g:LanguageClient_rootMarkers = {
\   'elixir': ['mix.exs'],
\   'rust': ['Cargo.toml'],
\ }

" Setup individual Language Servers from $PATH
let g:LanguageClient_serverCommands = {
\   'elixir': ['elixir-ls'],
\   'python': ['pyls'],
\   'typescript': ['javascript-typescript-stdio'],
\   'typescript.tsx': ['javascript-typescript-stdio'],
\   'json': ['vscode-json-languageserver', '--stdio'],
\   'rust': ['rustup', 'run', 'stable', 'rls'],
\ }

" Disable diagnostic signs in the signcolumn
" Do this because Gitgutter is more important in the signcolumn and virtual text means we don't need these signs
let g:LanguageClient_diagnosticsSignsMax = 0

" Set the location for LCNV to load settings from
let g:LanguageClient_settingsPath = g:xdg_config_home.'/nvim/lcnv-settings.json'

" Use the LanguageClient-Neovim key bindings in appropriate file buffers only to avoid breaking normal functionality
function s:SetLCNVKeyBindings()
  nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
  nnoremap <leader>lr :call LanguageClient#textDocument_rename()<CR>
  nnoremap <leader>lf :call LanguageClient#textDocument_formatting()<CR>
  nnoremap <leader>lt :call LanguageClient#textDocument_typeDefinition()<CR>
  nnoremap <leader>lx :call LanguageClient#textDocument_references()<CR>
  nnoremap <leader>la :call LanguageClient_workspace_applyEdit()<CR>
  nnoremap <leader>lc :call LanguageClient#textDocument_completion()<CR>
  nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
  nnoremap <leader>ls :call LanguageClient_textDocument_documentSymbol()<CR>
  nnoremap <leader>lm :call LanguageClient_contextMenu()<CR>
endfunction()

augroup LSP
  autocmd!
  autocmd FileType elixir,python,typescript,typescript.tsx,json,rust call s:SetLCNVKeyBindings()
augroup END

" Echo an arbitrary warning message
function! EchoWarning(msg)
  echohl WarningMsg
  echo a:msg
  echohl None
endfunction

" Check if a tsconfig.json file can be found by recursively searching up parent directories (until the root directory). Print a warning if one is not found
function VerifyTypeScriptTSXConfigExists()
  let l:currentDirectoryPath = getcwd()
  if empty(findfile(glob("tsconfig.json"), l:currentDirectoryPath.';'))
    call EchoWarning("You are opening a TSX file but no tsconfig.json could be found. TSX language server support requires a tsconfig.json file which specifies that TSX should be enabled.")
  endif
endfunction()

augroup LSPVerifyTSXConfig
  autocmd!
  " The unsilent part needed in order to echo messages with a FileType autocmd (https://gitter.im/neovim/neovim?at=5db6863be886fb5aa20b6808)
  autocmd FileType typescript.tsx unsilent call VerifyTypeScriptTSXConfigExists()
augroup END

""""""""""""
" Vim Test "
""""""""""""

" Tell Vim Test to use Dispatch Vim as the testing strategy
let g:test#strategy = "dispatch"

""""""""""""
" Vim JSON "
""""""""""""

" Disable Vim JSON warnings. We want to delegate these to the language server instead
let g:vim_json_warnings = 0

" Disable concealment of quotes in JSON files. Otherwise, the IndentLine plugin doesn't work, and that's more valuable
let g:vim_json_syntax_conceal = 0

"""""""""""""""
" Indent Line "
"""""""""""""""

" Change the characters recursively 
let g:indentLine_char_list = ['|', '¦', '┆', '┊']

" Use solarized base01 color for indent line characters
let g:indentLine_color_term = 240

""""""""""""""""
" Experimental "
""""""""""""""""
