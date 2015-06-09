" Vim simple TeX syntax file
" Maintainer:	GI <gi1242+vim@nospam.com> (replace nospam with gmail)
" Created:	Tue 16 Dec 2014 03:45:10 PM IST
" Last Changed:	Wed 20 May 2015 08:07:22 PM EDT
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
let s:cmdlist = 'usepackage RequirePackage documentclass'
	    \ . ' input includegraphics setlength'
	    \ . ' eqref cref ref cite cites pageref label'
	    \ . ' bibliography bibliographystyle nocite'
	    \ . ' url email subjclass texttt'
	    \ . ( exists( 'g:tex_special_arg_commands' ) ?
		    \ g:tex_special_arg_commands : '' )
let s:regexp = substitute( s:cmdlist, '\v\s+', '|', 'g' )
exe 'Tsy match texSpecialArgCommands contained'
	    \ 'nextgroup=@texArgsSpclSpcl skipwhite skipempty'
	    \ '"\v\\%('.s:regexp.')>\*?"'

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

" Arguments to preamble commands. (Don't color, mark delimiters, don't spell).
syn region texArgsPreamble contained
	    \ matchgroup=texArgDelims start='\[' end='\]'
	    \ nextgroup=texArgsPreamble skipwhite skipempty
	    \ contains=@texArgsPreambleAllowed
syn region texArgsPreamble contained
	    \ matchgroup=texArgDelims start='{' end='}'
	    \ nextgroup=texArgsPreamble skipwhite skipempty
	    \ contains=@texArgsPreambleAllowed
syn cluster texArgsPreambleAllowed
	    \ add=@texPreambleCommands,texBraceError,texTextBrace,texComment
	    \ add=texMath,texSpecialChars,texDimen,texEnvDispMath,texTokens

" Generic arguments of math commands
syn region texArgsMathGen contained transparent
	    \ matchgroup=texArgDelims start='\[' end='\]'
	    \ nextgroup=texArgsMathGen skipwhite skipempty
	    \ contains=@texAllowedInMath,texDimen
syn region texArgsMathGen contained transparent
	    \ matchgroup=texArgDelims start='{' end='}'
	    \ nextgroup=texArgsMathGen skipwhite skipempty
	    \ contains=@texAllowedInMath,texDimen

" Arguments of math commands with a text required argument.
syn cluster texArgsMathText contains=texArgsMathTextOpt,texArgsMathTextReq
syn region texArgsMathTextOpt contained
	    \ matchgroup=texArgDelims start='\[' end='\]'
	    \ nextgroup=@texArgsMathText skipwhite skipempty
	    \ contains=@TopNoSpell,texArgSep
syn region texArgsMathTextReq contained
	    \ matchgroup=texArgDelims start='{' end='}'
	    \ nextgroup=@texArgsMathText skipwhite skipempty
	    \ contains=TOP


" {{{1 Preamble
" Should be defined after commands
Tsy region texPreamble transparent fold
	    \ start='\v%(\\documentclass)@=' end='\v(\\begin\{document\})@='
	    \ contains=@texPreambleStuff

syn cluster texPreambleStuff contains=texComment,@texPreambleCommands
syn cluster texPreambleCommands contains=texPreambleGenCommand,texSpecialArgCommands

" Math {{{1
" Cluster with the same name as the default tex.vim syntax file, so that it
" should look OK when included.
syn cluster texMathZoneGroup contains=@texAllowedInMath

Tsy region texMath start='\$' end='\$' contains=@texAllowedInMath
Tsy region texMath start='\$\$' end='\$\$' contains=@texAllowedInMath
Tsy region texMath start='\\(' end='\\)' contains=@texAllowedInMath
Tsy region texMath start='\\\[' end='\\\]' contains=@texAllowedInMath

let s:cmdlist = 'texMathBrace,texSpecialChars,texMathCommands,texMathEnv,'
	    \ . 'texMathScripts,texComment,texEnvName,texEnvError,texBraceError'
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

" Generic math commands
syn match texMathCommands contained '\v\\[[:alpha:]@]+\*?'
	    \ nextgroup=texArgsMathGen

" Math mode commands with a text argument.
let s:cmdlist = 'makebox mbox framebox fbox raisebox parbox'
	    \ . ' text%(rm|tt|md|up|sl|bf|it)? operatorname'
	    \ . ( exists( 'g:tex_math_text_commands' ) ?
		    \ g:tex_math_text_commands : '' )
let s:regexp = substitute( s:cmdlist, '\v\s+', '|', 'g' )
exe 'syn match texMathCommands contained'
	    \ 'nextgroup=@texArgsMathText skipwhite skipempty'
	    \ '"\v\\%('.s:regexp.')>\*?"'

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
Tsy region texSectionFold   transparent fold keepend
	    \ start='\v%(%(\\begin\{document\}.*$\n)@<=^|\\section)'
	    \ end='\v\n%(\s*%(\\end\{document\}|\\section))@='
	    \ end='\v\n%(\s*\\bibliography%(style)?)@='
	    \ end='\v\n%(\s*\\begin\{%(thebibliography|biblist|bibdiv)\})@='
	    \ end='%endsection'

