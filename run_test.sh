#!/bin/bash

DEBUG=
LOADRC=
while getopts "d01" opt; do
    case $opt in
        d)
            DEBUG=1
            ;;
        0)
            LOADRC=
            ;;
        1)
            LOADRC=1
            ;;
    esac
done
shift $(($OPTIND-1))

if [[ -z $1 ]]; then
    echo "Usage: $0 [options] FILENAME"
    echo "Run a test using vimcram"
    echo
    echo "Options:"
    echo "  -d  Enable debug mode"
    exit 1
fi

VIMOPTIONS=""
if [[ -z $LOADRC ]]; then
    VIMOPTIONS="-N -u NONE" # Don't load user scripts or .vimrc
fi

VIMCOMMANDS="RunTest \"$1\""
if [[ -n $DEBUG ]]; then
    VIMCOMMANDS="let g:vimcram_debug=1 | $VIMCOMMANDS"
fi

vim $VIMOPTIONS -S vimcram.vim -c "$VIMCOMMANDS"
