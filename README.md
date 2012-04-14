# Vim Cram - better unit testing with vim

# Test file format

The test file format is based on that used in cram:

 * Tests should use the .t file extension.
 * Lines beginning with four spaces, a colon (:), and optionally a space are
   executed as a vim ex command.
 * Lines beginning with four spaces, a greater than sign (>), and optionally a
   space are inserted as text to the bottom of the file.
 * Lines beginning with four spaces, an at sign (@), and optionally a space
   are executed as normal mode commands.
 * All other lines beginning with four spaces are considered to be output
   lines and will be compared with the entire contents of the text buffer.
 * Output lines beginning with a number in parentheses will match the given
   line number, and disable matching of the entire buffer contents.
 * When specifying a line number, any subsequent lines are matched against the
   following lines in the text buffer. In other words, to match multiple
   consecutive lines in the middle of a file, you only need to specify the
   line number on the first line you intend to match.
 * When specifying a line number, the symbolic lines '.' and '$' can be used
   to specify the current line and the end of the file respectively.
 * Output lines ending with a space and the keyword (re) are matched as
   vim-style regular expressions.
 * Output lines ending with the 're' keyword are always first matched
   literally with actual command output.
 * Output lines containing a dollar sign followed by an expression inside
   curly brackets (${...}) will have the expression expanded. This allows for
   output to be dependent on the current environment, such as output
   containing today's date.
 * If the final line of a file is blank, then it is ignored when comparing the
   entire buffer contents.
 * Anything else is a comment.