Tsy region texSubsectionFold transparent fold keepend
	    \ start='\v\\subsection'
	    \ end='\v\n%(\s*%(\\end\{document\}|\\%(sub)?section))@='
	    \ end='\v\n%(\s*\\bibliography%(style)?)@='
	    \ end='\v\n%(\s*\\begin\{%(thebibliography|biblist|bibdiv)\})@='
	    \ end='\v\%end%(sub)?section'

Tsy region texSubsubsectionFold transparent fold keepend
	    \ start='\v\\subsubsection'
	    \ end='\v\n%(\s*%(\\end\{document\}|\\%(sub)*section))@='
	    \ end='\v\n%(\s*\\bibliography%(style)?)@='
	    \ end='\v\n%(\s*\\begin\{%(thebibliography|biblist|bibdiv)\})@='
	    \ end='\v\%end%(sub)*section'

" BibTeX bibliography.
Tsy region texBibFold transparent fold keepend
	    \ start='\v\\bibliography%(style)?'
	    \ end='\v\n%(\s*\\end\{document\})@='

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

" Comment markers. Only %{{{{ and %}}}} are supported. No number versions
" Use four braces (instead of 3) to avoid confusion with existing fold
" markers.
Tsy region texCommentFold transparent fold keepend extend
	    \ start='\v^.*\%.*\{{4}'
	    \ end='\v\%.*\}{4}'

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

