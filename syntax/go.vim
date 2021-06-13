"" hightlight operator of math
syn match cMathOperator display "[-+\*\%/=][ =]"
syn match cPointerOperator display "->\|\.\|\:\:"
syn match cLogicOperator display "[!<>]=\="
syn match cLogicOperator display "=="
syn match cBinaryOperator display "\(&\||\|\^\|<<\|>>\)=\="
syn match cBinaryOperator display "\~"

hi cMathOperator ctermfg=202 cterm=bold
hi cPointerOperator ctermfg=202 cterm=bold
hi cLogicOperator ctermfg=202 cterm=bold
hi cBinaryOperator ctermfg=202 cterm=bold

" highlight function

syn match cfun "\<[a-zA-Z_][a-zA-Z_0-9]*\>\s*("me=e-1
hi cfun ctermfg=blue

syn match import "import"
hi import ctermfg=red

syn match func "func"
hi func ctermfg=126
