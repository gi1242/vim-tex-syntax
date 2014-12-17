" Vim simple TeX syntax file
" Maintainer:	GI <gi1242+vim@nospam.com> (replace nospam with gmail)
" Created:	Tue 16 Dec 2014 03:45:10 PM IST
" Last Changed:	Wed 17 Dec 2014 12:45:38 PM IST
" Version:	0.1
"
" Description:
"   Highlight LaTeX documents without the ridiculous amount of complexity used
"   by the default tex.vim syntax file.

" Load control {{{1
if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

" Debug {{{1
command! SynIDs :call s:synids()
function! s:synids()
    for id in synstack( line('.'), col('.') )
	echo synIDattr( id, 'name' )
    endfor
endfunction

" Spell {{{1
syn spell toplevel

" All top level groups should be added manually to these groups
syn cluster TopNoSpell	remove=@Spell
syn cluster TopSpell	add=@Spell

" Helper function to create top level syntax groups
function! s:syn_top( qargs, action, groupname, ... )
    exe 'syn cluster TopNoSpell add='.a:groupname
    exe 'syn cluster TopSpell add='.a:groupname
    exe 'syn' a:qargs
endfunction
command! -nargs=+ Tsy :call s:syn_top( <q-args>, <f-args> )

" {{{1 TeX Commands
" Leading backslash for commands. Do this first, so it can be overridden
Tsy match texCommand '\v\\' nextgroup=@texCommands
syn cluster texCommands
	    \ contains=texSectionCommands,texSpecialCommands,texGenericCommand

" Generic commands {{{2
syn match texGenericCommand contained '\v[a-zA-Z@]+\*?'
	    \ nextgroup=texArgsGeneric skipwhite skipempty

" Highlight spelling in arguments. Don't color arguments, but mark delimiters.
syn region texArgsGeneric contained transparent
	    \ matchgroup=texArgDelims start='\[' end='\]'
	    \ nextgroup=texArgsGeneric skipwhite skipempty
	    \ contains=@TopSpell,texTokens
syn region texArgsGeneric contained transparent
	    \ matchgroup=texArgDelims start='{' end='}'
	    \ nextgroup=texArgsGeneric skipwhite skipempty
	    \ contains=@TopSpell,texTokens


" Section commands {{{2
syn keyword texSectionCommands contained
	    \ nextgroup=texStarSection,texArgsSection
	    \ skipwhite skipempty
	    \ part chapter section subsection subsubsection paragraph subparagraph

" Section command arguments. (Spell checked, highlighted as PreProc)
syn match texStarSection contained '\*'
	    \ nextgroup=texArgsSection skipwhite skipempty
syn region texArgsSection contained
	    \ matchgroup=texArgDelims start='\[' end='\]'
	    \ nextgroup=texArgsSection skipwhite skipempty
	    \ contains=@TopSpell
syn region texArgsSection contained
	    \ matchgroup=texArgDelims start='{' end='}'
	    \ nextgroup=texArgsSection skipwhite skipempty
	    \ contains=@TopSpell

" Special commands {{{2
syn keyword texSpecialCommands contained
	    \ nextgroup=@texArgsSpecial,texStarSpecial skipwhite skipempty
	    \ usepackage RequirePackage documentclass
	    \ newcommand renewcommand providecommand newenvironment renewenvironment
	    \ includegraphics setlength eqref ref cite cites label

" Color and don't spell arguments for Special commands
syn match texStarSpecial contained '\*' nextgroup=@texArgsSpecial skipwhite skipempty
syn cluster texArgsSpecial contains=texArgsSpecialOpt,texArgsSpecialReq
syn region texArgsSpecialOpt contained matchgroup=texArgDelims
	    \ start='\[' end='\]'
	    \ nextgroup=@texArgsSpecial skipwhite skipempty
	    \ contains=@TopNoSpell,texArgSep
syn region texArgsSpecialReq contained matchgroup=texArgDelims
	    \ start='{' end='}'
	    \ contains=@TopNoSpell,texArgSep
	    \ nextgroup=@texArgsSpecial skipwhite skipempty

" Math {{{1
Tsy region texMath start='\$' end='\$' contains=@texAllowedInMath
Tsy region texMath start='\$\$' end='\$\$' contains=@texAllowedInMath
Tsy region texMath start='\\(' end='\\)' contains=@texAllowedInMath

syn cluster texAllowedInMath
	    \ contains=texSpecialChars,texMathCommand,texMathEnv,texComment

" Math commands with math arguments.
syn match texMathCommand contained '\\' nextgroup=texMathCommands
syn match texMathCommands '\v[a-zA-Z]+\*?' contained
	    \ nextgroup=texMathMArg skipwhite skipempty
syn region texMathMArg contained transparent
	    \ matchgroup=texArgDelims start='\[' end='\]'
	    \ nextgroup=texMathMArg skipwhite skipempty
	    \ contains=@texAllowedInMath,texDimen
syn region texMathMArg contained transparent
	    \ matchgroup=texArgDelims start='{' end='}'
	    \ nextgroup=texMathMArg skipwhite skipempty
	    \ contains=@texAllowedInMath,texDimen

syn keyword texMathCommands contained
	    \ text textit textbf parbox raisebox mbox operatorname
	    \ nextgroup=@texMathTArgs,texMathTStar skipwhite skipempty
