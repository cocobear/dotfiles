
"set background=dark
syntax on


set title
" 取消备份
set nobackup
set noswapfile
set noundofile
" switch buffer without saving
set hidden

" 在状态栏显示正在输入的命令
set showcmd

" 显示括号配对情况
set showmatch

" :next, :make 命令之前自动保存
set autowrite

hi Normal guibg=NONE ctermbg=NONE

if has("termguicolors")
    " enable true color
    set termguicolors
endif

set termguicolors
let $NVIM_TUI_ENABLE_TRUE_COLOR=1

" 不检测文件类型
filetype off
" 针对不同的文件类型采用不同的缩进格式
filetype plugin indent on

""set guifont=SauceCodePro\ Nerd:h14

"improve autocomplete menu color
highlight Pmenu ctermbg=238 gui=bold

" 设置编码
set encoding=utf-8
set nocompatible
set laststatus=2
" 设置文件编码
set fenc=utf-8

" vimrc文件修改之后自动加载
autocmd! bufwritepost .vimrc source %

" 文件修改之后自动载入
set autoread

"set to use clipboard of system
set clipboard=unnamed

" 设置文件编码检测类型及支持格式
set fencs=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936

"显示行号
set number
"Show related row numbers
set relativenumber

"settings for backspace
set backspace=2
set backspace=indent,eol,start
" 退格键一次删掉4个空格
set smarttab

"忽略大小写查找
set ic
" 高亮搜索命中的文本
set hlsearch

" 随着键入即时搜索
set incsearch

" 搜索时忽略大小写
set ignorecase

" 有一个或以上大写字母时仍大小写敏感
set smartcase

" tab宽度
set tabstop=2
set cindent shiftwidth=2
set autoindent shiftwidth=2
set smartindent
" 填充Tab
set expandtab
set tabstop=4
set shiftwidth=4
set shiftround

" set 折叠
set foldmethod=indent
" 打开文件默认不折叠
set foldlevelstart=99
" 突出显示当前行，列
set cursorline
"set cursorcolumn
set showtabline=2  " Show tabline
set guioptions-=e  " Don't use GUI tabline

" 保存文件时自动删除行尾空格或Tab
autocmd BufWritePre * :%s/\s\+$//e

" 保存文件时自动删除末尾空行
autocmd BufWritePre * :%s/^$\n\+\%$//ge

" 打开文件时始终跳转到上次光标所在位置
autocmd BufReadPost *
      \ if ! exists("g:leave_my_cursor_position_alone") |
      \     if line("'\"") > 0 && line ("'\"") <= line("$") |
      \         exe "normal g'\"" |
      \     endif |
      \ endif


""""""""""""""KEY MAPPING""""""""""""""
"n: normal only"
"v: visual and select
"o: operator-pending
"x: visual only
"s: select only
"i: insert
"c: command-line
"l: insert, command-line...
"nnoremap: nore means Non-recursive

" Avoid shift mistakes when saving/quitting
command! W w
command! WQ wq
command! Wq wq
command! Q q

" Start external commands with a single bang
nnoremap ! :!

" Able to enter command mode with just ;
nnoremap ; :

" Easy way to surround a word using surround.vim
map sw ysiw

" Map jk to ESC in insert mode
inoremap jk <esc>
" Disable Esp key in insert mode
inoremap <esc> <nop>

"set my leader
let mapleader="\<Space>"
let g:mapleader="\<Space>"


" j k 移动行的时候光标始终在屏幕中间
nnoremap j gjzz
nnoremap k gkzz

" Keep search results at the center of screen
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz
" Press <leader> Enter to remove search highlights
noremap <silent> <leader><cr> :noh<cr>


" w!!写入只读文件
cmap w!! w !sudo tee >/dev/null %

" 给当前单词添加引号
nnoremap w" viw<esc>a"<esc>hbi"<esc>lel
nnoremap w' viw<esc>a'<esc>hbi'<esc>lel
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.jpg,*.png,*.gif,*.jpeg,.DS_Store  " MacOSX/Linux

" settings for resize splitted window
nmap w[ :vertical resize -3<CR>
nmap w] :vertical resize +3<CR>

nmap w- :resize -3<CR>
nmap w= :resize +3<CR>

call plug#begin('~/.local/share/nvim/plugged')

