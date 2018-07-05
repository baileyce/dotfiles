set fenc=utf-8
set autoread
set number
set smartindent
nnoremap j gj
nnoremap k gk
set expandtab
set tabstop=4
set shiftwidth=4
set ignorecase
set smartcase
set incsearch
set wrapscan
set hlsearch
nmap <Esc><Esc> :nohlsearch<CR><Esc>
set mouse=a
set cursorline
highlight CursorLine cterm=None ctermbg=237 ctermfg=None
highlight CursorLineNr cterm=None ctermbg=237 ctermfg=208
highlight LineNr ctermbg=236
nmap n nzz
nmap N Nzz
syntax on
if has("autocmd")
    au BufReadPost * if line("'\"")>1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif
