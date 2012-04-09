" Start vim with '-N -u NONE' to avoid sourcing user files
" vim:foldmethod=marker

" Debug mode
let s:debug = 0

" Utility functions
" s:RemoveCommandChars {{{
function! s:RemoveCommandChars(line)
    " Removes leading >, : or @, and removes any single space that follows
    if a:line[1] == ' '
        return a:line[2:]
    else
        return a:line[1:]
    endif
endfunction
" }}}

" Output/results functions
" s:Output {{{
let s:testout = []
function! s:Output(line)
    call add(s:testout, a:line)
endfunction
" }}}
" s:Debug {{{
function s:Debug(line)
    if s:debug
        call s:Output("DEBUG: ".a:line)
    endif
endfunction
"}}}
" s:WriteTestOut {{{
function! s:WriteTestOut(filename)
    call writefile(s:testout, a:filename.".out")
endfunction
" }}}
" s:ShowResults {{{
function! s:ShowResults(filename)
    let output = system("diff -u ".a:filename." ".a:filename.".out")
    set nomodified " Test output text buffer, allows quit without !
    exe "edit ".a:filename.".results"
    if empty(output)
        call setline(".", "All tests succeeded")
    else
        call setline(".", "One or more tests failed. Diff follows:")
        call append(".", split(output, "\n"))
        setlocal ft=diff
    endif
    set nomodified " Test results text buffer, allow quit without !
endfunction
" }}}

" s:CompareExpectedOutput {{{
function! s:CompareExpectedOutput(output)
    " Compare buffer contents with expected output
    if len(a:output) == 0
        return
    endif
    let lastline = line('$')
    " Hack to not compare a trailing blank line
    if getline('$') == '' && a:output[-1] != ''
        let lastline = lastline - 1
    endif
    call s:Debug("Comparing output")
    if a:output != getline(1,lastline)
        call s:Debug("Test failure: output doesn't match")
    endif
    " Write the actual output to the file
    for line in getline(1,lastline)
        call s:Output("    ".line)
    endfor
endfunction
" }}}

" Main function
" s:RunTest {{{
function! s:RunTest(filename)
    let test_script = readfile(a:filename)
    let output = []
    for line in test_script
        " Lines that aren't indented (and blank lines) are comments
        if line[0:3] != "    "
            " If a comment line comes after output, we should verify the
            " actual output here
            call s:CompareExpectedOutput(output)
            let output = []
            call s:Output(line)
            continue
        endif
        let line = substitute(line, '^    ', '', '')
        if index([':', '>', '@'], line[0]) != -1
            call s:CompareExpectedOutput(output)
            let output = []
        endif
        if line[0] == ':'
            " Command
            call s:Output("    ".line)
            exe s:RemoveCommandChars(line)
        elseif line[0] == '>'
            " Text to insert
            call s:Output("    ".line)
            call append(line('.') - 1, s:RemoveCommandChars(line))
        elseif line[0] == '@'
            " Normal mode commands
            call s:Output("    ".line)
            exe "normal ".s:RemoveCommandChars(line)
        else
            call add(output, line)
        endif
    endfor
    call s:CompareExpectedOutput(output)
    call s:WriteTestOut(a:filename)
    call s:ShowResults(a:filename)
endfunction
" }}}
" RunTest command {{{
command -nargs=1 RunTest :call s:RunTest(<args>)
" }}}
