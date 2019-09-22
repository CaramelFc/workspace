set background=dark
set tabstop=4
set shiftwidth=4
set autoindent
set showcmd
set nocompatible
set t_Co=256
set number
set laststatus=2
set hlsearch
set encoding=utf-8
set cursorcolumn
set cursorline
set autoindent
set cindent
set ruler
set display=lastline
set wildmenu
set ignorecase
set completeopt=menu,menuone
set expandtab
set splitright




set undofile
set undodir=~/.cache/undodir
"set path+=/usr/include/**
"set path+=~/Git/megipl-hexagon/**


if has('multi_byte')
	set encoding=utf-8

	set fileencoding=utf-8

	set fileencodings=ucs-bom,utf-8,gbk,gb18030,big5,euc-jp,latin1
endif

if has('autocmd')
	filetype plugin indent on
endif

if has('syntax')
	syntax enable
	syntax on
endif

set suffixes=.bak,~,.o,.h,.info,.swp,.obj,.pyc,.pyo,.egg-info,.class
set wildignore=*.o,*.obj,*~,*.exe,*.a,*.pdb,*.lib "stuff to ignore when tab completing
set wildignore+=*.so,*.dll,*.swp,*.egg,*.jar,*.class,*.pyc,*.pyo,*.bin,*.dex
set wildignore+=*.zip,*.7z,*.rar,*.gz,*.tar,*.gzip,*.bz2,*.tgz,*.xz    " MacOSX/Linux
set wildignore+=*DS_Store*,*.ipch
set wildignore+=*.gem
set wildignore+=*.png,*.jpg,*.gif,*.bmp,*.tga,*.pcx,*.ppm,*.img,*.iso
set wildignore+=*.so,*.swp,*.zip,*/.Trash/**,*.pdf,*.dmg,*/.rbenv/**
set wildignore+=*/.nx/**,*.app,*.git,.git
set wildignore+=*.wav,*.mp3,*.ogg,*.pcm
set wildignore+=*.mht,*.suo,*.sdf,*.jnlp
set wildignore+=*.chm,*.epub,*.pdf,*.mobi,*.ttf
set wildignore+=*.mp4,*.avi,*.flv,*.mov,*.mkv,*.swf,*.swc
set wildignore+=*.ppt,*.pptx,*.docx,*.xlt,*.xls,*.xlsx,*.odt,*.wps
set wildignore+=*.msi,*.crx,*.deb,*.vfd,*.apk,*.ipa,*.bin,*.msu
set wildignore+=*.gba,*.sfc,*.078,*.nds,*.smd,*.smc
set wildignore+=*.linux2,*.win32,*.darwin,*.freebsd,*.linux,*.android

let $GTAGSLABEL = 'native-pygments'
let $GTAGSCONF = '/home/jason/Downloads/build/share/gtags/gtags.conf'
