#!/bin/sh

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

while getopts "?pbc" opt; do
    case "$opt" in
    p)
        MODE="parse"
        ;;
    b)  SEP=\\
        ;;
    c)  SEP=%
        ;;
    \?) 
        echo Usage: foxpath [-p] [-b] [-c] foxpath
        echo foxpath : a foxpath expression
        echo -p      : show the parse tree, rather than evaluate the expression
        echo -b      : within the foxpath expression path and foxpath operator are swapped;
        echo           using the option: path operator = / , foxpath operator = \\
        echo           without option:   path operator = \\ , foxpath operator = /
        echo -c      : foxpath operator = / , path operator = %
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
exec basex -b mode="$MODE" -b sep="$SEP" -b foxpath="$FOXPATH" "$SCRIPT_PATH/fox.xq" -q "'&#xa;'"
