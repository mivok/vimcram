" vim:foldmethod=marker
" Maintainer: Mark Harrison <mark@mivok.net>
" License:    MIT/Expat - See LICENSE file for details

" Debug mode setting {{{
if !exists("g:vimcram_debug")
    let g:vimcram_debug = 0
endif
" }}}

" Variables/global settings
" {{{
let g:vimcram_expandvars = 1 " Perform ${foo} expansion
let g:vimcram_expandre = 1   " Perform regex expansion
let g:vimcram_per_line = 1   " Recognize per-line output
" }}}
" Script-local variables {{{
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
" s:ExpandLine - Expand expressions of the form ${expression} {{{
function! s:ExpandLine(line)
    if ! g:vimcram_expandvars
        return a:line
    endif

    let raw_line = a:line
    let line=substitute(a:line, '\${\([^}]\+\)}', '\=eval(submatch(1))', "g")
    if line != raw_line
        call s:Debug("Expanded line: " . line)
    endif
    return line
endfunction
" }}}

" Output/results functions
" s:InitTestOutput {{{
function s:InitTestOutput()
    " Clear and initialize variables that store output
    let s:testout = []
    let s:debugout = []
endfunction
" }}}
" s:OutputList {{{
function! s:OutputList(lines)
    " Outputs a list as multiple lines
    call extend(s:testout, a:lines)
    if g:vimcram_debug
        call extend(s:debugout, a:lines)
    endif
endfunction
" }}}
" s:Output {{{
function! s:Output(line)
    call s:OutputList([a:line])
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
function! s:CompareExpectedOutput(output, raw_output)
    " Compare buffer contents with expected output
    if len(a:output) == 0
        " Skip if there's no output to compare
        return
    endif
    let curr_line = 1
    let whole_buffer = 1 " Is the comparison against the entire buffer?
    let failed = 0
    call s:Debug("Comparing output")
    for idx in range(len(a:output))
        let line = a:output[idx]
        let raw_lines = a:raw_output[idx]
        " The prefix holds anything that was part of line we want to compare,
        " but not what we want to use as part of the comparison, such as a
        " line number specification.
        let prefix = ""
        let per_line = matchlist(line, '\v^\(([0-9]+|\.|\$)\) ?')
        if !empty(per_line) && g:vimcram_per_line == 1
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

        " Expand any variables/expressions in the line
        let line = s:ExpandLine(line)

        if line[-3:] == ' re' && g:vimcram_expandre == 1
            " Regexp line (try normal match first)
            if line == getline(curr_line)
                " Plain match succeeded
                call s:Debug("Plain match succeeded on regex line")
                call s:OutputList(raw_lines)
            elseif match(getline(curr_line), line[:-4]) != -1
                " If we succeed, print out the original regex
                call s:Debug("Regex match succeeded on regex line")
                call s:OutputList(raw_lines)
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
                call s:Output("    ".prefix.getline(curr_line))
            else
                call s:OutputList(raw_lines)
            endif
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
function! s:VerifyExpression(exp, raw_lines)
    let s:tests_ran[-1] += 1
    if eval(a:exp)
        " Expression matches
        call s:OutputList(a:raw_lines)
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
    let raw_output = [] " Raw output text (no expanded line continuations)
    let old_line = ""
    let raw_lines = [] " Current line(s) without expanded line continuations
    for linenum in range(len(test_script))
        let line = test_script[linenum]
        " Lines that aren't indented (and blank lines) are comments
        if line[0:3] != "    "
            " If a comment line comes after output, we should verify the
            " actual output here
            call s:CompareExpectedOutput(output, raw_output)
            let output = []
            let raw_output = []
            call s:Output(line)
            continue
        endif
        let raw_line = line
        let line = substitute(line, '^    ', '', '')
        " Deal with line continuations
        if old_line != "" && line[0] == '\'
            let line = old_line . line[1:]
            let old_line = ""
            call add(raw_lines, raw_line)
            call s:Debug("Line continuation: " . line)
        else
            " We've not just done a line continuation, so reset the raw lines
            " var to be just the current line.
            let raw_lines = [raw_line]
        endif
        if linenum < (len(test_script) - 1) &&
            \ test_script[linenum + 1][:4] == '    \'
            " If the next line is a continuation of this, store the current
            " line and let the next iteration deal with stiching the line
            " together
            let old_line = line
            continue
        endif
        if index([':', '>', '@', '?'], line[0]) != -1
            call s:CompareExpectedOutput(output, raw_output)
            let output = []
            let raw_output = []
        endif
        if line[0] == ':'
            " Command
            call s:OutputList(raw_lines)
            exe s:RemoveCommandChars(line)
        elseif line[0] == '>'
            " Text to insert
            call s:OutputList(raw_lines)
            exe "normal i". s:ExpandLine(s:RemoveCommandChars(line)) . "\<CR>"
        elseif line[0] == '@'
            " Normal mode commands
            call s:OutputList(raw_lines)
            exe "normal ".s:RemoveCommandChars(line)
        elseif line[0] == '?'
            " Verify an expression
            call s:VerifyExpression(s:RemoveCommandChars(line), raw_lines)
        else
            call add(output, line)
            " Raw output is a nested list
            call add(raw_output, raw_lines)
        endif
    endfor
    call s:CompareExpectedOutput(output, raw_output)
    call s:WriteTestOut(a:filename)
endfunction
" }}}
" RunTest command {{{
command -nargs=* RunTests :call s:RunTests(<f-args>)
" }}}
