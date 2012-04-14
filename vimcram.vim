" vim:foldmethod=marker

" Debug mode setting {{{
if !exists("g:vimcram_debug")
    let g:vimcram_debug = 0
endif
" }}}

" Variables
" {{{
let s:tests_ran = []
let s:tests_failed = []
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
" s:NewScratchBuffer - Create a new buffer {{{1
function! s:NewScratchBuffer(name)
    " Set the buffer name
    let name="[".a:name."]"
    if !has("win32")
        let name = escape(name, "[]")
    endif
    " Switch buffers
    exec "silent hide edit " escape(name, ' \')
    " Set the new buffer properties to be a scratch buffer
    setlocal bufhidden=delete
    setlocal buftype=nofile
    setlocal modifiable
    setlocal noswapfile
endfunction
"1}}}

" Output/results functions
" s:InitTestOutput {{{
function s:InitTestOutput()
    " Clear and initialize variables that store output
    let s:testout = []
    let s:debugout = []
endfunction
" }}}
" s:Output {{{
function! s:Output(line)
    call add(s:testout, a:line)
    if g:vimcram_debug
        call add(s:debugout, a:line)
    endif
endfunction
" }}}
" s:Debug {{{
function s:Debug(line)
    if g:vimcram_debug
        call add(s:debugout, "DEBUG: ".a:line)
    endif
endfunction
"}}}
" s:WriteTestOut {{{
function! s:WriteTestOut(filename)
    call writefile(s:testout, a:filename.".out")
    if g:vimcram_debug
        call writefile(s:debugout, a:filename.".dbg")
    endif
endfunction
" }}}
" s:ShowResults {{{
function! s:ShowResults(filenames)
    call s:NewScratchBuffer("TestResults")
    let total_tests_ran = 0
    let total_tests_failed = 0
    let testfiles_failed = 0
    let testfiles_ran = len(s:tests_ran)
    for t in s:tests_ran
        let total_tests_ran += t
    endfor
    for t in s:tests_failed
        let total_tests_failed += t
        if t > 0
            let testfiles_failed += 1
        endif
    endfor
    call append("$", ["\# Test summary", "",
        \testfiles_ran - testfiles_failed . "/" . testfiles_ran .
        \" test files with no failed tests",
        \total_tests_ran - total_tests_failed . "/" . total_tests_ran .
        \" tests succeeded", ""])
    let test_num = 0
    for f in a:filenames
        let output = system("diff -u ".escape(f, ' \').
                    \" ".escape(f, ' \').".out")
        call append("$", "\# ".f." - " . (s:tests_ran[test_num] -
                    \s:tests_failed[test_num]) . "/" . s:tests_ran[test_num] .
                    \" tests succeeded")
        if !empty(output)
            call append("$", ["", "\#\# Diff:", ""])
            call append("$", split(output, "\n"))
            setlocal ft=diff
        endif
        if g:vimcram_debug
            call append("$", ["", "\#\# ".f." - Test debug output", ""])
            call append("$", readfile(f.".dbg"))
        endif
        call append("$", "")
        let test_num += 1
    endfor
    1d " Remove the first blank line
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
    let whole_buffer = 1 " Is the comparison against the entire buffer?
    let failed = 0
    call s:Debug("Comparing output")
    for line in a:output
        " The prefix holds anything that was part of line we want to compare,
        " but not what we want to use as part of the comparison, such as a
        " line number specification.
        let prefix = ""
        let per_line = matchlist(line, '\v^\(([0-9]+|\.|\$)\) ?')
        if !empty(per_line)
            " Output is matching a specific line
            let whole_buffer = 0 " Don't match entire buffer if line num given
            let prefix = per_line[0]
            let line = line[len(per_line[0]):]
            let curr_line = line(per_line[1])
            if curr_line == 0
                " Line number wasn't symbolic, so it must be a number
                let curr_line = per_line[1]
            endif
            call s:Debug("Comparing buffer line ".curr_line)
        endif

        if line[-3:] == ' re'
            " Regexp line (try normal match first)
            if line == getline(curr_line)
                " Plain match succeeded
                call s:Debug("Plain match succeeded on regex line")
                call s:Output("    ".prefix.line)
            elseif match(getline(curr_line), line[:-4]) != -1
                " If we succeed, print out the original regex
                call s:Debug("Regex match succeeded on regex line")
                call s:Output("    ".prefix.line)
            else
                call s:Debug("Regex match failed")
                " If we fail a regex check, print the text that failed to
                " match in the output
                let failed = 1
                call s:Output("    ".prefix.getline(curr_line))
            endif
        else
            " Normal line
            if line != getline(curr_line)
                call s:Debug("Regular line match failed")
                let failed = 1
            endif
            call s:Output("    ".prefix.getline(curr_line))
        endif
        let curr_line = curr_line + 1
    endfor
    " Hack to not compare a trailing blank line
    let lastline = line('$')
    if getline('$') == '' && a:output[-1] != ''
        let lastline = lastline - 1
    endif
    if whole_buffer && curr_line <= lastline
        call s:Debug("Failed to match entire buffer")
        for line in getline(curr_line, lastline)
            call s:Output("    ".line)
        endfor
        let failed = 1
    endif
    let s:tests_ran[-1] += 1
    let s:tests_failed[-1] += failed
endfunction
" }}}
" s:VerifyExpression {{{
function! s:VerifyExpression(exp, orig_line)
    let s:tests_ran[-1] += 1
    if eval(a:exp)
        " Expression matches
        call s:Output("    " . a:orig_line)
    else
        " Expression doesn't match
        call s:Output('    ? ' . eval(a:exp))
        let s:tests_failed[-1] += 1
    endif
endfunction
" }}}

" Main function
" s:RunTests {{{
function! s:RunTests(...)
    for f in a:000
        call add(s:tests_ran, 0)
        call add(s:tests_failed, 0)
        call s:RunTest(f)
    endfor
    call s:ShowResults(a:000)
endfunction
" }}}
" s:RunTest {{{
function! s:RunTest(filename)
    call s:NewScratchBuffer("Test ".a:filename) " Perform tests in new buffer
    call s:InitTestOutput()
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
        if index([':', '>', '@', '?'], line[0]) != -1
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
        elseif line[0] == '?'
            " Verify an expression
            call s:VerifyExpression(s:RemoveCommandChars(line), line)
        else
            call add(output, line)
        endif
    endfor
    call s:CompareExpectedOutput(output)
    call s:WriteTestOut(a:filename)
endfunction
" }}}
" RunTest command {{{
command -nargs=* RunTests :call s:RunTests(<f-args>)
" }}}
