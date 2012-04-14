#!/bin/bash
# Maintainer: Mark Harrison <mark@mivok.net>
# License:    MIT/Expat - See LICENSE file for details

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

PRE_COMMANDS=""
if [[ -n $DEBUG ]]; then
    PRE_COMMANDS="let g:vimcram_debug=1"
fi

FILES=""
for i in "$@"; do
    # Escape spaces
    FILES="$FILES ${i// /\\ }"
done
vim $VIMOPTIONS -S $(dirname $0)/vimcram.vim \
    -c "$PRE_COMMANDS" -c "RunTests $FILES"
