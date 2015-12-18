" Vim simple TeX syntax file
" Maintainer:	GI <gi1242+vim@nospam.com> (replace nospam with gmail)
" Created:	Tue 16 Dec 2014 03:45:10 PM IST
" Last Changed:	Tue 27 Oct 2015 09:53:46 AM EDT
" Version:	0.2
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
if !exists( 'b:is_sty' )
    let b:is_sty = exists( 'g:tex_is_sty' ) ? g:tex_is_sty :
		\	( expand( '%:e' ) =~? '\v(sty|cls)' ? 1 : 0 )
endif

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
" Generic commands
Tsy match texGenericCommand '\v\\[[:alpha:]@]+\*?'
	    \ nextgroup=texArgsNormNorm skipwhite skipempty

syn match texPreambleGenCommand contained '\v\\[[:alpha:]@]+\*?'
	    \ nextgroup=texArgsPreamble skipwhite skipempty

" Commands with special arguments.
let s:cmdlist = 'usepackage RequirePackage ProvidesPackage documentclass'
	    \ . ' input include subfile includegraphics setlength'
	    \ . ' eqref cref ref cite cites pageref label'
	    \ . ' bibliography bibliographystyle nocite'
	    \ . ' url email subjclass texttt'
	    \ . ( exists( 'g:tex_special_arg_commands' ) ?
		    \ g:tex_special_arg_commands : '' )
let s:regexp = substitute( s:cmdlist, '\v\s+', '|', 'g' )
exe 'Tsy match texSpecialArgCommands'
	    \ 'nextgroup=@texArgsSpclSpcl skipwhite skipempty'
	    \ '"\v\\%('.s:regexp.')>\*?"'

" Treat title specially (could be in preamble or document)
Tsy match texSpecialArgCommands
	    \ nextgroup=texArgsNormNorm skipwhite skipempty
	    \ '\v\\title>'

" Special commands. (Highlighted differently; but arguments are normal)
let s:cmdlist = 'tiny scriptsize footnotesize small normalsize large Large'
	    \ . ' LARGE huge Huge'
	    \ . ' text%(it|rm|md|up|sl) emph'
	    \ . ( exists( 'g:tex_special_commands' ) ? g:tex_special_commands : '')
let s:regexp = substitute( s:cmdlist, '\v\s+', '|', 'g' )
exe 'Tsy match texSpecialCommands'
	    \ 'nextgroup=texArgsNormNorm skipwhite skipempty'
	    \ '"\v\\%('.s:regexp.')>\*?"'

" Section commands
let s:cmdlist = 'part chapter section subsection subsubsection paragraph subparagraph'
	    \ . ( exists( 'g:tex_section_commands' ) ? g:tex_section_commands : '')
let s:regexp = substitute( s:cmdlist, '\v\s+', '|', 'g' )
exe 'Tsy match texSectionCommands'
	    \ 'nextgroup=texArgsNormNorm skipwhite skipempty'
	    \ '"\v\\%('.s:regexp.')>\*?"'


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
	    \ matchgroup=texArgDelims start='{'
	    \ end='\v%(\\end\{\a+\*?)@<!}'
	    \ nextgroup=texArgsNormNorm skipwhite skipempty
	    \ contains=@TopSpell

" Optional argument is special, normal argument is regular text.
syn cluster texArgsSpclNorm contains=texArgsSpclNormOpt,texArgsSpclNormReq
syn region texArgsSpclNormOpt contained
	    \ matchgroup=texArgDelims start='\[' end='\]'
	    \ nextgroup=@texArgsSpclNorm skipwhite skipempty
	    \ contains=@TopNoSpell,texArgSep
syn region texArgsSpclNormReq contained transparent
	    \ matchgroup=texArgDelims start='{'
	    \ end='\v%(\\end\{\a+\*?)@<!}'
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
	    \ matchgroup=texArgDelims start='{'
	    \ end='\v%(\\end\{\a+\*?)@<!}'
	    \ contains=@TopNoSpell,texArgSep
	    \ nextgroup=@texArgsSpclSpcl skipwhite skipempty

" Arguments to preamble commands. (Don't color, mark delimiters, don't spell).
syn region texArgsPreamble contained
	    \ matchgroup=texArgDelims start='\[' end='\]'
	    \ nextgroup=texArgsPreamble skipwhite skipempty
	    \ contains=@texArgsPreambleAllowed
