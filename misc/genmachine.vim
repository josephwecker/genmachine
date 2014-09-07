" Vim syntax file
" Language:        genmachine-spec
" Maintainer:      Joseph Wecker
" Latest Revision: 2011-8-15
" License:         None, Public Domain
"
" genmachine mode for (g)vim, more or less from scratch.
"
" 
" TODO:
"

if version < 600
	syntax clear
elseif exists("b:current_syntax")
	finish
endif

set ambiwidth=double
map! -> ￫
map! <- ￩
map! \- ⌞
map! -/ ⌟
map! /null ⌀
map! /alpha α
map! /any ɛ

"syn match   gmNormalRow   /^\s*| .*$/ contains=gmNStartCond

syn match   gmState       /:[^ \|]\+/
syn match   gmSpecialOps  /->\|￫\|<-\|￩\|\\-\|⌞\|-\/\|⌟\|<</

syn region  gmRange       start=/\[/ end=/\]/ skip=/\\./ keepend contains=gmSpecMetas,gmMetachars,gmRangeDelims
syn match   gmSpecMetas   /\\s\|\\n/ contained
syn match   gmMetachars   /\\t\|\\r\|\\f\|\\b\|\\a\|\\e\|\\\[\|\\\]\|\\\\/ contained
syn match   gmRangeDelims /\\\@!\[\|\\\@!]/ contained
syn match   gmRange       /\/any\|ɛ/

syn keyword gmSpecialVars s c col row T F
syn match   gmSpecialVars /\/alpha\|α\|\/null\|⌀/

"syn region  gmNStartCond  start=/| / end=/|/me=e-1 skip=/|[^ ]/ contained nextgroup=gmNInput contains=gmDelim,gmState,gmSpecState
"syn region  gmNInput      start=/| / end=/|/me=e-1 skip=/|[^ ]/ contained nextgroup=gmNAcc contains=gmDelim,gmRange,gmCondPhrase
"syn region  gmNAcc        start=/| / end=/|/me=e-1 skip=/|[^ ]/ contained nextgroup=gmNCode contains=gmDelim,gmAccDiscard,gmAccum
"syn region  gmNCode       start=/| / end=/|/me=e-1 skip=/|[^ ]/ contained nextgroup=gmNTransition contains=gmDelim,gmGlobals,gmOperators,gmSpecialVars
"syn region  gmNTransition start=/| / end=/|/me=e-1 skip=/|[^ ]/ contained nextgroup=gmEndComment contains=gmDelim,gmState,gmReturn,gmCall

"syn match   gmFollowRow   /^\s*: .*$/ contains=gmFStartCond
"syn region  gmFStartCond  start=/: / end=/:/me=e-1 skip=/:[^ ]/ contained nextgroup=gmFInput contains=gmDelim,gmState,gmSpecState
"syn region  gmFInput      start=/: / end=/:/me=e-1 skip=/:[^ ]/ contained nextgroup=gmFAcc contains=gmDelim,gmRange,gmCondPhrase
"syn region  gmFAcc        start=/: / end=/:/me=e-1 skip=/:[^ ]/ contained nextgroup=gmFCode contains=gmDelim,gmAccDiscard,gmAccum
"syn region  gmFCode       start=/: / end=/:/me=e-1 skip=/:[^ ]/ contained nextgroup=gmFTransition contains=gmDelim,gmGlobals,gmOperators,gmSpecialVars
"syn region  gmFTransition start=/: / end=/:/me=e-1 skip=/:[^ ]/ contained nextgroup=gmEndComment contains=gmDelim,gmState,gmReturn,gmCall

syn match   gmDelim       /[|;,{}=()]/
"syn match   gmOperators   /[=<>+]\+/ contained contains=gmSpecOps
"syn match   gmSpecOps     /<<</ contained
"syn match   gmSpecState   /\s*{[^}]\+}\s*/ contained
"syn match   gmState       /\s*:[^ )({}]\+\s*/ contained
"syn match   gmGlobals     /\$\w\+/ contained

"syn region  gmRange       start=/\[/ end=/\]/ skip=/\\./ keepend contained contains=gmSpecMetas,gmMetachars,gmRangeDelims
"syn match   gmSpecMetas   /\\s\|\\n/ contained
"syn match   gmMetachars   /\\t\|\\r\|\\f\|\\b\|\\a\|\\e\|\\\[\|\\\]\|\\\\/ contained
"syn match   gmRangeDelims /\\\@!\[\|\\\@!]/ contained
"syn match   gmRange       /\./ contained
"syn match   gmCondPhrase  /{[^}]\+}/ contained contains=gmCond,gmOperators,gmGlobals "TODO: contains operators, numbers, etc. etc.
"syn match   gmCond        /[{}]/ contained

"syn match   gmAccDiscard  /<</ contained
"syn match   gmAccum       /[a-zA-Z_][a-zA-Z0-9_]*<</ contained contains=gmOperators

"syn keyword gmSpecialVars p s contained

"syn match   gmReturn      /<[^>]*>/ contained
"syn match   gmCall        /[a-zA-Z_][a-zA-Z0-9_]*([^)]*)/ contained contains=gmState

"syn match   gmEndComment  /.*$/ contained contains=gmDelim

syn match   gmComment     /^\s*[^|:].*$/

"hi def link gmEndComment  Comment
"hi def link gmNStartCond  Label
hi def link gmDelim       Operator
hi def link gmState       Identifier
hi def link gmRange       Character
hi def link gmSpecMetas   SpecialChar
hi def link gmMetachars   String
"hi def link gmCond        Conditional
"hi def link gmCondPhrase  Identifier
"hi def link gmAccDiscard  Repeat
"hi def link gmAccum       Identifier
hi def link gmSpecialOps  Operator
hi def link gmOperators   Operator
"hi def link gmGlobals     Typedef
"hi def link gmSpecOps     Constant
hi def link gmSpecialVars Keyword
hi def link gmNCode       Identifier
hi def link gmFCode       Identifier
hi def link gmReturn      PreProc
hi def link gmCall        Function
hi def link gmSpecState   Macro
hi def link gmComment     Comment

let b:current_syntax = "genmachine"
