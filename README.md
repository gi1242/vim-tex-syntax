# vim-tex-syntax

This is a rewrite of the default `syntax/tex.vim` used for [TeX]/[LaTeX],
because I finally got fed-up with the default `syntax/tex.vim` file. My main
complaints were that syntax folding is painfully slow for large files and
doesn't work the way I want. Also spell checking checking missed many things I
wanted checked (and erratically failed).

## Features

1. *Syntax folding.*
   If you set `fdm=syntax`, the document will be folded like this:

        +--  6 lines: \documentclass[draft]{amsart}-------------
        \begin{document}
        +-- 27 lines: \title[Continuity theorem for Bernstein tr
        +--169 lines: \section{Introduction.}\label{sxnIntro}---
        +-- 12 lines: \section{Continuity theorem.}\label{sxnCT}
        +--  3 lines: \bibliographystyle{habbrv}----------------
        \end{document}

     Additionally theorems, lemmas, proofs etc. are also folded, manual folds
   can be added. Syntax folding is about 3 to 4 times faster than the default
   syntax script shipped with Vim. This only make a difference if you edit
   large files. On my system, a file with 15,000 lines (and multiple sections
   / subsections / etc.) takes about 7 seconds to highlight and fold with this
   script, and it takes about 27 with the Vim default syntax script. Both
   scripts are snappy if folding is disabled, of course. If you plan on
   editing large TeX/LaTeX files and using syntax folding I recommend using
   the [FastFold] plugin in addition to this script.


2. *Spell checking.*
   Most everything that should be spell checked is. Arguments of all commands
   (except special commands in `g:tex_special_commands`) are spell checked,
   and arguments of environments (except theorem like environments in
   `g:tex_thm_envs`) are not spell checked.

3. *Brace matching.*
   Extra open braces in an environment will produce an error in the enclosing
   `\end{...}` statement. Extra closed braces are flagged. Braces denoting
   command and script script arguments are highlighted differently.

## Configuration options.

`g:tex_special_arg_commands`
: Space separated list of commands with special arguments (e.g. `usepackage`).
  Arguments of these commands will be colored and not spell checked.

`g:tex_special_commands`
: Space separated list of special commands (e.g. `large`). These will be
  colored differently from other commands (but the arguments will not be
  handled specially).

`g:tex_section_commands`
: Space separated list of sectioning commands (e.g. `chapter`).

`g:tex_math_text_commands`
: Space separated list of commands in math mode with text arguments (e.g.
  `text`).

`g:tex_thm_envs`
: Space separated list of theorem like environments (e.g. `theorem`).
  Arguments of these commands are spell checked (and not colored).

`g:tex_math_envs`
: Space separated list of environment names that start a math zone (e.g.
  `equation` etc.),

`g:tex_fold_envs`
: Set this to a space separated list of environment names that should start a
  fold.

`g:tex_isk`
: `iskeyword` option for [TeX]/[LaTeX] files.

## Additional syntax folds

In case the automatically created syntax folds created are not sufficient for
your purposes, you can adjust it manually in the following ways.

1. The comment markers `%{{{` and `%}}}` can be used to create a fold.
   The numbered versions `%{{{1` etc. are ignored.

2. Section / subsection level folds can manually be started using
   `%startsection`, `%startsubsection` or `%startsubsubsection`. (Similarly
   for chapters).

3. Section / subsection level folds can be manually closed using
   using `%endsection`, `%endsubsection` or `%endsubsubsection`. (Similarly
   for chapters)

4. The front matter fold (that starts on the line after `\begin{document}`)
   usually ends when a section or chapter is started. If you want to end it
   earlier, use the comment `%endfrontmatter'

## Links

* [Github page](https://github.com/gi1242/vim-tex-syntax)

* [Vim script page](http://www.vim.org/scripts/script.php?script_id=5076)

[TeX]: http://en.wikipedia.org/wiki/TeX

[LaTeX]: http://www.latex-project.org
