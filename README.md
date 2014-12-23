# vim-tex-syntax

This is a rewrite of the default `syntax/tex.vim` used for [TeX]/[LaTeX],
because I got fed-up with the default `syntax/tex.vim` file.

## Features (and differences from the default `syntax/tex.vim`) 

1. *Syntax folding works differently.*
   The document is folded like this

        +--  6 lines: \documentclass[draft]{amsart}-------------
        \begin{document}
        +-- 27 lines: \title[Continuity theorem for Bernstein tr
        +--169 lines: \section{Introduction.}\label{sxnIntro}---
        +-- 12 lines: \section{Continuity theorem.}\label{sxnCT}
        +--  3 lines: \bibliographystyle{habbrv}----------------
        \end{document}

   Additionally, theorems, lemmas, proofs etc. are folded. (Equations are NOT
   folded, but you can configure this.)

2. *Spell checking works correctly.*
   The old syntax file erratically missed highlighting spelling errors in a
   few parts of the document. I couldn't trace down the bug, unfortunately;
   but can confirm it isn't present with this updated syntax file.

3. *Brace matching.*
   Braces denoting command arguments are highlighted differently from braces
   denoting script arguments, which in turn are highlighted differently from
   braces matching script arguments.
   Extra open braces will produce an error in the nearest `\end{...}`
   statement, and extra closed braces are flagged.

4. *Minimality.*
   I have no interest in using conceal to replace `\alpha` with `α`, or find a
   comprehensive list of commands of type X to highlight specially. Only a few
   commands (sectioning, `\ref`, `\usepackage` etc.) are treated specially.
   (You can configure a few more easily.)

## Configuration options.

`g:tex_special_commands`
: Set this to a space separated list of special commands. (I.e. commands whose
  arguments should be colored, and not spell checked.)

`g:tex_math_envs`
: Set this to a space separated list of extra environment names that start a
  math zone (e.g. equation, gather, etc.),

`g:tex_fold_envs`
: Set this to a space separated list of environment names that should start a
  fold. For one time folds, you can also use the markers `%{{{{` and `%}}}}`.

`g:tex_isk`
: `iskeyword` option for [TeX]/[LaTeX] files.

## Links.

* [Github page](https://github.com/gi1242/vim-ab-prefix)

* [Vim script page](http://www.vim.org/scripts/script.php?script_id=5049)

[TeX]: http://en.wikipedia.org/wiki/TeX

[LaTeX]: http://www.latex-project.org