syn match texMathTStar contained '\*' nextgroup=@texMathTArgs skipwhite skipempty
syn cluster texMathTArgs contains=texMathTOptArg,texMathTRegArg
syn region texMathTOptArg contained
	    \ matchgroup=texArgDelims start='\[' end='\]'
	    \ nextgroup=@texMathTArgs skipwhite skipempty
	    \ contains=@TopNoSpell,texArgSep
syn region texMathTRegArg contained
	    \ matchgroup=texArgDelims start='{' end='}'
	    \ nextgroup=@texMathTArgs skipwhite skipempty
	    \ contains=TOP

" Environments {{{1
Tsy region texEnv transparent
	    \ matchgroup=texArgsPreProcReq
	    \ start='\v\\begin\{\z([a-zA-Z]+\*?)\}'
	    \ end='\v\\end\{\z1\}'
	    \ contains=@TopSpell

Tsy region texArgsEnvReq
	    \ matchgroup=texArgDelims
	    \ start='\v%(\\begin\{[a-zA-Z]+\*?\}\s*)@<=\{' end='}'
	    \ contains=@TopNoSpell,texArgSep
	    \ nextgroup=@texArgsSpecial skipwhite skipempty
Tsy region texArgsEnvOpt
	    \ matchgroup=texArgDelims
	    \ start='\v%(\\begin\{[a-zA-Z]+\*?\})@<=\[' end=']'
	    \ contains=@TopNoSpell,texArgSep
	    \ nextgroup=@texArgsSpecial skipwhite skipempty

" Math environments
let s:math_env_names = []
command! -nargs=+ MathEnv let s:math_env_names += [<f-args>]
MathEnv align alignat displaymath eqnarray equation gather IEEEeqnarray
	    \ multline subequations xalignat xxalignat

let start_re = '\v\\begin\{\z(%(' . join( s:math_env_names, '|' ) . ')\*?)\}'
exe 'Tsy region texEnvMath matchgroup=texMath'
	    \ 'start="'.start_re.'" end="\v\\end\{\z1\}" contains=@texAllowedInMath'

syn region texMathEnv transparent contained
	    \ matchgroup=texArgsPreProcReq
	    \ start='\v\\begin\{\z([a-zA-Z]+\*?)\}'
	    \ end='\v\\end\{\z1\}'
	    \ contains=@texAllowedInMath

"Tsy match texBegin '\\begin' nextgroup=texEnvDelimStart
"syn match texEnvDelimStart contained '{' nextgroup=texEnvStart
"syn region texEnvStart matchgroup=texArgsSpecialReq transparent
"	    \ start='\v\z([a-zA-Z]+\*?)' end='\v\\end\{\zs\z1\ze\}'
"	    \ nextgroup=texEnvDelimEnd
"syn match texEnvDelimEnd contained '}'
"
"hi def link texBegin texCommand
"hi def link texEnvDelimStart texArgDelims
"hi def link texEnvDelimEnd texArgDelims


" Misc TeX Constructs. {{{1
" {{{2 Misc TeX dimensions
Tsy match texDimen '\v-?%(\.[0-9]+|([0-9]+(\.[0-9]+)?))%(pt|pc|bp|in|cm|mm|dd|cc|sp|ex|em)>'
"syn keyword texUnits contained pt pc bp in cm mm dd cc sp ex em

" {{{2 TeX macro tokens
Tsy match texTokenError '#[0-9]'
syn match texTokens contained '#[0-9]'

" TeX backslashed special characters
Tsy match texSpecialChars '\v\\%(\\%(\[[0-9]\])?|[$&#\'":`]|[ijv]>)'

" {{{1 TeX Comments
Tsy match  texComment	'%.*$' contains=@Spell
Tsy region texComment	start='\\iffalse\>'	end='\\else\>'  end='\\fi\>' contains=texComment,texNestedIf matchgroup=texComment
syn region texNestedIf contained transparent start='\\if\%(false\|true\)\@!\w\{2,}' skip='\\else\>' end='\\fi\>' contains=texNestedIf


" Synchronization {{{1
syn sync fromstart

" {{{1 Highlighting groups
hi def link texMath		    Type
hi def link texCommand		    Statement

hi def link texSectionCommands	    texCommand
hi def link texSpecialCommands	    texCommand
hi def link texGenericCommand	    texCommand
hi def link texPStar		    texSectionCommands
hi def link texStarSpecial		    texSpecialCommands

hi def link texArgSep		    Special
hi def link texDimen		    Number
hi def link texTokens		    Type
hi def link texTokenError	    Error
hi def link texSpecialChars	    Special

hi def link texArgDelims	    Special
hi def link texArgsSpecialOpt		    Constant
hi def link texArgsSpecialReq		    Type
hi def link texArgsSectionOpt		    texArgsSpecialOpt
hi def link texArgsPreProcReq		    PreProc

hi def link texStarSection	texSectionCommands
hi def link texArgsSection	PreProc


hi def link texMathCommand	    texCommand
hi def link texMathCommands	    texCommand
hi def link texMathTOptArg	    texArgsSpecialOpt
hi def link texMathTRegArg	    Normal
hi def link texMathTStar	    texMathCommand

hi def link texEnvMath  texMath
hi def link texArgsEnvReq texArgsSpecialReq
hi def link texArgsEnvOpt texArgsSpecialOpt



hi def link texComment		    Comment

" {{{1 Cleanup
let   b:current_syntax = "tex"
let &cpo               = s:cpo_save