"Theme
Plug 'iCyMind/NeoSolarized'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'morhetz/gruvbox'

Plug 'mileszs/ack.vim'
Plug 'mattn/emmet-vim'
Plug 'ryanoasis/vim-devicons'
Plug 'scrooloose/nerdtree'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'scrooloose/nerdcommenter'
"Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': 'NERDTreeToggle'}
Plug 'tsony-tsonev/nerdtree-git-plugin'
Plug 'majutsushi/tagbar'
"using fzf instead
"Plug 'kien/ctrlp.vim'
Plug 'vim-scripts/xml.vim'
Plug 'airblade/vim-gitgutter'
Plug 'jiangmiao/auto-pairs'
Plug 'flazz/vim-colorschemes'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'
""Plug 'itchyny/lightline.vim'
Plug 'Lokaltog/vim-easymotion'
Plug 'terryma/vim-multiple-cursors'
""Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}
Plug 'neomake/neomake'
Plug 'mhinz/vim-startify'
Plug 'vim-scripts/wildfire.vim'
Plug 'yonchu/accelerated-smooth-scroll'
Plug 'ianva/vim-youdao-translater'
"Move current line/selection up/down
Plug 'matze/vim-move'
Plug 'pbrisbin/vim-mkdir'
"Perhaps may try LeaderF
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
"Plugins for golang
"Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'Shougo/neosnippet.vim'
Plug 'Shougo/neosnippet-snippets'
"Plugin(s) for Rust
Plug 'rust-lang/rust.vim'
Plug 'junegunn/goyo.vim'
call plug#end()

"theme must set after plugins avaiable
set background=dark
set t_Co=256
try
"colorscheme NeoSolarized
"colorscheme dracula
    colorscheme gruvbox
catch /^Vim\%((\a\+)\)\=:E185/
    "
endtry

