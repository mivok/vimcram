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
