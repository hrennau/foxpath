#!/bin/bash

# ====================================================================================
#
#     evaluate options
#
# ====================================================================================

# initialize defaults
MODE="eval"
SEP=/

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

while getopts "?pb" opt; do
    case "$opt" in
    p)
        MODE="parse"
        ;;
    b)  SEP=\\
        ;;
    \?) 
        echo Usage: foxpath [-p] [-b] foxpath
        echo foxpath : a foxpath expression
        echo -p      : show the parse tree, rather than evaluate the expression
        echo -b      : within the foxpath expression path and foxpath operator are swapped;
        echo           using the option: path operator = / , foxpath operator = \
        echo           without option:   path operator = \ , foxpath operator = /
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
CMD="basex -b mode=$MODE -b sep=$SEP -b foxpath=$FOXPATH $SCRIPT_PATH/fox.xq"
$CMD
echo 
