" Vim simple TeX syntax file
" Maintainer:	GI <gi1242+vim@nospam.com> (replace nospam with gmail)
" Created:	Tue 16 Dec 2014 03:45:10 PM IST
" Last Changed:	Fri 26 Dec 2014 10:28:25 PM IST
" Version:	0.1
"
" Description:
"   Highlight LaTeX documents without the ridiculous amount of complexity used
"   by the default tex.vim syntax file. See README.md for options.

" Load control {{{1
if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

" Keyword / sty settings. {{{1
" (La)TeX keywords: uses the characters 0-9,a-z,A-Z,192-255 only...
" but _ is the only one that causes problems.
" One may override this iskeyword setting by providing
" g:tex_isk
let &l:isk = exists( 'g:tex_isk' ) ? g:tex_isk : '@-@,48-57,a-z,A-Z,192-255'

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
Tsy match texCommand '\v\\%([[:alpha:]@]+)@='
	    \ nextgroup=texSpecialCommands,texGenericCommand

" Generic commands
syn match texGenericCommand contained '\v[[:alpha:]@]+\*?'
	    \ nextgroup=texArgsNormNorm skipwhite skipempty

" Special commands
let s:cmdlist = 
	    \ 'usepackage RequirePackage documentclass'
	    \ . ' input includegraphics setlength'
	    \ . ' eqref cref ref cite cites pageref label'
	    \ . ' bibliography bibliographystyle notcite'
	    \ . ' url email subjclass'
	    \ . ( exists( 'g:tex_special_commands' ) ? g:tex_special_commands : '')

exe 'syn keyword texSpecialCommands contained'
	    \ 'nextgroup=@texArgsSpclSpcl,texStarSpecial skipwhite skipempty'
	    \ s:cmdlist
syn match texStarSpecial contained '\*' nextgroup=@texArgsSpclSpcl skipwhite skipempty

" Section commands
let s:cmdlist = 'part chapter section subsection subsubsection paragraph subparagraph'
	    \ . ( exists( 'g:tex_section_commands' ) ? g:tex_section_commands : '')
let s:start_re = substitute( s:cmdlist, '\v\s+', '|', 'g' )
exe 'Tsy match texSectionCommands'
	    \ 'nextgroup=texArgsNormNorm skipwhite skipempty'
	    \ '"\v\\%('.s:start_re.')\*?"'


" {{{1 Command arguments

" Braces (do before command arguments)
Tsy match texBraceError '}'
Tsy region texTextBrace transparent start='{' end='}' contains=TOP,texBraceError

" Optional and required arguments are normal text.
syn region texArgsNormNorm contained transparent
	    \ matchgroup=texArgDelims start='\[' end='\]'
	    \ nextgroup=texArgsNormNorm skipwhite skipempty
	    \ contains=@TopSpell
syn region texArgsNormNorm contained transparent
	    \ matchgroup=texArgDelims start='{' end='}'
	    \ nextgroup=texArgsNormNorm skipwhite skipempty
	    \ contains=@TopSpell

" Optional argument is special, normal argument is regular text.
syn cluster texArgsSpclNorm contains=texArgsSpclNormOpt,texArgsSpclNormReq
syn region texArgsSpclNormOpt contained
	    \ matchgroup=texArgDelims start='\[' end='\]'
	    \ nextgroup=@texArgsSpclNorm skipwhite skipempty
	    \ contains=@TopNoSpell,texArgSep
syn region texArgsSpclNormReq contained transparent
	    \ matchgroup=texArgDelims start='{' end='}'
	    \ nextgroup=@texArgsSpclNorm skipwhite skipempty
	    \ contains=@TopSpell
syn match texArgSep contained '[,=]'

" Optional and required arguments are special (colored, no spell).
syn cluster texArgsSpclSpcl contains=texArgsSpclSpclOpt,texArgsSpclSpclReq
syn region texArgsSpclSpclOpt contained
	    \ matchgroup=texArgDelims start='\[' end='\]'
	    \ nextgroup=@texArgsSpclSpcl skipwhite skipempty
	    \ contains=@TopNoSpell,texArgSep
syn region texArgsSpclSpclReq contained
	    \ matchgroup=texArgDelims start='{' end='}'
	    \ contains=@TopNoSpell,texArgSep
	    \ nextgroup=@texArgsSpclSpcl skipwhite skipempty

" {{{1 Preamble
" Should be defined after commands
Tsy region texPreamble fold
	    \ start='\v%(\\documentclass)@=' end='\v(\\begin\{document\})@='
	    \ contains=@texPreambleStuff

syn cluster texPreambleStuff contains=texComment,texPreambleCommand

