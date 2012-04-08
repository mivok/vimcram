#!/bin/bash
if [[ -z $1 ]]; then
    echo "Usage: $0 [filename]"
    echo "Run a test using vimcram"
    exit 1
fi
VIMOPTIONS="-N -u NONE" # Don't load user scripts or .vimrc
vim $VIMOPTIONS -S vimcram.vim -c 'RunTest "'$1'"'
