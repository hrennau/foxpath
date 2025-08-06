#!/bin/bash

# ====================================================================================
#
#     evaluate options
#
# ====================================================================================

# initialize defaults
MODE="eval"
SEP=/

SOURCE="$0"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
	DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
	SOURCE="$(readlink "$SOURCE")"
	[[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_PATH="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

OPTS=()

while getopts "?pbcs:x:" opt; do
    case "$opt" in
    p)
        MODE="parse"
        ;;
    b)  SEP=\\
        ;;
    c)  SEP=%
        ;;
    s)  OPTS+=(-b "ispace=$2")
        ;;
    x)  OPTS+=(-b "ispaceext=$2")
        ;;
    \?)
        echo   'Usage: foxpath [-p] [-b] [-c] foxpath'
        echo   'foxpath : a foxpath expression'
        echo   '-p      : show the parse tree, rather than evaluate the expression'
        echo   '-b      : within the foxpath expression path and foxpath operator are swapped;'
        echo   '          using the option: path operator = / , foxpath operator = \'
        echo   '          without option:   path operator = \ , foxpath operator = /'
        echo   '-c      : foxpath operator = / , path operator = %%\n'
        echo   '-s infospace-dir :'
        echo   '          file path of an infospace definition document replacing the standard definition'
        echo   '-x infospaceext : '
        echo   '          file path of an infospace definition document extending the standard definition'

        exit 0
        ;;
    esac
done

FOXPATH="${!OPTIND}"

# ====================================================================================
#
#     launch query
#
# ====================================================================================
exec basex -s indent=yes -b mode="$MODE" -b sep="$SEP" -b foxpath="$FOXPATH" \
    "${OPTS[*]}" \
    "$SCRIPT_PATH/fox.xq" -q "'&#xa;'"