" Allow unmatched environments in these arguments so that
" \newcommand{\be}{\begin{equation}} etc. work. No \end funny-ness for end
" pattern, here since unmatched environments are allowed.
syn region texArgsPreamble contained
	    \ matchgroup=texArgDelims start='{'
	    \ end='}'
	    \ nextgroup=texArgsPreamble skipwhite skipempty
	    \ contains=@texArgsPreambleAllowed
syn cluster texArgsPreambleAllowed
	    \ add=@texPreambleCommands,texBraceError,texTextBrace,texComment
	    \ add=texMath,texSpecialChars,texDimen,texTokens,texEnvName

" Generic arguments of math commands
syn region texArgsMathGen contained transparent
	    \ matchgroup=texArgDelims start='\[' end='\]'
	    \ nextgroup=texArgsMathGen skipwhite skipempty
	    \ contains=@texAllowedInMath,texDimen
syn region texArgsMathGen contained transparent
	    \ matchgroup=texArgDelims start='{'
	    \ end='\v%(\\end\{\a+\*?)@<!}'
	    \ nextgroup=texArgsMathGen skipwhite skipempty
	    \ contains=@texAllowedInMath,texDimen

" Arguments of math commands with a text required argument.
syn cluster texArgsMathText contains=texArgsMathTextOpt,texArgsMathTextReq
syn region texArgsMathTextOpt contained
	    \ matchgroup=texArgDelims start='\[' end='\]'
	    \ nextgroup=@texArgsMathText skipwhite skipempty
	    \ contains=@TopNoSpell,texArgSep
syn region texArgsMathTextReq contained
	    \ matchgroup=texArgDelims start='{'
	    \ end='\v%(\\end\{\a+\*?)@<!}'
	    \ nextgroup=@texArgsMathText skipwhite skipempty
	    \ contains=TOP


" {{{1 Preamble
" Should be defined after commands
if b:is_sty
    " Whole document is preamble, but don't fold it.
    Tsy region texPreamble transparent start='\v%^' end='\v%$'
	    \ contains=@texPreambleStuff
else
    Tsy region texPreamble transparent fold
	    \ start='\v%(\\documentclass)@=' end='\v(\\begin\{document\})@='
	    \ contains=@texPreambleStuff
endif

syn cluster texPreambleStuff contains=texComment,@texPreambleCommands
syn cluster texPreambleCommands contains=texPreambleGenCommand,texSpecialArgCommands,texMathParenCommand

" Math {{{1
" Cluster with the same name as the default tex.vim syntax file, so that it
" should look OK when included.
syn cluster texMathZoneGroup contains=@texAllowedInMath

Tsy region texMath start='\$' end='\$' contains=@texAllowedInMath
Tsy region texMath start='\$\$' end='\$\$' contains=@texAllowedInMath
Tsy region texMath start='\\(' end='\\)' contains=@texAllowedInMath
Tsy region texMath start='\\\[' end='\\\]' contains=@texAllowedInMath

let s:cmdlist = 'texMathBrace,texSpecialChars,texMathCommand,texMathEnv,'
	    \ . 'texMathScripts,texComment,texEnvName,texEnvError,'
	    \ . 'texBraceError,texMathParen,texMathParenCommand'
exe 'syn cluster texAllowedInMath contains=' . s:cmdlist
exe 'syn cluster texMathNoBraceError add='.s:cmdlist 'remove=texBraceError'

syn region texMathBrace contained transparent start='{' end='}'
	    \ contains=@texMathNoBraceError

" Math sub/super scripts
syn match texMathScripts contained '[_^]'
	    \ nextgroup=texMathScriptArg skipwhite skipempty
syn region texMathScriptArg contained transparent
	    \ matchgroup=texMathScripts start='{'
	    \ end='\v%(\\end\{\a+\*?)@<!}'
	    \ contains=@texAllowedInMath

" Generic math commands
syn match texMathCommand contained '\v\\[[:alpha:]@]+\*?'
	    \ nextgroup=texArgsMathGen

" Math mode commands with a text argument.
let s:cmdlist = 'makebox mbox framebox fbox raisebox parbox'
	    \ . ' text%(rm|tt|md|up|sl|bf|it)? operatorname'
	    \ . ( exists( 'g:tex_math_text_commands' ) ?
		    \ g:tex_math_text_commands : '' )
let s:regexp = substitute( s:cmdlist, '\v\s+', '|', 'g' )
exe 'syn match texMathCommand contained'
	    \ 'nextgroup=@texArgsMathText skipwhite skipempty'
	    \ '"\v\\%('.s:regexp.')>\*?"'

