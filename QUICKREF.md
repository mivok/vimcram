# Quick reference to test creation

 * Non-indented text and blank lines are comments
 * All tests are indented 4 spaces
 * Indented text is output to test. Normally the entire contents of the buffer
   are compared.
 * Prefixes
    * `:` - ex command
    * `@` - normal mode command
    * `>` insert mode (newline is automatically inserted)
    * `?` Test an expression
    * `(1)` - Compare the buffer contents of line 1
        * ($), (.) - Last line and current line
        * This disables comparing the entire buffer contents
 * Output lines
    * `re` - at the end, enable regex output comparison
    * `${expression}` - Evaluate expression and use the result during
      comparisons.
