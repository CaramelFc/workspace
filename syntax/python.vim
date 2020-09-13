
"function NewPyHeader()
"    call setline(1, "#!/usr/bin/env python3")
"    normal G
"endfunction
"au BufNewFile *.py exec ":call NewPyHeader()"

" hightlight operator of math
hi cMathOperator ctermfg=202 cterm=bold
hi cPointerOperator ctermfg=202 cterm=bold
hi cLogicOperator ctermfg=202 cterm=bold
hi cBinaryOperator ctermfg=202 cterm=bold

syn match cMathOperator display "[-+\*\%/=]"
syn match cPointerOperator display "->\|\.\|\:\:"
syn match cLogicOperator display "[!<>]=\="
syn match cLogicOperator display "=="
syn match cBinaryOperator display "\(&\||\|\^\|<<\|>>\)=\="
syn match cBinaryOperator display "\~"

" highlight functions
syn match cfun "\<[a-zA-Z_][a-zA-Z_0-9]*\>\s*("me=e-1
hi cfun ctermfg=blue cterm=bold