""""""""""""""""PLUGIN CONFIG

" code search
let g:ackprg = 'ag --nogroup --nocolor --column'

"For neomake
map <leader>m :Neomake<CR>
let g:neomake_open_list = 2
let g:neomake_list_height = 7

" coc settings
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<CR>"

" Settings for vim-easymotion
let g:EasyMotion_leader_key = ","

"For vim-move
let g:move_key_modifier = 'C'

"For ack
let g:ackprg = 'ag --nogroup --nocolor --column'

"For Youdao Translater Plugin
vnoremap <silent> <C-T> <Esc>:Ydv<CR>
nnoremap <silent> <C-T> <Esc>:Ydc<CR>

"For fzf
nnoremap <C-p> :Files<Cr>

"airline setting
let g:airline_theme='molokai'
let g:airline_powerline_fonts = 1
let g:airline_extensions = ['tabline', 'tagbar']
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#tab_nr_type = 1 " tab number
let g:airline#extensions#tabline#show_tab_nr = 1
let g:airline#extensions#tabline#formatter = 'default'
let g:airline#extensions#tabline#buffer_nr_show = 0
let g:airline#extensions#tabline#fnametruncate = 16
let g:airline#extensions#tabline#fnamecollapse = 2
let g:airline#extensions#tabline#buffer_idx_mode = 1
let g:airline#extensions#tabline#fnamemod = ':p:t'
" tabline中当前buffer两端的分隔字符
let g:airline#extensions#tabline#left_sep = ' '
" tabline中未激活buffer两端的分隔字符
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#hunks#enabled = 0
let g:airline_section_y = '%{strftime("%H:%M")}'
let g:airline_detect_modified=1
let g:airline_detect_paste=1
let g:airline_detect_crypt=1
let g:airline_highlighting_cache = 1
let g:airline#extensions#tabline#show_tab_type = 0
" tab or buf 1
nnoremap <leader>1 :b 1<CR>
nnoremap <leader>2 :b 2<CR>

" tab navigation like zsh
:nmap <leader>h :bp<CR>
:imap <leader>h <C-c>:bp<CR>
:nmap <leader>l :bn<CR>
:imap <leader>l <C-c>:bn<CR>
:nmap <leader>w :bd<CR>:bn<CR>:bp<CR>
:imap <leader>w <C-c>:bd<CR>:bn<CR>:bp<CR>
"Settings for Golang
let g:go_fmt_command = "goimports"
let g:go_highlight_types = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_snippet_engine = "neosnippet"

au FileType go nmap <Leader>i <Plug>(go-info)
au FileType go nmap <Leader>gd <Plug>(go-doc)
au FileType go nmap <leader>r <Plug>(go-run)
au FileType go nmap <leader>b <Plug>(go-build)
au FileType go nmap <leader>t <Plug>(go-test)
au FileType go nmap <leader>c <Plug>(go-coverage)
au FileType go nmap gd <Plug>(go-def-tab)

"For go
au BufNewFile,BufRead *.go set filetype=go  noexpandtab tabstop=4 shiftwidth=4

"For python
au BufRead,BufNewFile *.py set shiftwidth=4 tabstop=4 softtabstop=4 expandtab smarttab autoindent

"For Rust settings
let g:rustfmt_autosave = 1

"scss,sass
au BufRead,BufNewFile *.scss set filetype=scss
au BufRead,BufNewFile *.sass set filetype=scss

"coffee script
au BufWritePost *.coffee silent CoffeeMake!
au BufWritePost *.coffee :CoffeeCompile watch vert

"let skim use slim syntax
au BufRead,BufNewFile *.skim set filetype=slim

" NeoSnippet Plugin key-mappings.
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

" SuperTab like snippets behavior.
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
imap <expr><TAB>
 \ pumvisible() ? "\<C-n>" :
 \ neosnippet#expandable_or_jumpable() ?
 \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" For conceal markers.
if has('conceal')
  set conceallevel=2 concealcursor=niv
endif
"Settings for TagBar
map <leader>g :TagbarToggle<CR>
""let g:tagbar_type_go = {
""    \ 'ctagstype' : 'go',
""    \ 'kinds' : [
""        \ 'p:package',
""        \ 'i:imports:1',
""        \ 'c:constants',
""        \ 'v:variables',
""        \ 't:types',
""        \ 'n:interfaces',
""        \ 'w:fields',
""        \ 'e:embedded',
""        \ 'm:methods',
""        \ 'r:constructor',
""        \ 'sro' : '.',
""        \ 'f':'functions',
""    \ ],
""    \ 'kind2scope' : {
""        \ 't' : 'ctype',
""        \ 'n' : 'ntype',
""    \ },
""    \ 'scope2kind' : {
""        \ 'ctype' : 't',
""        \ 'ntype' : 'n',
""    \ },
""    \ 'ctagsbin' : 'gotags',
""    \ 'ctagsargs' : '-sort -silent',
""\ }
"use in  edit
imap <C-A> <C-C><c-p>

"For NERDTree
" 设定文件浏览器目录为当前目录
set bsdir=buffer
let NERDTreeQuitOnOpen = 0
let NERDChristmasTree=1
let g:NERDTreeWinSize = 32
map <leader>f :NERDTreeToggle<CR>
let NERDTreeMinimalUI = 1
let NERDTreeShowHidden = 1
let g:NERDTreeDirArrowExpandable = "\u00a0"
let g:NERDTreeDirArrowCollapsible = "\u00a0"

let g:nerdtree_tabs_open_on_console_startup = 1
let g:nerdtree_tabs_focus_on_files = 1

let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "",
    \ "Staged"    : "",
    \ "Untracked" : "",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "",
    \ "Clean"     : "✔︎",
    \ 'Ignored'   : '☒',
    \ "Unknown"   : "?"
    \ }

let g:NERDTreeGitStatusNodeColorization = 1
let g:NERDTreeGitStatusWithFlags = 1

let g:NERDTreeColorMapCustom = {
    \ "Modified"  : "#33BBFF",
    \ "Staged"    : "#33FF6B",
    \ "Untracked" : "#FF5733",
    \ "Dirty"     : "#FCEE09",
    \ "Clean"     : "#ffFCAB",
    \ "Ignored"   : "#07939A",
    \ }

"For vim-devicons
let g:WebDevIconsNerdTreeBeforeGlyphPadding = ""
let g:WebDevIconsUnicodeDecorateFolderNodes = v:true
""let g:webdevicons_conceal_nerdtree_brackets = 0
let g:DevIconsEnableNERDTreeRedraw = 1
""let g:WebDevIconsUnicodeGlyphDoubleWidth = 1
autocmd FileType nerdtree setlocal signcolumn=no
" after a re-source, fix syntax matching issues (concealing brackets):
""if exists('g:loaded_webdevicons')
""  call webdevicons#refresh()
""endif

