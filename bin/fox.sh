#!/bin/bash

# ====================================================================================
#
#     evaluate options
#
# ====================================================================================

# initialize defaults
MODE="eval"
SEP=/
ISFILE="false"

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

while getopts "?pbf" opt; do
    case "$opt" in
    p)
        MODE="parse"
        ;;
    b)  
        SEP=\\
        ;;
    f)  
        ISFILE="true"
        ;;
    \?) 
        echo Usage: foxpath [-p] [-b] [-f] foxpath
        echo foxpath : a foxpath expression
        echo -f      : the foxpath parameter is not a foxpath expression, but the path or URI of 
        echo '     a file containing the foxpath expression;'
        echo
        echo '     if the value of foxpath has a trailing # name, e.g.'
        echo '     foxlib.xml#niem30'
        echo 
        echo '     the substring before # identifies a foxpath lib, which is an XML file '
        echo '     containing foxpath elements with a name attribute and a foxpath expression '
        echo '     as content; the substring after # selects the foxpath element with'
        echo '     a corresponding @name attribute; example of a foxlib:'
        echo           
        echo '     <foxlib>'                   
        echo '         <foxpath name="niem30" doc="all niem-30 XSDs">'
        echo '     /xsdbase/niem-3.0//*.xsd'
        echo '         </foxpath>'
        echo '         <foxpath name="niem30-count doc="a count of all niem-30 XSDs">'
        echo '     count(/xsdbase/niem-3.0//*.xsd)'
        echo '         /foxpath>'
        echo '     </foxlib>'
        echo
        echo -p      : show the parse tree, rather than evaluate the expression
        echo -b      : within the foxpath expression path and foxpath operator are swapped;
        echo           using the option: path operator = / , foxpath operator = \\
        echo           without option:   path operator = \\ , foxpath operator = /
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
CMD="basex -b mode=$MODE -b isFile=$ISFILE -b sep=$SEP -b foxpath=$FOXPATH $SCRIPT_PATH/fox.xq"
$CMD
echo 
