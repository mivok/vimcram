Insert text and verify contents

    > foo
    > bar
    foo
    bar

Perform a regex comparison

    fo\+ re
    bar

Delete a line (@ is normal mode text)

    @ kdd
    foo

Test plain matching with a line that ends in re

    > This is some text that ends in re
    foo
    This is some text that ends in re

Test regex matching on part of the line

    :silent %d
    > This is a test
    is a re

Test regex anchor matching

    ^This is a re

Test very magic option (allows + to be unescaped)

    \v^Th[si]+ re

Perform a line specific comparison

    > This is line 2
    > This is line 3
    > This is line 4
    (1) This is a test
    (3) This is line 3

Perform a line specific regex comparison

    (2) line 2 re

Symbolic lines (delete last blank line first)

    @Gddgg
    (.) This is a test
    ($) This is line 4

Compare multiple lines, only specifying line number for the first

    (2) This is line 2
    This is line 3

Verify an expression

    :let g:some_var=1
    ? g:some_var == 1

Test expressions/variables in output

    (2) This is line ${1+1}

Test abbreviations when inserting

    @ggdG
    :iab foo bar
    > foo
    bar

Test a more complex expression involving today's date.

    @ggdG
    :iab ds <C-R>=strftime("%Y-%m-%d")
    > ds
    ($) ${strftime("%Y-%m-%d")}

Test line continuation in inserted text

    @ggdG
    > Some text
    \ continued on another line
    Some text continued on another line

Test line continuation in output text
    @ggdG
    > Some text here
    Some text
    \ here

Test line continuation in expression tests
    ? 1 + 1
    \ == 2

Test line continuation in normal mode

    > Some text that will be deleted
    @gg
    \dG
    > Some text
    Some text

Test line continuation in ex commands

    :let g:test_line_cont = "abc"
    \ . "defg"
    ? g:test_line_cont == "abcdefg"

Test variable expansion in output

    @ggdG
    :let g:test_foo = "hello"
    > hello
    ${g:test_foo}

Test variable expansion during insert

    @ggdG
    > ${g:test_foo}
    hello

Test disabling variable expansion during insert (a literal ${g:test_foo}
should be inserted)

    @ggdG
    :let g:vimcram_expandvars = 0
    > ${g:test_foo}
    test_foo}$ re

Test disabling variable expansion in output (a literal ${g:test_foo}
should be matched). Makes use of text already inserted from previous test.

    ${g:test_foo}
    :let g:vimcram_expandvars = 1

vim: ft=vimcram