" Parenthesis.
let s:cmdlist = '[bB]igg?[lr]? left right'
let s:regexp = '\v\\%(' . substitute( s:cmdlist, '\v\s+', '|', 'g' )
	    \ . ')>'
	    "\ . ')\s*%([.()|[\]]|\\[{|}])'
exe 'Tsy match texMathParenCommand contained' "'".s:regexp."'"

syn region texMathParen transparent contained matchgroup=texEnvName
	    \ start='\v\\left\s*%([.(|[]|\\[{|])'
	    \ end='\v\\right\s*%([.)|\]]|\\[}|])'
	    \ contains=@texAllowedInMath

" Environments {{{1
" Generic environments. Arguments are treated as texArgsSpclSpcl
Tsy region texEnv transparent
	    \ matchgroup=texCommand
	    \ start='\v\\begin\{%(\z(\a+\*?)\})@='
	    \ end='\v\\end\{%(\z1\})@='
	    \ contains=@TopSpell

" \zs, \ze don't seem to work for this.
"Tsy match texEnvName '\v\\begin\{\zs\a+\*?\ze\}' nextgroup=texEnvCloseBrace
Tsy match texEnvName '\v%(\\%(begin|end)\{)@<=\a+\*?\}@='
	    \ nextgroup=texEnvCloseBrace
syn match texEnvCloseBrace '}' contained

Tsy region texArgsEnvReq
	    \ matchgroup=texArgDelims
	    \ start='\v%(\\begin\{\a+\*?\}\s*)@<=\{'
	    \ end='\v%(\\end\{\a+\*?)@<!}'
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
let s:regexp = '\v(\\begin\{%('
	    \ . substitute( s:cmdlist, '\v\s+', '|', 'g' )
	    \ . ')\*?\}\s*)@<='
exe 'Tsy region texArgsEnvNormReq transparent matchgroup=texArgDelims'
	    \ 'start="'.s:regexp.'\{"' 'end="}"'
	    \ 'contains=@TopSpell'
	    \ 'nextgroup=@texArgsNormNorm skipwhite skipempty'
exe 'Tsy region texArgsEnvNormOpt transparent matchgroup=texArgDelims'
	    \ 'start="'.s:regexp.'\["' 'end="]"'
	    \ 'contains=@TopSpell'
	    \ 'nextgroup=@texArgsNormNorm skipwhite skipempty'

" Math environments
let s:math_env_names = 'align alignat displaymath eqnarray equation gather'
	    \ . ' IEEEeqnarray multline subequations xalignat xxalignat'
	    \ . ( exists( 'g:tex_math_envs' ) ? ' '.g:tex_math_envs : '')
let s:regexp = '\v\\begin\{\z(%('
	    \ . substitute( s:math_env_names, '\v\s+', '|', 'g' )
	    \ . ')\*?)\}'
exe 'Tsy region texEnvDispMath matchgroup=texMath'
	    \ 'start="'.s:regexp.'" end="\v\\end\{\z1\}"'
	    \ 'contains=@texAllowedInMath'

syn region texMathEnv transparent contained
	    \ matchgroup=texCommand
	    \ start='\v\\begin\{%(\z(\a+\*?)\})@='
	    \ end='\v\\end\{%(\z1\})@='
	    \ contains=@texAllowedInMath

" Unmatched end environments
Tsy match texEnvError '\\end\>'

" Document will likely be longer than sync minlines; don't match a missing end
" as an error.
Tsy match texEnvEndDoc '\v\\end\{document\}'

" Misc TeX Constructs. {{{1
" TeX dimensions
Tsy match texDimen '\v<-?%(\.[0-9]+|([0-9]+(\.[0-9]+)?))%(pt|pc|bp|in|cm|mm|dd|cc|sp|ex|em)>'
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

Tsy region texVerb
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
"Tsy region texFrontmatterFold transparent fold keepend
"	    \ start='\v\\frontmattter' end='\v\n%(\s*\\mainmatter)@='

Tsy region texFrontmatterFold   transparent fold keepend
	    \ start='\v%(\\begin\{document\}.*$\n)@<=^'
	    \ end='\v\%endfrontmatter'
	    \ end='\v\n%(\s*\\end\{document\})@='
	    \ end='\v\n%(\s*%(\\chapter|\%startchapter)>)@='
	    \ end='\v\n%(\s*%(\\section|\%startsection)>)@='
	    \ end='\v\n%(\s*\\bibliography%(style)?>)@='
	    \ end='\v\n%(\s*\\begin\{%(thebibliography|bibdiv)\})@='

