call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree', {'on': 'NERDTreeToggle'}
Plug 'scrooloose/nerdcommenter'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'Chiel92/vim-autoformat'
Plug 'w0ng/vim-hybrid'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'mhinz/vim-startify'
Plug 'easymotion/vim-easymotion'
Plug 'tpope/vim-surround'
Plug 'gcmt/wildfire.vim', {'for': ['cpp', 'cc', 'vim', 'python', 'sh', 'h', 'hpp']}
Plug 'solarnz/thrift.vim'
Plug 'heavenshell/vim-pydocstring', {'for': ['python']}
Plug 'fatih/vim-go'
Plug 'sonph/onehalf', { 'rtp': 'vim' }
Plug 'f-person/git-blame.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'sindrets/diffview.nvim'
Plug 'pseewald/vim-anyfold', {'for': ['cpp', 'cc', 'h', 'hpp', 'python']}
"轻量补全（路径/缓冲区词），替代 YCM，需要 neovim
if has('nvim')
	Plug 'hrsh7th/nvim-cmp'
	Plug 'hrsh7th/cmp-path'
	Plug 'hrsh7th/cmp-buffer'
endif
call plug#end()

"补全配置：C-n/C-p 选择，C-y 确认，C-e 取消；输入 ./ / ~ 弹路径
if has('nvim')
	lua << EOF
local ok, cmp = pcall(require, 'cmp')
if ok then
	vim.o.completeopt = 'menu,menuone,noselect'
	cmp.setup({
		mapping = cmp.mapping.preset.insert({
			['<C-n>'] = cmp.mapping.select_next_item(),
			['<C-p>'] = cmp.mapping.select_prev_item(),
			['<C-y>'] = cmp.mapping.confirm({ select = true }),
			['<C-e>'] = cmp.mapping.abort(),
		}),
		sources = cmp.config.sources({
			{ name = 'path' },
		}, {
			{ name = 'buffer', keyword_length = 3 },
		}),
	})
end
EOF
endif

"anyfold
au Filetype cpp,c,python AnyFoldActivate
set foldlevel=99


"git blame
let g:gitblame_enabled = 0

"pydoc
let g:pydocstring_doq_path = "doq"
nmap <silent> <C-_> <Plug>(pydocstring)
au FileType python nnoremap <leader>cc :Pydocstring<cr>
"vim-go
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_function_parameters = 1
let g:go_highlight_variable_declarations = 1
let g:go_highlight_variable_assignments = 1
"let g:go_gopls_enabled = 0

"colorscheme is like hybrid
colorscheme hybrid-self

highlight PMenu ctermfg=172 ctermbg=236 guifg=black guibg=darkgrey
highlight PMenuSel ctermfg=172 ctermbg=236 guifg=darkgrey guibg=black


"ctrlp config
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll|so|a|zip|tar|obj|o|git|tar\.gz|pyc|out|dep)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }

"autoformat config
let g:formatters_python = ['black']
let g:formatdef_prettyjson = '"python3 -m json.tool"'
let g:formatters_json = ['prettyjson']
"let g:formatter_yapf_style = "google"
"let g:autoformat_autoindent = 0
"let g:autoformat_retab = 0
"let g:autoformat_remove_trailing_spaces = 0

" undodir
let s:undodir = expand("~/.cache/undodir")
if !isdirectory(s:undodir)
silent! call mkdir(s:undodir, 'p')
endif

"vim-ariline config
if !exists('g:airline_symbols')
	let g:airline_symbols = {}
endif
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme = 'bubblegum'
"let g:airline_left_sep = '⮀'
"let g:airline_left_alt_sep = '⮁'
"let g:airline_right_sep = '⮂'
"let g:airline_right_alt_sep = '⮃'
"let g:airline_symbols.branch = '⭠'
"let g:airline_symbols.readonly = '⭤'
"let g:airline_symbols.linenr = '⭡'

"easy-motion
nmap <leader><leader>. <Plug>(easymotion-repeat)

"my aucmd
func HppHeader()
	call setline(1, "#pragma once")
endfunc
func NewPyHeader()
	call setline(1, "#!/usr/bin/env python3")
endfunc
func ModeExec(current_file)
	if filereadable(a:current_file)
		let cmd = "!chmod +x ".a:current_file
		silent exec cmd
	endif
endfunc


au BufNewFile *.h :call HppHeader()
au BufNewFile *.py call NewPyHeader()
"au VimLeave *.py :call ModeExec(expand("%:p"))
"au VimLeave *.sh :call ModeExec(expand("%:p"))
au BufWritePre * %s/\s\+$//e
