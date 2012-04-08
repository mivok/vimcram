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
 * Ouput lines ending with a space and the keyword (re) are matched as
   vim-style regular expressions.
 * Output lines ending with the 're' keyword are always first matched
   literally with actual command output.
 * If the final line of a file is blank, then it is ignored when 
 * Anything else is a comment.