syn match texPreambleCommand contained '\v\\%([[:alpha:]@]+)@='
	    \ nextgroup=texPreambleGenCommand,texSpecialCommands

" Should be done before texSpecialCommands
syn match texPreambleGenCommand contained '\v[[:alpha:]@]+\*?'
	    \ nextgroup=texArgsPreamble skipwhite skipempty

" Don't color arguments, but mark delimiters. Don't spell.
syn region texArgsPreamble contained transparent
	    \ matchgroup=texArgDelims start='\[' end='\]'
	    \ nextgroup=texArgsPreamble skipwhite skipempty
	    \ contains=@texArgsPreambleAllowed
syn region texArgsPreamble contained transparent
	    \ matchgroup=texArgDelims start='{' end='}'
	    \ nextgroup=texArgsPreamble skipwhite skipempty
	    \ contains=@texArgsPreambleAllowed
syn cluster texArgsPreambleAllowed
	    \ add=texPreambleCommand,texBraceError,texTextBrace,texComment
	    \ add=texMath,texSpecialChars,texDimen,texEnvDispMath,texTokens

" Math {{{1
" Cluster with the same name as the default tex.vim syntax file, so that it
" should look OK when included.
syn cluster texMathZoneGroup contains=@texAllowedInMath

Tsy region texMath start='\$' end='\$' contains=@texAllowedInMath
Tsy region texMath start='\$\$' end='\$\$' contains=@texAllowedInMath
Tsy region texMath start='\\(' end='\\)' contains=@texAllowedInMath
Tsy region texMath start='\\\[' end='\\\]' contains=@texAllowedInMath

let s:cmdlist = 'texMathBrace,texSpecialChars,texMathCommand,texMathEnv,'
	    \ . 'texMathScripts,texComment,texEnvError,texBraceError'
exe 'syn cluster texAllowedInMath contains=' . s:cmdlist
exe 'syn cluster texMathNoBraceError add='.s:cmdlist 'remove=texBraceError'

syn region texMathBrace contained transparent start='{' end='}'
	    \ contains=@texMathNoBraceError

" Math sub/super scripts
syn match texMathScripts contained '[_^]'
	    \ nextgroup=texMathScriptArg skipwhite skipempty
syn region texMathScriptArg contained transparent
	    \ matchgroup=texMathScripts start='{' end='}'
	    \ contains=@texAllowedInMath


"
" Math commands with math arguments.
syn match texMathCommand contained '\v\\%([[:alpha:]@]+)@=' nextgroup=texMathCommands
syn match texMathCommands '\v[[:alpha:]@]+\*?' contained
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
	    \ nextgroup=@texMathTArgs,texStarMathText skipwhite skipempty
syn match texStarMathText contained '\*' nextgroup=@texMathTArgs skipwhite skipempty
syn cluster texMathTArgs contains=texArgsMathTextOpt,texArgsMathTextReq
syn region texArgsMathTextOpt contained
	    \ matchgroup=texArgDelims start='\[' end='\]'
	    \ nextgroup=@texMathTArgs skipwhite skipempty
	    \ contains=@TopNoSpell,texArgSep
syn region texArgsMathTextReq contained
	    \ matchgroup=texArgDelims start='{' end='}'
	    \ nextgroup=@texMathTArgs skipwhite skipempty
	    \ contains=TOP

" Environments {{{1
" Generic environments. Arguments are treated as texArgsSpclSpcl
Tsy region texEnv transparent
	    \ matchgroup=texCommand
	    \ start='\v\\begin\{%(\z(\a+\*?)\})@='
	    \ end='\v\\end\{%(\z1\})@='
	    \ contains=@TopSpell

" \zs, \ze don't seem to work for this.
"Tsy match texEnvName '\v\\begin\{\zs\a+\*?\ze\}' nextgroup=texEnvCloseBrace
Tsy match texEnvName '\v%(\\%(begin|end)\{)@<=\a+\*?\ze\}'
	    \ nextgroup=texEnvCloseBrace
syn match texEnvCloseBrace '}' contained

Tsy region texArgsEnvReq
	    \ matchgroup=texArgDelims
	    \ start='\v%(\\begin\{\a+\*?\}\s*)@<=\{' end='}'
	    \ contains=@TopNoSpell,texArgSep
	    \ nextgroup=@texArgsSpclSpcl skipwhite skipempty
Tsy region texArgsEnvOpt
	    \ matchgroup=texArgDelims
	    \ start='\v%(\\begin\{\a+\*?\})@<=\[' end=']'
	    \ contains=@TopNoSpell,texArgSep
	    \ nextgroup=@texArgsSpclSpcl skipwhite skipempty

