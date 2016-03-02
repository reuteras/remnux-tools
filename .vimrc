" Many settings copied from 
"   https://github.com/nvie/vimrc
" Use vim settings, rather then vi settings (much better!)
" This must be first, because it changes other options as a side effect.
set nocompatible
set showmode                    " always show what mode we're currently editing in

" Keyboard map
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <c-h> <c-w>h
nmap <c-l> <c-w>l

syntax on

set ignorecase                  " ignore case when searching
set smartcase                   " ignore case if search pattern is all lowercase,
                                "    case-sensitive otherwise

set wildignore=*.o,*.obj,*.bak,*.exe

set updatecount=0               " number of characters before writting to swap
set nobackup                    " do not keep backup files, it's 70's style cluttering
set noswapfile                  " do not write annoying intermediate swap files,
                                "    who did ever restore from swap files
                                "    anyway?

" tab settings
" To enter a tab use <ctrl-v><tab>
set expandtab
set shiftwidth=4
set tabstop=4
set softtabstop=4

set autoindent                  " always set autoindenting on
set copyindent                  " copy the previous indentation on autoindenting
set showmatch                   " set show matching parenthesis

set scrolloff=4                 " keep 4 lines off the edges of the screen when scrolling
set ruler                       " show cursor position

set hlsearch                    " highlight search terms
set incsearch                   " show search matches as you type
set gdefault                    " search/replace 'globally' (on a line) by default

set pastetoggle=<F2>            " when in insert mode, press <F2> to go to
                                "    paste mode, where you can paste mass data
                                "    that won't be autoindented

set fileformats="unix,dos,mac"
set formatoptions+=1            " When wrapping paragraphs, don't end lines
                                "    with 1-letter words (looks stupid)

filetype on                     " enables filetype detection
filetype plugin on              " enables filetype specific plugins

" Search with regular expressions
nnoremap / /\v
vnoremap / /\v

" Let F3 insert timestamp
inoremap <F3> <C-R>=strftime('%c').': '<CR>   

set termencoding=utf-8
set encoding=utf-8

set laststatus=2                " tell VIM to always put a status line in, even
                                "    if there is only one window

set history=1000                " remember more commands and search history
set undolevels=1000             " use many muchos levels of undo
if v:version >= 730
    set undofile                " keep a persistent backup file
    set undodir=~/.vim/.undo
endif

set wildmenu                    " make tab completion for files/buffers act like bash
set wildmode=list:full          " show a list when pressing tab and complete
                                "    first full match
set wildignore=*.swp,*.bak,*.pyc,*.class
set title                       " change the terminal's title
set visualbell                  " don't beep
set noerrorbells                " don't beep
set showcmd                     " show (partial) command in the last line of the
                                "    screen this also shows visual selection info
set nomodeline                  " disable mode lines (security measure)
set cursorline                  " underline the current line, for quick orientation

set viminfo='20,\"100,:20,%,n~/.viminfo

function! ResCur()
    if line("'\"") <= line("$")
        normal! g`"
        return 1
    endif
endfunction

augroup resCur
    autocmd!
    autocmd BufWinEnter * call ResCur()
augroup END

" Spell
" Download Swedish files from ftp://ftp.vim.org/pub/vim/runtime/spell/sv/
" Control via
" setlocal spell spelllang=sv
" setlocal spell spelllang=en
" set nospell

let g:syntastic_check_on_wq = 0