" Conceal mode support (supports set cole=2) {{{1
if has("conceal") && &enc == 'utf-8'

 " Math Symbols {{{2
 " (many of these symbols were contributed by Björn Winckler)
 if s:tex_conceal =~ 'm'
  let s:texMathList=[
    \ ['|'		, '‖'],
    \ ['aleph'		, 'ℵ'],
    \ ['amalg'		, '∐'],
    \ ['angle'		, '∠'],
    \ ['approx'		, '≈'],
    \ ['ast'		, '∗'],
    \ ['asymp'		, '≍'],
    \ ['backepsilon'	, '∍'],
    \ ['backsimeq'	, '≃'],
    \ ['backslash'	, '∖'],
    \ ['barwedge'	, '⊼'],
    \ ['because'	, '∵'],
    \ ['between'	, '≬'],
    \ ['bigcap'		, '∩'],
    \ ['bigcirc'	, '○'],
    \ ['bigcup'		, '∪'],
    \ ['bigodot'	, '⊙'],
    \ ['bigoplus'	, '⊕'],
    \ ['bigotimes'	, '⊗'],
    \ ['bigsqcup'	, '⊔'],
    \ ['bigtriangledown', '∇'],
    \ ['bigtriangleup'	, '∆'],
    \ ['bigvee'		, '⋁'],
    \ ['bigwedge'	, '⋀'],
    \ ['blacksquare'	, '∎'],
    \ ['bot'		, '⊥'],
    \ ['bowtie'	        , '⋈'],
    \ ['boxdot'		, '⊡'],
    \ ['boxminus'	, '⊟'],
    \ ['boxplus'	, '⊞'],
    \ ['boxtimes'	, '⊠'],
    \ ['bullet'	        , '•'],
    \ ['bumpeq'		, '≏'],
    \ ['Bumpeq'		, '≎'],
    \ ['cap'		, '∩'],
    \ ['Cap'		, '⋒'],
    \ ['cdot'		, '·'],
    \ ['cdots'		, '⋯'],
    \ ['circ'		, '∘'],
    \ ['circeq'		, '≗'],
    \ ['circlearrowleft', '↺'],
    \ ['circlearrowright', '↻'],
    \ ['circledast'	, '⊛'],
    \ ['circledcirc'	, '⊚'],
    \ ['clubsuit'	, '♣'],
    \ ['complement'	, '∁'],
    \ ['cong'		, '≅'],
    \ ['coprod'		, '∐'],
    \ ['copyright'	, '©'],
    \ ['cup'		, '∪'],
    \ ['Cup'		, '⋓'],
    \ ['curlyeqprec'	, '⋞'],
    \ ['curlyeqsucc'	, '⋟'],
    \ ['curlyvee'	, '⋎'],
    \ ['curlywedge'	, '⋏'],
    \ ['dagger'	        , '†'],
    \ ['dashv'		, '⊣'],
    \ ['ddagger'	, '‡'],
    \ ['ddots'	        , '⋱'],
    \ ['diamond'	, '⋄'],
    \ ['diamondsuit'	, '♢'],
    \ ['div'		, '÷'],
    \ ['doteq'		, '≐'],
    \ ['doteqdot'	, '≑'],
    \ ['dotplus'	, '∔'],
    \ ['dots'		, '…'],
    \ ['dotsb'		, '⋯'],
    \ ['dotsc'		, '…'],
    \ ['dotsi'		, '⋯'],
    \ ['dotso'		, '…'],
    \ ['doublebarwedge'	, '⩞'],
    \ ['downarrow'	, '↓'],
    \ ['Downarrow'	, '⇓'],
    \ ['ell'		, 'ℓ'],
    \ ['emptyset'	, '∅'],
    \ ['eqcirc'		, '≖'],
    \ ['eqsim'		, '≂'],
    \ ['eqslantgtr'	, '⪖'],
    \ ['eqslantless'	, '⪕'],
    \ ['equiv'		, '≡'],
    \ ['exists'		, '∃'],
    \ ['fallingdotseq'	, '≒'],
    \ ['flat'		, '♭'],
    \ ['forall'		, '∀'],
    \ ['frown'		, '⁔'],
    \ ['ge'		, '≥'],
    \ ['geq'		, '≥'],
    \ ['geqq'		, '≧'],
    \ ['gets'		, '←'],
    \ ['gg'		, '⟫'],
    \ ['gneqq'		, '≩'],
    \ ['gtrdot'		, '⋗'],
    \ ['gtreqless'	, '⋛'],
    \ ['gtrless'	, '≷'],
    \ ['gtrsim'		, '≳'],
    \ ['hbar'		, 'ℏ'],
    \ ['heartsuit'	, '♡'],
    \ ['hookleftarrow'	, '↩'],
    \ ['hookrightarrow'	, '↪'],
    \ ['iiint'		, '∭'],
    \ ['iint'		, '∬'],
    \ ['Im'		, 'ℑ'],
    \ ['imath'		, 'ɩ'],
    \ ['in'		, '∈'],
    \ ['infty'		, '∞'],
    \ ['int'		, '∫'],
    \ ['lceil'		, '⌈'],
    \ ['ldots'		, '…'],
    \ ['le'		, '≤'],
    \ ['leadsto'	, '↝'],
    \ ['left('		, '('],
    \ ['left\['		, '['],
    \ ['left\\{'	, '{'],
    \ ['leftarrow'	, '⟵'],
    \ ['Leftarrow'	, '⟸'],
    \ ['leftarrowtail'	, '↢'],
    \ ['leftharpoondown', '↽'],
    \ ['leftharpoonup'	, '↼'],
    \ ['leftrightarrow'	, '↔'],
    \ ['Leftrightarrow'	, '⇔'],
    \ ['leftrightsquigarrow', '↭'],
    \ ['leftthreetimes'	, '⋋'],
    \ ['leq'		, '≤'],
    \ ['leq'		, '≤'],
    \ ['leqq'		, '≦'],
    \ ['lessdot'	, '⋖'],
    \ ['lesseqgtr'	, '⋚'],
    \ ['lesssim'	, '≲'],
    \ ['lfloor'		, '⌊'],
    \ ['ll'		, '≪'],
    \ ['lmoustache'     , '╭'],
    \ ['lneqq'		, '≨'],
    \ ['ltimes'		, '⋉'],
    \ ['mapsto'		, '↦'],
    \ ['measuredangle'	, '∡'],
    \ ['mid'		, '∣'],
    \ ['models'		, '╞'],
    \ ['mp'		, '∓'],
    \ ['nabla'		, '∇'],
    \ ['natural'	, '♮'],
    \ ['ncong'		, '≇'],
    \ ['ne'		, '≠'],
    \ ['nearrow'	, '↗'],
    \ ['neg'		, '¬'],
    \ ['neq'		, '≠'],
    \ ['nexists'	, '∄'],
    \ ['ngeq'		, '≱'],
    \ ['ngeqq'		, '≱'],
    \ ['ngtr'		, '≯'],
    \ ['ni'		, '∋'],
    \ ['nleftarrow'	, '↚'],
    \ ['nLeftarrow'	, '⇍'],
    \ ['nLeftrightarrow', '⇎'],
    \ ['nleq'		, '≰'],
    \ ['nleqq'		, '≰'],
    \ ['nless'		, '≮'],
    \ ['nmid'		, '∤'],
    \ ['notin'		, '∉'],
    \ ['nprec'		, '⊀'],
    \ ['nrightarrow'	, '↛'],
    \ ['nRightarrow'	, '⇏'],
    \ ['nsim'		, '≁'],
    \ ['nsucc'		, '⊁'],
    \ ['ntriangleleft'	, '⋪'],
    \ ['ntrianglelefteq', '⋬'],
    \ ['ntriangleright'	, '⋫'],
    \ ['ntrianglerighteq', '⋭'],
    \ ['nvdash'		, '⊬'],
    \ ['nvDash'		, '⊭'],
    \ ['nVdash'		, '⊮'],
    \ ['nwarrow'	, '↖'],
    \ ['odot'		, '⊙'],
    \ ['oint'		, '∮'],
    \ ['ominus'		, '⊖'],
    \ ['oplus'		, '⊕'],
    \ ['oslash'		, '⊘'],
    \ ['otimes'		, '⊗'],
    \ ['owns'		, '∋'],
    \ ['P'	        , '¶'],
    \ ['parallel'	, '║'],
    \ ['partial'	, '∂'],
    \ ['perp'		, '⊥'],
    \ ['pitchfork'	, '⋔'],
    \ ['pm'		, '±'],
    \ ['prec'		, '≺'],
    \ ['precapprox'	, '⪷'],
    \ ['preccurlyeq'	, '≼'],
    \ ['preceq'		, '⪯'],
    \ ['precnapprox'	, '⪹'],
    \ ['precneqq'	, '⪵'],
    \ ['precsim'	, '≾'],
    \ ['prime'		, '′'],
    \ ['prod'		, '∏'],
    \ ['propto'		, '∝'],
    \ ['rceil'		, '⌉'],
    \ ['Re'		, 'ℜ'],
    \ ['rfloor'		, '⌋'],
    \ ['right)'		, ')'],
    \ ['right]'		, ']'],
    \ ['right\\}'	, '}'],
    \ ['rightarrow'	, '⟶'],
    \ ['Rightarrow'	, '⟹'],
    \ ['rightarrowtail'	, '↣'],
    \ ['rightleftharpoons', '⇌'],
    \ ['rightsquigarrow', '↝'],
    \ ['rightthreetimes', '⋌'],
    \ ['risingdotseq'	, '≓'],
    \ ['rmoustache'     , '╮'],
    \ ['rtimes'		, '⋊'],
    \ ['S'	        , '§'],
    \ ['searrow'	, '↘'],
    \ ['setminus'	, '∖'],
    \ ['sharp'		, '♯'],
    \ ['sim'		, '∼'],
    \ ['simeq'		, '⋍'],
    \ ['smile'		, '‿'],
    \ ['spadesuit'	, '♠'],
    \ ['sphericalangle'	, '∢'],
    \ ['sqcap'		, '⊓'],
    \ ['sqcup'		, '⊔'],
    \ ['sqsubset'	, '⊏'],
    \ ['sqsubseteq'	, '⊑'],
    \ ['sqsupset'	, '⊐'],
    \ ['sqsupseteq'	, '⊒'],
    \ ['star'		, '✫'],
    \ ['subset'		, '⊂'],
    \ ['Subset'		, '⋐'],
    \ ['subseteq'	, '⊆'],
    \ ['subseteqq'	, '⫅'],
    \ ['subsetneq'	, '⊊'],
    \ ['subsetneqq'	, '⫋'],
    \ ['succ'		, '≻'],
    \ ['succapprox'	, '⪸'],
    \ ['succcurlyeq'	, '≽'],
    \ ['succeq'		, '⪰'],
    \ ['succnapprox'	, '⪺'],
    \ ['succneqq'	, '⪶'],
    \ ['succsim'	, '≿'],
    \ ['sum'		, '∑'],
    \ ['supset'		, '⊃'],
    \ ['Supset'		, '⋑'],
    \ ['supseteq'	, '⊇'],
    \ ['supseteqq'	, '⫆'],
    \ ['supsetneq'	, '⊋'],
    \ ['supsetneqq'	, '⫌'],
    \ ['surd'		, '√'],
    \ ['swarrow'	, '↙'],
    \ ['therefore'	, '∴'],
    \ ['times'		, '×'],
    \ ['to'		, '→'],
    \ ['top'		, '⊤'],
    \ ['triangle'	, '∆'],
    \ ['triangleleft'	, '⊲'],
    \ ['trianglelefteq'	, '⊴'],
    \ ['triangleq'	, '≜'],
    \ ['triangleright'	, '⊳'],
    \ ['trianglerighteq', '⊵'],
    \ ['twoheadleftarrow', '↞'],
    \ ['twoheadrightarrow', '↠'],
    \ ['uparrow'	, '↑'],
    \ ['Uparrow'	, '⇑'],
    \ ['updownarrow'	, '↕'],
    \ ['Updownarrow'	, '⇕'],
    \ ['varnothing'	, '∅'],
    \ ['vartriangle'	, '∆'],
    \ ['vdash'		, '⊢'],
    \ ['vDash'		, '⊨'],
    \ ['Vdash'		, '⊩'],
    \ ['vdots'		, '⋮'],
    \ ['vee'		, '∨'],
    \ ['veebar'		, '⊻'],
    \ ['Vvdash'		, '⊪'],
    \ ['wedge'		, '∧'],
    \ ['wp'		, '℘'],
    \ ['wr'		, '≀']]
