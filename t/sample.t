Insert text and verify contents

    > foo
    > bar
    foo
    bar

Perform a regex comparison

    fo+ re
    bar

Delete a line (@ is normal mode text)

    @ kdd
    foo

Test plain matching with a line that ends in re

    > This is some text that ends in re
    foo
    This is some text that ends in re
