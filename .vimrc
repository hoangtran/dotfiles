""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Author     : Hoang Tran
" Version    : 1.4
" Last Change: Wed Jan 25 12:19:36 PST 2017
"
""""""""""""""""""""""""""""""""""""""""""""""""""""

"Get out of VI's compatible mode..
set nocompatible
filetype off

"Sets how many lines of history VIM har to remember
set history=400

"Set to auto read when a file is changed from the outside
set autoread

"With a map leader it's possible to do extra key combinations
"like <leader>w saves the current file
let mapleader = ","
let g:mapleader = ","

nnoremap ; :

"Fast saving
nmap <leader>w :w!<cr>

"Fast editing of the .vimrc
map <leader>e :e! ~/.vimrc<cr>

"When vimrc is edited, reload it
autocmd! bufwritepost .vimrc source ~/.vimrc

set showmode           "What is the mode?
set showcmd            "Show command
set ruler

set wildmenu           "Turn on wild menu
set wildcharm=<C-Z>    "Shortcut to open the wildmenu when you are in the command mode - it's similar to <C-D>

set linebreak          "If on Vim will wrap long lines at a character in 'breakat'
set showbreak=>>\      "identifier put in front of wrapped lines
set lazyredraw         "no readraw when running macros

"set mouse=n            "mouse only in normal mode support in vim

function! CurDir()
    let curdir = substitute(getcwd(), '/home/hoangtran/', "~/", "g")
    return curdir
endfunction

"Turn backup off
set nobackup
set nowritebackup
set noswapfile

set ffs=unix,dos,mac   "favorite filetypes

set hid                "Change buffer - without saving

"Showing matches
set showmatch
set matchtime=2

"highlight and increase search
set hlsearch
set incsearch
"Ignore case but smart
set ignorecase
set smartcase

"timeout
set timeoutlen=1000
set ttimeoutlen=0

syntax enable

call plug#begin('~/.vim/plugged')

"Plug 'OmniCppComplete'
"Plug 'The-NERD-tree'
Plug 'jlanzarotta/bufexplorer'
Plug 'ctrlpvim/ctrlp.vim'
"Plug 'taglist.vim'
Plug 'tpope/vim-fugitive'
"Plug 'tpope/vim-pathogen'
"Plug 'tpope/vim-surround'
Plug 'airblade/vim-gitgutter'
"Plug 'tpope/vim-jdaddy.git'
Plug 'altercation/vim-colors-solarized'
Plug 'morhetz/gruvbox'
"Plug 'jpo/vim-railscasts-theme'
"Plug 'sjl/gundo.vim'
Plug 'rking/ag.vim'
Plug 'jremmen/vim-ripgrep'
Plug 'will133/vim-dirdiff'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tmux-plugins/vim-tmux'
"Plug 'scrooloose/syntastic'
Plug 'rhysd/vim-clang-format'
Plug 'lervag/vimtex'

call plug#end()

"Enable filetype plugin
filetype plugin indent on

set ai         "Auto indent
set si         "Smart indent
set cindent    "C-style indent

"set laststatus=2       "statusline is always visible
"Format the statusline
"set statusline=\ (%{bufnr('%')})%f%m%r%h\ %w\ #%{expand('#:t')}\ (%{bufnr('#')})%=CWD:\ %r%{CurDir()}%h\ \ \ Line:\ %l/%L:%c

"Linux kernel coding style
set noexpandtab
set tabstop=8
set shiftwidth=8
set smarttab
"set textwidth=78     "screen in 80 columns wide, wrap at 78
set backspace=eol,start,indent
set formatoptions=tcqlron
set cinoptions=:0,l1,t0,g0

"set selectmode=mouse,key,cmd

set listchars=tab:\|\ ,trail:~,extends:>,precedes:<
"Remap VIM 0
map 0 ^

"make Y effect to end of line instead of whole line
map Y y$

"Moving by visible lines
map <Up> gk
map <Down> gj

map Q gq       "Never Ex mode
noremap gQ Q   "If you want Ex mode again

"Map space to / (search) and c-space to ? (backwards search)
map <space> /
map <c-space> ?
map <silent> <leader><cr> :noh<cr>

" highlight last inserted text
"nnoremap gV `[v`]

"Smart way to move btw. windows
"map <C-j> <C-W>j
"map <C-k> <C-W>k
"map <C-h> <C-W>h
"map <C-l> <C-W>l

" jk is escape
inoremap jk <ESC>

nnoremap <NL> i<cr><ESC>

"Close the current buffer
map <leader>bd :Bclose<cr>

"Close all the buffers
map <leader>ba :1,300 bd!<cr>

map <leader>bn :bn<cr>
map <leader>bp :bp<cr>

"Use the arrows to something usefull
map <right> :bn<cr>
map <left> :bp<cr>

"Tab configuration
map <leader>tn :tabnew %<cr>
map <leader>te :tabedit
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove

"When pressing <leader>cd switch to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>
map <leader>lcd :lcd %:p:h<cr>

"Close and open quickfix quick
map <leader>cc :cclose<cr>
map <leader>co :copen<cr>

cnoremap sudow w !sudo tee % >/dev/null

" Use r for [right-angle braces] and a for <angle braces> like vim-surround
vnoremap ir i]
vnoremap ar a]
vnoremap ia i>
vnoremap aa a>
onoremap ir i]
onoremap ar a]
onoremap ia i>
onoremap aa a>

"autocmd BufEnter * if expand("%:p:h") !~ '^/tmp' | lcd %:p:h | endif

"Remember the cursor's last position after exit
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

"always add the current file's directory to the path if not already there
autocmd BufRead *
      \ let s:tempPath=escape(escape(expand("%:p:h"), ' '), '\ ') |
      \ exec "set path-=".s:tempPath |
      \ exec "set path+=".s:tempPath

command! Bclose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
    let l:currentBufNum = bufnr("%")
    let l:alternateBufNum = bufnr("#")

    if buflisted(l:alternateBufNum)
        buffer #
    else
        bnext
    endif

    if bufnr("%") == l:currentBufNum
        new
    endif

    if buflisted(l:currentBufNum)
        execute("bdelete! ".l:currentBufNum)
    endif
endfunction

"automatically leave insert mode after 'updatetime' milliseconds of inaction
au CursorHoldI * stopinsert

"set 'updatetime' to 15 seconds when in insert mode
au InsertEnter * let updaterestore=&updatetime | set updatetime=15000
au InsertLeave * let &updatetime=updaterestore

"delete trailing white space on save
func! DeleteTrailingWS()
    exe "normal mz"
    %s/\s\+$//ge
    exe "normal `z"
endfunc
autocmd BufWrite *.py :call DeleteTrailingWS()
autocmd BufRead,BufNewFile *.txt setlocal ft=txt

"replace multiple empty lines by single empty line.
func! ReplaceMultiEmptyLines()
    exe "normal mz"
    %s/\s\+$//ge
    %s/\n\{3,}/\r\r/ge
    exe "normal `z"
endfunc

"Specify the behavior when switching between buffers
"try
"    set switchbuf=usetab
"    set stal=2
"catch
"endtry

"Really useful!
"In visual mode when you press * or # to search for the current selection
vnoremap <silent> * :call VisualSearch('f')<CR>
vnoremap <silent> # :call VisualSearch('b')<CR>

vnoremap ,u :s/\<\@!\([A-Z]\)/\_\l\1/g<CR>gul

"When you press gv you vimgrep after the selected text
vnoremap <silent> gv :call VisualSearch('gv')<CR>
map <leader>g :vimgrep // **/*.<left><left><left><left><left><left><left>

function! CmdLine(str)
    exe "menu Foo.Bar :" . a:str
    emenu Foo.Bar
    unmenu Foo
endfunction

"From an idea by Michael Naumann
function! VisualSearch(direction) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", '\\/.*$^~[]')
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'b'
        execute "normal ?" . l:pattern . "^M"
    elseif a:direction == 'gv'
        call CmdLine("vimgrep " . '/'. l:pattern . '/' . ' **/*.')
    elseif a:direction == 'f'
        execute "normal /" . l:pattern . "^M"
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction

"Quickly open a buffer for scripbble
map <leader>q :e ~/buffer<cr>

set pastetoggle=<F10>

set background=dark
"let g:solarized_termcolors=256
"let g:solarized_termtrans=1
"colorscheme solarized
let g:airline_powerline_fonts=1
let g:gruvbox_contrast_dark='dark'
let g:gruvbox_transparent_bg=1
let g:gruvbox_termcolors=256
colorscheme gruvbox

highlight clear SignColumn

"bufexplorer.vim stuff
let g:bufExplorerDefaultHelp=0
let g:bufExplorerShowRelativePath=1
"let g:bufExplorerSortBy = "name"

" Always show the airline bar
set laststatus=2
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline#extensions#whitespace#enabled = 1
let g:airline#extensions#whitespace#checks = [ 'trailing' ]
let g:airline_powerline_fonts = 1
let g:airline_symbols.maxlinenr = 'Ξ'

au BufNewFile,BufRead ~/.mutt/temp/* setlocal ft=mail

"mail options {{{
au Filetype mail call SetMailOpts()

function! SetMailOpts()
    "source ~/.vim/autofix.vimrc " auto-correct

    setlocal spell
    setlocal nohls

    setlocal fo+=aw

    nmap <F1> gqap
    nmap <F2> gqqj
    nmap <F3> kgqj
    map! <F1> <ESC>gqapi
    map! <F2> <ESC>gqqji
    map! <F3> <ESC>kgqji
endfunction
"}}}

"set up F7 to toggle the NERDtree
nnoremap <silent> <F7> :NERDTreeToggle<CR>

"find recursively tags
set tags=./tags,./../tags,./*/tags,./.git/tags;

"scim stuff
function! Vietnamese()
    au InsertEnter,InsertLeave * call ToggleScim()
endfunction

function! ToggleScim()
    silent !xdotool key ctrl+space
    redraw!
endfunction

function! InsertMagicHyphen(hyphen)
    let vpos = virtcol(".") - 2
    if vpos < 0
        return a:hyphen
    endif
    let line = getline(".")
    let char = strpart(line, vpos, 1)
    if char =~ '\w'
        if a:hyphen == "-"
            return "_"
        else
            return "-"
        endif
    else
        return a:hyphen
    endif
endfunction

"inoremap <expr> - InsertMagicHyphen("-")
"inoremap <expr> _ InsertMagicHyphen("_")

"Supertab literal
"let g:SuperTabMappingTabLiteral='<c-v>'

"Open ag.vim
nnoremap <leader>a :Ag

"Ctrl-P stuff
let g:ctrlp_max_files = 20000
let g:ctrlp_max_depth = 10
let g:ctrlp_match_window = 'bottom,order:ttb'
let g:ctrlp_switch_buffer = 0
let g:ctrlp_working_path = 0
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files', 'ag %s -l --nocolor --hidden -g ""']

" toggle gundo
nnoremap <leader>u :GundoToggle<CR>

"Syntastic
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*

"let g:syntastic_always_populate_loc_list = 1
"let g:syntastic_auto_loc_list = 1
"let g:syntastic_check_on_open = 1
"let g:syntastic_check_on_wq = 0

"map _u :call ID_search()<Bar>execute "/\\<" . g:word . "\\>"<CR>
"map _n :n<Bar>execute "/\\<" . g:word . "\\>"<CR>
"
"function! ID_search()
"    let g:word = expand("<cword>")
"    let x = system("lid --key=none ". g:word)
"    let x = substitute(x, "\n", " ", "g")
"    execute "next " . x
"endfun

function! s:Shell(...)
    let curline=line ('.')
    if curline < 6
        let start=0
    else
        let start=curline-5
    endif
    let end=curline+15
    execute 'silent !clear'
    execute 'silent !echo -e "\n...\n"'
    execute 'silent !sed ' . start . ',' . end . '\!d %'
    execute 'silent !echo -e "\n...\n"'
    execute 'shell'
endfunction
command! Shell call s:Shell()

function! Yank(...)
    if a:0
        let response = system("xsel -pi", a:1)
    else
        let response = system("xsel -pi", @")
    endif
endfunction

function! YankClip(...)
    if a:0
        let response = system("xsel -bi", a:1)
    else
        let response = system("xsel -bi", @")
    endif
endfunction

function! Paste(paste_before, use_primary)
    let at_q = @q
    if a:use_primary
        let @q = system("xsel -po")
    else
        let @q = system("xsel -bo")
    endif
    if a:paste_before
        normal! "qP
    else
        normal! "qp
    endif
    let @q = at_q
endfunction

vmap <silent> <leader>y y:call Yank()<cr>
vmap <silent> <leader>gy y:call YankClip()<cr>
nmap <silent> <leader>yy yy:call Yank()<cr>
nmap <silent> <leader>p :call Paste(0, 1)<cr>
nmap <silent> <leader>P :call Paste(1, 1)<cr>
nmap <silent> <leader>gp :call Paste(0, 0)<cr>
nmap <silent> <leader>gP :call Paste(1, 0)<cr>

"highlight DiffAdd cterm=none ctermfg=fg ctermbg=Blue gui=none guifg=fg guibg=Blue
"highlight DiffDelete cterm=none ctermfg=fg ctermbg=Blue gui=none guifg=fg guibg=Blue
"highlight DiffChange cterm=none ctermfg=fg ctermbg=Blue gui=none guifg=fg guibg=Blue
"highlight DiffText cterm=none ctermfg=bg ctermbg=White gui=none guifg=bg guibg=White
highlight Comment cterm=italic

"dirdiff
let g:DirDiffExcludes = "*.d,*.o,*.cmd,*.orig,*.mod,.*.swp"

let g:clang_format#style_options = {
            \ "AccessModifierOffset" : -4,
            \ "AllowShortIfStatementsOnASingleLine" : "true",
            \ "AlwaysBreakTemplateDeclarations" : "true",
            \ "Standard" : "C++11"}

" map to <Leader>cf in C++ code
"autocmd FileType cpp,objc nnoremap <buffer><leader>cf :<C-u>ClangFormat<CR>
"autocmd FileType cpp,objc vnoremap <buffer><leader>cf :ClangFormat<CR>
" if you install vim-operator-user
"autocmd FileType cpp,objc map <buffer><leader>x <Plug>(operator-clang-format)
" Toggle auto formatting:
"nmap <leader>C :ClangFormatAutoToggle<CR>

"autocmd FileType cpp ClangFormatAutoEnable

let g:tex_flavor='latex'
let g:vimtex_view_method='zathura'
let g:vimtex_quickfix_mode=0
set conceallevel=1
let g:tex_conceal='abdmg'

