" vim:foldmethod=marker

" Debug mode setting {{{
if !exists("g:vimcram_debug")
    let g:vimcram_debug = 0
endif
" }}}

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
    if g:vimcram_debug
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
    let output = system("diff -u ".a:filename.
        \" <(grep -v ^DEBUG: ".a:filename.".out)")
    set nomodified " Test output text buffer, allows quit without !
    exe "edit ".a:filename.".results"
    if empty(output)
        call setline(".", "\# All tests succeeded")
    else
        call setline(".", "\# One or more tests failed")
        call append("$", ["", "\#\# Diff:", ""])
        call append("$", split(output, "\n"))
        setlocal ft=diff
    endif
    if g:vimcram_debug
        call append("$", ["", "\#\# Test output:", ""])
        call append("$", readfile(a:filename.".out"))
    endif
    set nomodified " Test results text buffer, allow quit without !
endfunction
" }}}

" s:CompareExpectedOutput {{{
function! s:CompareExpectedOutput(output)
    " Compare buffer contents with expected output
    if len(a:output) == 0
        " Skip if there's no output to compare
        return
    endif
    let curr_line = 1
    let match_fail = 0
    call s:Debug("Comparing output")
    for line in a:output
        if line[-3:] == ' re'
            " Regexp line (try normal match first)
            if line == getline(curr_line)
                " Plain match succeeded
                call s:Debug("Plain match succeeded on regex line")
                call s:Output("    ".line)
            elseif match(getline(curr_line), line[:-4])
                " If we succeed, print out the original regex
                call s:Debug("Regex match succeeded on regex line")
                call s:Output("    ".line)
            else
                call s:Debug("Regex match failed")
                " If we fail a regex check, print the text that failed to
                " match in the output
                call s:Output("    ".getline(curr_line))
            endif
        else
            " Normal line
            if line != getline(curr_line)
                call s:Debug("Regular line match failed")
            endif
            call s:Output("    ".getline(curr_line))
        endif
        let curr_line = curr_line + 1
    endfor
    " Hack to not compare a trailing blank line
    let lastline = line('$')
    if getline('$') == '' && a:output[-1] != ''
        let lastline = lastline - 1
    endif
    if curr_line <= lastline
        call s:Debug("Failed to match entire buffer")
        for line in getline(curr_line, lastline)
            call s:Output("    ".line)
        endfor
    endif
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
