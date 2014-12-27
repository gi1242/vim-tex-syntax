# vim-tex-syntax

This is a rewrite of the default `syntax/tex.vim` used for [TeX]/[LaTeX],
because I got fed-up with the default `syntax/tex.vim` file. My main
complaints were that syntax folding didn't work the way I wanted, and spell
checking missed many things I wanted checked (and erratically failed).

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

     Additionally theorems, lemmas, proofs etc. are folded. Additional
   environment names for folding can be configured using `g:tex_fold_envs`.
   For one time folds, you can also use the markers `%{{{{` and `%}}}}`.
   (Note the extra brace, which is added to avoid double folding when editing
   a file with fold markers.)

2. *Spell checking.*
   Most everything that should be spell checked is. Arguments of all commands
   (except special commands in `g:tex_special_commands`) are spell checked,
   and arguments of environments (except theorem like environments in
   `g:tex_thm_envs`) are not spell checked.

3. *Brace matching.*
   Extra open braces in an environment will produce an error in the enclosing 
   `\end{...}` statement.
   Extra closed braces are flagged.
   Braces denoting command and script script arguments are highlighted
   differently.

## Configuration options.

`g:tex_special_commands`
: Space separated list of special commands (e.g. `usepackage`). Arguments of
  these commands will be colored and not spell checked.

`g:tex_section_commands`
: Space separated list of sectioning commands (e.g. `chapter`).

`g:tex_thm_envs`
: Space separated list of theorem like environments (e.g. `theorem`).
  Arguments of these commands are spell checked (and not colored).

`g:tex_math_envs`
: Space separated list of environment names that start a math zone (e.g.
  `equation` etc.),

`g:tex_fold_envs`
: Set this to a space separated list of environment names that should start a
  fold. For one time folds, you can also use the markers `%{{{{` and `%}}}}`.

`g:tex_isk`
: `iskeyword` option for [TeX]/[LaTeX] files.

## Links

* [Github page](https://github.com/gi1242/vim-tex-syntax)

* [Vim script page](http://www.vim.org/scripts/script.php?script_id=5076)

[TeX]: http://en.wikipedia.org/wiki/TeX

[LaTeX]: http://www.latex-project.org
