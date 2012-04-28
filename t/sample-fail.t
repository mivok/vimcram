Note: all of the tests in this file should fail. If any succeed, then there is
a problem.

(Fails) Insert text and verify contents. Buffer contains more lines than the
comparison text.

    > foo
    > bar
    foo

(Fails) Regex match failure test

    @ggdG
    > This is a test
    This is b .* re

(Fails) Regex anchor matching with the regex itself only containing part of
the line

    ^is a$ re

(Fails) Match multiple lines starting with the end of the file:

    ($)
    foo

(Fails) Verify the value of a variable

    :let g:some_var = 2
    ? g:some_var == 1


(Fails) Test line continuation in non-matching output text
    @ggdG
    > Some text here
    Some text
    \ not here

(Fails) Test line continuation in failing expression tests
    ? 1 + 1
    \ == 3

(Fails) Test disabling regex matching
    :let g:vimcram_expandre = 0
    @ggdG
    > hello world
    wo.ld$ re
    :let g:vimcram_expandre = 1

vim: ft=vimcram
