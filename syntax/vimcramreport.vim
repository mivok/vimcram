" Vimcram report syntax file
" Maintainer: Mark Harrison <mark@mivok.net>
" License: MIT/Expat - See LICENSE file for details

" Quit when a (custom) syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

syn include @diff           syntax/diff.vim

syn match   vcrHeading      "^#.*$" contains=vcTestFail,vcTestSucceed
syn region  vcrDiff         start=/\(^## Diff:\n\)\@<=/ end=/^#/me=e-1
                            \ contains=@diff
syn region  vcrDebug         start=/^DEBUG:/ end=/$/

syn match   vcrTestFail     "[0-9]\+/[0-9]\+"
syn match   vcrTestSucceed  "\([0-9]\+\)/\1"

hi def link vcrHeading      Title
hi def link vcrDebug        Debug

hi def      vcrTestFail     guifg=red ctermfg=red gui=bold cterm=bold
hi def      vcrTestSucceed  guifg=green ctermfg=green gui=bold cterm=bold