"    \ ['jmath'		, 'X']
"    \ ['uminus'	, 'X']
"    \ ['uplus'		, 'X']
  for texmath in s:texMathList
   if texmath[0] =~ '\w$'
    exe "syn match texMathSymbol '\\\\".texmath[0]."\\>' contained conceal cchar=".texmath[1]
   else
    exe "syn match texMathSymbol '\\\\".texmath[0]."' contained conceal cchar=".texmath[1]
   endif
  endfor

  if &ambw == "double"
   syn match texMathSymbol '\\gg\>'			contained conceal cchar=≫
   syn match texMathSymbol '\\ll\>'			contained conceal cchar=≪
  else
   syn match texMathSymbol '\\gg\>'			contained conceal cchar=⟫
   syn match texMathSymbol '\\ll\>'			contained conceal cchar=⟪
  endif

  syn match texMathSymbol '\\hat{a}' contained conceal cchar=â
  syn match texMathSymbol '\\hat{A}' contained conceal cchar=Â
  syn match texMathSymbol '\\hat{c}' contained conceal cchar=ĉ
  syn match texMathSymbol '\\hat{C}' contained conceal cchar=Ĉ
  syn match texMathSymbol '\\hat{e}' contained conceal cchar=ê
  syn match texMathSymbol '\\hat{E}' contained conceal cchar=Ê
  syn match texMathSymbol '\\hat{g}' contained conceal cchar=ĝ
  syn match texMathSymbol '\\hat{G}' contained conceal cchar=Ĝ
  syn match texMathSymbol '\\hat{i}' contained conceal cchar=î
  syn match texMathSymbol '\\hat{I}' contained conceal cchar=Î
  syn match texMathSymbol '\\hat{o}' contained conceal cchar=ô
  syn match texMathSymbol '\\hat{O}' contained conceal cchar=Ô
  syn match texMathSymbol '\\hat{s}' contained conceal cchar=ŝ
  syn match texMathSymbol '\\hat{S}' contained conceal cchar=Ŝ
  syn match texMathSymbol '\\hat{u}' contained conceal cchar=û
  syn match texMathSymbol '\\hat{U}' contained conceal cchar=Û
  syn match texMathSymbol '\\hat{w}' contained conceal cchar=ŵ
  syn match texMathSymbol '\\hat{W}' contained conceal cchar=Ŵ
  syn match texMathSymbol '\\hat{y}' contained conceal cchar=ŷ
  syn match texMathSymbol '\\hat{Y}' contained conceal cchar=Ŷ
 endif

 " Greek {{{2
 if s:tex_conceal =~ 'g'
  fun! s:Greek(group,pat,cchar)
    exe 'syn match '.a:group." '".a:pat."' contained conceal cchar=".a:cchar
  endfun
  call s:Greek('texGreek','\\alpha\>'		,'α')
  call s:Greek('texGreek','\\beta\>'		,'β')
  call s:Greek('texGreek','\\gamma\>'		,'γ')
  call s:Greek('texGreek','\\delta\>'		,'δ')
  call s:Greek('texGreek','\\epsilon\>'		,'ϵ')
  call s:Greek('texGreek','\\varepsilon\>'	,'ε')
  call s:Greek('texGreek','\\zeta\>'		,'ζ')
  call s:Greek('texGreek','\\eta\>'		,'η')
  call s:Greek('texGreek','\\theta\>'		,'θ')
  call s:Greek('texGreek','\\vartheta\>'		,'ϑ')
  call s:Greek('texGreek','\\kappa\>'		,'κ')
  call s:Greek('texGreek','\\lambda\>'		,'λ')
  call s:Greek('texGreek','\\mu\>'		,'μ')
  call s:Greek('texGreek','\\nu\>'		,'ν')
  call s:Greek('texGreek','\\xi\>'		,'ξ')
  call s:Greek('texGreek','\\pi\>'		,'π')
  call s:Greek('texGreek','\\varpi\>'		,'ϖ')
  call s:Greek('texGreek','\\rho\>'		,'ρ')
  call s:Greek('texGreek','\\varrho\>'		,'ϱ')
  call s:Greek('texGreek','\\sigma\>'		,'σ')
  call s:Greek('texGreek','\\varsigma\>'		,'ς')
  call s:Greek('texGreek','\\tau\>'		,'τ')
  call s:Greek('texGreek','\\upsilon\>'		,'υ')
  call s:Greek('texGreek','\\phi\>'		,'φ')
  call s:Greek('texGreek','\\varphi\>'		,'ϕ')
  call s:Greek('texGreek','\\chi\>'		,'χ')
  call s:Greek('texGreek','\\psi\>'		,'ψ')
  call s:Greek('texGreek','\\omega\>'		,'ω')
  call s:Greek('texGreek','\\Gamma\>'		,'Γ')
  call s:Greek('texGreek','\\Delta\>'		,'Δ')
  call s:Greek('texGreek','\\Theta\>'		,'Θ')
  call s:Greek('texGreek','\\Lambda\>'		,'Λ')
  call s:Greek('texGreek','\\Xi\>'		,'Χ')
  call s:Greek('texGreek','\\Pi\>'		,'Π')
  call s:Greek('texGreek','\\Sigma\>'		,'Σ')
  call s:Greek('texGreek','\\Upsilon\>'		,'Υ')
  call s:Greek('texGreek','\\Phi\>'		,'Φ')
  call s:Greek('texGreek','\\Psi\>'		,'Ψ')
  call s:Greek('texGreek','\\Omega\>'		,'Ω')
  delfun s:Greek
 endif

 " Superscripts/Subscripts {{{2
 if s:tex_conceal =~ 's'
  if s:tex_fast =~ 's'
   syn region texSuperscript	matchgroup=Delimiter start='\^{'	skip="\\\\\|\\[{}]" end='}'	contained concealends contains=texSpecialChar,texSuperscripts,texStatement,texSubscript,texSuperscript,texMathMatcher
   syn region texSubscript	matchgroup=Delimiter start='_{'		skip="\\\\\|\\[{}]" end='}'	contained concealends contains=texSpecialChar,texSubscripts,texStatement,texSubscript,texSuperscript,texMathMatcher
  endif
  fun! s:SuperSub(group,leader,pat,cchar)
    if a:pat =~ '^\\' || (a:leader == '\^' && a:pat =~ g:tex_superscripts) || (a:leader == '_' && a:pat =~ g:tex_subscripts)
