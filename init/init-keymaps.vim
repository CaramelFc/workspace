nnoremap J j
nnoremap K k
nnoremap L l
nnoremap H h
vnoremap J j
vnoremap K k
vnoremap L l
vnoremap H h
vnoremap <C-c> "*y
nnoremap <C-c> "*yy
nnoremap <C-v> <Esc>"*p
nnoremap <C-a> <s-^>
vnoremap <C-a> <s-^>
nnoremap <C-e> <s-$>
vnoremap <C-e> <s-$>
vnoremap <C-x> "*x
vnoremap ya y
vnoremap xa x
vnoremap yga <S-$>"*y
vnoremap xga <S-$>"*x

"vnoremap     <leader>cc  <S-$><Plug>NERDCommenterComment
nnoremap     <leader>fm :Autoformat<CR>
nnoremap     \q :tabc!<CR>
nnoremap     <c-n> :tabnew
nnoremap     <c-h> gT
nnoremap     <c-l> gt

"ctrlp
nnoremap     \ff :CtrlP<CR>
nnoremap     \fr :CtrlPMRUFiles<CR>

"nerdtree
nnoremap <silent> \nn :NERDTree<CR>
nnoremap <silent> \mm :NERDTree<CR>:q<CR>

"tagbar
nnoremap <silent> \to :Tagbar<CR>
nnoremap <silent> \tc :TagbarClose<CR>

"preview
nnoremap <silent> \gg :PreviewTag<CR>

"gutentags_plus
noremap <silent> <leader>gs :GscopeFind s <C-R><C-W><cr>

" {\n}
au FileType cpp inoremap {<CR> {}<ESC>i<ENTER><ESC>O
au FileType c inoremap {<CR> {}<ESC>i<ENTER><ESC>O
au FileType go inoremap {<CR> {}<ESC>i<ENTER><ESC>O
au FileType sh inoremap {<CR> {}<ESC>i<ENTER><ESC>O