" Theorem/proof type environments. Arguments are treated as texArgsNormNorm
let s:cmdlist = 'theorem lemma proposition corollary conjecture definition'
	    \ . ' remark example proof'
	    \ . ( exists( 'g:tex_thm_envs' ) ? ' '.g:tex_thm_envs : '')
let s:start_re = '\v(\\begin\{%('
	    \ . substitute( s:cmdlist, '\v\s+', '|', 'g' )
	    \ . ')\*?\}\s*)@<='
exe 'Tsy region texArgsEnvNormReq transparent matchgroup=texArgDelims'
	    \ 'start="'.s:start_re.'\{"' 'end="}"'
	    \ 'contains=@TopSpell'
	    \ 'nextgroup=@texArgsNormNorm skipwhite skipempty'
exe 'Tsy region texArgsEnvNormOpt transparent matchgroup=texArgDelims'
	    \ 'start="'.s:start_re.'\["' 'end="]"'
	    \ 'contains=@TopSpell'
	    \ 'nextgroup=@texArgsNormNorm skipwhite skipempty'

" Math environments
let s:math_env_names = 'align alignat displaymath eqnarray equation gather'
	    \ . ' IEEEeqnarray multline subequations xalignat xxalignat'
	    \ . ( exists( 'g:tex_math_envs' ) ? ' '.g:tex_math_envs : '')
let s:start_re = '\v\\begin\{\z(%('
	    \ . substitute( s:math_env_names, '\v\s+', '|', 'g' )
	    \ . ')\*?)\}'
exe 'Tsy region texEnvDispMath matchgroup=texMath'
	    \ 'start="'.s:start_re.'" end="\v\\end\{\z1\}"'
	    \ 'contains=@texAllowedInMath'

syn region texMathEnv transparent contained
	    \ matchgroup=texMathEnvGroup
	    \ start='\v\\begin\{\z(\a+\*?)\}'
	    \ end='\v\\end\{\z1\}'
	    \ contains=@texAllowedInMath

" Unmatched end environments
Tsy match texEnvError '\\end\>'

" Document will likely be longer than sync minlines; don't match a missing end
" as an error.
Tsy match texEnvEndDoc '\v\\end\{document\}'

" Misc TeX Constructs. {{{1
" TeX dimensions
Tsy match texDimen '\v-?%(\.[0-9]+|([0-9]+(\.[0-9]+)?))%(pt|pc|bp|in|cm|mm|dd|cc|sp|ex|em)>'
"syn keyword texUnits contained pt pc bp in cm mm dd cc sp ex em

" TeX macro tokens
Tsy match texTokens contained '#[0-9]'