"     call Decho("SuperSub: group<".a:group."> leader<".a:leader."> pat<".a:pat."> cchar<".a:cchar.">")
     exe 'syn match '.a:group." '".a:leader.a:pat."' contained conceal cchar=".a:cchar
     exe 'syn match '.a:group."s '".a:pat."' contained conceal cchar=".a:cchar.' nextgroup='.a:group.'s'
    endif
  endfun
  call s:SuperSub('texSuperscript','\^','0','⁰')
  call s:SuperSub('texSuperscript','\^','1','¹')
  call s:SuperSub('texSuperscript','\^','2','²')
  call s:SuperSub('texSuperscript','\^','3','³')
  call s:SuperSub('texSuperscript','\^','4','⁴')
  call s:SuperSub('texSuperscript','\^','5','⁵')
  call s:SuperSub('texSuperscript','\^','6','⁶')
  call s:SuperSub('texSuperscript','\^','7','⁷')
  call s:SuperSub('texSuperscript','\^','8','⁸')
  call s:SuperSub('texSuperscript','\^','9','⁹')
  call s:SuperSub('texSuperscript','\^','a','ᵃ')
  call s:SuperSub('texSuperscript','\^','b','ᵇ')
  call s:SuperSub('texSuperscript','\^','c','ᶜ')
  call s:SuperSub('texSuperscript','\^','d','ᵈ')
  call s:SuperSub('texSuperscript','\^','e','ᵉ')
  call s:SuperSub('texSuperscript','\^','f','ᶠ')
  call s:SuperSub('texSuperscript','\^','g','ᵍ')
  call s:SuperSub('texSuperscript','\^','h','ʰ')
  call s:SuperSub('texSuperscript','\^','i','ⁱ')
  call s:SuperSub('texSuperscript','\^','j','ʲ')
  call s:SuperSub('texSuperscript','\^','k','ᵏ')
  call s:SuperSub('texSuperscript','\^','l','ˡ')
  call s:SuperSub('texSuperscript','\^','m','ᵐ')
  call s:SuperSub('texSuperscript','\^','n','ⁿ')
  call s:SuperSub('texSuperscript','\^','o','ᵒ')
  call s:SuperSub('texSuperscript','\^','p','ᵖ')
  call s:SuperSub('texSuperscript','\^','r','ʳ')
  call s:SuperSub('texSuperscript','\^','s','ˢ')
  call s:SuperSub('texSuperscript','\^','t','ᵗ')
  call s:SuperSub('texSuperscript','\^','u','ᵘ')
  call s:SuperSub('texSuperscript','\^','v','ᵛ')
  call s:SuperSub('texSuperscript','\^','w','ʷ')
  call s:SuperSub('texSuperscript','\^','x','ˣ')
  call s:SuperSub('texSuperscript','\^','y','ʸ')
  call s:SuperSub('texSuperscript','\^','z','ᶻ')
  call s:SuperSub('texSuperscript','\^','A','ᴬ')
  call s:SuperSub('texSuperscript','\^','B','ᴮ')
  call s:SuperSub('texSuperscript','\^','D','ᴰ')
  call s:SuperSub('texSuperscript','\^','E','ᴱ')
  call s:SuperSub('texSuperscript','\^','G','ᴳ')
  call s:SuperSub('texSuperscript','\^','H','ᴴ')
  call s:SuperSub('texSuperscript','\^','I','ᴵ')
  call s:SuperSub('texSuperscript','\^','J','ᴶ')
  call s:SuperSub('texSuperscript','\^','K','ᴷ')
  call s:SuperSub('texSuperscript','\^','L','ᴸ')
  call s:SuperSub('texSuperscript','\^','M','ᴹ')
  call s:SuperSub('texSuperscript','\^','N','ᴺ')
  call s:SuperSub('texSuperscript','\^','O','ᴼ')
  call s:SuperSub('texSuperscript','\^','P','ᴾ')
  call s:SuperSub('texSuperscript','\^','R','ᴿ')
  call s:SuperSub('texSuperscript','\^','T','ᵀ')
  call s:SuperSub('texSuperscript','\^','U','ᵁ')
  call s:SuperSub('texSuperscript','\^','W','ᵂ')
  call s:SuperSub('texSuperscript','\^',',','︐')
  call s:SuperSub('texSuperscript','\^',':','︓')
  call s:SuperSub('texSuperscript','\^',';','︔')
  call s:SuperSub('texSuperscript','\^','+','⁺')
  call s:SuperSub('texSuperscript','\^','-','⁻')
  call s:SuperSub('texSuperscript','\^','<','˂')
  call s:SuperSub('texSuperscript','\^','>','˃')
  call s:SuperSub('texSuperscript','\^','/','ˊ')
  call s:SuperSub('texSuperscript','\^','(','⁽')
  call s:SuperSub('texSuperscript','\^',')','⁾')
  call s:SuperSub('texSuperscript','\^','\.','˙')
  call s:SuperSub('texSuperscript','\^','=','˭')
  call s:SuperSub('texSubscript','_','0','₀')
  call s:SuperSub('texSubscript','_','1','₁')
  call s:SuperSub('texSubscript','_','2','₂')
  call s:SuperSub('texSubscript','_','3','₃')
  call s:SuperSub('texSubscript','_','4','₄')
  call s:SuperSub('texSubscript','_','5','₅')
  call s:SuperSub('texSubscript','_','6','₆')
  call s:SuperSub('texSubscript','_','7','₇')
  call s:SuperSub('texSubscript','_','8','₈')
  call s:SuperSub('texSubscript','_','9','₉')
  call s:SuperSub('texSubscript','_','a','ₐ')
  call s:SuperSub('texSubscript','_','e','ₑ')
  call s:SuperSub('texSubscript','_','i','ᵢ')
  call s:SuperSub('texSubscript','_','o','ₒ')
  call s:SuperSub('texSubscript','_','u','ᵤ')
  call s:SuperSub('texSubscript','_',',','︐')
  call s:SuperSub('texSubscript','_','+','₊')
  call s:SuperSub('texSubscript','_','-','₋')
  call s:SuperSub('texSubscript','_','/','ˏ')
  call s:SuperSub('texSubscript','_','(','₍')
  call s:SuperSub('texSubscript','_',')','₎')
  call s:SuperSub('texSubscript','_','\.','‸')
  call s:SuperSub('texSubscript','_','r','ᵣ')
  call s:SuperSub('texSubscript','_','v','ᵥ')
  call s:SuperSub('texSubscript','_','x','ₓ')
  call s:SuperSub('texSubscript','_','\\beta\>' ,'ᵦ')
  call s:SuperSub('texSubscript','_','\\delta\>','ᵨ')
  call s:SuperSub('texSubscript','_','\\phi\>'  ,'ᵩ')
  call s:SuperSub('texSubscript','_','\\gamma\>','ᵧ')
  call s:SuperSub('texSubscript','_','\\chi\>'  ,'ᵪ')
  delfun s:SuperSub
 endif

 " Accented characters: {{{2
 if s:tex_conceal =~ 'a'
  if b:tex_stylish
   syn match texAccent		"\\[bcdvuH][^a-zA-Z@]"me=e-1
   syn match texLigature		"\\\([ijolL]\|ae\|oe\|ss\|AA\|AE\|OE\)[^a-zA-Z@]"me=e-1
  else
   fun! s:Accents(chr,...)
     let i= 1
     for accent in ["`","\\'","^",'"','\~','\.','=',"c","H","k","r","u","v"]
      if i > a:0
       break
      endif
      if strlen(a:{i}) == 0 || a:{i} == ' ' || a:{i} == '?'
       let i= i + 1
       continue
      endif
      if accent =~ '\a'
       exe "syn match texAccent '".'\\'.accent.'\(\s*{'.a:chr.'}\|\s\+'.a:chr.'\)'."' conceal cchar=".a:{i}
      else
       exe "syn match texAccent '".'\\'.accent.'\s*\({'.a:chr.'}\|'.a:chr.'\)'."' conceal cchar=".a:{i}
      endif
      let i= i + 1
     endfor
   endfun
   "                  \`  \'  \^  \"  \~  \.  \=  \c  \H  \k  \r  \u  \v
   call s:Accents('a','à','á','â','ä','ã','ȧ','ā',' ',' ','ą','å','ă','ǎ')
   call s:Accents('A','À','Á','Â','Ä','Ã','Ȧ','Ā',' ',' ','Ą','Å','Ă','Ǎ')
   call s:Accents('c',' ','ć','ĉ',' ',' ','ċ',' ','ç',' ',' ',' ',' ','č')
   call s:Accents('C',' ','Ć','Ĉ',' ',' ','Ċ',' ','Ç',' ',' ',' ',' ','Č')
   call s:Accents('d',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','ď')
   call s:Accents('D',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','Ď')
   call s:Accents('e','è','é','ê','ë','ẽ','ė','ē','ȩ',' ','ę',' ','ĕ','ě')
   call s:Accents('E','È','É','Ê','Ë','Ẽ','Ė','Ē','Ȩ',' ','Ę',' ','Ĕ','Ě')
   call s:Accents('g',' ','ǵ','ĝ',' ',' ','ġ',' ','ģ',' ',' ',' ','ğ','ǧ')
   call s:Accents('G',' ','Ǵ','Ĝ',' ',' ','Ġ',' ','Ģ',' ',' ',' ','Ğ','Ǧ')
   call s:Accents('h',' ',' ','ĥ',' ',' ',' ',' ',' ',' ',' ',' ',' ','ȟ')
   call s:Accents('H',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','Ȟ')
   call s:Accents('i','ì','í','î','ï','ĩ','į','ī',' ',' ','į',' ','ĭ','ǐ')
   call s:Accents('I','Ì','Í','Î','Ï','Ĩ','İ','Ī',' ',' ','Į',' ','Ĭ','Ǐ')
   call s:Accents('J',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','ǰ')
   call s:Accents('k',' ',' ',' ',' ',' ',' ',' ','ķ',' ',' ',' ',' ','ǩ')
   call s:Accents('K',' ',' ',' ',' ',' ',' ',' ','Ķ',' ',' ',' ',' ','Ǩ')
   call s:Accents('l',' ','ĺ','ľ',' ',' ',' ',' ','ļ',' ',' ',' ',' ','ľ')
   call s:Accents('L',' ','Ĺ','Ľ',' ',' ',' ',' ','Ļ',' ',' ',' ',' ','Ľ')
   call s:Accents('n',' ','ń',' ',' ','ñ',' ',' ','ņ',' ',' ',' ',' ','ň')
   call s:Accents('N',' ','Ń',' ',' ','Ñ',' ',' ','Ņ',' ',' ',' ',' ','Ň')
   call s:Accents('o','ò','ó','ô','ö','õ','ȯ','ō',' ','ő','ǫ',' ','ŏ','ǒ')
   call s:Accents('O','Ò','Ó','Ô','Ö','Õ','Ȯ','Ō',' ','Ő','Ǫ',' ','Ŏ','Ǒ')
   call s:Accents('r',' ','ŕ',' ',' ',' ',' ',' ','ŗ',' ',' ',' ',' ','ř')
   call s:Accents('R',' ','Ŕ',' ',' ',' ',' ',' ','Ŗ',' ',' ',' ',' ','Ř')
   call s:Accents('s',' ','ś','ŝ',' ',' ',' ',' ','ş',' ','ȿ',' ',' ','š')
   call s:Accents('S',' ','Ś','Ŝ',' ',' ',' ',' ','Ş',' ',' ',' ',' ','Š')
   call s:Accents('t',' ',' ',' ',' ',' ',' ',' ','ţ',' ',' ',' ',' ','ť')
   call s:Accents('T',' ',' ',' ',' ',' ',' ',' ','Ţ',' ',' ',' ',' ','Ť')
   call s:Accents('u','ù','ú','û','ü','ũ',' ','ū',' ','ű','ų','ů','ŭ','ǔ')
   call s:Accents('U','Ù','Ú','Û','Ü','Ũ',' ','Ū',' ','Ű','Ų','Ů','Ŭ','Ǔ')
   call s:Accents('w',' ',' ','ŵ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ')
   call s:Accents('W',' ',' ','Ŵ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ')
   call s:Accents('y','ỳ','ý','ŷ','ÿ','ỹ',' ',' ',' ',' ',' ',' ',' ',' ')
   call s:Accents('Y','Ỳ','Ý','Ŷ','Ÿ','Ỹ',' ',' ',' ',' ',' ',' ',' ',' ')
   call s:Accents('z',' ','ź',' ',' ',' ','ż',' ',' ',' ',' ',' ',' ','ž')
   call s:Accents('Z',' ','Ź',' ',' ',' ','Ż',' ',' ',' ',' ',' ',' ','Ž')
   call s:Accents('\\i','ì','í','î','ï','ĩ','į',' ',' ',' ',' ',' ','ĭ',' ')
   "                    \`  \'  \^  \"  \~  \.  \=  \c  \H  \k  \r  \u  \v
   delfun s:Accents
   syn match texAccent   '\\aa\>'	conceal cchar=å
   syn match texAccent   '\\AA\>'	conceal cchar=Å
   syn match texAccent	'\\o\>'		conceal cchar=ø
   syn match texAccent	'\\O\>'		conceal cchar=Ø
   syn match texLigature	'\\AE\>'	conceal cchar=Æ
   syn match texLigature	'\\ae\>'	conceal cchar=æ
   syn match texLigature	'\\oe\>'	conceal cchar=œ
   syn match texLigature	'\\OE\>'	conceal cchar=Œ
   syn match texLigature	'\\ss\>'	conceal cchar=ß
  endif
 endif
endif

" ---------------------------------------------------------------------

" {{{1 Cleanup
let   b:current_syntax = "tex"
let &cpo               = s:cpo_save

unlet s:cpo_save s:math_env_names s:regexp s:fold_envs s:cmdlist
