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

Test line continuations

    @ggdG
    > Some text
    \ continued on another line
    Some text continued on another line
