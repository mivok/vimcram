" Vimcram test syntax file
" Maintainer: Mark Harrison <mark@mivok.net>
" License: MIT/Expat - See LICENSE file for details

" Quit when a (custom) syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

runtime! syntax/vim.vim
unlet b:current_syntax

syn match       vcComment       /^\S.*$/
syn match       vcContinue      /^    \\/
syn region      vcExCmd         start=/^    :/ end=/^    [^\\]/me=e-5
    \ end=/^[^ ]/me=e-1 end=/^$/ contains=vcContinue,vimAddress,vimAutoCmd,vimCommand,vimExtCmd,vimFilter,vimLet,vimMap,vimMark,vimSet,vimSyntax,vimUserCmd
syn region      vcNoCmd         start=/^    @/ end=/^    [^\\]/me=e-5
    \ end=/^[^ ]/me=e-1 end=/^$/ contains=vcContinue
syn region      vcExpression    start=/^    ?/ end=/^    [^\\]/me=e-5
    \ end=/^[^ ]/me=e-1 end=/^$/
    \ contains=vcContinue,vimVar,vimFuncVar,vimString,vimNumber
syn region      vcInsert        start=/^    >/ end=/^    [^\\]/me=e-5
    \ end=/^[^ ]/me=e-1 end=/^$/ contains=vcContinue,vcExpand
syn match       vcRegex         / re$/ contained
syn match       vcPerLine       /^ *([^)]\+)/ contained
syn match       vcExpand        /\${[^}]\+}/ contained
    \ contains=vimVar,vimFuncVar,vimString,vimNumber
syn match       vcOutput        /^    [^@:?>].*$/
    \ contains=vcRegex,vcPerLine,vcExpand

hi def link     vcComment       Comment
hi def link     vcContinue      Special
hi def link     vcRegex         PreProc
hi def link     vcExCmd         Statement
hi def link     vcNoCmd         Statement
hi def link     vcExpression    Statement
hi def link     vcInsert        Statement
hi def link     vcOutput        String
hi def link     vcPerLine       PreProc
hi def link     vcExpand        Keyword

let b:current_syntax = "vimcram"
