# Vimcram - better testing with vim

Vimcram is a functional testing framework intended make testing in vim as easy
as [cram](https://bitheap.org/cram/) makes testing shell scripts.

It tries to mirror cram's test format of looking like a transcript of an
interactive session. Tests in vimcram look like this:

    Test substituting text:

        > Add some text
        > Add some more text
        :%s/some //
        Add text
        Add more text

    Test normal mode commands

        @ggdW
        @jdW
        text
        more text

## Installation/Usage

Just clone the git repository/untar to wherever you want.

If you want to include vimcram with your tests, you just need the run_test.sh
and vimcram.vim files (and a copy of the license file somehwere), and they can
be placed in the same directory as the tests themselves if desired.

To run a test, simply use the run_test.sh script:

    ./run_test.sh t/test001.t

or to run multiple tests:

    ./run_test.sh t/*.t

Vimcram will then run the tests, and display a test report showing how many
tests were run and how many succeeded/failed. If any tests fail, a diff will
be shown of the test output and the test script, showing where any problems
lie.

## Test file format

The test file format is based on that used in cram:

 * Tests should use the .t file extension.
 * Lines beginning with four spaces, a colon (:), and optionally a space are
   executed as a vim ex command.
 * Lines beginning with four spaces, a greater than sign (>), and optionally a
   space are inserted as text.
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
 * Output lines and insert lines containing a dollar sign followed by an
   expression inside curly brackets (${...}) will have the expression
   expanded.
 * If the final line of a file is blank, then it is ignored when comparing the
   entire buffer contents.
 * Anything else is a comment.

### Overriding behavior

Most of the special behavior above can be disabled by setting various
variables inside your tests. An example of where this would be useful is if
you are finding that you don't need the variable expansion feature, but you do
have a lot of text that looks like ${...} in your test input/output.

The following variables currently affect vimcram's behavior. Set them to 0 to
disable, and back to 1 to re-enable:

 * g:vimcram_expandvars - enable/disable expanding of ${...} expressions
 * g:vimcram_expandre - enable/disable regular expression matches
 * g:vimcram_per_line - enable/disable line specific matching with `(linenum)`
   at the beginning of an output line.

Example:

    Don't expand anything inside ${...}

        :let g:vimcram_expandvars = 0

    Type in the start of a shell script

        > #!/bin/bash
        > BAR=1
        > BAZ=2
        > FOO=${BAR}${BAZ}

    Now check the contents of line 4 (${BAR}${BAZ} should have been inserted
    literally and vimcram shouldn't have tried to expand them)

        (4) BAR.*BAZ re

    We can re-enable variable expansion if desired

        :let g:vimcram_expandvars = 1

## Test output

Vimcram generates an output file which should be identical to the input script
if all tests pass. If any test fails, then the output file will differ. In the
case where you are comparing buffer output, the output file will print what
was actually found. This should make it easy to change the test if the
behavior of the script you're testing has changed. For tests where it's not a
simple text comparison, the output tries to be as sensible as possible:

 * For regular expression tests, just the actual output that was found is
   shown instead.
 * For line specific tests, the actual output of the line is shown, and the
   prefix specifying the line number is kept.
 * For expression tests (? foo == bar), the result of the expression (usually
   1 or 0) is printed after the question mark.
 * If any expressions are included in the output text in a test (${foo}), then
   the expanded value is printed in the output for failing tests.
