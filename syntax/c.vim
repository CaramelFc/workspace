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

syn match template_type "\<[a-zA-Z_][a-zA-Z_0-9]*\><"me=e-1
hi template_type ctermfg=175

" highlight macrio
syn match cmacro "\<[A-Z_][A-Z_0-9]*\>\s*("me=e-1
hi cmacro ctermfg=124
syn match cmacro "\<[A-Z_][A-Z_0-9]*\>"
hi cmacro ctermfg=124

" highlight namespace
syn match cplusplusnamespace "\<[a-zA-Z_][a-zA-Z_0-9]*\::"me=e-2
hi cplusplusnamespace ctermfg=cyan

" highlight string
"syn match cstring "\".*\""
"hi cstring ctermfg=216

" highlight #error
syn match cerror "#error\s.*"
hi cerror ctermfg=124 cterm=bold

"syn match Comment "//.*"
"syn match Comment "/\*.*\*/"
"hi Comment ctermfg=14

