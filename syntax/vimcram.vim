" Vimcram test syntax file
" Maintainer: Mark Harrison <mark@mivok.net>
" License: MIT/Expat - See LICENSE file for details

" Quit when a (custom) syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

syn include     @vimscript      syntax/vim.vim

syn match       vcComment       /^\S.*$/
syn match       vcContinue      /^    \\/
syn region      vcExCmd         start=/^    :/ end=/^    [^\\]/me=e-5
    \ end=/^[^ ]/me=e-1 end=/^$/ contains=vcContinue,@vimscript
syn region      vcNoCmd         start=/^    @/ end=/^    [^\\]/me=e-5
    \ end=/^[^ ]/me=e-1 end=/^$/ contains=vcContinue
syn region      vcExpression    start=/^    ?/ end=/^    [^\\]/me=e-5
    \ end=/^[^ ]/me=e-1 end=/^$/ contains=vcContinue
syn region      vcInsert        start=/^    >/ end=/^    [^\\]/me=e-5
    \ end=/^[^ ]/me=e-1 end=/^$/ contains=vcContinue
syn match       vcRegex         / re$/
syn match       vcOutput        /^    [^@:?>].*$/ contains=vcRegex

hi def link     vcComment       Comment
hi def link     vcContinue      Special
hi def link     vcRegex         PreProc
hi def link     vcExCmd         Statement
hi def link     vcNoCmd         Statement
hi def link     vcExpression    Statement
hi def link     vcInsert        Statement
hi def link     vcOutput        String

let b:current_syntax = "vimcram"