Tsy region texChapterFold   transparent fold keepend
	    \ start='\v%(\\chapter|\%startchapter)>'
	    \ end='\v\n%(\s*\\end\{document\})@='
	    \ end='\v\n%(\s*%(\\chapter|\%startchapter)>)@='
	    \ end='%endchapter'
	    \ end='\v\n%(\s*\\bibliography%(style)?>)@='
	    \ end='\v\n%(\s*\\begin\{%(thebibliography|bibdiv)\})@='

Tsy region texSectionFold   transparent fold keepend
	    \ start='\v%(\\section|\%startsection)>'
	    \ end='\v\n%(\s*\\end\{document\})@='
	    \ end='\v\n%(\s*%(\\chapter|\%startchapter)>)@='
	    \ end='%endchapter'
	    \ end='\v\n%(\s*%(\\section|\%startsection)>)@='
	    \ end='%endsection'
	    \ end='\v\n%(\s*\\bibliography%(style)?)@='
	    \ end='\v\n%(\s*\\begin\{%(thebibliography|bibdiv)\})@='

Tsy region texSubsectionFold transparent fold keepend
	    \ start='\v%(\\subsection|\%startsubsection)>'
	    \ end='\v\n%(\s*\\end\{document\})@='
	    \ end='\v\n%(\s*%(\\chapter|\%startchapter)>)@='
	    \ end='%endchapter'
	    \ end='\v\n%(\s*%(\\%(sub)?section|\%start%(sub)?section)>)@='
	    \ end='\v\%end%(sub)?section'
	    \ end='\v\n%(\s*\\bibliography%(style)?)@='
	    \ end='\v\n%(\s*\\begin\{%(thebibliography|bibdiv)\})@='

Tsy region texSubsubsectionFold transparent fold keepend
	    \ start='\v%(\\subsubsection|\%startsubsubsection)>'
	    \ end='\v\n%(\s*\\end\{document\})@='
	    \ end='\v\n%(\s*%(\\chapter|\%startchapter)>)@='
	    \ end='%endchapter'
	    \ end='\v\n%(\s*%(\\%(sub)*section|\%start%(sub)*section)>)@='
	    \ end='\v\%end%(sub)*section'
	    \ end='\v\n%(\s*\\bibliography%(style)?)@='
	    \ end='\v\n%(\s*\\begin\{%(thebibliography|bibdiv)\})@='

" BibTeX bibliography.
Tsy region texBibFold transparent fold keepend
	    \ start='\v\\bibliography%(style)?'
	    \ end='\v\n%(\s*\\end\{document\})@='
	    \ end='\v\n%(\s*%(\\chapter|\%startchapter)>)@='
	    \ end='%endchapter'
	    \ end='\v\n%(\s*%(\\%(sub)*section|\%start%(sub)*section)>)@='
	    \ end='\v\%end%(sub)*section'

syn region texBibitemFold fold containedin=texEnv
	    \ start='\v^\s*\\bib\{.*$'
	    \ end='\v^%(\s*\})'

" Fold environments (theorems, etc.)
let s:fold_envs = 'theorem lemma proposition corollary conjecture definition'
	    \ . ' remark example proof abstract figure'
	    \ . ' thebibliography biblist bibdiv'
	    \ . ( exists( 'g:tex_fold_envs' ) ? ' '.g:tex_fold_envs : '' )

let s:regexp = '\v\\begin\{\z(%('
	    \ . substitute( s:fold_envs, '\v\s+', '|', 'g' )
	    \ . ')\*?)\}'
exe 'Tsy region texEnvFold transparent fold keepend extend'
	    \ 'start="'.s:regexp.'" end="\v\\end\{\z1\}"'

" Comment markers. Only %{{{ and %}}} are supported. No number versions
Tsy region texCommentFold transparent fold keepend extend
	    \ start='\v^.*\%.*\{{3}[0-9]@!'
	    \ end='\v\%.*\}{3}[0-9]@!'

" Synchronization {{{1
"syn sync maxlines=200
syn sync minlines=50
"syn sync match texSync		grouphere NONE		'\v\\(sub)*section>'
syn sync match texSync		grouphere texEnv	'\v\\(sub)*section>'

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
hi def link texSpecialCommands	    Special
hi def link texSpecialArgCommands   texCommand
hi def link texGenericCommand	    texCommand

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
hi def link texMathParen	    Identifier
hi def link texMathParenCommand	    texMathParen
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

unlet s:cpo_save s:math_env_names s:regexp s:fold_envs s:cmdlist