" TeX backslashed special characters
"Tsy match texSpecialChars /\v\c\\%(\\%(\[[0-9]\])?|[[:alpha:]@]%([[:alpha:]@])@!|[^[:alpha:]@])/
Tsy match texSpecialChars /\v\\%(\\%(\[[0-9]\])?|[$&%#{}_]|\s)/

" Abbreviations, so that we don't get them marked as spelling errors
" 2014-12-18: Adding transparent makes this ineffective.
"Tsy match texAbbrevs /\v\C<[0-9A-Z]*[A-Z][0-9A-Z]+>/

" Verb
"Tsy region texVerb start='\v(\\verb\*?)@<=\z([^a-zA-Z@])'	end='\z1'
Tsy region texVerb matchgroup=texCommand
	    \ start='\v\\verb\*?\z([^a-zA-Z@])' end='\z1'

Tsy region texVerb matchgroup=texCommand
	    \ start='\v\\begin\{\z(lstlistings|verbatim)}'
	    \ end='\v\\end\{\z1\}'

" {{{1 TeX Comments
Tsy match  texComment	'%.*$'
Tsy match  texComment	'%\s.*$' contains=@Spell
Tsy region texComment	 matchgroup=texComment fold
	    \ start='\\iffalse\>' end='\\else\>' end='\\fi\>'
	    \ contains=texComment,texNestedIf
syn region texNestedIf contained transparent
	    \ start='\v\\if%(f>)@!\w+>' skip='\\else\>' end='\\fi\>'
	    \ contains=texNestedIf

" {{{1 Folding

" Fold by sections / subsections
Tsy region texSectionFold   transparent fold keepend
	    \ start='\v%(%(\\begin\{document\}.*$\n)@<=^|\\section)'
	    \ end='\v\n%(\s*%(\\end\{document\}|\\section))@='
	    \ end='\v\n%(\s*(\\bibliographystyle|\\begin\{thebibliography\}))@='
	    \ end='%endsection'

Tsy region texSubsectionFold transparent fold keepend
	    \ start='\v\\subsection'
	    \ end='\v\n%(\s*%(\\end\{document\}|\\%(sub)?section))@='
	    \ end='\v\n%(\s*(\\bibliographystyle|\\begin\{thebibliography\}))@='
	    \ end='\v\%end%(sub)?section'

Tsy region texSubsubsectionFold transparent fold keepend
	    \ start='\v\\subsubsection'
	    \ end='\v\n%(\s*%(\\end\{document\}|\\%(sub)*section))@='
	    \ end='\v\n%(\s*(\\bibliographystyle|\\begin\{thebibliography\}))@='
	    \ end='\v\%end%(sub)*section'

" BibTeX bibliography.
Tsy region texBibFold transparent fold keepend
	    \ start='\v\\bibliographystyle'
	    \ end='\v\n%(\s*\\end\{document\})@='

" Fold environments (theorems, etc.)
let s:fold_envs = 'theorem lemma proposition corollary conjecture definition'
	    \ . ' remark example proof abstract figure thebibliography'
	    \ . ( exists( 'g:tex_fold_envs' ) ? ' '.g:tex_fold_envs : '' )

let s:start_re = '\v\\begin\{\z(%('
	    \ . substitute( s:fold_envs, '\v\s+', '|', 'g' )
	    \ . ')\*?)\}'
exe 'Tsy region texEnvFold transparent fold keepend extend'
	    \ 'start="'.s:start_re.'" end="\v\\end\{\z1\}"'

" Comment markers. Only %{{{{ and %}}}} are supported. No number versions
" Use four braces (instead of 3) to avoid confusion with existing fold
" markers.
Tsy region texCommentFold transparent fold keepend extend
	    \ start='\v^.*\%.*\{{4}'
	    \ end='\v\%.*\}{4}'

" Synchronization {{{1
"syn sync maxlines=200
syn sync minlines=50
syn sync match texSync		grouphere NONE		'\v\\(sub)*section>'

" Sync items from the official VIM syntax file. Matching one of these might
" break the end proof environment, since proofs can be quite long.
"syn sync match texSync		groupthere NONE		'\\end{abstract}'
"syn sync match texSync		groupthere NONE		'\\end{center}'
"syn sync match texSync		groupthere NONE		'\\end{description}'
"syn sync match texSync		groupthere NONE		'\\end{enumerate}'
"syn sync match texSync		groupthere NONE		'\\end{itemize}'
"syn sync match texSync		groupthere NONE		'\\end{table}'
"syn sync match texSync		groupthere NONE		'\\end{tabular}'

" End math zones.
"let math_end_re = '\v\\end\{%(' . join( math_env_names, '|' ) . ')\*?\}'
"exe 'syn sync match texSync groupthere NONE' "'".math_end_re."'"

" {{{1 Highlighting groups
hi def link texMath		    Type
hi def link texCommand		    Statement
hi def link texComment		    Comment

hi def link texSectionCommands	    PreProc
hi def link texSpecialCommands	    texCommand
hi def link texGenericCommand	    texCommand
hi def link texStarSpecial	    texSpecialCommands

hi def link texPreambleCommand	    texCommand
hi def link texPreambleGenCommand   texPreambleCommand

hi def link texSpecialChars	    Special
hi def link texArgSep		    Special
hi def link texDimen		    Constant
hi def link texTokens		    Identifier
hi def link texVerb		    PreProc

hi def link texArgDelims	    texCommand
hi def link texArgsSpclSpclOpt	    Constant
hi def link texArgsSpclSpclReq	    Special
hi def link texArgsSpclNormOpt	    texArgsSpclSpclOpt

hi def link texMathCommand	    texCommand
hi def link texMathCommands	    texCommand
hi def link texArgsMathTextOpt	    texArgsSpclSpclOpt
hi def link texArgsMathTextReq	    Normal
hi def link texStarMathText	    texMathCommand
hi def link texMathScripts	    Constant
hi def link texMathEnvGroup	    Identifier

hi def link texEnvName		    Identifier
hi def link texEnvCloseBrace	    texCommand
hi def link texEnvDispMath	    texMath
hi def link texArgsEnvReq	    texArgsSpclSpclReq
hi def link texArgsEnvOpt	    texArgsSpclSpclOpt

hi def link texBraceError	    Error
hi def link texEnvError		    Error
hi def link texEnvEndDoc	    texCommand

" {{{1 Cleanup
let   b:current_syntax = "tex"
let &cpo               = s:cpo_save

unlet s:cpo_save s:math_env_names s:start_re s:fold_envs s:cmdlist
