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

    @ggdG
    > This is a test
    is a re

Test regex anchor matching

    ^This is a re

Test very magic option (allows + to be unescaped)

    \v^Th[si]+ re
