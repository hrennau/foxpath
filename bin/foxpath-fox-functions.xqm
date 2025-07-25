module namespace f="http://www.foxpath.org/ns/fox-functions";
import module namespace i="http://www.ttools.org/xquery-functions" 
at "foxpath-processorDependent.xqm",
   "foxpath-uri-operations.xqm",
   "foxpath-parser.xqm";

import module namespace uth="http://www.foxpath.org/ns/urithmetic" 
at  "foxpath-urithmetic.xqm";

import module namespace util="http://www.ttools.org/xquery-functions/util" 
at  "foxpath-util.xqm";

import module namespace use="http://www.foxpath.org/ns/unified-string-expression" 
at  "foxpath-unified-string-expression.xqm";

import module namespace const="http://www.foxpath.org/ns/constants" 
at  "foxpath-constants.xqm";


(:~
 : Writes a set of standard attributes. Can be useful when working
 : with `xelement`.
 :
 : @param context the current context
 : @param flags flags signaling which attributes are required
 : @return the attributes
 :)
declare function f:atts($context as item(), $flags as xs:string)
        as attribute()* {
    if (contains($flags, 'b')) then
        let $uri :=
            if ($context instance of xs:anyAtomicType) then $context
            else $context ! base-uri(.)
        return
            attribute xml:base {$uri},
    if (contains($flags, 'j')) then
        if (not($context instance of node())) then ()
        else
            let $jpath := f:namePath($context, (), 'jname')
            return attribute jpath {$jpath}
};

(:~
 : Returns the annotated local names of nodes. In case of attributes
 : the annotated local name is the local name preceded by an '@'
 : character. In case of elements the annotated local name is equal
 : to the local name.
 :
 : @param nodes nodes
 : @return the node names
 :)
declare function f:alname($nodes as node()*)
        as xs:string* {
    $nodes ! (self::attribute()/'@' || local-name())        
};

(:~
 : Returns the annotated lexical names of nodes. In case of attributes
 : the annotated lexical name is the lexical name preceded by an '@'
 : character. In case of elements the annotated lexical name is equal
 : to the lexical name. The lexical name is the name returned by
 : the standared function name(). It consists of the local name,
 : optionally preceded by name prefix and a colon.
 :
 : @param nodes nodes
 : @return the node names
 :)
declare function f:aname($nodes as node()*)
        as xs:string* {
    $nodes ! (self::attribute()/'@' || name())        
};

(:~
 : Annotates a value, appending information surrounded
 : by prefix and postfix.
 :
 : @param value a value item
 : @param anno the annotation
 : @param prefix string inserted between value and annotation
 : @param postfix string appended to the annotation
 : @return concatenation of value, prefix, annotation, postfix
 :)
declare function f:annotate($value as item()?,
                            $anno as item()?,
                            $prefix as xs:string?,
                            $postfix as xs:string?)
        as xs:string? {
    if (empty($value)) then () else
    
    let $prefix := ($prefix, ' (')[1]
    let $postfix := ($postfix, ')')[1]
    return $value||$prefix||$anno||$postfix
};        

(:~
 : Inserts nodes into a document. The receiving nodes are selected 
 : by an expression evaluated in the context of the input node, or the 
 : document node in case of an input URI. The received content is provided 
 : by an expression evaluated in the context of the receiving node. Optionally, 
 : the received content is wrapped in an element or attribute with a name 
 : provided by an expression also evaluated in the context of the receiving 
 : node.
 :
 : @param item a node or a document URI
 : @param insertWhereExpr a Foxpath expression selecting the nodes receiving new 
 :   content
 : @param insertWhatExpr a Foxpath expression providing new content
 : @param wrapExpr a Foxpath expression providing the name of an optional
 :   wrapper element or attribute
 : @param options options controling processing details
 :   att - node kind of wrapper node is attribute
 :   elem - node kind of wrapper node is element 
 :   first - new content is inserted as first child node of receiving node 
 :   last - new content is inserted as first child node of receiving node
 :   before - new content is inserted as sibling immediate preceding the receiving node 
 :   after - new content is inserted as sibling immediate following the receiving node 
 : @param processingOptions options controling the Foxpath processor 
 : @return the augmented document
 :)
declare function f:insertNodes($items as item()*,
                               $insertWhereExpr as item(),
                               $insertWhatExpr as item(),
                               $nodeName as xs:string?,
                               $fnOptions as xs:string?,
                               $options as map(*))
        as item()* {
    if (empty($items)) then () else
    
    let $ops := f:getOptions($fnOptions, ('first', 'last', 'before', 'after', 'base', 'foreach'), 'insert-nodes')
    let $insertionPoint := ($ops[. = ('first', 'last', 'before', 'after')], 'last')[1]
    let $nodeKind := $nodeName ! (if (starts-with(., '@')) then 'att' else 'elem')
    let $nodeName := $nodeName ! replace(., '^@', '')
    let $withBaseUri := $ops = 'base'
    let $foreach := $ops = 'foreach'
    
    for $item in $items   
    let $isDocResource := uth:instanceOfDocResource($item)
    let $node := uth:itemToNode($item, $options)
    let $resultDoc :=  
        copy $node_ := $node
        modify
            let $receivingNodes := f:resolveFoxpath($node_, $insertWhereExpr, $options)
            for $rnode in $receivingNodes
            let $ivalue := f:resolveFoxpath($rnode, $insertWhatExpr, $options)
            let $inodes :=
                if (not($nodeName)) then 
                    for $item in $ivalue
                    return if ($item instance of node()) then $item else text {$item}
                else
                    if ($nodeKind eq 'att') then attribute {$nodeName} {$ivalue} 
                    else if ($foreach) then $ivalue ! element {$nodeName} {.}
                    else element {$nodeName} {$ivalue}
            return (
                for $inode in $inodes
                return
                    switch($insertionPoint)
                    case 'first' return insert node $inode as first into $rnode 
                    case 'before' return insert node $inode before $rnode
                    case 'after' return insert node $inode after $rnode
                    default return insert node $inode as last into $rnode
                ,
                if (not($withBaseUri)) then () else
                    let $targetElem := $node_/root()/descendant-or-self::*[1]
                    return
                        if ($targetElem/@xml:base) then () else
                            insert node attribute xml:base {$targetElem/base-uri(.)} into $targetElem              
            )                        
        return $node_
    let $result :=
        if ($isDocResource) then uth:updateDocResourceContent($item, $resultDoc)
        else $resultDoc
    return $result
 };

(:~
 : Returns the names of folders containing a resource identified by $item. Parameter
 : $distance specifies the number of containing folders ($distance ge 1). A value
 : of 1, 2, 3, ... selects the closest, the two closest, the three closest folders,
 : and so forth. The folder names are returned in the order of containing before 
 : contained.
 :
 : @param item a node or a URI
 : @param distance identifies the number of folders to be reported
 : @return folder names, with a containing folder preceding the folders contained
 :)
declare function f:baseUriDirectories($item as item(), $distance as xs:integer?)
        as xs:string* {
    if ($distance eq 1) then f:baseUriDirectory($item)
    else if ($distance gt 1) then    
        let $baseUri := 
            (if ($item instance of node()) then $item else i:fox-doc($item, ()))
            ! base-uri(.) ! replace(., '\\', '/')
        let $resources := tokenize($baseUri, '/')
        return subsequence($resources, count($resources) - $distance - 1, $distance)
    else ()            
};

(:~
 : Extracts from a base URI the name of the containing directory.
 :
 : @param item a node or a URI
 : @return the name of the containing directory 
 :)
declare function f:baseUriDirectory($item as item())
        as xs:string? {
    (if ($item instance of node()) then $item else i:fox-doc($item, ()))
    ! base-uri(.) ! replace(., '(^|.*/)([^/]*)/[^/]*$', '$2', 'x')
};

declare function f:baseUriFileName($item as item())
        as xs:string {
    (if ($item instance of node()) then $item else i:fox-doc($item, ()))
    ! base-uri(.) ! file:name(.)
};

(:~
 : Returns the base URI relative to a context.
 :
 : This is an early version where the context can only be
 : specified by a name pattern identifying the name of
 : the context step. 
 :
 : @param item a node or a URI
 : @param context as xs:string*
 : @return relative URI
 :)
declare function f:baseUriRelative($item as item(), $contextName as xs:string)
        as xs:string* {
    let $regex := util:glob2regex($contextName)        
    let $baseUri := 
        (if ($item instance of node()) then $item else i:fox-doc($item, ()))
         ! base-uri(.) ! replace(., '\\', '/')        
    let $steps := tokenize($baseUri, '/')
    let $countSteps := count($steps)
    let $lastMatchingStep := (for $i in 1 to $countSteps return $steps[$i][matches(., $regex, 'i')] ! $i)[last()]
    return
        if (empty($lastMatchingStep)) then $baseUri
        else if ($lastMatchingStep eq $countSteps) then '.'
        else string-join($steps[position() gt $lastMatchingStep], '/')
};

(:~
 : Returns all atomic items occurring in the first value and in the second value. 
 :
 : @param leftValue a value
 : @param rightValue another value 
 : @return the items occurring in both values
 :)
declare function f:bothValues($leftValue as item()*,
                              $rightValue as item()*)
    as item()* {
    $leftValue[. = $rightValue] => distinct-values() => sort()
};

(:~
 : Edits a text, replacing forward slashes by back slashes.
 :
 : @param arg text to be edited
 : @return edited text
 :)
declare function f:bslash($arg as xs:string?)
        as xs:string? {
    replace($arg, '/', '\\')        
};      

(:~
 : Creates a character class report.
 :)
declare function f:charClassReport($items as item()*,
                                   $classes as xs:string?,
                                   $options as xs:string?)
        as element(charClassReport) {
    let $ops := f:getOptions($options, ('example', 'parent', 'fname', 'text', 'att'), 'char-class-report')
    let $nodes := 
        if (not($ops = 'example')) then ()
        else 
            let $wrapperNodes := $items[. instance of node()]
            return
                if ($ops = 'att') then $wrapperNodes//@*
                else $wrapperNodes/descendant-or-self::text()
    let $texts :=
        for $item in $items
        return
            if (not($item instance of node())) then string($item)
            else if ($ops = 'att') then $item//@* => string-join('')
            else if ($ops = 'anynode') then $item/string()||($item//@* => string-join(''))
            else $item/string()
    let $classes := $classes ! lower-case(.)
    let $classes :=
        let $letters :=
            if ($classes and not(contains($classes, 'l'))) then () else
            let $charStat :=
                $texts ! replace(., '\P{L}', '') => f:charStat($nodes, $options)
            return <letters>{$charStat}</letters>
        let $marks :=
            if ($classes and not(contains($classes, 'm'))) then () else
            let $charStat :=
                $texts ! replace(., '\P{M}', '') => f:charStat($nodes, $options)
            return <marks>{$charStat}</marks>
        let $numbers :=
            if ($classes and not(contains($classes, 'n'))) then () else
            let $charStat :=
                $texts ! replace(., '\P{N}', '') => f:charStat($nodes, $options)
            return <numbers>{$charStat}</numbers>
        let $punctuation :=
            if ($classes and not(contains($classes, 'p'))) then () else
            let $charStat :=
                $texts ! replace(., '\P{P}', '') => f:charStat($nodes, $options)
            return <punctuation>{$charStat}</punctuation>
        let $separators :=
            if ($classes and not(contains($classes, 'z'))) then () else
            let $charStat :=
                $texts ! replace(., '\P{Z}', '') => f:charStat($nodes, $options)
            return <separators>{$charStat}</separators>
        let $symbols :=
            if ($classes and not(contains($classes, 's'))) then () else
            let $charStat :=
                $texts ! replace(., '\P{S}', '') => f:charStat($nodes, $options)
            return <symbols>{$charStat}</symbols>
        let $other :=
            if ($classes and not(contains($classes, 'c'))) then () else
            let $charStat :=
                $texts ! replace(., '\P{C}', '') => f:charStat($nodes, $options)
            return <other>{$charStat}</other>
        return
            <classes>{
                $letters, $marks, $numbers, $punctuation,
                $separators, $symbols, $other
            }</classes>
    return 
        <charClassReport>{
            $classes
        }</charClassReport>
};

(:~
 : Creates a simple character usage statistic. For each character
 : the string representation, the unicode codepoint and the number
 : of occurrences is given.
 :)
declare function f:charStat($texts as xs:string*,
                            $nodes as node()*,
                            $options as xs:string?) {
    let $ops := f:getOptions($options, ('example', 'parent', 'fname', 'text', 'att'), 'char-stat')                            
    let $fnGetExamples :=
        if (not($ops = 'example')) then () else
        let $size := 3 return
        function($charval) {
            for $node in $nodes[contains(., $charval)][position() le $size]
            let $node := if ($ops = 'parent') then $node/../.. else $node
            let $charpos := substring-before($node, $charval) ! (1 + string-length(.))
            let $fname :=
                if (not($ops = 'fname')) then () else
                    $node ! base-uri(.) ! file:name(.) ! (attribute fname {.})
            return
                $node ! <example charpos="{$charpos}">{$fname, $node/string()}</example>
        }
    let $chars := 
        for $text in $texts
        for $i in 1 to string-length($text) 
        return substring($text, $i, 1)  
    let $charReports := 
        for $char in $chars
        let $charval := $char
        group by $charval
        order by $charval
        return <char s="{$charval}" 
                     code="{string-to-codepoints($charval)}" n="{count($char)}">{
                   $fnGetExamples ! .($charval)                     
               }</char>
    return
        <chars n="{count($charReports)}">{
            $charReports
        }</chars>
};

(:~
 : Maps a string to a sequence of characters, represented
 : by strings of length 1.
 :)
declare function f:chars($string as xs:string?)
        as xs:string* {
    for $i in 1 to string-length($string) return substring($string, $i, 1)                  
};

(:~
 : Returns the concatenated text nodes immediately contained by a
 : given sequence of element nodes.
 :
 : If option 'ign-wsonly' is used, only text nodes containing non-WS
 : are considered.
 :)
declare function f:childText($elems as element()*,
                             $options as xs:string?) {
    let $ops := f:getOptions($options, ('ign-wsonly'), 'child-text')
    let $tnodes :=
        if ($ops = 'ign-wsonly') then $elems/text()[normalize-space(.)]
        else $elems/text()
    return $tnodes => string-join('')        
};

(:~
 : Concatenates values.
 :
 : Options:
 : - 'distinct': use distinct values.
 : - 'sort': sort values
 :
 : @param values the values to be concatenated
 : @param sep the separator
 : @options options
 :)
declare function f:concatValues($values as item()*,
                                $sep as xs:string?,                                
                                $options as xs:string?) {
    let $ops := f:getOptions($options, ('distinct', 'sort', 'numsort'), 'concat-values')
    let $val := if ($ops = 'distinct') then $values => distinct-values() else $values
    let $val := 
        if ($ops = 'sort') then $val => sort()
        else if ($ops = 'numsort') then $val => sort((), function($item) {try{$item ! number(.)} catch * {}})
        else $val
    return $val ! string(.) => string-join($sep)
};

(:~
 : Checks if two or more nodes have deep-equal content. The content to be
 : compared can be restricted by the $scope parameter.
 :
 : scope s - compare the items themselves
 : scope c - compare content, that is, attributes and child nodes
 : scope n - compare child nodes
 : scope a - compare attributes
 :
 : @param items the items to be checked
 : @param scope specifies which part of the content to compare
 : @return false if there is a pair of items which do not have deep-equal content, true otherwise
 :)
declare function f:contentDeepEqual($items as item()*, 
                                    $scope as xs:string?,
                                    $options as xs:string?)
        as xs:boolean? {
    (:
    let $_DEBUG := trace($items, 'ITEMS: ')        
    let $_DEBUG := trace($scope, 'SCOPE: ')
     :)
     
    let $docs :=
        for $item in $items return
            if ($item instance of node()) then $item
            else i:fox-doc($item, ())/*
    let $count := count($docs)
    return if ($count le 1) then () else
    
    let $scope := ($scope[string()], 'c')[1]
    return if ($scope eq 's' and $count eq 2) then deep-equal($docs[1], $docs[2]) else
    
    let $fn_cmp :=
        switch($scope)
        case 'c' return
            function($item1, $item2) {
                let $atts1 := for $a in $item1/@* order by local-name($a), namespace-uri($a), string($a) return $a
                let $atts2 := for $a in $item2/@* order by local-name($a), namespace-uri($a), string($a) return $a
                return deep-equal($atts1, $atts2) and deep-equal($item1/node(), $item2/node())
            }
        case 'n' return
            function($item1, $item2) {deep-equal($item1/node(), $item2/node())}
        case 'a' return
            function($item1, $item2) {
                let $atts1 := for $a in $item1/@* order by local-name($a), namespace-uri($a), string($a) return $a
                let $atts2 := for $a in $item2/@* order by local-name($a), namespace-uri($a), string($a) return $a
                return deep-equal($atts1, $atts2)
            }
        case 's' return 
            function($item1, $item2) {deep-equal($item1, $item2)}
        default return error((), 'Unknown scope: '||$scope||' ; must be one of: c|n|a|s')    
    return    
        every $i in 1 to $count - 1 satisfies
            let $item1 := $docs[$i]
            let $item2 := $docs[$i + 1]
            return $fn_cmp($item1, $item2)
};      

(:~
 : Returns the number of occurrences of a character in a string
 :
 : @param s a string
 : @param char a character
 : @return the number of times the character occurs in the string
 :)
declare function f:countChars($s as xs:string?, $char as xs:string?)
        as xs:integer? {
    let $char := replace($char, '[\^\-(){}\[\]]', '\\$0')
    let $s2 := replace($s, $char, '')        
    return string-length($s) - string-length($s2)        
};

(:~
 : Returns the depth of a node in the hierarchical structure. The root element
 : has depth 1, its child elements have depth2, etc. Document nodes have depth 
 : 0, non-element nodes have the depth of their parent element. If the input 
 : item is not a node, the empty sequence is returned.
 : 
 : Formally: the depth is the number of ancestor-or-self element nodes.
 :
 : @param an item
 : @return the node depth
 :)
declare function f:depth($item as item())
        as xs:integer? {
    if (not($item instance of node())) then () 
    else $item/count(ancestor-or-self::*)
};

(:~
 : Returns the XML representation of a docx document.
 :
 : @param uri the URI of the .docxfile
 : @return the XML document
 :)
declare function f:docxDoc($uri as xs:string)
        as document-node()? {
    archive:extract-text(i:fox-binary($uri, ()), 'word/document.xml')   
    ! parse-xml(.)
};

(:~
 : Groups a sequence of items, obtaining the grouping key from an expression
 : evaluated in the context of the items to be grouped.
 :
 : @param items the items to group
 : @param groupKeyExpr expression returning the grouping key
 : @param wrapperName the grouped items are wrapped in an element
 :   with this name; if the value is delimited by { and }, it is
 :   interpreted as a Foxpath expression evaluated in the context
 :   of the current key 
 : @param keyName name of attributes storing the group keys
 : @options options controling function behavior
 : @processingOptions processing options
 : @return for each group an element containing the grouped items
 :)
declare function f:groupItems($items as item()*,
                              $groupKeyExpr as item()?,
                              $groupProcExpr as item()?,
                              $groupWhereExpr as item()?,
                              $keyName as xs:string?,
                              $groupElemSpec as item()?,
                              $wrapperElemName as xs:string?,                              
                              $orderBy as xs:string?,                              
                              $options as xs:string?,
                              $processingOptions as map(*))
        as node()* {
    if (empty($items)) then () else
    
    let $groupKeyExpr := ($groupKeyExpr, '.')[1]
    
    let $groupElemNameExpr := $groupElemSpec[. instance of node()]
    let $groupElemName := 
        if ($groupElemNameExpr) then () else ($groupElemSpec, 'group')[1]
    let $wrapperElemNameEff := ($wrapperElemName, 'groups')[1]    
    let $keyName := ($keyName, 'key')[1]
    let $itemsQname := QName((), 'items')
    let $groups :=
        for $item in $items
        let $key := f:resolveFoxpath($item, $groupKeyExpr, $processingOptions)
        group by $key
        where if (empty($groupWhereExpr)) then true() else
            f:resolveFoxpath($key, $groupWhereExpr, map{$itemsQname: $item}, $processingOptions)
            
        let $groupContent :=
            if (not($groupProcExpr)) then $item
            else f:resolveFoxpath($key, $groupProcExpr, map{$itemsQname: $item}, $processingOptions)
        let $groupElemNameEff := 
            if ($groupElemNameExpr) then f:resolveFoxpath(
                $key, $groupElemNameExpr, map{$itemsQname: $item}, $processingOptions)
            else $groupElemName
        order by if (not($orderBy)) then ()
                 else
                     switch($orderBy)
                     case 's' return string($key)
                     case 'n' return $key (:  ! try {number(.)} catch * {()} :)
                     default return ()
        return
            element {$groupElemNameEff} {
                attribute {$keyName} {$key}[not($keyName eq '#none')],
                for $item in $groupContent  return
                    typeswitch ($item) 
                        case document-node() | element() return $item 
                        case attribute() return $item
                        default return <item>{$item}</item>
            }
    return
        element {$wrapperElemName} {
            attribute count {count($groups)},
            $groups
        }
 };

(:~
 : Compares two or more nodes for deep equality. The nodes can be
 : supplied as nodes or as document URI.
 :
 : @param items nodes and or document URIs
 : @return true if all nodes are deep-equal, false otherwise
 :)
declare function f:nodesDeepEqual($items as item()*)
        as xs:boolean? {
    let $count := count($items) return        
    if ($count lt 2) then () else

    let $nodes :=
        for $item in $items return 
            if ($item instance of node()) then $item else i:fox-doc($item, ())
    return
        if ($count eq 2) then deep-equal($nodes[1], $nodes[2])
        else
            every $result in
                for $node at $pos in $nodes[position() lt last()]
                return deep-equal($node, $nodes[$pos + 1])
            satisfies $result
};

(:~
 : Compares two or more nodes for deep similarity. The nodes can be
 : supplied as nodes or as document URI.
 :
 : Deep similarity means that after removing nodes selected by
 : supplied expressions, the compared nodes are deep-equal.
 :
 : @param items nodes and or document URIs
 : @param excludeExprs expressions excluding nodes
 : @return true if all nodes are deep-similar, false otherwise
 :)
declare function f:nodesDeepSimilar($items as item()+,
                                    $excludeExprs as item()*,
                                    $processingOptions as map(*))
        as xs:boolean? {
    let $count := count($items) return        
    if ($count lt 2) then () else

    let $nodes := 
        for $item in $items return 
            if ($item instance of node()) then $item else i:fox-doc($item, ())
    return
        if ($count eq 2) then f:nodePairDeepSimilar($nodes[1], $nodes[2], $excludeExprs, $processingOptions)
        else
            every $result in
                for $node at $pos in $nodes[position() lt last()]
                return f:nodePairDeepSimilar($node, $nodes[$pos + 1], $excludeExprs, $processingOptions)
            satisfies $result
};

declare function f:nodePairDeepSimilar($node1 as node(), 
                                       $node2 as node(), 
                                       $excludeExprs as item()*,
                                       $processingOptions as map(*))
        as xs:boolean {
    if (empty($excludeExprs)) then deep-equal($node1, $node2) else
    
    let $fnPrune := function($node) {
        copy $node_ := $node
        modify
            let $delNodes :=
                $excludeExprs ! f:resolveFoxpath($node_, ., $processingOptions)
                [. instance of node()]
            (: let $_DEBUG := trace($delNodes, '_DEL_NODES: ') :)
            return 
                if (empty($delNodes))then () else
                    delete nodes $delNodes
        return $node_
    }
    let $n1 := $fnPrune($node1) ! util:prettyNode(., ())
    let $n2 := $fnPrune($node2) ! util:prettyNode(., ())
    return deep-equal($n1, $n2)                    
};

(:~
 : Returns true if the file identified by a URI or file path
 : contains a pattern. The pattern is interpreted as a 
 : pattern-or-regex string - a Glob pattern or regex text, followed
 : by optional flags preceded by '#'. 
 :
 : If the pattern is a Glob pattern, characters \ and # must be escaped 
 : by a preceding slash. 
 :
 : Flags:
 : r - pattern is a regular expression
 : c - matching case-sensitive
 :
 : Example patterns:
 : 'Kap*'         # glob pattern
 : 'Kap*#c        # glob pattern, case-sensitive
 : 'Kap.*#r'      # regex
 : 'Kap.*l#cr'    # regex, case-sensitive 
 : '5|Kap*'       # glob pattern; | character is literal 
 : '5|Kap.*#r'    # regex; | character is regex operator (or)
 : 'x\#y'         # glob pattern containing a literal # character
 : 'x\#y#c'       # as before, case-sensitive
 :
 : @param uri the file URI
 : @param pattern the string pattern
 : @param encoding an encoding
 : @param globolOptions for future use
 : @return true or false
 :)
declare function f:fileContains($uri as xs:string,
                                $pattern as xs:string,
                                $encoding as xs:string?,
                                $globalOptions as map(*)?)
        as xs:boolean {
    let $text := i:fox-unparsed-text($uri, $encoding, $globalOptions)
    let $regexAndFlags := util:glob2regex($pattern, false(), true())
        (: anchors false; dot-all true :)
    let $regex := $regexAndFlags[1]
    let $flags := $regexAndFlags[2]
    return matches($text, $regex, string($flags))
};      

(:~
 : Returns the text content of a file resource.
 :
 : @param uri the file URI
 : @param encoding an encoding
 : @param options for future use
 : @return the text content
 :)
declare function f:fileContent($uri as xs:string?, 
                               $encoding as xs:string?,
                               $options as map(*)?)
        as xs:string? {
    let $redirectedRetrieval := i:fox-unparsed-text_github($uri, $encoding, $options)
    return
        if ($redirectedRetrieval) then $redirectedRetrieval
        else i:fox-unparsed-text($uri, $encoding, $options)
};      

(:~
 : Copies files and/or folders to a target URI. If a source URI is a folder URI, 
 : the target URI must be a folder URI or a non-existing URI. If all source URIs
 : are file URIs, the target URI may be a folder URI or a file URI.
 :
 : Flags:
 : o - copy overwrites existing file
 : d - non-existing URI is interpreted as folder URI, and the folder is created;
 :     non-existing parent folders are also created
 : c - non-existing URI is interpreted as file URI, and non-existing parent 
 :     folders are created
 :
 : @param sourceUris URIs of files to be copied
 : @param targetUri target URI, which may be a file or folder URI
 : @flags flags controlling the copy
 : @return empty sequence; as a side effect, file copies are performed
 :)
declare function f:fileCopy($sourceUris as xs:string*,
                            $targetUri as xs:string,
                            $flags as xs:string?)
        as empty-sequence() {
    if (empty($sourceUris)) then () else        
    for $sourceUri in $sourceUris return
    
    let $sourceUriDomain := i:uriDomain($sourceUri, ())
    return
        if (not($sourceUriDomain eq 'FILE_SYSTEM')) then 
            error(QName((), 'INVALID_CALL'),
                concat('Function file-copy() expects a source file from the ',
                  'file system; file URI: ', $sourceUri))
            else

    let $targetUriDomain := i:uriDomain($targetUri, ())
    return
        if (not($targetUriDomain eq 'FILE_SYSTEM')) then 
            error(QName((), 'INVALID_CALL'),
                concat('Function file-copy() expects a target folder in the ',
                  'file system; target dir URI: ', $targetUri))
            else
            
    (: Target URI exists :)        
    if (i:fox-file-exists($targetUri, ())) then
        if (i:fox-is-file($targetUri, ()) and i:fox-is-dir($sourceUri, ())) then
             error(QName((), 'INVALID_CALL'), concat('Cannot copy a folder URI ',
                 'to a file URI; target URI: ', $targetUri))
        else if (i:fox-is-file($targetUri, ()) and not(contains($flags, 'o'))) then
             error(QName((), 'INVALID_CALL'), concat('Target file exists; use flag "o" ',
                 'if you want to overwrite existing files; file URI: ', $targetUri))
        else file:copy($sourceUri, $targetUri)
        
    (: Target URI non-existing, with flag 'd' :)    
    else if (contains($flags, 'd')) then (
        file:create-dir($targetUri),
        file:copy($sourceUri, $targetUri)
    )
    (: Target URI non-existing, without flag 'd' :)
    else
        let $targetParentUri := file:parent($targetUri)
        let $_CREATE_PARENT := 
            if (i:fox-file-exists($targetParentUri, ())) then ()
            else if (not(contains($flags, 'c'))) then
                error(QName((), 'INVALID_CALL'), concat('Target URI is a file URI belonging ',
                    'to a non existent folder; use flag "c" if you want automatic creation of ',
                    'containing folders; use flag "d" if the target URI ',
                    'should be interpreted as folder URI; target URI: ', $targetUri))
            else file:create-dir($targetParentUri)
        return
            file:copy($sourceUri, $targetUri)
};        

(:~
 : Copies resources as a file tree, preserving their folder structure.
 :
 : Errors:
 : - INVALID_SOURCE_CONTEXT - the source context specified does not
 :     contain all resources 
 : - INVALID_SET_OF_RESOURCES - the resources are not all contained
 :     by a single context
 :)
declare function f:fileTreeCopy($resources as item()*,
                                $targetUri as xs:string,
                                $srcContext as xs:string?,
                                $rename as xs:string?,
                                $flags as xs:string?)
        as empty-sequence() {
    if (empty($resources)) then () else     
    
    let $fnCopy := function($resource, $path) {
        if ($resource instance of map(*)) then
                if ($resource?_objecttype eq 'doc-resource') then 
                    uth:writeDocResource($path, $resource, $flags)
                else if ($resource?_objecttype eq 'textfile-resource') then 
                    uth:writeTextfileResource($path, $resource, $flags)
                else if ($resource?_objecttype eq 'cssdoc-resource') then
                    let $fn := util:getModuleFunction('writeCssdocResource') 
                    return try {$fn($path, $resource, $flags)} catch * {$err:code, $err:description}
                else error()
        else try {file:copy($resource, $path)} catch * {trace((), '* Failed to copy resource: '||$path)},
        'yes'    (: dummy return value, assuring execution :)
    }
    
    (: The source context is either provided explicitly,
       or it is determined as the closest common ancestor 
       (note that URI format is required, in order to
        support source locations not in the file system :)    
    let $srcContextEff := (
       if ($srcContext) then $srcContext else uth:commonContextUri($resources))
       ! uth:absoluteUri(.)
    return
        if (empty($srcContextEff)) then
        error(QName((), 'INVALID_SET_OF_RESOURCES'), 'The resources do not '||
            'have a common root URI') else
            
    (: The target context :)
    let $targetUriEff := $targetUri ! uth:absoluteUri(.)
    let $fnRename :=
        if (not($rename)) then () else
        let $from := $rename ! replace(., '\s*=.*', '')
        let $to := $rename ! replace(., '.*?=\s*', '')
        return 
            function ($path) {
                let $name := file:name($path)
                let $name2 := $name ! replace(., $from, $to)
                return ($path ! file:parent(.))||'/'||$name2}
    for $resource in $resources 
    let $uri := uth:resourceUri($resource) ! uth:absoluteUri(.)   (: Normalized URIs required :)
    return if (not(starts-with($uri, $srcContextEff||'/'))) then
        error(QName((), 'INVALID_SOURCE_CONTEXT'), 
          'Invalid argument - the source context ('||$srcContextEff||') must '||
          'contain all '||'resources, but resource "'||$uri||'" is not contained.')
        else
    let $relpath := uth:relPath($srcContextEff, $uri)
    let $tpath := $targetUriEff||'/'||$relpath    
    let $tpath2 := if (empty($fnRename)) then $tpath else $tpath ! $fnRename(.)
    let $_CREATE_DIR := 
        let $folder := $tpath ! uth:parentPath(.)
        return if (file:exists($folder)) then () else file:create-dir($folder)
    let $_COPY := $fnCopy($resource, $tpath2)
    let $_CHECK := if (($_COPY, $_CREATE_DIR) eq 'NEVER') then error() else ()
    return ()
};

(:~
 : Returns a string describing a resource identified by a URI.
 :
 : The structure of the info string is configured by $content.
 : The value is a whitespace-separated list of display components.
 : A display component specifies the kind of information item (first character)
 : and the format of its display (following characters).
 : Item kind:
 :  * p - URI
 :  * n - file name
 :  * s - file size
 :  * d - file date
 : Display:
 :  * number... - right-pad to this length; padding character is the character following the number 
 :  * -number... - left-pad to this length; padding character is the character following the number
 :  () - put value into parentheses
 :
 : @param URI the resource URI
 : @param content format of info line
 :)
declare function f:fileInfo($uri as xs:string?, $content as xs:string?, $options as map(*)?)
        as xs:string? {
    let $content :=
        if (not($content)) then 'p60. s-10_ d'
        else if ($content eq '#nsd') then 'p60. s-10_ d'
        else if ($content eq '#dn') then 'd28 p'
        else if ($content eq '#dns') then 'd28 p s()'        
        else $content
    let $items := tokenize(normalize-space($content), ' ')
    let $line := string-join((
        for $item in $items
        let $kind := substring($item, 1, 1)
        let $format := substring($item, 2)[string()]
        let $parentheses := $format eq '()'
        let $pad :=
            if (not($format)) then ()
            else if ($parentheses) then ()
            else map{
                'padWidth': $format ! replace(., '\D', '') ! xs:integer(.),
                'padSide': if (starts-with($format, '-')) then 'l' else 'r',
                'fillChar': if (empty($format)) then () else (replace($format, '^-?\d+', '')[string()], ' ')[1]
            }
        let $isDir := i:fox-is-dir($uri, $options)            
        let $value :=
            if ($kind eq 'p') then $uri
            else if ($kind eq 'n') then f:fileName($uri)
            else if ($kind eq 's') then 
                if (i:fox-is-dir($uri, $options)) then '/' else i:fox-file-size($uri, $options)
            else if ($kind eq 'd') then i:fox-file-date($uri, $options)
            else if ($kind eq 'r') then
                let $doc := i:fox-doc($uri, $options)
                return
                    if (not($doc)) then '-' 
                    else $doc/*/local-name(.)
            else if ($kind eq 't') then
                let $doc := i:fox-doc($uri, $options)
                return
                    if (not($doc)) then '-'
                    else $doc/*/concat(local-name(.), ' / ', 
                        string-join(sort(distinct-values(*/local-name()), lower-case#1), ' '))
            else if ($kind eq 'e') then
                let $doc := i:fox-doc($uri, $options)
                return
                    if (not($doc)) then '-'
                    else $doc/*/concat(local-name(.), ' / ', 
                        string-join(sort(distinct-values(.//*/local-name()), lower-case#1), ' '))
            else if ($kind eq 'a') then
                let $doc := i:fox-doc($uri, $options)
                return
                    if (not($doc)) then '-'
                    else $doc/string-join(sort(distinct-values(
                        .//@*/local-name()), lower-case#1), ' ')
            else ()
        return
            if (exists($pad)) then
                if ($kind eq 's' and $isDir) then util:rpad('/', $pad?padWidth, ' ')  
                else if ($pad?padSide eq 'l') then util:lpad($value, $pad?padWidth, $pad?fillChar)
                else util:rpad($value, $pad?padWidth, $pad?fillChar)
            else if ($parentheses) then '('||$value||')'
            else $value
        ), ' ')            
    return
        $line
};

(: Extracts from a URI the file name. :)
declare function f:fileName($uri as xs:string?)
        as xs:string? {
    $uri ! replace(., '.*/', '')
};

(:~
 : Filters a sequence of items by the value of a Foxpath expression. 
 : The expression is resolved in the context of each item. Only those
 : items are retained for which the expression returns an effective 
 : Boolean true.
 :
 : @param items the items to be filtered
 : @param pattern a unified string pattern
 : @return true or false
 :)
declare function f:filterItems($items as item()*, 
                               $expr as xs:string,
                               $processingOptions as map(*)?)
        as item()* {
    $items [f:resolveFoxpath(., $expr, (), $processingOptions)]        
};

(:~
 : Returns the folder size, defined as the sum of the sizes
 : of contained files. Can also process multiple folders.
 : By default, files at any level are considered, and sizes
 : are rendered as number of bytes. Use options 'flat',
 : 'mb' and 'kb' in order to ignore files in subfolders
 : and have the size in megabytes or kilobytes, respectively.
 :
 : @param uris folder URIs
 : @param options options controlling details of the execution
 : @param processingOptions processing options
 : @return the sum of file sizes
 :)
declare function f:folderSize($uris as xs:string*, 
                              $options as xs:string?,
                              $processingOptions as map(*)?)
        as xs:decimal? {
    let $ops := f:getOptions($options, ('flat', 'deep', 'mb', 'kb'), 'folder-size')  
    let $fn :=
        if ($ops = 'flat') 
        then i:childUriCollectionAbsolute#2
        else i:descendantUriCollectionAbsolute#2
    let $files :=
        for $uri in $uris return
           $fn($uri, $processingOptions)[i:fox-is-file(., $processingOptions)]
    let $size := ($files ! i:fox-file-size(., $processingOptions)) => sum()
    let $sizeRep :=
        if ($ops = 'mb') then ($size div 1000000) ! round(., 0)
        else if ($ops = 'kb') then ($size div 1000) ! round(., 0)
        else $size
    return $sizeRep
};

(:~
 : Maps a URI to the URI resulting from a shift of a given ancestor folder. 
 : The result URI is reached from the ancestor specified by $shiftedAncestor 
 : by the same path as the input $uri s reached from the ancestor specified
 : by $ancestor.
 :
 : If $nameReplaceSubstring is specified, the result URI has a file name 
 : obtained by editing the file name of $uris, replacing substring 
 : $nameReplaceSubstring with substring nameReplaceWith.
 :
 : @param uris the URIs to be mapped
 : @param ancestor specifies an ancestor; if the parameter value is delimited
 :   by curly braces, the value is interpreted as a Foxpath expression as
 :   contained by the curly braces; otherwise the value is interpreted as a 
 :   name filter; when interpreted as an expression, the expression is 
 :   evaluated in the context of the URI to be mapped
 : @param shiftedAncestor specifies the shifted ancestor; if the parameter value
 :   is delimited by curly braces, the value is interpreted as a Foxpath
 :   expression as contained by the curly braces; otherwise the value is
 :   interpreted as a URI; when interpreted as an expression, the expression
 :   is evaluated in the context of the ancestor URI specified by $ancestor,
 :   not in the context of the URI to be mapped
 : @param nameReplaceSubstring when editing the file name of the mapped URIs,
 :   this substring is replaced by the string specified by $nameReplaceWith 
 : @return the mapped URIs for which a resource exists at that URI
 :) 
declare function f:foxAncestorShifted(
                                  $uris as xs:string+, 
                                  $ancestor as xs:string?, 
                                  $shiftedAncestor as xs:string?,
                                  $nameReplaceSubstring as xs:string?,
                                  $nameReplaceWith as xs:string?,
                                  $processingOptions as map(*))
        as xs:string* {    
    if (not($shiftedAncestor)) then () else
    
    for $uri in $uris
    let $ancestorURI := 
        if (not($ancestor)) then $uri ! i:parentUri(., ())
        else
            let $expr := util:extractExpr($ancestor)
            return
                if ($expr) then f:resolveFoxpath($uri, $expr, (), $processingOptions)
                else f:foxNavigation($uri, 'ancestor', $ancestor, 1, ())
    return if (not(i:fox-file-exists($ancestorURI, ()))) then
        error(QName((), 'INVALID_ARG'), concat('No resource at ancestor URI: ', $ancestorURI)) 
        else
    let $shiftedAncestorURI := 
        let $expr := util:extractExpr($shiftedAncestor)
        (: let $_DEBUG := trace($expr, '_EXPR: ') :)
        return
            if ($expr) then f:resolveFoxpath($ancestorURI, $expr, (), $processingOptions)
            else $shiftedAncestor
    return if (not($shiftedAncestorURI)) then
        error(QName((), 'INVALID_ARG'), concat('Shifted ancestor cannot be resolved to a URI: ', $shiftedAncestor)) 
        else if (not(i:fox-file-exists($shiftedAncestorURI, ()))) then
        error(QName((), 'INVALID_ARG'), concat('No resource at shifted ancestor URI: ', $shiftedAncestorURI)) 
        else
    let $pathAncestorToUri :=
        if (matches($uri, $ancestorURI||'(/.*)?$')) then
            substring-after($uri, $ancestorURI||'/')            
        else if (matches ($ancestorURI, $uri||'(/.*)?$')) then
            let $countSteps :=
                (substring-after($ancestorURI, $uri||'/')
                ! tokenize(., '\s*/\s*')) => count()
            return (for $i in 1 to $countSteps return '..') => string-join('/')
        else ()
    return
        (: Lefthook which is not ancestor or descendant of $uri not supported :)
        if (empty($pathAncestorToUri)) then () else
        
    let $shiftedPathAncestorToUri :=
        if (empty($nameReplaceSubstring)) then $pathAncestorToUri
        else
            let $parts := replace($pathAncestorToUri, '^(.*?)?([^/]+)$', '$1~~~$2')
            let $path := substring-before($parts, '~~~')
            let $name := substring-after($parts, '~~~')
            let $newName := replace($name, $nameReplaceSubstring, $nameReplaceWith)
            return concat($path, $newName)
    let $mirroredPath := concat($shiftedAncestorURI, '/', $shiftedPathAncestorToUri)
    return $mirroredPath[i:fox-file-exists(., ())]
};

(:~
 : Returns the resource URIs reached by a step of fox axis navigation. 
 :
 : If $namesFilter is specified, only URIs with a file name matching the filter 
 : are considered. The parameter value is expected to use general filter syntax. 
 :
 : When parameter $pselector is not used, all resource URIs reached along the specified 
 : axis and not discarded because of name filters are returned. When $pselector is a 
 : positive integer, for each context URI only the result URI at that position is 
 : returned; when $pselector is a negative integer, for each context URI only the 
 : result URI at position "number-of-result-URIs + 1 + $pselector" is returned. 
 : Selection by position is performed after selection by file name. URI positions are 
 : one-based and in file-system order in case of a forward axis, in reverse file-system 
 : order otherwise.
 :
 : The function returns the sequence of URIs obtained from the merged results obtained 
 : for individual context URIs by removing duplicate URIs and ordering in file system
 : order.
 : 
 : Supported navigation axes include:
 : - classical forward axes: 
 :     self, child, descendant, descendant-or-self, following-sibling,
 : - classical reverse axes:
 :     parent, ancestor, ancestor-or-self, preceding-sibling
 : - compound axes:
 : -- sibling: the union of following and preceding siblings
 :
 : @param contextUris the context URIs
 : @axis the navigation axis
 : @param names a name filter, consiting of whitespace-separated name tokens
 : @param namesExcluded a name filter defining exclusions
 : @param pselector an integer number, defining a positional filter
 : @param flags flags controling the name filtering behaviour
 : @return resource URIs reached by a step of axis navigation, applied to 
 :   each context URI
 :)
declare function f:foxNavigation(
                       $contextUris as item()*,
                       $axis as xs:string,
                       $namesFilter as xs:string?,
                       $pselector as xs:integer?,
                       $options as xs:string?)                       
        as xs:string* {
    if ($axis eq 'parent-sibling') then f:foxNavigation(
        $contextUris ! i:parentUri(., ()), 'sibling', $namesFilter, $pselector, $options) else
        
    let $ops := $options ! tokenize(.)        
    let $useBaseUri := $ops = 'use-base-uri'
    let $cNamesFilter := $namesFilter ! use:compileUnifiedStringExpression(., true(), (), ()) 
    let $contextUris :=
        if (not($useBaseUri)) then $contextUris else
            $contextUris ! (if (. instance of node()) then base-uri(.) else .)
    let $fn_uris :=
        switch($axis)
        case 'child' return function($c) {i:childUriCollectionAbsolute($c, ())}
        case 'descendant' return function($c) {i:descendantUriCollectionAbsolute($c, ())}
        case 'descendant-or-self' return function($c) {$c, i:descendantUriCollectionAbsolute($c, ())}
        case 'self' return function($c) {$c}
        case 'ancestor' return function ($c) {i:ancestorUriCollection($c, (), ())}
        case 'ancestor-or-self' return function ($c) {i:ancestorUriCollection($c, (), true())}
        case 'parent' return function ($c) {i:parentUri($c, ())}
        case 'following-sibling' return function ($c) {
             i:parentUri($c, ()) ! i:childUriCollectionAbsolute(., ())[. > $c]}
        case 'preceding-sibling' return function ($c) {
             i:parentUri($c, ()) ! i:childUriCollectionAbsolute(., ())[. < $c]}
        case 'sibling' return function ($c) {
             i:parentUri($c, ()) ! i:childUriCollectionAbsolute(., ())[. ne $c]}
        default return error()
        
    let $fn_name := function($uri) {replace($uri, '.*/', '')}
    let $result :=
        for $curi in $contextUris
        let $related := $curi ! $fn_uris(.)[$fn_name(.) 
                        ! use:matchesUnifiedStringExpression(., $cNamesFilter)]
        return if (empty($pselector)) then $related else

        let $reverseAxis := $axis = ('ancestor', 'ancestor-or-self', 'parent', 'preceding-sibling')
        let $related := if (not($reverseAxis)) then $related else $related => reverse()
        return
            if ($pselector lt 0) then $related[last() + 1 + $pselector]
            else $related[$pselector]
    return $result => sort() => distinct-values()            
};

declare function f:fractions($values as item()*, 
                             $compareWith as item()*, 
                             $comparison as xs:string, 
                             $valueFormat as xs:string?,
                             $compareAs as xs:string?)
        as item()* {
    if (empty($values)) then () else
    
    let $countValues := count($values)
    let $vformat := ($valueFormat, 'count')[1]    
    let $vformatParts := replace($vformat, '(.+?)(col\d*)?$', '$1~$2') ! tokenize(., '~')
    let $colSpec := $vformatParts[2]
    let $colWidth := if (not($colSpec)) then () else replace($colSpec, '.*?(\d+)', '$1') ! xs:integer(.)    
    let $vformat := $vformatParts[1] ! (
        switch(.)
        case 'c' return 'count'
        case 'f' return 'fraction'
        case 'p' return 'percent'
        default return .)
    let $compareAs := ($compareAs, 'decimal')[1] ! concat('xs:', .)
    let $comparison := replace($comparison, '^be$', 'between')
    let $fnCast :=
        switch($compareAs)
        case 'xs:decimal' return function($v) {xs:decimal($v)}
        case 'xs:date' return function($v) {xs:date($v)}
        case 'xs:string' return function($v) {string($v)}
        default return error()
    let $fnCastable :=
        switch($compareAs)
        case 'xs:decimal' return function($v) {$v castable as xs:decimal}
        case 'xs:date' return function($v) {$v castable as xs:date}
        case 'xs:string' return function($v) {$v castable as xs:string}
        default return error()
        
    let $fnFraction :=
        switch($vformat)
        case 'count' return
            function($selected) {count($selected)}
        case 'fraction' return
            function($selected) {(count($selected) div $countValues) ! format-number(., '0.00')}
        case 'percent' return
            function($selected) {((count($selected) div $countValues) * 100) ! format-number(., '0.0')}
        default return error()
        
    let $cvalues := try {$values ! $fnCast(.)} catch * {()}        
    return
        if (count($cvalues) lt $countValues) then
            let $invalidValues:= $values[not($fnCastable(.))]
            let $countInvalid := count($invalidValues)
            return
                error(QName((), 'INVALID_ARG'), concat($countInvalid, ' value(s) cannot ',
                  'be cast into ', $compareAs, ', for example'[$countInvalid gt 1],
                  ': ', $invalidValues[1]))
        else 
        
    let $useCompareWith :=
        if (count($compareWith) gt 1 
            or not(matches(string($compareWith[1]), '^(\*|\d.*);(\*|\d.*);[\d.]+'))) then 
            let $cCompareWith := try {$compareWith ! $fnCast(.)} catch * {()}
            return
                if (count($cCompareWith) lt count($compareWith)) then            
                    let $invalidValues:= $compareWith[not($fnCastable(.))]
                    let $countInvalid := count($invalidValues)
                    return
                        error(QName((), 'INVALID_ARG'), 
                            concat($countInvalid, ' value(s) with which to compare cannot ',
                            'be cast into ', $compareAs, ', for example'[$countInvalid gt 1],
                            ': ', $invalidValues[1]))
                else $cCompareWith                      
        else
            let $parts := tokenize($compareWith, ';\s*')
            let $n1 := $parts[1]
            let $n2 := $parts[2]
            let $step := 
                if ($compareAs eq 'xs:date') then $parts[3] ! xs:integer(.)
                else $parts[3] ! $fnCast(.)
            let $n1 :=
                if ($n1 ne '*') then $n1 ! $fnCast(.) else
                    let $min := $cvalues => min() return 
                        if ($compareAs eq 'xs:date') then $min                            
                        else $step * floor($min div $step) ! $fnCast(.)
            let $n2 :=
                if ($n2 ne '*') then $n2 ! $fnCast(.) else
                    let $max := $cvalues => max() return 
                        if ($compareAs eq 'xs:date') then $max
                        else $step * ceiling($max div $step) ! $fnCast(.)
            let $nsteps := 
                if ($compareAs eq 'xs:date') then days-from-duration($n2 - $n1) div $step
                else 
                    let $prelim := ($n2 - $n1) div $step
                    return if ($prelim lt $n2) then $prelim + 1 else $prelim
            (:
            let $_DEBUG := trace($n2, '_N2: ')
            let $_DEBUG := trace($nsteps, '_NSTEPS: ')
             :)
            return 
                if ($compareAs eq 'xs:date') then
                    for $snr in 0 to xs:integer($nsteps)
                    let $ndays := $snr * $step
                    let $interval := xs:dayTimeDuration('P'||$ndays||'D')                    
                    return $n1 + $interval                
                else
                    for $snr in 0 to xs:integer($nsteps) return
                        ($n1 + ($snr * $step)) ! $fnCast(.)
                return
    let $useCompareWith := sort($useCompareWith)     
    let $countCompareWith := count($useCompareWith)
    let $rvalues :=
        for $comp at $pos in $useCompareWith return
        switch($comparison)
        case 'lt' return $cvalues[. < $comp] => $fnFraction()
        case 'le' return $cvalues[. <= $comp] => $fnFraction()
        case 'gt' return $cvalues[. > $comp] => $fnFraction()
        case 'ge' return $cvalues[. >= $comp] => $fnFraction()
        case 'eq' return $cvalues[. = $comp] => $fnFraction()
        case 'ne' return $cvalues[. != $comp] => $fnFraction()
        case 'between' return (
            if ($pos eq 1) then $cvalues[. < $comp] => $fnFraction()
            else $cvalues[. < $comp][. >= $useCompareWith[$pos - 1]] => $fnFraction(),
            (: comparison 'between' - append fraction of values greater highest limit :)
            if ($pos ne count($useCompareWith)) then () else
                $cvalues[. >= $comp] => $fnFraction()
        )    
    default return error()            
    return
        if (count($useCompareWith) eq 1) then $rvalues
        else (: write table :)
            let $c1ValueWidth := 0 + ($useCompareWith ! string-length()) => max()   
            let $c2ValueWidth := ($rvalues ! string-length()) => max()
            let $useLabels :=
                if ($comparison ne 'between') then 
                    $useCompareWith ! util:lpad(., $c1ValueWidth, ' ') ! concat($comparison, ' ', .)
                else
                    let $padded := $useCompareWith ! util:lpad(., $c1ValueWidth, ' ') 
                        return (
                            (if (xs:decimal($rvalues[1]) = 0) then '[  ' else ' < ')||$padded[1],
                            ($padded => subsequence(2)) ! concat('[) ', .),
                            '>= '||$padded[last()])
            let $rvaluesPruned := $rvalues
            (:
                if ($comparison ne 'between' or $rvalues[$countCompareWith] gt 0) then $rvalues
                else subsequence($rvalues, 1, $countCompareWith - 1)
             :)
            let $rvaluesMax := if (empty($colWidth)) then () else ($rvalues ! xs:decimal(.)) => max()
            let $colFrameLine :=
                let $labelWidth := ($useLabels ! string-length(.)) => max() return
                if (not($colWidth)) then () else
                    util:lpad(' ', $labelWidth + $c2ValueWidth + 6, ' ')||'#'||f:repeat('-', $colWidth)||'#'
            return (
                $colFrameLine,                    
                for $c at $pos in $rvaluesPruned 
                let $cdec := xs:decimal($c)
                let $rvalue := (
                    if ($comparison ne 'between' or $pos gt 1 or $cdec gt 0) then $c else ' ')
                    ! util:lpad(., $c2ValueWidth, ' ')
                return 
                    $useLabels[$pos]||'   '||$rvalue||(if (not($colWidth)) then () else 
                      '   |'
                    ||util:rpad(f:repeat('*', ($cdec div $rvaluesMax * $colWidth)), $colWidth,  ' ')
                    ||'|'),                    
                       (: In case of between, the line "< lower limit" is represented differently
                          if there are no values < lower limit :)
                $colFrameLine                                          
            )                          
};        

(:~
 : Returns a frequency distribution.
 :
 : @param values a sequence of terms
 : @param min if specified - return only terms with a frequency >= $min
 : @param max if specified - return only terms with a frequency >= $max
 : @param kind the kind of frequency value - count, relfreq (relative frequency), 
 :   percent (percent frequency)
 : @param orderBy sort order - "a" (order by frequency ascending, 
 -   "d" (order by frequency descending); default: alphabetically
 : @param format  the output format, one of xml|json|csv|text|text*, default = text;
 :   "text* denotes "text" followed by a number (e.g. text40) specifying the width 
 :   of the term column - shorter terms are padded to this width
 : @return the frequency distribution
 :)
declare function f:frequencies($values as item()*, 
                               $min as xs:integer?, 
                               $max as xs:integer?, 
                               $kind as xs:string?, (: count | relfreq | percent :)
                               $orderBy as xs:string?,
                               $format as xs:string?)
        as item()? {
    if (empty($values)) then () else
       
    let $width := 
        if (not($format) or $format eq 'text*') then 1 + ($values ! string(.) ! string-length(.)) => max()
        else if (matches($format, '^text\d')) then replace($format, '^text', '')[string()] ! xs:integer(.)
        else ()
    let $format := 
        if (not($format)) then 'text'
        else if (matches($format, '^text.')) then 'text'
        else $format    
 
    let $freqAttName := ($kind, 'count')[1]
    
    (: Function return the frequency representation :)
    let $fn_count2freq :=
        switch($kind)
        case 'freq' return function($c, $nvalues) {($c div $nvalues) ! round(., 1) ! string(.) ! replace(., '^[^.]+$', '$0.0')}
        case 'percent' return function($c, $nvalues) {($c div $nvalues * 100) ! round(., 1) ! string(.) ! replace(., '^[^.]+$', '$0.0')}
        default return function($c, $nvalues) {$c}

    (: Function item returning a term representation :)
    let $fn_itemText :=
        switch($format) 
        case 'text' return function($s, $c) {
            if (empty($width)) then concat($s, ' (', $c, ')')
            else 
                concat($s, ' ', 
                       string-join(for $i in 1 to $width - string-length($s) - 1 return '.', ''), 
                       ' (', $c, ')')}
        case 'json' return function($s, $c) {'"'||$s||'": '||$c}
        case 'csv' return function($s, $c) {'"'||$s||'",'||$c}
        case 'xml' return ()
        default return error(QName((), 'INVALID_ARG'), 
            concat('Unknown frequencies format, should be text|xml|json|csv; found: ', $format))

    let $nvalues := count($values)     
    let $itemsUnordered :=        
        for $value in $values
        group by $s := string($value)
        let $c := count($value)        
        let $f := $fn_count2freq($c, $nvalues)
        where (empty($min) or not($c) or $c ge $min) and (empty($max) or not($max) or $c le $max)
        return <value text="{$s}" f="{$f}"/>

    let $items :=
        switch($orderBy)
        case 'a' return 
            for $item in $itemsUnordered 
            order by $item/@f/number(.), $item/@text/lower-case(.) 
            return $item
        case 'd' return 
            for $item in $itemsUnordered 
            order by $item/@f/number(.) descending, $item/@text/lower-case(.) 
            return $item
        case 'n' return 
            for $item in $itemsUnordered 
            order by try {$item/@text/number(.)} catch * {} ascending 
            return $item
        case 'N' return 
            for $item in $itemsUnordered 
            order by try {$item/@text/number(.)} catch * {} descending 
            return $item
        default return 
            for $item in $itemsUnordered 
            order by $item/@text/lower-case(.) 
            return $item
            
    return  
        switch($format)
        case 'xml' return 
            let $min := $items/@f/number(.) => min()
            let $max := $items/@f/number(.) => max()
            return
                <values>{
                    if ($kind eq 'percent') then (
                        attribute minPercent {$min},
                        attribute maxPercent {$max}
                    ) else if ($kind eq 'freq') then (
                        attribute minFreq {$min},
                        attribute maxFreq {$max}
                    ) else (
                        attribute minCount {$min},
                        attribute maxCount {$max}
                    ),
                    $items/<value text="{@text}">{attribute {$freqAttName} {@f}}</value>
            }</values>
        case 'json' return ('{', $items/$fn_itemText(@text, @f) ! concat('  ', .), '}') => string-join('&#xA;')
        case 'csv' return $items/$fn_itemText(@text, @f) => string-join('&#xA;')
        case 'text' return $items/$fn_itemText(@text, @f) => string-join('&#xA;')
        default return $items => string-join('&#xA;')
};      

(:~
 : Perform full text tokenization.
 :
 : @param text text item(s) to be tokenized
 : @param options options controlling the tokenization:
 :   M do not merge adjacent text nodes
 :   s* with stemming
 :   s-... with stemming, language ... (e.g. s-de) 
 :   d diacritics sensitive
 :   c case sensitive
 : @return the tokens
 :)
declare function f:ftTokenize($text as item()*, 
                              $options as xs:string?)
        as xs:string* {
    let $opts := tokenize($options)        
    let $mergeTextnodes := $opts = 'M'        
    let $useText :=
       if ($mergeTextnodes) then $text => string-join(' ')
       else if (empty($text[. instance of element() or . instance of document-node()])) then $text => string-join(' ')        
       else (
           for $t in $text return typeswitch($t)
           case document-node() | element() return $t//text() => string-join(' ')
           default return $t
       ) => string-join(' ')
    let $stemming := exists($opts[starts-with(., 's')])
    let $lang := $opts[starts-with(., 's-')] ! replace(., '^s-', '')       
    let $options := map:merge((
        map:entry('stemming', true())[$stemming],
        map:entry('language', $lang)[$lang],        
        map:entry('diacritics', 'sensitive')[$opts = 'd'],
        map:entry('case', 'sensitive')[$opts = 'c']        
    ))
    return ft:tokenize($useText, $options)
};        

declare function f:getRootUri($uris as xs:string*)
        as xs:string? {
    let $schemas :=        
        for $uri in $uris
        group by $schema := string(replace($uri, '^(\S+?:/+)(.:/)?.*', '$1$2')[. ne $uri])
        return $schema
    return
        if (count($schemas) ne 1) then () (: No root if no common schema :)
        else ($schemas ! replace(., '/$', ''))
             ||f:getRootUriREC('', $uris ! replace(., '^(\S+?:)?/+(.:/)?', ''))
};

(:~
 : Recursive helper function of `f:getRootUri`.
 :)
declare function f:getRootUriREC($potentialRoot as xs:string, $paths as xs:string*)
        as xs:string? {
    if (exists($paths[not(contains(., '/'))])) then $potentialRoot else
    
    let $step1 :=
        for $path in $paths
        group by $step := string(replace($path, '/.*', '')[. ne $path])
        return $step
    return 
        if (count($step1) gt 1) then ($potentialRoot[string()], '/')[1]
        else f:getRootUriREC($potentialRoot||'/'||$step1, $paths ! replace(., '^.+?/', ''))
};        

(:~
 : Add description.
 :
 : Flags:
 : n - return the number of matches, not the matching lines
 :)
declare function f:grep($uris as xs:string*,
                        $textFilter as xs:string?,
                        $flags as xs:string?)
        as item()* {                        
    let $ctextFilter := use:compileUnifiedStringExpression($textFilter, false(), (), ())
    for $uri in $uris
    where i:fox-is-file($uri, ())
    let $matchLines :=
        i:fox-unparsed-text-lines($uri, (), ())
        [use:matchesUnifiedStringExpression(., $ctextFilter)]
    return
        if (contains($flags, 'n')) then count($matchLines)
        else
            if (empty($matchLines)) then () else
                string-join((concat('##### ', $uri, ' #####'), $matchLines, '----------'), '&#xA;')
};

(:
declare function f:grepObsolete($uris as xs:string*,
                        $pattern as xs:string?,
                        $patternExcluded as xs:string?,
                        $flags as xs:string?)
        as item()* {   
    let $ignoreCase := not(contains($flags, 'c'))
    let $regex := contains($flags, 'r')
    let $addAnchors := contains($flags, 'a')
    let $filter := $pattern ! util:compilePatternFilter(., $addAnchors, $ignoreCase, $regex)
    let $filterExclude := $patternExcluded ! util:compilePatternFilter(., $addAnchors, $ignoreCase, $regex)
    (: let $_DEBUG := trace($filter, '_FILTER: ')  :)
    for $uri in $uris
    where i:fox-is-file($uri, ())
    let $matchLines :=
        i:fox-unparsed-text-lines($uri, (), ())
        [util:matchesPlusMinusNameFilters(., $filter, $filterExclude)]
    return
        if (contains($flags, 'n')) then count($matchLines)
        else
            if (empty($matchLines)) then () else
                string-join((concat('##### ', $uri, ' #####'), $matchLines, '----------'), '&#xA;')
};
:)

(:~
 : Transforms a sequence of value into an indented list. Each value is a concatenated 
 : list of items from subsequent levels of hierarchy. Example:
 :
 : foo#bar
 : foo#bar2#bar3
 : foo#zoo#zoo2
 : boo#len
 : zoo
 : =>
 : foo
 : . bar2
 : . . bar3
 : . zoo
 . . . zoo2
 . boo
 . . len
 . zoo
 :)
declare function f:hlist($values as array(*)*, 
                         $headers as xs:string*,
                         $emptyLines as xs:string?)
        as xs:string {
    let $headers :=
        if (count($headers) eq 1) then tokenize($headers, ',\s*') else $headers    
    let $values := $values => sort()
    let $emptyLineFns :=
        if (not($emptyLines)) then () else

        map:merge(
            for $i in 1 to string-length($emptyLines)
            let $lineCount := substring($emptyLines, $i, 1) ! xs:integer(.)
            where $lineCount
            return
                map:entry($i - 1, function() {for $j in 1 to $lineCount return ''})
        )                    
            
    return
        let $lines := f:hlistRC(0, $values, $emptyLineFns)
        return (
            if (empty($headers)) then () else 
                let $maxLen := min(( (($lines ! string-length(.) => max()), 80)[1], 100))
                let $sepline := string-join(for $i in 1 to $maxLen return '=', '')
                return (
                    $sepline,        
                    for $header at $pos in $headers
                    let $prefix := (for $i in 1 to $pos - 1 return '.  ') => string-join('')
                    return $prefix || $header,
                    $sepline,
                    ''                    
                ),
            $lines) => string-join('&#xA;')
};

declare function f:hlistRC($level as xs:integer, 
                           $rows as array(*)*, 
                           $emptyLineFns as map(*)?)
        as xs:string* {
    let $prefix := (for $i in 1 to $level return '.  ') => string-join('')
    return
        (: All rows with at most one member :)
        if (not(some $row in $rows satisfies array:size($row) gt 1)) then
            for $row in $rows[array:size(.) gt 0]
            group by $v := $row(1) ! string()
            let $suffix := count($row)[. ne 1] ! concat(' (', ., ')')
            let $parts := tokenize($v, '~~~')
            return 
                if (count($parts) eq 1) then $prefix || $v || $suffix
                else for $part in $parts return $prefix || $part
        (: Some rows with more than one member :)                
        else
            for $row in $rows
            group by $groupValue := $row(1)
            let $contentValue := $row ! array:subarray(., 2)           
            order by $groupValue
            let $parts := tokenize($groupValue, '~~~')
            return (
                if (count($parts) eq 1) then concat($prefix, $groupValue)
                else for $part in $parts return ($prefix || $part),
                f:hlistRC($level + 1, $contentValue, $emptyLineFns),
                $emptyLineFns ! map:get(., $level) ! .()
                (:''[$level eq 0] :)
            )
};

(:~
 : Indents text items. Parameters specify the size of
 : indentation (default: 4) and the indentation character
 : (default: blank).
 :)
declare function f:indent($items as item()*, 
                          $indentString as xs:string?, 
                          $options as xs:string?)
        as xs:string* {
    let $ops := f:getOptions($options, ('skip1'), 'insert')        
    let $skip1 := $ops = 'skip1'
    
    let $prefix := ($indentString, '    ')[1] 
    let $strings := $items ! string(.)            
    for $string in $strings return $prefix[not($skip1)] || replace($string, '&#xA;', '&#xA;'||$prefix)
};

(:~
 : Returns for a given element all namespace bindings as strings
 : prefix=uri. The bindings are ordered by lowercase prefixes,
 : then lowercase URIs.
 :
 : @param elem the element to be observed
 : @return strings representing namespace bindings
 :)
declare function f:inScopeNamespaces($item as item()) 
        as xs:string+ {        
    let $elem :=
        typeswitch($item)
        case $doc as document-node() return $doc/*
        case $elem as element() return $elem
        case $node as node() return $node/..
        case $uri as xs:anyAtomicType return doc($uri)/*
        default return error()
        
    for $prefix in in-scope-prefixes($elem)
    order by $prefix
    return concat($prefix, '=', namespace-uri-for-prefix($prefix, $elem))
};    

(:~
 : Returns for a given element all namespace bindings as strings
 : prefix=uri. The bindings are ordered by lowercase prefixes,
 : then lowercase URIs.
 :
 : @param elem the element to be observed
 : @return strings representing namespace bindings
 :)
declare function f:inScopeNamespacesDescriptor($item as item()) 
        as xs:string+ {        
    f:inScopeNamespaces($item) => string-join(', ')
};    

(:~
 : Returns the child elements of input nodes with a JSON name equal to
 : one of a set of input names. The JSON name is the name obtained by
 : decoding the element name as a JSON key.
 :
 : @param context the context URI
 : @param names one or several name patterns
 : @return child elements with a matching JSON name
 :)
declare function f:jchild($context as node()*,
                          $names as xs:string+)
        as item()* {
    let $flags := '' return
    
    if (every $name in $names satisfies not(matches($name, '[*?]'))) then        
        $context/*[convert:decode-key(local-name()) = $names]
    else
        let $namesRX := 
            $names 
            ! replace(., '\*', '.*') 
            ! replace(., '\?', '.') 
            ! concat('^', ., '$')
        return
            $context/*[
                let $jname := convert:decode-key(local-name())
                return some $rx in $namesRX satisfies matches($jname, $rx, $flags)
            ]                
};

(:~
 : Returns the JSON names of given nodes.
 :
 : @param nodes a sequence of nodes
 : @return a sequence of JSON names
 :)
declare function f:jname($nodes as node()*)
        as xs:string* {
    $nodes ! local-name(.) ! convert:decode-key(.)        
};

declare function f:jparse($text as xs:string*,
                          $options as xs:string?)
        as document-node()* {
    let $omap := trace(
        if (not($options)) then () else
            let $ops := $options ! tokenize(.)
            return 
                map:merge((
                    map:entry('escape', 'yes')[$ops = 'escape'],
                    map:entry('escape', 'no')[$ops = '~escape']
                )) , '_OMAP: ')
    return
        $text ! json:parse(., $omap)                
};

(:~
 : Returns the JSON Schema keywords found at and under a set of nodes from a 
 : JSON Schema document.
 :
 : @param values JSON values (element or document nodes)
 : @param namePatterns a list of names or name patterns, whitespace separated
 : @return the resolved reference, if the value contains one, or the original value
 :)
declare function f:jschemaKeywords($nodes as node()*, 
                                   $nameFilter as xs:string?)
        as element()* {
    let $cnameFilter := $nameFilter ! use:compileUnifiedStringExpression(., true(), (), ())
    return
        $nodes/f:jschemaKeywordsRC(., $cnameFilter)
};

(:~
 : Recursive helper function of jschemaKeywords().
 :
 : @param n a node to process
 : @param filter a filter consisting of names and regular expressions
 : @return the keyword nodes under the input node, including it
 :)
declare function f:jschemaKeywordsRC($n as node(),
                                     $nameFilter as map(xs:string, item()*)?)
        as node()* {
    let $unfiltered :=        
        typeswitch($n)
        case element(default) return $n    
        case element(discriminator) return $n    
        case element(example) return $n
        case element(examples) return $n
        case element(enum) return $n    
        case element(json) return ($n[parent::*], $n/*/f:jschemaKeywordsRC(., $nameFilter))
        case element(patternProperties) return ($n, $n/*/*/f:jschemaKeywordsRC(., $nameFilter))    
        case element(properties) return ($n, $n/*/*/f:jschemaKeywordsRC(., $nameFilter))
        case element(_) return $n/*/f:jschemaKeywordsRC(., $nameFilter)
        case document-node() return $n/*/f:jschemaKeywordsRC(., $nameFilter)
        default return 
            if (starts-with($n/name(), 'x-')) then $n
            else ($n, $n/*/f:jschemaKeywordsRC(., $nameFilter))
    return
        if (empty($nameFilter)) then $unfiltered else
        for $node in $unfiltered
        let $jname := $node/local-name() ! convert:decode-key(.) ! lower-case(.)
        where use:matchesUnifiedStringExpression($jname, $nameFilter)
        return $node
};        

(:~
 : Returns the effective content of a JSON value: if it is an object containing
 : a reference, the reference is recursively resolved. Otherwise, the original
 : value is returned.
 :
 : This function can be used in order to integrate reference resolving into navigation.
 : Example: all payload schemas in an OpenAPI document may be collected like this:
 :
 :    $oas\paths\*\jeff()\(get, post, put, delete, options, head, patch, trace)
 :    \(
 :         (requestBody, responses\*)\jeff()\(content\schema, schema),
 :         parameters\_\jeff()[in eq 'body']\schema
 :    )
 :
 : @param value a JSON value
 : @return the resolved reference, if the value contains one, or the original value
 :)
declare function f:jsonEffectiveValue($value as element())
        as element()? {
    let $reference := $value/_0024ref return
    
    if (not($reference)) then $value else
        $reference ! f:resolveJsonRef(., ., 'single') ! f:jsonEffectiveValue(.)
};

(:~
 : Returns all atomic items occurring in the first value, but not the second. 
 :
 : @param leftValue a value
 : @param rightValue another value 
 : @return the items in the left value, but not the right one
 :)
declare function f:leftValueOnly($leftValue as item()*,
                                 $rightValue as item()*)
    as item()* {
    $leftValue[not(. = $rightValue)] => distinct-values() => sort()
};

(:~
 : Maps each item to the value of an expression evaluated in the
 : contest of the item. Returns the concatenation of the result
 : sequences in order.
 :
 : @param items the items to be filtered
 : @param expr a Foxpath expression
 : @return concatenation of the result sequences
 :)
declare function f:mapItems($items as item()*, 
                            $expr as xs:string,
                            $processingOptions as map(*)?)
        as item()* {
    $items ! f:resolveFoxpath(., $expr, (), $processingOptions)        
};

(:~
 : Returns true if an item matches a complex string filter, false otherwise.
 :
 : @param item the item to check
 : @param pattern a complex string filter
 : @return true or false
 :)
declare function f:matchesPattern($item as item()+, 
                                  $pattern as xs:string,
                                  $fnOptions as xs:string?,
                                  $controlOptions as map(*)?)
        as xs:boolean {
    let $cpattern := $pattern ! 
        use:compileUnifiedStringExpression(
            ., true(), count($item) gt 1, $controlOptions?NAMESPACE_BINDINGS, $fnOptions)
    let $item :=
        (if ($item instance of xs:anyAtomicType) then string($item) else $item)
        ! normalize-space(.)
    (: let $_DEBUG := trace($item, '_ item: ') :)
    (: let $_DEBUG := trace($cpattern, '_CPATTERN: ') :)  
    return use:matchesUnifiedStringExpression($item, $cpattern)
};

(:~
 : Returns the median value of a set of numeric values
 :
 : @param values the values
 : @return the median value
 :)
declare function f:median($values as xs:anyAtomicType*)
        as xs:anyAtomicType {
    let $count := count($values)
    return
        if ($count eq 1) then $values else
        
        let $sorted := $values => sort()
        let $half := $count div 2
        return
            if ($half eq ceiling($half)) then 
                0.5 * ($sorted[$half] + $sorted[$half + 1])
            else $sorted[ceiling($half)]            
};

(:~
 : Returns name strings. Dependent on $nameKind, the name
 : string expresses the lexical name, the local name or
 : the JSON name. If the node is an attribute node, an
 : @ character is prepended.
 :)
declare function f:nameString($nodes as node()*, 
                              $nameKind as xs:string?,
                              $options as xs:string?)
        as xs:string* {
    switch($nameKind)
    case 'name' return $nodes/concat(self::attribute()/'@', name(.))
    case 'jname' return $nodes/concat(self::attribute()/'@', f:unescapeJsonName(local-name(.)))
    default return $nodes/concat(self::attribute()/'@', local-name(.))
};        

(:~
 : Returns for given nodes their plain name paths.
 :
 : @param nodes a set of nodes
 : @param nameKind identifies the kind of names to be used in the path -
 :        name|lname|jname for lexical name, local name, JSON name
 : @param numSteps truncate path to this number of steps by removing
 :        leading steps
 : @param options options controlling the evaluation;
 :        noconcat - do not concatenate the path steps
 : @return the parent name
 :)
declare function f:namePath($nodes as node()*, 
                            $numSteps as xs:integer?,
                            $options as xs:string?)
        as xs:string* {
    f:namePath($nodes, (), $numSteps, (), $options)        
};        

(:~
 : Returns for given nodes their plain name paths, with attribute value 
 : info appended to the step names.
 :
 : @param nodes a set of nodes
 : @param nameKind identifies the kind of names to be used in the path -
 :        name|lname|jname for lexical name, local name, JSON name
 : @param numSteps truncate path to this number of steps by removing
 :        leading steps
 : @param attFilter a unified string expression selecting attributes
 : @param options options controlling the evaluation;
 :        noconcat - do not concatenate the path steps
 : @return the parent name
 :)
declare function f:namePathAttributed(
                            $nodes as node()*, 
                            $attFilter as xs:string?,
                            $numSteps as xs:integer?,                            
                            $options as xs:string?)
        as xs:string* {
    f:namePath($nodes, (), $numSteps, $attFilter, $options)        
};        

(:~
 : Returns for given nodes their plain name paths.
 :
 : @param nodes a set of nodes
 : @param context if specified, the result path is the path
 :   relative to this context is determined
 : @param nameKind identifies the kind of names to be used in the path -
 :        name|lname|jname for lexical name, local name, JSON name
 : @param numSteps truncate path to this number of steps by removing
 :        leading steps
 : @param options options controlling the evaluation;
 :        noconcat - do not concatenate the path steps
 : @return the parent name
 :)
declare function f:namePath($nodes as node()*, 
                            $context as node()?,
                            $numSteps as xs:integer?,
                            $attFilter as xs:string?,
                            $options as xs:string?)
        as xs:string* {
    let $ops := f:getOptions($options, 
      ('name', 'lname', 'jname', 'fname', 'fpath', 'rfpath', 
       'text', 'value', 'xsdcompname', 'noconcat', 'with-context', 'indexed',
       'text*'), 
       'name-path')
    let $nameKind := ($ops[. = ('lname', 'jname', 'name')][1], 'lname')[1]
    let $noconcat := $ops = 'noconcat'
    let $withBaseUri := $ops[. = ('fpath', 'rfpath', 'fname')][1] 
    let $withIndex := $ops = 'indexed'
    
    let $attFilterC := $attFilter ! use:compileUnifiedStringExpression(., true(), (), ())
        
    let $acceptNodes :=
        $nodes[not(self::text()) or not(../*) or matches(., '\S')]
    for $node in $acceptNodes return
    (: _TO_DO_ Remove hack when BaseX Bug is removed; return to: let $nodes := $node/ancestor-or-self::node() :)     
    let $kindMark := if ($node instance of attribute()) then '@' 
                     else if ($node instance of text()) then 'text()' else ()
    let $ancos := 
        let $all := $node/ancestor-or-self::node()[not($context) or . >> $context]
        let $all := if ($context and $ops = 'with-context') then ($context, $all)
                    else $all
        let $dnode := $all[. instance of document-node()]
        return ($dnode, $all except $dnode)
    let $fnAddAtts :=
        if (empty($attFilterC)) then () else
        function($node) {
            let $atts := $node/@*[use:matchesUnifiedStringExpression(local-name(.), $attFilterC)]
            where $atts
            return string-join($atts/concat('[', local-name(.), '=', .,']'), '')
        }
    let $fnAddIndex :=
        if (not($withIndex)) then () else
        function($n) {
            let $nodes := if ($n instance of text()) then $n/preceding-sibling::text()
                          else $n/preceding-sibling::*[node-name() eq node-name($n)]
            return '['||(1 + count($nodes))||']'        
        }
    let $steps :=   
        if ($nameKind eq 'lname') then $ancos/concat(local-name(),
            if (not($withIndex) or self::attribute()) then () else $fnAddIndex(.),
            if (empty($attFilterC)) then () else $fnAddAtts(.),
            self::xs:*/@name/concat('(', ., ')')[$ops = 'xsdcompname'])
        else if ($nameKind ne 'jname') then $ancos/concat(name(),
            if (not($withIndex) or not(self::*)) then () else $fnAddIndex(.),        
            if (empty($attFilterC)) then () else $fnAddAtts(.),        
            self::xs:*/@name/concat('(', ., ')')[$ops = 'xsdcompname'])        
        else
            $ancos/( 
                let $raw := f:unescapeJsonName(local-name(.))
                return if (not(contains($raw, '/'))) then $raw else concat('"', $raw, '"')
            )
    let $steps := if (not($kindMark)) then $steps 
                  else ($steps[position() lt last()], $kindMark||$steps[last()])
    let $steps := if (empty($numSteps)) then $steps 
                  else subsequence($steps, count($steps) + 1 - $numSteps)
    return         
        if ($ops = 'noconcat') then $steps[string()] else
 
        let $value := 
            if (not($ops = 'value')) then () 
            else if ($node/self::attribute()) then $node/f:truncate(., 60, 't')
            else if ($node/self::text()) then $node/f:truncate(., 60, ())
            else if ($ops = 'text') then ()    (: when text nodes are included, the value
                                                  is attached to them, not the element :)
            else if ($node/text()) then $node/f:truncate(., 60, ())
            else ()
        let $path := string-join($steps, '/')||($value ! concat('=', .))
        return if (not($withBaseUri)) then $path
            else if ($withBaseUri eq 'fpath') 
                 then $node/i:fox-base-uri(.)||'#'||$path
            else if ($withBaseUri eq 'fname') 
                 then $node/(i:fox-base-uri(.) ! file:name(.))||'#'||$path
            else (uth:relUri(file:current-dir(), $node/i:fox-base-uri(.)))||'#'||$path
};        

(:~
 : Returns for given nodes their indexed name paths.
 :
 : @param nodes a set of nodes
 : @param nameKind identifies the kind of names to be used in the path -
 :        name|lname|jname for lexical name, local name, JSON name
 : @param numSteps truncate path to this number of steps by removing
 :        leading steps
 : @param options options controlling the evaluation;
 :        noconcat - do not concatenate the path steps
 : @return the parent name
 :)
declare function f:indexedNamePath(
                            $nodes as node()*, 
                            $numSteps as xs:integer?,                            
                            $options as xs:string?)
        as xs:string* {
    let $ops := $options ! tokenize(.)        
    let $nameKind := ($ops[. = ('lname', 'jname', 'name')][1], 'lname')[1]
    let $noconcat := $ops = 'N'       
    let $options := map:merge((map:entry('noconcat', true())[$noconcat]))
    let $fnGetName :=
        switch($nameKind)
        case 'name' return function($node) {name($node)}
        case 'lname' return function($node) {local-name($node)}
        case 'jname' return function($node) {$node ! name() ! convert:decode-key(.)}
        default return error()
        
    for $node in $nodes return
    
    (: _TO_DO_ Remove hack when BaseX Bug is removed; return to: let $nodes := $node/ancestor-or-self::node() :)        
    (:
    let $ancos := 
        let $all := $node/ancestor-or-self::node()
        let $dnode := $all[. instance of document-node()]
        return ($dnode, $all except $dnode)
     :)
    let $ancos := $node/ancestor-or-self::node()
    let $steps := 
        for $n in $ancos
        let $index := $n/self::*/(
            '['|| (1 + count($n/preceding-sibling::*[node-name() eq node-name($n)])) ||']'
        )
        return $n/self::attribute()/'@'||$n/$fnGetName(.)||$index
    let $steps := if (empty($numSteps)) then $steps else subsequence($steps, count($steps) + 1 - $numSteps)        
    return 
        if ($options?noconcat) then $steps[string()]
        else string-join($steps, '/')
};        

(:~
 : Returns for given nodes their indexed name paths.
 :
 : @param nodes a set of nodes
 : @param context if specified, the result path is the path
 :   relative to this context is determined
 : @param numSteps truncate path to this number of steps by removing
 :        leading steps
 : @param options options controlling the evaluation;
 :        noconcat - do not concatenate the path steps
 :        lname - use local names
 :        jname - use JSON names
 :        name - use lexical names
 : @return the parent name
 :)
declare function f:indexedNamePath(
                            $nodes as node()*, 
                            $context as node()?,
                            $numSteps as xs:integer?,                            
                            $options as xs:string?)
        as xs:string* {
    let $ops := $options ! tokenize(.)        
    let $nameKind := ($ops[. = ('lname', 'jname', 'name')][1], 'lname')[1]
    let $noconcat := $ops = 'N'       
    let $options := map:merge((map:entry('noconcat', true())[$noconcat]))
    let $fnGetName :=
        switch($nameKind)
        case 'name' return function($node) {name($node)}
        case 'lname' return function($node) {local-name($node)}
        case 'jname' return function($node) {$node ! name() ! convert:decode-key(.)}
        default return error()
        
    for $node in $nodes return
    
    (: _TO_DO_ Remove hack when BaseX Bug is removed; return to: let $nodes := $node/ancestor-or-self::node() :)        
    (:
    let $ancos := 
        let $all := $node/ancestor-or-self::node()
        let $dnode := $all[. instance of document-node()]
        return ($dnode, $all except $dnode)
     :)
    let $ancos := $node/ancestor-or-self::node()[not($context) or . >> $context]
    let $steps := 
        for $n in $ancos
        let $index := $n/self::*/(
            '['|| (1 + count($n/preceding-sibling::*[node-name() eq node-name($n)])) ||']'
        )
        return $n/self::attribute()/'@'||$n/$fnGetName(.)||$index
    let $steps := if (empty($numSteps)) then $steps else subsequence($steps, count($steps) + 1 - $numSteps)        
    return 
        if ($options?noconcat) then $steps[string()]
        else string-join($steps, '/')
};        

(:~
 : Creates an Item Location Report for a sequence of given nodes.
 :
 : @param nodes A sequence of JSON nodes
 : @param nameKind Identifies the kind of name - lexical name (name), local name (lname), JSON name (jname)
 : @param flags If contains 'v' - output also the distinct values of attributes and simple elements;
 :   if contains 'f', optionally followed by an integer number (e.g. 'f', 'f2') - the number of
 :   file system names to be included; f1 - file name; f2 - folder name and file name; etc.
 : @return a location report
 :)
declare function f:nodesLocationReport($nodes as node()*,
                                       $nameKind as xs:string?,   (: name | lname | jname :)
                                       $options as xs:string?)
        as xs:string {
    let $ops := f:getOptions($options, ('deep', 'f', 'f1', 'f2', 'f3', 'v', 'xsdcompname'), 'nodes-location')
    let $namePathOptions := string-join(($ops[. = ('xsdcompname')], 'noconcat'[$ops = 'deep']), ' ')
    let $withValues := $ops = 'v'        
    let $numberFsLevels := 
        if ($ops = 'f') then 1
        else if ($ops = 'f1') then 2
        else if ($ops = 'f2') then 3
        else if ($ops = 'f3') then 4
        else ()
    let $withFileName := $numberFsLevels gt 0
    let $numberOfFolders := $numberFsLevels - 1
    let $fn_name := 
        switch($nameKind)
        case 'name' return name#1
        case 'lname' return local-name#1
        case 'jname' return f:jname#1
        default return error(QName((), 'INVALID_ARG'), concat('Invalid "nameKind": ', $nameKind))
    return
    
    $nodes/f:row((
        if ($numberOfFolders) then f:baseUriDirectories(., $numberOfFolders) else (),
        f:baseUriFileName(.)[$withFileName], 
        'Name: '||$fn_name(.), 
        let $namePathOptions := string-join(($nameKind, $namePathOptions), ' ')
        let $steps := f:namePath(., (), $namePathOptions)
        return if ($ops = 'a') then ('/'||$steps[1], subsequence($steps, 2))
               else $steps,
        .[self::attribute(), text()][$withValues]/concat('value: ', .)
        ))
        => f:hlist((for $i in 1 to $numberOfFolders return 'Folder', 
            'File'[$withFileName], 'Name', 'Path', 'Value'[$withValues]), ())
};

(:~
 : Returns the nodes reached by a step of axis navigation. 
 :
 : If $namesFilter is specified, only nodes with a name matching the name filter are
 : considered. Per default, the filtering by node names refers to local names. Use
 : $options value 'name' or 'jname' to filter by lexical node names or JSON names.
 :
 : When parameter $pselector is not used, all nodes reached along the specified axis
 : and not discarded because of name filters are returned. When $pselector is a positive 
 : integer, for each context node only the result node at that position is returned; 
 : when $pselector is a negative integer, for each context node only the result node 
 : at position "number-of-result-nodes + 1 + $pselector" is returned. Selection by 
 : position is performed after selection by node name. Node positions are one-based 
 : and in document order in case of a forward axis, in reverse document order otherwise.
 :
 : The function returns the sequence of nodes obtained from the merged results obtained 
 : for individual context nodes by removing duplicate nodes and ordering in document order.
 : 
 : Supported navigation axes include:
 : - classical forward axes: 
 :     self, child, descendant, descendant-or-self, following-sibling,
 : - classical reverse axes:
 :     parent, ancestor, ancestor-or-self, preceding-sibling
 : - compound axes:
 : -- all-descendant: all descendant elements and their attributes 
 : -- all-descendant-or-self: all descentant-or-self nodes and their attributes
 : -- sibling: the union of following and preceding siblings
 :
 : @param contextNodes the context nodes
 : @axis the navigation axis
 : @param names a name filter, consiting of whitespace-separated name tokens
 : @param namesExcluded a name filter defining exclusions
 : @param pselector an integer number, defining a positional filter
 : @param options options controling the name filtering behaviour;
 :   possible values: name, jname, lname
 : @return nodes reached by a step of axis navigation, applied to each 
 :   context node
 :)
declare function f:nodeNavigation(
                       $contextItems as item()*,
                       $axis as xs:string,
                       $namesFilter as xs:string?,
                       $fnOptions as xs:string?,
                       $extFuncName as xs:string,
                       $options as map(*))                       
        as node()* {
    let $ops := f:getOptions($fnOptions, ('name', 'lname', 'jname', 'qname', 'first', 'first2', 'last', 'last2'), $extFuncName)   
    let $pselector :=
        if ($ops = 'first') then 1
        else if ($ops = 'first2') then 2
        else if ($ops = 'last') then -1
        else if ($ops = 'last2') then -2
        else ()
    let $contextNodes :=
        for $item in $contextItems return
            if ($item instance of node()) then $item else 
                i:fox-doc($item, $options)
    let $cNamesFilter := $namesFilter ! 
        use:compileUnifiedStringExpression(., true(), $ops = 'qname', $options?NAMESPACE_BINDINGS)
    let $fn_nodes :=
        switch($axis)
        case 'child' return function($c) {$c/*}
        case 'attributes' return function($c) {$c/@*}        
        case 'descendant' return function($c) {$c/descendant::*}
        case 'descendant-or-self' return function($c) {$c/descendant-or-self::*}
        case 'self' return function($c) {$c}
        case 'ancestor' return function ($c) {$c/ancestor::node()}
        case 'ancestor-or-self' return function ($c) {$c/ancestor-or-self::node()}
        case 'parent' return function ($c) {$c/parent::node()}
        case 'following-sibling' return function ($c) {$c/following-sibling::*}
        case 'preceding-sibling' return function ($c) {$c/preceding-sibling::*}
        case 'sibling' return function ($c) {$c/(preceding-sibling::*, following-sibling::*)}
        case 'content' return function($c) {$c/descendant::*/(., @*)}    
        case 'content-or-self' return function($c) {$c/descendant-or-self::*/(., @*)}        
        case 'all-descendant' return function($c) {$c/descendant::*/(., @*)}    
        case 'all-descendant-or-self' return function($c) {$c/descendant-or-self::*/(., @*)}        
        default return error()
        
    let $fn_matchesName := 
        if ($ops = 'name') then function($node) 
            {$node/name(.)[string()]! use:matchesUnifiedStringExpression(., $cNamesFilter)}
        else if ($ops = 'jname') then function($node) 
            {$node/local-name(.)[string()] ! convert:decode-key(.) ! use:matchesUnifiedStringExpression(., $cNamesFilter)}
        else if ($ops = 'qname') then function($node) 
            {$node/use:matchesUnifiedStringExpressionQualified(local-name(.), namespace-uri(.), $cNamesFilter)}
        else function($node) 
            {$node/local-name(.)[string()] ! use:matchesUnifiedStringExpression(., $cNamesFilter)}

    let $result :=
        for $node in $contextNodes
        let $related := $node ! $fn_nodes(.)[
                        empty($cNamesFilter) or $fn_matchesName(.)]
        return if (empty($pselector)) then $related else

        let $reverseAxis := $axis = ('ancestor', 'ancestor-or-self', 'parent', 'preceding-sibling')
        let $related := if (not($reverseAxis)) then $related else $related => reverse()
        return
            if ($pselector lt 0) then $related[last() + 1 + $pselector]
            else $related[$pselector]
    return $result/.            
};

declare function f:nameContent(
                       $contextItems as item()*,
                       $namesFilter as xs:string?,
                       $fnOptions as xs:string?,
                       $options as map(*))                       
        as item()* {
    let $ops := $fnOptions ! tokenize(.)   
    
    let $inputNodes :=
        for $item in $contextItems return
            if ($item instance of node()) then $item 
            else i:fox-doc($item, $options)
    let $cNamesFilter := $namesFilter ! use:compileUnifiedStringExpression($namesFilter, true(), (), ())

    let $fn_name := 
        if ($ops = 'name') then function($node) {$node/name(.)}
        else if ($ops = 'jname') then function($node) {$node/local-name(.) ! convert:decode-key(.)}
        else function($node) {$node/local-name(.)}
    let $withAtts := $ops = ('a', 'att')
    let $withChildren := $ops = ('c', 'child')
    let $withParent := $ops = ('p', 'parent')
    let $sepline := 
        if (not($withAtts) and not($withChildren) and not($withParent)) then () else
        '------------------------------------------'
    let $nodes :=
        for $inputNode in $inputNodes
        return
            $inputNode/descendant-or-self::*/(., @*)
                [$fn_name(.) ! use:matchesUnifiedStringExpression(., $cNamesFilter)]
                
    let $results :=
        for $node in $nodes
        group by $name := $node/self::attribute()/'@'||$fn_name($node)
        let $countNodes := count($node)
        
        let $parentInfo := if (not($withParent)) then () else      
            let $rnodeNames :=
                for $rnode in $node/parent::*
                group by $rnodeName := $rnode/$fn_name(.)
                let $count := count($rnode)
                order by $rnodeName
                return $rnodeName||' ('||$count||')'
            return '  P: '||string-join($rnodeNames, ', ')
        let $attInfo := 
            if (not($withAtts) or starts-with($name, '@')) then () else            
                let $rnodeNames :=
                    for $rnode in $node/@*
                    let $rnodeName := $rnode/$fn_name(.)
                    group by $rnodeName
                    let $count := count($rnode)
                    order by $rnodeName
                    return $rnodeName||' ('||$count||')'
                return '  @: '||string-join($rnodeNames, ', ')
        let $childInfo := 
            if (not($withChildren) or starts-with($name, '@')) then () else            
                let $rnodeNames :=
                    for $rnode in $node/*
                    let $rnodeName := $rnode/$fn_name(.)
                    group by $rnodeName
                    let $count := count($rnode)
                    order by $rnodeName
                    return $rnodeName||' ('||$count||')'
                return '  C: '||string-join($rnodeNames, ', ')
        order by $name
        return (
            $name||' ('||$countNodes||')',
            $parentInfo,
            $attInfo,
            $childInfo,
            $sepline
        )
    return (
        '=== name-content ===============================',
        $results,
        '================================================',
        ''
    )        
};

(:~
 : Returns the URIs in $uris which are contain a non-distinct file name, that is,
 : which contain a file name also contained by a different URI.
 :
 : @param uris the URIs to analyze
 : @param ignoreCase if true, distinctness check ignores case
 : @return the URIs with a non-distinct file name
 :)
declare function f:nonDistinctFileNames($uris as item()*,
                                        $ignoreCase as xs:boolean?)
        as item()* {
    if (not($ignoreCase)) then
        for $uri in $uris
        group by $fname := file:name($uri)
        where count($uri) gt 1
        return $uri
    else
        for $uri in $uris
        group by $fname := file:name($uri) ! lower-case(.)
        where count($uri) gt 1
        return distinct-values($uri)
};

(:~
 : Returns the items in $value which are not distinct, that is, which
 : occur in $value more than once.
 :
 : @param value the items to analyze
 : @param ignoreCase if true, distinctness check ignores case
 : @return the non-distinct values
 :)
declare function f:nonDistinctValues($value as item()*,
                                     $ignoreCase as xs:boolean?)
        as item()* {
    if (not($ignoreCase)) then
        for $item in $value
        group by $data := data($item)
        where count($item) gt 1
        return $data
    else
        for $item in $value
        group by $data := data($item) ! lower-case(.)
        where count($item) gt 1
        return distinct-values($item)
};

(:~
 : Returns the JSON Schema keywords found in OpenAPI document.
 :
 : @param oasNodes nodes from OpenAPI documents
 : @param names list of names or name patterns - return only matching keywords
 : @param namesExclude list of names or name patterns - do not return matching 
 :   keywords 
 : @return keyword elements contained by the OpenAPI documents
 :)
declare function f:oasJschemaKeywords($oasNodes as node()*,
                                      $nameFilter as xs:string?)
        as element()* {
    let $oasNodes := 
        $oasNodes ! (
          typeswitch(.) case document-node() return * 
          default return ancestor-or-self::*[last()])
    return
    
    $oasNodes/(
        definitions/*/*/f:jschemaKeywords(., $nameFilter),
        components/schemas/*/*/f:jschemaKeywords(., $nameFilter),
        f:oasMsgSchemas(.)/*/f:jschemaKeywords(., $nameFilter)
    )        
};

(:~
 : Returns the JSON Schema keywords found at and under a set of nodes from a 
 : JSON Schema document.
 :
 : @param values JSON values
 : @param namePatterns a list of names or name patterns, whitespace separated
 : @return the resolved reference, if the value contains one, or the original value
 :)
declare function f:oasKeywords($values as node()*, 
                               $nameFilter as xs:string?)
        as element()* {
    let $cnameFilter := use:compileUnifiedStringExpression($nameFilter, true(), (), ())
    let $values := $values ! root()/descendant-or-self::*[1]        
    for $value in $values
    let $oasVersion := $value/ancestor-or-self::*[last()]/(
        openapi/substring(., 1, 1),
        swagger/substring(., 1, 1)
        )[1]
    return        
        $value/f:oasKeywordsRC(., $oasVersion, $cnameFilter)
};

(:~
 : Recursive helper function of jschemaKeywords().
 :
 : @param n a node to process
 : @param filter a filter consisting of names and regular expressions
 : @return the keyword nodes under the input node, including it
 :)
declare function f:oasKeywordsRC($n as node(),
                                 $version as xs:string?,
                                 $nameFilter as map(xs:string, item()*)?)
        as node()* {
    let $unfiltered :=        
        typeswitch($n)
        
        (: Array item - continue with children :)
        case element(_) return $n/*/f:oasKeywordsRC(., $version, $nameFilter)
        
        (: Keywords with version-dependent treatment :)
        
        (: Keyword 'examples' 
           - if version 2: do not continue recursion;
           - if version 3: treat as map and continue with children :)           
        case element(examples) return (
            $n,
            if ($version ! starts-with(., '2')) then ()
            else $n/*/*/f:oasKeywordsRC(., $version, $nameFilter))
            
        (: Schema-related keywords - do not continue recursion :)
        case element(schema) return $n
        case element(schemas) return $n
        case element(definitions) return $n (: V2 :)
        
        (: Maps with object-valued entries - use the map object and continue with the children of the map entries :)

        case element(callbacks) return ($n, $n/*/*/*/f:oasKeywordsRC(., $version, $nameFilter)) (: Callback has a single member = expr :)
        case element(content) return ($n, $n/*/*/f:oasKeywordsRC(., $version, $nameFilter))   
        case element(encoding) return ($n, $n/*/*/f:oasKeywordsRC(., $version, $nameFilter))        
        case element(examples) return ($n, $n/*/*/f:oasKeywordsRC(., $version, $nameFilter))        
        case element(headers) return ($n, $n/*/*/f:oasKeywordsRC(., $version, $nameFilter))
        case element(links) return ($n, $n/*/*/f:oasKeywordsRC(., $version, $nameFilter))
        case element(pathItems) return ($n, $n/*/*/f:oasKeywordsRC(., $version, $nameFilter))        
        case element(paths) return ($n, $n/*/*/f:oasKeywordsRC(., $version, $nameFilter))        
        case element(requestBodies) return ($n, $n/*/*/f:oasKeywordsRC(., $version, $nameFilter))
        case element(responses) return ($n, $n/*/*/f:oasKeywordsRC(., $version, $nameFilter))
        case element(securityDefinitions) return ($n, $n/*/*/f:oasKeywordsRC(., $version, $nameFilter))   (: V2 :)
        case element(securitySchemes) return ($n, $n/*/*/f:oasKeywordsRC(., $version, $nameFilter))        
        case element(variables) return ($n, $n/*/*/f:oasKeywordsRC(., $version, $nameFilter))
        case element(webhooks) return ($n, $n/*/*/f:oasKeywordsRC(., $version, $nameFilter))        
        
        (: Keywords which MAY be a map :)
        (: ... parameters - dependent on location an array or a map:
               - in Components Object or Link Object or Swagger Object (V2): a map
               - elsewhere (in PathItem Object, Operation Object): an array
         :)
        case element(parameters) return (
            $n, 
            if ($n/(parent::components, ../parent::links, parent::json)) then $n/*/*/f:oasKeywordsRC(., $version, $nameFilter)
            else $n/*/f:oasKeywordsRC(., $version, $nameFilter)
        )            
        
        (: Maps string-string - do not consider children :)        
        case element(mapping) return $n (: map: string -> string :)        
        case element(scopes) return $n (: map: string -> string :)
        
        (: Keywords with type Any - do not consider children :)
        case element(example) return $n
        case element(value) return $n
        
        (: Keyword 'security' :)
        case element(security) return $n   (: an array of objects with a single property '{name}' :)

        (: requestBody - if in Link Object, do not recurse deeper :)
        case element(requestBody) return (
            $n,
            if ($n/../parent::links) then () else
            $n/*/f:oasKeywordsRC(., $version, $nameFilter)
        )
        
        default return (
            $n, 
            if (starts-with(local-name($n), 'x-')) then () else
                $n/*/f:oasKeywordsRC(., $version, $nameFilter))
   
    return
        if (empty($nameFilter)) then $unfiltered else
        for $node in $unfiltered
        let $jname := $node/local-name() ! convert:decode-key(.) ! lower-case(.)
        where use:matchesUnifiedStringExpression($jname, $nameFilter)
        return $node
};        

(:~
 : Returns the schema objects describing the messages of an OpenAPI document.
 :
 : @param oas OpenAPI documents (root element or some other node)
 : @return the schema objects describing messages
 :)
declare function f:oasMsgSchemas($oas as node()*) {
    let $fn_soContent := function ($co) {$co/*/schema}
    let $fn_soParameters := function ($p) {$p/*[in eq 'body']/schema}
    let $fn_soRequestBody := function ($rb) {$rb/content/$fn_soContent(.)}
    let $fn_soResponseObject := function ($ro) {$ro/(schema, content/$fn_soContent(.))}
    let $fn_soPathItem := 
        function ($pi) {
            $pi/(get, post, put, delete, options, head, patch, trace)/(
                parameters/$fn_soParameters(.),
                requestBody/$fn_soRequestBody(.),
                responses/*/$fn_soResponseObject(.))}
    let $oas := $oas/root()/descendant-or-self::json[1]            
    return $oas/(
        paths/*/$fn_soPathItem(.),
        parameters/$fn_soParameters(.),
        responses/*/$fn_soResponseObject(.),
        components/(
            responses/*/$fn_soResponseObject(.),
            requestBodies/*/$fn_soRequestBody(.),
            pathItems/*/$fn_soPathItem(.)))    
};

(:~
 : Compares the item order of two values and reports differences.
 :
 : The item order of two values differs if an item in the atomized value of 
 : $value1 is followed by an item which in the atomized value of $value2
 : precedes the other item. Note that a difference can only occur if both 
 : values have at least two items. The return value depends on $reportType:
 : - $reportType equal boolean – the Boolean value true if there is no 
 :     difference, false otherwise
 : - $reportType equal backsteps – for each backstep item in $value1 the 
 ;     backstep item, preceded by the two items preceding it in $value1, 
 :     separated by " # ". If the backstep item is the second item of $value1, 
 :     only two, rather than three items are returned. 
 : - $reportType equal backstep – like backsteps, but only the first backstep 
 :     item is considered
 : 
 : Examples
 : Returns true – repetition cannot create a difference of item order.
 : fox "order-diff((2, 4, 5, 5), 1 to 6, 'boolean')"
 :
 : Returns true – if one of the values has a single item, there cannot be a 
 :   difference.
 : fox "order-diff(2, 1 to 6, 'boolean')"
 :
 : fox "order-diff((2, 1, 5, 4), 1 to 6, 'backsteps')"
 : =>
 : 2 # 1
 : 1 # 5 # 4
 :
 : fox "order-diff((
 :   ('Summary', 'Conclusion', 'Introduction', 'AdditionalDetails', 'Details'),  
 :   ('Introduction', 'Summary', 'Details', 'AdditionalDetails', 'Conclusion'), 
 :   'backsteps')
 : =>
 : Summary # Conclusion # Introduction
 :)
declare function f:orderDiff($value1 as item()*, 
                             $value2 as item()*, 
                             $reportType as xs:string?)
        as item()* {
    let $reportType := ($reportType, 'backstep1')[1]
    let $value1b := $value1[. = $value2]
    let $positions := $value1b ! index-of($value2, .)
    let $posBeforeBack := (1 to count($positions) - 1)[let $p := . return $positions[$p] > $positions[$p + 1]]
    return
        switch($reportType)
        case 'boolean' return empty($posBeforeBack)
        case 'backsteps' return for $p in $posBeforeBack return
            $value1b[position() = ($p - 1, $p, $p + 1)] => string-join(' # ')
        case 'backstep1' return let $p := $posBeforeBack[1] return
            $value1b[position() = ($p - 1, $p, $p + 1)] => string-join(' # ')
        default return error()
};

(:~
 : Returns the parent name of a node. If $localNames is true, the local name is returned, 
 : otherwise the lexical names. 
 :
 : @param node a node
 : @param localName if true, the local name is returned, otherwise the lexical name
 : @return the parent name
 :)
declare function f:parentName($node as node(),
                              $nameKind as xs:string?)   (: name | lname | jname :)
        as xs:string* {
    let $item := $node/..
    let $name := if ($nameKind eq 'lname') then $item/local-name(.)
                 else if ($nameKind eq 'jname') then $item/f:unescapeJsonName(local-name(.))
                 else $item/name(.)
    return
        $name
};        

(:~
 : Parses a glorex into a tree representation. This function is intended for
 : analytical and diagnosis purposes.
 :
 : @param item the item to check
 : @param pattern a complex string filter
 : @return true or false
 :)
declare function f:parseGlorex($glorex as xs:string,
                               $options as xs:string?,
                               $processingOptions as map(*)?)
        as item() {
    let $ops := f:getOptions($options, ('qualified'), 'parse-glorex')
    let $qualified := $ops eq 'qualified'
    return use:compileUnifiedStringExpression($glorex, true(), $qualified, $processingOptions?NAMESPACE_BINDINGS)
};

(:~
 : Compares two documents or nodes with respect to the names which they contain.
 :
 : Options: name, lname, jname, only1, only2, uncommon, common, fname.
 :
 : @param docs two nodes or document URIs
 : @param options options controling the comparison 
 : @return if no difference, the empty sequence; otherwise a report
 :   describing the differences
 : 
 :)
declare function f:nameDiff($docs as item()*,
                            $options as xs:string?,
                            $extFuncName as xs:string?)
        as item()? {
    if (count($docs) gt 2) then error(QName((), 'INVALID_CALL'), 
        'INVALID_CALL; name-diff cannot compare more than two documents; '||
        '#documents: '||count($docs))        
    else

    let $d1 := $docs[1] ! (if (. instance of node()) then . else i:fox-doc(., ()))
    let $d2 := $docs[2] ! (if (. instance of node()) then . else i:fox-doc(., ()))
    return 
        if (count(($d1, $d2)) lt 2) then () 
        else if (deep-equal($d1, $d2)) then () else
    
    let $ops := f:getOptions($options, 
        ('lname', 'jname', 'name', 'all', 'only1', 'only2', 'common', 'uncommon', 'fname'),
        $extFuncName)
    let $fname := $ops = 'fname'
    let $nameKind := ($ops[. = ('lname', 'jname', 'name')][1], 'lname')[1]  
    let $scope := 
        if ($ops = 'all') then ('only1', 'only2', 'common', 'uncommon')
        else
            let $raw := $ops[. = ('only1', 'only2', 'common', 'uncommon')]
            return if (exists($raw)) then $raw else 'uncommon'    
    let $fn_name := 
        if ($nameKind eq 'name') then f:aname#1
        else if ($nameKind eq 'jname') then f:jname#1
        else f:alname#1    
    let $names1 :=
        for $item in $d1/f:allDescendants(.)
        group by $name := $item/$fn_name(.)
        order by $name return $name
    let $names2 :=
        for $item in $d2/f:allDescendants(.)
        group by $name := $item/$fn_name(.)
        order by $name return $name
    let $common := $names1[. = $names2]
    let $only1 := $names1[not(. = $names2)]
    let $only2 := $names2[not(. = $names1)]
    
    let $docids :=
        let $baseUris := ($d1, $d2)/base-uri(.) return
            if ($fname) then (
                $baseUris[1] ! replace(., '.*/', '') ! attribute fileName1 {.},
                $baseUris[2] ! replace(., '.*/', '') ! attribute fileName2 {.}
            ) else (
                $baseUris[1] ! attribute uri1 {.},
                $baseUris[2] ! attribute uri2 {.}
            )
        
    return
        <nameDiff scope="{$scope}">{
            $docids,
            if (empty($only1) or not($scope = ('only1', 'uncommon'))) then () else
            <only1 count="{count($only1)}">{$only1 ! <item name="{.}"/>}</only1>,
            if (empty($only2) or not($scope = ('only2', 'uncommon'))) then () else
            <only2 count="{count($only2)}">{$only2 ! <item name="{.}"/>}</only2>,
            if (not($scope = 'common')) then () else
            <common count="{count($common)}">{$common ! <item name="{.}"/>}</common>
        }</nameDiff>
};

(:~
 : Parses a CSS record into a node tree.
 :)
declare function f:cssParse($text as xs:string, $options as xs:string?)
        as node() {
    let $fn := util:getModuleFunction('parseCss') 
    return
        try {$fn($text, ())?parsed} catch * {()}
};

(:~
 : Parses a CSS record into a node tree.
 :)
declare function f:cssSerialize($doc as node(), $options as xs:string?)
        as xs:string {
    let $fn := util:getModuleFunction('serializeCss')                
    return
        try {$fn($doc, ())} catch * {()}
};

(:~
 : Compares two documents or nodes with respect to the data paths which
 : they contain. The paths use node names as specified by $nameKind. The comparison 
 : is defined by the comparison type ($cmpType). Supported types:
 :
 : - path - compares plain paths (without index), report paths not common to
 :     both documents (default style of comparison) 
 : - path-count - compare plain paths (without index) and their frequencies,
 :     report paths not common to both documents or with different
 :     frequencies in both documents
 : - indexed - compares indexed paths (without index), containing for each
 :     element step the index of the respective element (e.g. /a[1]/b[2]/c[1]/@d.
 : - indexed-value - compares indexed paths (without index), accompanied (in
 :     case of attributes or elements with text children) by their string value
 :
 : Options:
 : - selecting the comparison type (plain, plain-count, indexed, indexed-value)
 : - selecting the name kind used when comparing (name, jname, lname)
 : - keep-ws - suppress preliminary removal of pretty print text nodes
 : - fname - the report identifies the documents by file names, rather than URIs 
 : - always - return a report element also if no difference has been detedted 
 :
 : @param doc1 a document, or its document URI
 : @param doc2 another document, or its document URI
 : @param nameKind name, lname, jname for name, local name, JSON name 
 : @param cmpType defines the type of comparison
 : @return if no difference, the empty sequence; otherwise a <deviations>
 :   element with optional child elements <only1> and <only2>, containing
 :   the paths occurring only in document 1 or 2, respectively
 : 
 :)
declare function f:pathDiff($docs as item()*,
                            $options as xs:string?,
                            $extFuncName as xs:string?)
        as item()? {
    if (count($docs) ne 2) then 
        let $msg :=
            if (count($docs) eq 1) then (
                'Function '||$extFuncName||' compares two documents, but only '||
                'one document has been supplied')
            else (
                'Function '||$extFuncName||' compares exactly two documents, '||
                'but more documents have been supplied ('||count($docs)||').')
 
        return error(QName((), 'INVALID_CALL'), $msg)        
    else

    let $d1 := $docs[1] ! (if (. instance of node()) then . else i:fox-doc(., ()))
    let $d2 := $docs[2] ! (if (. instance of node()) then . else i:fox-doc(., ()))
        
    let $ops := f:getOptions($options, 
        ('lname', 'jname', 'name', 
         'path', 'path-count', 'indexed', 'indexed-value',
         'all', 'common', 'uncommon',
         'keep-ws', 'fname', 'always'),
        $extFuncName)
        
    let $scope := 
        let $raw := $ops[. = ('all', 'common', 'uncommon')]
        return if (exists($raw)) then $raw else 'uncommon'    
        
    let $fn_name := 
        if ($ops = 'name') then function($node) {$node/name(.)}
        else if ($ops = 'jname') then function($node) {$node/local-name(.) ! convert:decode-key(.)}
        else function($node) {$node/local-name(.)}
    let $cmpType := ($ops[. = ('path', 'path-count', 'indexed', 'indexed-value')][1], 'path')[1]        
    let $nameKind := ($ops[. = ('lname', 'name', 'jname')][1], 'lname')[1]
    let $keepws := $ops = 'keep-ws'
    let $useFname := $ops = 'fname'    
    let $reportAlways := 'always'    
    let $d1 := if ($keepws) then $d1 else $d1 ! util:prettyNode(., ())
    let $d2 := if ($keepws) then $d2 else $d2 ! util:prettyNode(., ())
    let $docids :=
        let $baseUris := ($d1, $d2)/base-uri(.) return
            if ($useFname) then (
                $baseUris[1] ! replace(., '.*/', '') ! attribute fileName1 {.},
                $baseUris[2] ! replace(., '.*/', '') ! attribute fileName2 {.}
            ) else (
                $baseUris[1] ! attribute uri1 {.},
                $baseUris[2] ! attribute uri2 {.}
            )            
    let $reportContent :=     
        switch($cmpType)
        case "path-count" return
            let $paths1 :=
                for $item in $d1/f:allDescendants(.)
                group by $path := f:namePath($item, (), $nameKind)
                order by $path
                return $path||'#'||count($item)
            let $paths2 :=
                for $item in $d2/f:allDescendants(.)
                group by $path := f:namePath($item, (), $nameKind)
                order by $path
                return $path||'#'||count($item)
            let $paths1NA := $paths1 ! replace(., '#\d+$', '')                
            let $paths2NA := $paths2 ! replace(., '#\d+$', '')
            let $only1 := if (not($scope = ('all', 'uncommon'))) then () 
                          else $paths1NA[not(. = $paths2NA)]
            let $only2 := if (not($scope = ('all', 'uncommon'))) then () 
                          else $paths2NA[not(. = $paths1NA)]
            let $annoDiff := if (not($scope = ('all', 'uncommon'))) then () else
                for $path in $paths1
                let $pathNA := $path ! replace(., '#\d+$', '')
                where not($pathNA = $only1)
                return
                    let $path2 := $paths2[starts-with(., $pathNA||'#')]
                    let $anno1 := replace($path, '.+#', '')
                    let $anno2 := replace($path2, '.+#', '')
                    where $anno1 ne $anno2
                    return
                        <item path="{$pathNA}" count1="{$anno1}" count2="{$anno2}"/>
            let $common := if (not($scope = ('all', 'common'))) then () else
                    for $path in $paths1[. = $paths2]
                    let $pathNA := replace($path, '#.*', '')
                    let $count := substring-after($path, '#')
                    return <item path="{$pathNA}" count="{$count}"/>
            return (
                if (empty(($only1, $only2, $annoDiff))) then ()
                else (
                    if (empty($only1)) then () else
                    <only1 count="{count($only1)}">{$only1 ! <item path="{.}"/>}</only1>,
                    if (empty($only2)) then () else
                    <only2 count="{count($only2)}">{$only2 ! <item path="{.}"/>}</only2>,
                    if (empty($annoDiff)) then () else
                    <pathCountDiff>{$annoDiff}</pathCountDiff>                        
                ),
                if (not($common)) then () else <common>{$common}</common>
           )

        case "indexed-value" return
            let $paths1 :=
                for $item in $d1/f:allDescendants(.)
                let $path := f:indexedNamePath($item, (), $nameKind)
                return
                    if ($item instance of attribute()) then $path||$item/concat('#', .)
                    else $path||$item[text()]/concat('#', string-join(text(), ''))
            let $paths2 :=
                for $item in $d2/f:allDescendants(.)
                let $path := f:indexedNamePath($item, (), $nameKind)
                return
                    if ($item instance of attribute()) then $path||$item/concat('#', .)
                    else $path||$item[text()]/concat('#', string-join(text(), ''))
            let $paths1NA := $paths1 ! replace(., '^(.*?)#.*', '$1', 's')                
            let $paths2NA := $paths2 ! replace(., '^(.*?)#.*', '$1', 's')
            let $only1 := if (not($scope = ('all', 'uncommon'))) then ()
                          else $paths1NA[not(. = $paths2NA)]
            let $only2 := if (not($scope = ('all', 'uncommon'))) then ()
                          else $paths2NA[not(. = $paths1NA)]
            let $annoDiff := if (not($scope = ('all', 'uncommon'))) then () else
                for $path in $paths1
                let $pathNA := $path ! replace(., '^(.*?)#.*', '$1', 's')
                where not($pathNA = $only1)
                return
                    let $path2 := $paths2[starts-with(., $pathNA||'#')]
                    let $anno1 := replace($path, '^.*?#', '', 's')
                    let $anno2 := replace($path2, '^.*?#', '', 's')
                    where ($path||$path2) ! contains(., '#') and $anno1 ne $anno2
                    return
                        <loc path="{$pathNA}" value1="{$anno1}" value2="{$anno2}"/>
            let $common := if (not($scope = ('all', 'common'))) then () else
                    for $path in $paths1[. = $paths2]
                    let $pathNA := replace($path, '#.*', '')
                    let $value := substring-after($path, '#')
                    return <item path="{$pathNA}" value="{$value}"/>                        
            return (
                if (empty(($only1, $only2, $annoDiff))) then ()
                else (
                    if (empty($only1)) then () else
                    <only1 count="{count($only1)}">{$only1 ! <loc path="{.}"/>}</only1>,
                    if (empty($only2)) then () else
                    <only2 count="{count($only2)}">{$only2 ! <loc path="{.}"/>}</only2>,
                    if (empty($annoDiff)) then () else
                    <pathValueDiff>{
                        $annoDiff
                    }</pathValueDiff>
                ),
                if (not($common)) then () else <common>{$common}</common>
           )

        (: path | indexed :)
        default return
            let $fnNamePath := if ($cmpType eq 'indexed') then f:indexedNamePath#3 else f:namePath#3
            let $paths1 := $d1/f:allDescendants(.)/$fnNamePath(., (), $nameKind) => distinct-values() => sort()
            let $paths2 := $d2/f:allDescendants(.)/$fnNamePath(., (), $nameKind) => distinct-values() => sort()
            let $only1 := if (not($scope = ('all', 'uncommon'))) then ()
                          else $paths1[not(. = $paths2)]
            let $only2 := if (not($scope = ('all', 'uncommon'))) then ()
                          else $paths2[not(. = $paths1)]   
            let $common :=
                if (not($scope = ('all', 'common'))) then () 
                else $paths1[. = $paths2] ! <item path="{.}"/>
            return (
                if (empty($only1) and empty($only2)) then () else (
                    if (empty($only1)) then () else
                    <only1 count="{count($only1)}">{$only1 ! <loc path="{.}"/>}</only1>,
                    if (empty($only2)) then () else
                    <only2 count="{count($only2)}">{$only2 ! <loc path="{.}"/>}</only2>
                ),
                if (not($common)) then () else <common>{$common}</common>
            )                
    return
        if (empty($reportContent) and not($reportAlways)) then () else
        <pathDiff comparisonType="{$cmpType}">{
            $docids,
            $reportContent
        }</pathDiff>
};

(:~
 : Reports the data paths contained in a set of documents or document 
 : fragments. Input items can be nodes and/or atomic items. Atomic input items
 : are interpreted as document URI and replaced with the corresponding 
 : document node. The function reports the data paths "contained" by the input 
 : nodes, more precisely: the data paths connecting the input nodes and the 
 : nodes which they contain. 
 : 
 : By default, the report comprises the following sections. To request a 
 : subset, use the corresponding options:
 : - The document URIs and fragment paths, when appropriate (option docs)
 : - The data paths contained by all nodes (option common)
 : - The data paths contained by some, but not all nodes (option uncommon)
 : - For each input node the paths contained by this, but not every other node (option details)

 : @param items document URIs and/or nodes
 : @param options a whitespace separated list of options;
 :   lname - path string uses local names
 :   name - path string uses lexical names
 :   jname - path string uses JSON names
 :   docs - include: document URIs and fragment paths, if appropriate
 :   common - include: data paths contained by all input nodes
 :   uncommon - include: data paths not contained by all input nodes
 :   details - include: for each input node the uncommon paths it contains
 :   ~docs - exclude: document URIs and fragment paths, if appropriate
 :   ~common - exclude: data paths contained by all input nodes
 :   ~uncommon - exclude: data paths not contained by all input nodes
 :   ~details - exclude: for each input node the uncommon paths it contains
 :)
declare function f:pathMultiDiff($items as item()*,                                 
                                 $options as xs:string?, 
                                 $extFuncName as xs:string)
        as item()? {
    let $count := count($items)
    return if ($count lt 2) then () else    
    
    let $options := f:getOptions($options, 
        ('lname', 'jname', 'name', 
         'docs', 'common', 'uncommon', 'details', '~docs', '~common', '~uncommon', '~details',
         'indexed', 'fname',
         'report-names'),
        $extFuncName)
    let $nameKind := ($options[. = ('lname', 'jname', 'name')][1], 'lname')[1]  
    let $scopeDefault := ('docs', 'common', 'uncommon', 'details')
    let $scope := $options[. = $scopeDefault]
    let $scopePlus := if (exists($scope)) then $scope else $scopeDefault
    let $minusOptions := $options[starts-with(., '~')] ! substring(., 2)
    let $scope := $scopePlus[not(. = $minusOptions)]
    let $indexed := $options = 'indexed'
    let $reportNames := $options = 'report-names'
    let $useFname := $options = 'fname'
    
    let $elemName_inAll := 
        if ($reportNames) then 'namesInAll'
        else 'pathsInAll'
    let $elemName_notInAll := 
        if ($reportNames) then 'namesNotInAll'
        else 'pathsNotInAll'
    let $elemName_root :=
        if ($reportNames) then 'nameMultiDiff'
        else 'pathMultiDiff'
        
    let $fnPath := 
        if ($indexed) then f:indexedNamePath#4
        else if ($reportNames) then f:nameString#3
        else f:namePath#5
        
    let $fnPathElem := 
        if ($reportNames) then function ($name) {<item name="{$name}"/>}
        else function($path) {<path p="{$path}"/>} 
    
    let $fnGetPaths :=
        if ($reportNames) then function($nodes) {$nodes//item/@name}
        else function($nodes) {$nodes//path/@p}
        
    let $fnFragmentPath := function($doc) {
        $doc[..]/f:indexedNamePath(., (), $nameKind)}
        
    let $fnUri :=
        if ($useFname) then function($node) 
            {$node/base-uri(.) ! replace(., '.*/', '') ! attribute file-name {.}}
        else function($node) 
            {$node/base-uri(.) ! attribute uri {.}}
    let $docs := $items ! 
        (typeswitch(.) case node() return . default return i:fox-doc(., ()))
    
    let $pathArrays := 
        for $doc at $pos in $docs
        let $context := $doc[parent::*]
        let $alldesc := $doc/f:allDescendants(.)
        let $paths := (
            if ($reportNames) then $alldesc/$fnPath(., $context, $nameKind, ())
            else $alldesc/$fnPath(., $context, (), $nameKind)
        ) => distinct-values() => sort()
        return array{$paths}
        
    let $commonPaths := util:atomIntersection($pathArrays)
    
    let $reportDocs :=
        <documents count="{count($docs)}">{
            $docs/<document>{root()/$fnUri(.), 
                $fnFragmentPath(.)! attribute fragmentPath {.}
            }</document>
        }</documents>    
        [$scope = 'docs']
    let $reportPathsInAll :=
        element {$elemName_inAll} {
            attribute count {count($commonPaths)},
            $commonPaths ! $fnPathElem(.)            
        }
        [$scope = 'common']
    let $reportDocDetails :=    
        for $i in 1 to $count
        let $paths := $pathArrays[$i] ! array:flatten(.)
        let $pathsNotCommon := $paths[not(. = $commonPaths)]
        return if (empty($pathsNotCommon)) then () else
            <document nr="{$i}">{
                $docs[$i]/$fnUri(.),
                $docs[$i]/$fnFragmentPath(.) ! attribute fragmentPath {.},
                element {$elemName_notInAll} {
                    attribute count {count($pathsNotCommon)},
                    if ($options = 'counts') then () else
                    ($pathsNotCommon => sort()) ! $fnPathElem(.)
                }
             }</document>
    let $reportPathsNotInAll := if (not($reportDocDetails)) then () else
        let $paths := $fnGetPaths($reportDocDetails) => distinct-values() => sort()
        return
            element {$elemName_notInAll} {
                attribute count {count($paths)},
                $paths ! $fnPathElem(.)
            }
            [$scope = 'uncommon']
    return
        element {$elemName_root} {
            attribute scope {$scope},
            $reportDocs,
            $reportPathsInAll,
            $reportPathsNotInAll,
            <documentDetails count="{count($reportDocDetails)}">{
                $reportDocDetails
            }</documentDetails>[$reportDocDetails][$scope = 'details']
        }
};

(:~
 : Returns the paths leading from a context node to all descendants. This may be
 : regarded as a representation of the node's content, hence the function name.
 :
 : The paths can be filtered in two ways:
 : - ignore leaf nodes not matching $leafNamesFilter
 : - ignore nodes with an ancestor matching $excludedInnerNamesFilter
 :
 : Options:
 : - scope options -
 : with-inner - also the paths of inner nodes are returned
 : - output format options -
 : text - no padding between path and frequency info
 : text* - padding aligned with longest path 
 : textNN - padding to length NN
 : xml - XML format
 : json - JSON format
 : csv - CSV format 
 :
 : @param context nodes and or document URIs
 : @param nameKind the kind of name used as path steps: 
 :   jname - JSON names; lname - local names; name - lexical names
 : @param leafNamesFilter - leaf nodes not matching this filter are ignored 
 : @param excludedInnerNamesFilter - all nodes with a matching ancestor are ignored 
 : @param options paraeters controling the execution 
 : @return the parent name
 :)
declare function f:pathContent($context as item()*, 
                               $leafNameFilter as xs:string?,
                               $innerNodeNameFilter as xs:string?,
                               $excludedInnerNodeNameFilter as xs:string?,                               
                               $fnOptions as xs:string?,
                               $options as map(*))
        as item()* {
    let $ops := f:getOptions($fnOptions, (
                                        'name', 'lname', 'jname', 
                                        'with-inner', 'text', 'indexed',
                                        'with-context',
                                        'text*', 'csv', 'json', 'xml'), 
                                        'path-content')  
    let $opsFormat := 
        $ops[not(. eq 'text') and (starts-with(., 'text') or . = ('csv', 'json', 'xml'))]
    let $ops := $ops[not(. = $opsFormat)]
    let $outputIsText := not($opsFormat = ('csv', 'json', 'xml'))
    
    let $namePathOptions := $ops[not(. = 'with-inner')] => string-join(' ')
    let $alsoInnerNodes := $ops = 'with-inner'
    let $cLeafNameFilter := $leafNameFilter 
        ! use:compileUnifiedStringExpression(., true(), (), ())    
    let $cInnerNodeNameFilter := $innerNodeNameFilter 
        ! use:compileUnifiedStringExpression(., true(), (), ())
    let $cExcludedInnerNodeNameFilter := $excludedInnerNodeNameFilter 
        ! use:compileUnifiedStringExpression(., true(), (), ())
    let $fnGetName :=
        if ($ops = 'name') then function($node) {name($node)}
        else if ($ops = 'jname') then function($node) {$node ! name() ! convert:decode-key(.)} 
        else function($node) {local-name($node)}
    let $context := (
        $context[. instance of node()],
        $context[not(. instance of node())] 
            ! (try {i:fox-doc(., $options)} catch * {try {json:doc(.)} catch * {}})
    ) 
    let $paths :=
    
    for $cnode in $context
    let $descendants1 := (
        if (empty($cInnerNodeNameFilter)) then    
            if ($ops = 'jname') then $cnode/descendant::*[not(*)]
            else ($cnode//@*, $cnode//*[not(*)])
        else
            let $inodes := $cnode//*[@*, *]
              [use:matchesUnifiedStringExpression($fnGetName(.), $cInnerNodeNameFilter)]         
            return
                if ($ops = 'jname') then $inodes/descendant::*[not(*)]
                else ($inodes//@*, $inodes//*[not(*)])
    )
    let $descendants2 := (
        if (empty($cExcludedInnerNodeNameFilter)) then $descendants1 
        else
            let $inodes := $cnode//*[@*, *]
              [use:matchesUnifiedStringExpression($fnGetName(.), $cExcludedInnerNodeNameFilter)]
            let $excludedLeaves := ($inodes//@*, $inodes//*[not(*)])
            return
                $descendants1 except $excludedLeaves
    )
    let $descendants3 :=
        if (empty($cLeafNameFilter)) then $descendants2 else
            $descendants2[use:matchesUnifiedStringExpression(
                $fnGetName(.), $cLeafNameFilter)]
    let $descendants4 := 
        if (not($ops = 'text')) then $descendants3
        else 
            let $textNodes :=
                ($cnode/text(), $descendants3/text())[matches(., '\S')]
            return ($descendants3, $textNodes)
    let $descendants5 :=
        if (not($alsoInnerNodes)) then $descendants4
        else $descendants4/ancestor-or-self::node()[. >> $cnode] 
    return
        f:namePath($descendants5, $cnode, (), (), $namePathOptions)

    return (
        '=== path-content ==============================='[$outputIsText],
        f:frequencies($paths, (), (), (), (), $opsFormat),
        '================================================'[$outputIsText]
    )        
};        

(:~
 : Returns the percent value of a fraction
 :
 : The nominator is the first item of $values.
 : The denominator is $value2, if not empty, or the second item of $values, otherwise.
 :
 : @param values either one or several values
 : @param value2 the denominator
 : @param fractionDigits number of fraction digits
 : @return the quotient as percent value
 :)
declare function f:percent($values as xs:numeric*, $value2 as xs:numeric?, $fractionDigits as xs:integer?)
        as xs:numeric? {
    let $fd := ($fractionDigits, 1) [1]
    let $value1 := $values[1]
    let $value2 := ($value2, $values[2])[1]
    let $percent := ($value1 div $value2 * 100) => round($fd)
    return $percent
};

(:~
 : Filters a sequence of items, retaining those with a string value 
 : matching a unified string pattern.
 :
 : @param items the items to be filtered
 : @param pattern a unified string pattern
 : @return true or false
 :)
declare function f:pfilterItems($items as item()*, 
                               $pattern as xs:string)
        as item()* {
    let $cpattern := $pattern ! use:compileUnifiedStringExpression(., true(), (), ())
    return $items[use:matchesUnifiedStringExpression(string(.), $cpattern)]
};

declare function f:prettyNode($items as item()*, 
                              $processingOptions as xs:string?,
                              $options as map(*))
        as item()* {
    let $ops := $processingOptions ! tokenize(.)
    for $item in $items
    let $isDocResource := uth:instanceOfDocResource($item)
    let $node := uth:itemToNode($item, $options)
    let $resultNode := $node ! util:prettyNode(., $ops)
    let $result :=
        if ($isDocResource) then uth:updateDocResourceContent($item, $resultNode)
        else $resultNode
    return $result
};

(:~
 : Creates a reduced copy of a node. Content nodes selected by the
 : expressions $excludeExprs are removed.
 :
 : Input items which are strings are treated as document URIs, and the
 : corresponding documents are processed.
 :
 : Input items which are doc-resources are updated as doc-resources, that 
 : is the object field 'doc' is replaced with the updated document.
 :
 : @param doc document URI, node or doc-resource
 : @param excludeExprs expressions excluding nodes
 : @return a copy of the input doc in which the selected nodes have been removed
 :)
declare function f:deleteNodes($items as item()*,
                               $excludeExpr as item(),
                               $fnOptions as xs:string?,
                               $options as map(*))
        as item()* {
    let $ops := f:getOptions($fnOptions, ('base', 'keepws'), 'delete-nodes')
    let $keepWS := $ops = 'keepws'
    let $withBaseUri := $ops = 'base'
    
    for $item in $items   
    let $isDocResource := uth:instanceOfDocResource($item)
    let $_DEBUG := trace($isDocResource, '_ isDocResource: ')
    let $node := uth:itemToNode($item, $options)
    let $resultDoc :=  
        copy $node_ := $node
        modify (
            (: let $_DEBUG := trace($excludeExpr, '_EXCLUDE_EXPR: ') :)
            let $delNodes := $excludeExpr !                 
                f:resolveFoxpath($node_, ., $options)[. instance of node()]
            return 
            if (empty($delNodes))then () else
                delete nodes $delNodes
            ,
            if (not($withBaseUri)) then () else
                let $targetElem := $node_/root()/descendant-or-self::*[1]
                return
                    if ($targetElem/@xml:base) then () else
                        insert node attribute xml:base {$targetElem/base-uri(.)} into $targetElem              
        )   
        return $node_
    let $resultDoc := if ($keepWS) then $resultDoc else $resultDoc ! util:prettyFoxPrint(.) 
    let $result :=
        if ($isDocResource) then uth:updateDocResourceContent($item, $resultDoc)
        else $resultDoc
    return $result
 };

(:~
 : Returns the names of nodes structurally related to given nodes. Dependent 
 : on $nameKind, the local names (lname), the JSON names (jname) or the lexical 
 : names (name) are returned. By default, names are sorted.
 :
 : When using $nameFilter, only those child elements are considered which have
 : a local name matching the pattern.
 :
 : Example: .../foo/child-names(., ', ', false(), '*put')
 : Example: .../foo/child-names(., ', ', false(), 'input|output') 
 :
 : @param nodes nodes (only elements contribute to the result)
 : @param concat if true, the names are concatenated
 : @param nameKind one of "name", "lname" or "jname" 
 : @param namePatterns optional name patterns selecting child names to be considered
 : @param excludedNamePattern optional name patterns selecting child elements to be ignored
 : @return the names as a sequence, or as a concatenated string
 :)
declare function f:relatedNames($nodesOrUris as item()*, 
                            $relationship as xs:string,
                            $nameKind as xs:string?,   (: name | lname | jname :)
                            $nameFilter as xs:string?,
                            $options as xs:string?)
        as xs:string* {
    let $ops := f:getOptions($options, ('nosort', 'duplicates'), 'child-names')        
    let $nodes :=
        for $item in $nodesOrUris return
            if ($item instance of node()) then $item else 
                i:fox-doc($item, ())        
    let $nosort := $ops = 'nosort' 
    let $duplicates := $ops = 'duplicates'    
    let $cnameFilter := $nameFilter ! use:compileUnifiedStringExpression(., true(), (), ())
    (:
    let $_DEBUG := trace($nameFilter, '_FILTER_STRING: ')    
    let $_DEBUG := trace($cnameFilter, '_FILTER_ELEM: ')
     :)
    let $fnName := 
        if ($relationship = ('content')) then
        switch($nameKind)
        case 'name' return function($node) {'@'[$node/self::attribute()]||name($node)}
        case 'jname' return function($node) {convert:decode-key(local-name(.))}
        default return function($node) {'@'[$node/self::attribute()]||local-name($node)}
        
        else
        switch($nameKind)
        case 'name' return function($node) {name($node)}
        case 'jname' return function($node) {convert:decode-key(local-name(.))}
        default return function($node) {local-name($node)}
    
    let $separator := ', '

    for $node in $nodes
    let $items :=
        let $unfiltered :=
            switch($relationship)
            case 'child' return $node/*
            case 'parent' return $node/..
            case 'att' return $node/@*
            case 'content' return $node/(@*, *)
            case 'descendant' return $node//*
            case 'ancestor' return $node/ancestor::*
            case 'ancestor-or-self' return $node/ancestor-or-self::*
            default return error(QName((), 'INVALID_ARG'), 'Unknown structure relationship: '||$relationship)
        return 
            if (empty($cnameFilter)) then $unfiltered
            else $unfiltered[$fnName(.) ! replace(., '^@', '') ! use:matchesUnifiedStringExpression(., $cnameFilter)]
    let $names := for $item in $items return $fnName($item)
    let $names := if ($duplicates) then $names else $names => distinct-values()
    let $names := if ($nosort) then $names else $names => sort()        
    let $nameseq := string-join($names, $separator)
    order by $nameseq        
    return
        $nameseq
};        

(:~
 : Returns the XSDs which can be used for validating given documents.
 :)
declare function f:relevantXsds($docs as item()*,
                                $xsds as item()*)
        as element() {
    let $fnNode2Filepath := function($node) {$node ! base-uri(.) ! file:path-to-native(.) ! replace(., '\\', '/')}        
    let $xsdNodes := map:merge(
        for $xsd in $xsds 
        let $xsdNode :=
            if ($xsd instance of node()) then descendant-or-self::xs:schema[1]
            else doc($xsd)/*
        group by $tns := string($xsdNode/@targetNamespace)
        return map:entry($tns, $xsdNode)
    )
    let $docInfos :=
        for $doc in $docs
        let $docNode := 
            if ($doc instance of node()) then descendant-or-self::*[1] else doc($doc)/*    
        let $uri := $docNode/namespace-uri(.)
        let $lname := $docNode/local-name(.)
        let $myxsds := $xsdNodes?($uri)[xs:element/@name =$lname]
        return
            <doc uri="{$docNode ! $fnNode2Filepath(.)}" countXsds="{count($myxsds)}">{
                $myxsds ! <xsd uri="{$fnNode2Filepath(.)}"/>
            }</doc>
    let $count1 := $docInfos[count(xsd) eq 1] => count()           
    let $count0 := $docInfos[not(xsd)] => count()
    let $count2 := $docInfos[count(xsd) gt 1] => count()
    return
        <docs countDocs="{count($docInfos)}"
              countXsds="{count($xsds)}"
              countWithXsd="{$count1}" 
              countWithoutXsd="{$count0}" 
              countAmbiguousXsd="{$count2}">{$docInfos}</docs>
};

(:~
 : Returns the local name of a lexical QName.
 :
 : @param name a lexical QName
 : @return the name with the prefix removed
 :)
declare function f:removePrefix($name as xs:string?)
        as xs:string? {
    $name ! replace(., '^.+:', '')
};        

(:~
 : Foxpath function `repeat#2'. Creates a string which is the concatenation of
 : a given number of instances of a given string.
 :
 : @param string the string to be repeated
 : @param count the number of repeats
 : @return the result of repeating the string
 :)
declare function f:repeat($string as xs:string?, $count as xs:decimal?)
        as xs:string {
    string-join(for $i in 1 to xs:integer($count + 0.5) return $string, '')
};      

(:~
 : Replaces the values of selected nodes.
 :
 : @param items the documents to be modified, as nodes or document URIs
 : @param replaceNodesExpr a Foxpath expression selecting the nodes which to modify 
 : @param valueExpr a Foxpath expression returning the new value of the node; the expression
 :   is evaluated in the context of the node to be changed
 : @param options options controling processing details
 : @param processingOptions options controling the Foxpath processor 
 : @return the edited input item
 :)
declare function f:replaceValues($items as item()*,
                                 $replaceNodesExpr as item(),
                                 $valueExpr as item(),
                                 $options as xs:string?,
                                 $processingOptions as map(*))
        as item()* {
    let $ops := f:getOptions($options, ('base'), 'replace-values')
    let $withBaseUri := $ops = 'base'
    for $item in $items
    let $isDocResource := uth:instanceOfDocResource($item)
    let $node := uth:itemToNode($item, $options)
    
    let $resultDoc :=  
        copy $node_ := $node
        modify (
            let $replaceNodes := f:resolveFoxpath($node_, $replaceNodesExpr, $processingOptions)
            (:
            let $_DEBUG := trace($replaceNodesExpr, '_REPLACE_NODES_EXPR: ')
            let $_DEBUG := trace(count($replaceNodes), '_#REPLACE_NODES: ')
            :)
            for $rnode in $replaceNodes
            let $newValue := f:resolveFoxpath($rnode, $valueExpr, $processingOptions)
            return replace value of node $rnode with $newValue,
            
            if (not($withBaseUri)) then () else
                let $targetElem := $node_/root()/descendant-or-self::*[1] (: /ancestor-or-self::*[last()] :)
                return
                    if ($targetElem/@xml:base) then () else
                        insert node attribute xml:base {$targetElem/base-uri(.)} into $targetElem              
            )                        
        return $node_
    let $result :=
        if ($isDocResource) then uth:updateDocResourceContent($item, $resultDoc)
        else $resultDoc
    return $result
 };

(:~
 : Parses text nodes or attribute values and inserts the parse tree as a child element.
 :
 : @param items the documents to be modified, as nodes or document URIs
 : @param replaceNodesExpr a Foxpath expression selecting the nodes which to modify 
 : @param valueExpr a Foxpath expression returning the new value of the node; the expression
 :   is evaluated in the context of the node to be changed
 : @param options options controling processing details
 : @param processingOptions options controling the Foxpath processor 
 : @return the edited input item
 :)
declare function f:iexpandNodes($items as item()*,
                                $targetNodesExpr as item(),
                                $grammar as xs:string,
                                $fnOptions as xs:string?,
                                $options as map(*))
        as item()* {
    let $ops := f:getOptions($fnOptions, ('base', 'pretty'), 'iexpand-nodes')
    let $withBaseUri := $ops = 'base'
    for $item in $items
    let $isDocResource := uth:instanceOfDocResource($item)
    let $node := uth:itemToNode($item, $options)
    
    let $resultDoc :=  
        copy $node_ := $node
        modify (
            let $replaceNodes := 
                f:resolveFoxpath($node_, $targetNodesExpr, $options)
            for $rnode in $replaceNodes
            let $ptree := string($rnode) ! i:fox-ixml-parse(., $grammar, $options)
            where $ptree
            let $insertionTarget := 
                typeswitch($rnode)
                case attribute() return $rnode/..
                case text() return $rnode/..
                default return $rnode
            let $elemName := 
                if ($rnode instance of text()) then $insertionTarget/local-name(.)
                else $rnode/local-name(.)
            let $newElem := 
                let $qname := QName($const:NS_FOX, 'fox:'||$elemName)
                return element {$qname} {$ptree}
            return insert node $newElem as first into $insertionTarget
        )
        return $node_/*
    let $baseAtt := if (not($withBaseUri)) then () else 
        let $targetElem := $node/root()/descendant-or-self::*[1]
        return $targetElem[not(@xml:base)] ! attribute xml:base {base-uri(.)}        
    let $resultDoc :=
        if (deep-equal($node,$resultDoc)) then $resultDoc else
            element {node-name($resultDoc)} {
                namespace {'fox'} {$const:NS_FOX},
                $baseAtt,
                $resultDoc/(@*, node())
            }
    let $resultDoc := if ($ops = 'pretty') then $resultDoc/util:prettyNode(., ()) 
                      else $resultDoc        
    let $result :=
        if ($isDocResource) then uth:updateDocResourceContent($item, $resultDoc)
        else $resultDoc
    return $result
 };

(:~
 : Renames selected nodes.
 :
 : @param items the documents to be modified, as nodes or document URIs
 : @param targetNodesExpr a Foxpath expression selecting the nodes which to rename 
 : @param nameExpr a Foxpath expression returning the new name of the node; the expression
 :   is evaluated in the context of the node to be renamed
 : @param options options controling processing details
 : @param processingOptions options controling the Foxpath processor 
 : @return the edited input item
 :)
declare function f:renameNodes($items as item()*,
                               $targetNodesExpr as item(),
                               $nameExpr as item(),
                               $options as xs:string?,
                               $processingOptions as map(*))
        as item()* {
    let $ops := f:getOptions($options, ('base'), 'rename-nodes')
    let $withBaseUri := $ops = 'base'
    for $item in $items
    let $isDocResource := uth:instanceOfDocResource($item)
    let $node := uth:itemToNode($item, $options)
    let $resultDoc :=  
        copy $node_ := $node
        modify (
            let $targetNodes := $targetNodesExpr !                 
                f:resolveFoxpath($node_, ., $processingOptions)[. instance of node()]
            
            for $rnode in $targetNodes
            let $newName := $nameExpr !
                f:resolveFoxpath($rnode, ., $processingOptions)
            return rename node $rnode as $newName,
            
            if (not($withBaseUri)) then () else
                let $targetElem := $node_/root()/descendant-or-self::*[1] (: /ancestor-or-self::*[last()] :)
                return
                    if ($targetElem/@xml:base) then () else
                        insert node attribute xml:base {$targetElem/base-uri(.)} into $targetElem              
            )                        
        return $node_
    let $result :=
        if ($isDocResource) then uth:updateDocResourceContent($item, $resultDoc)
        else $resultDoc        
    return $result
 };

(:~
 : Returns those atomic items which are in the right value, but not in the left one. 
 :
 : @param leftValue a value
 : @param rightValue another value 
 : @return the items in the right value, but not the left one
 :)
declare function f:rightValueOnly($leftValue as item()*,
                                  $rightValue as item()*)
    as item()* {
    $rightValue[not(. = $leftValue)]  => distinct-values() => sort()
};

declare function f:resolveFoxpath($context as item(), 
                                  $exprTextOrTree as item(), 
                                  $options as map(*))
        as item()* {
    (:
    let $_DEBUG := trace($exprTextOrTree, '_EXPRESSION_TREE: ')
    let $_DEBUG := trace($context, '_CONTEXT: ')
    :)
    let $isContextNode := $context instance of node()
    let $useOptions := map:put($options, 'IS_CONTEXT_URI', $isContextNode)
    return
        if ($exprTextOrTree instance of node()) then
            let $expr := 
                if ($exprTextOrTree/self::contextExpression) then $exprTextOrTree/* 
                else $exprTextOrTree 
            let $result := i:resolveFoxpathExprTree($expr, false(), $context, (), $useOptions)
            (: let $_DEBUG := trace($result, '___RESULT: ') :)
            return $result
        else
            (: Set IS_CONTEXT_URI to empty sequence to enable ambivalent frog steps :)
            let $useOptions := map:put($options, 'IS_CONTEXT_URI', ())
            return i:resolveFoxpathExpr($exprTextOrTree, false(), $context, (), $useOptions)
};

declare function f:resolveFoxpath($context as item()?, 
                                  $exprTextOrTree as item(),
                                  $vars as map(xs:QName, item()*),
                                  $options as map(*))
        as item()* {
    (: let $_DEBUG := trace($exprTextOrTree, '_RESOLVEFOXPATH#4 EXPRESSION_TEXT_OR_TREE: ') :)
    let $context := ($context, '')[1]
    let $isContextNode := $context instance of node()
    let $useOptions := map:put($options, 'IS_CONTEXT_URI', $isContextNode)
    return
        if ($exprTextOrTree instance of node()) then
            let $expr := 
                if ($exprTextOrTree/self::contextExpression) then $exprTextOrTree/* 
                else $exprTextOrTree 
            let $result := i:resolveFoxpathExprTree($expr, false(), $context, $vars, $useOptions)
            return $result
        else
            (: Set IS_CONTEXT_URI to empty sequence to enable ambivalent frog steps :)
            let $useOptions := map:put($options, 'IS_CONTEXT_URI', ())
            return i:resolveFoxpathExpr($exprTextOrTree, false(), $context, $vars, $useOptions)
};

(:
declare function f:resolveFoxpath($context as item(), 
                                  $expr as xs:string?, 
                                  $exprTree as element()?, 
                                  $options as map(*))
        as item()* {
    (: let $_DEBUG := trace($exprTree, '_EXPRESSION_TREE: ') :)        
    let $useOptions :=
        if ($context instance of node()) then $options
        (: else if ($context?IS_CONTEXT_URI) then $options :)   (: 20200213 - commented out _TO_DO_ must be analyzed :)
        else map:put($options, 'IS_CONTEXT_URI', true())
    return
        if ($exprTree) then
            i:resolveFoxpathTree($exprTree, false(), $context, $useOptions, ())
            (: i:resolveFoxpathRC($exprTree, false(), $context, 1, 1, (), $options) :)
        else i:resolveFoxpathExpr($expr, false(), $context, $useOptions, ())
};
:)

(:
declare function f:resolveFoxpath($context as item(), 
                                  $expr as xs:string?, 
                                  $exprTree as element()?,
                                  $vars as map(*)?,
                                  $options as map(*))
        as item()* {
    (: let $_DEBUG := trace(map:keys($vars), '_VARS: ') :)        
    let $useOptions :=
        if ($context instance of node()) then $options
        (: else if ($context?IS_CONTEXT_URI) then $options :)   (: 20200213 - commented out _TO_DO_ must be analyzed :)
        else map:put($options, 'IS_CONTEXT_URI', true())
    return
        if ($exprTree) then
            i:resolveFoxpathExprTree($exprTree, false(), $context, $useOptions, $vars)
        else i:resolveFoxpathExpr($expr, false(), $context, $useOptions, $vars)
        
        (:
declare function f:resolveFoxpathExpr($foxpath as element(foxpath), 
                                      $ebvMode as xs:boolean?,
                                      $context as item()?,
                                      $position as xs:integer?,
                                      $last as xs:integer?,
                                      $vars as map(xs:QName, item()*)?,
                                      $options as map(*)?)                                      
:)        
};
:)

(:~
 : Resolves a JSON Schema allOf group. Returns all subschemas, with schema
 : references recursively resolved and allOf subschemas recursively replaced
 : by their subschemas.
 :
 : @param allOf a JSON Schema allOf keyword
 : @return the subschemas, recursively resolved
 :)
declare function f:resolveJsonAllOf($allOf as element())
        as element()* {
    for $subschema in $allOf/_        
    return
        if ($subschema[_0024ref]) then 
            let $effective := f:jsonEffectiveValue($subschema)
            return
                if ($effective/allOf) then $effective/allOf/f:resolveJsonAllOf(.)
                else $effective
        else if ($subschema/_allOf) then $subschema/allOf/f:resolveJsonAllOf(.)
        else $subschema
};

(:~
 : Resolves a JSON Schema anyOf group. Returns all subschemas, with schema
 : references recursively resolved and anyOf subschemas recursively replaced
 : by their subschemas.
 :
 : @param allOf a JSON Schema allOf keyword
 : @return the subschemas, recursively resolved
 :)
declare function f:resolveJsonAnyOf($anyOf as element())
        as element()* {
    for $subschema in $anyOf/_/f:jsonEffectiveValue(.)        
    return
        if ($subschema/_anyOf) then $subschema/anyOf/f:resolveJsonAnyOf(.)
        else $subschema
};

(:~
 : Resolves a JSON Schema oneOf group. Returns all subschemas, with schema
 : references recursively resolved and oneOf subschemas recursively replaced
 : by their subschemas.
 :
 : @param oneOf a JSON Schema oneOf keyword
 : @return the subschemas, recursively resolved
 :)
declare function f:resolveJsonOneOf($oneOf as element())
        as element()* {
    for $subschema in $oneOf/_/f:jsonEffectiveValue(.)
    return
        if ($subschema/_oneOf) then $subschema/oneOf/f:resolveJsonOneOf(.)
        else $subschema
};

(:~
 : Resolves a JSON reference to a set of JSON objects. The reference is
 : a JSON Pointer (https://tools.ietf.org/html/rfc6901).
 :
 : Parameter 'mode' controls the mode of resolving:
 : mode=recursive - the reference is resolved recursively, 
 :                  only the final result is returned;
 : mode=recursive-collecting' - 
                    the reference is resolved recursively, 
 :                  all referenced values are returned;
 : mode=single -    the reference is resolved once, no recursive resolving 
 :
 : Default mode: recursive
 :
 : @param reference the reference string
 : @param doc a node from the document used as congtext
 : @param mode mode of resolve - one of 'recursive', 'recursive-collecting', 'single' 
 : @return the referenced schema object, or the empty string if no such object is found
 :)
declare function f:resolveJsonRef($reference as xs:string?, 
                                  $doc as element(),
                                  $mode as xs:string?)
        as element()* {
    if (not($reference)) then () else

    let $mode := ($mode, 'recursive')[1]
    return f:resolveJsonRefRC($reference, $doc, $mode, (), ())
};

declare function f:resolveJsonRefRC(
                          $reference as xs:string?, 
                          $doc as element(),
                          $mode as xs:string?,
                          $visited as element()*,
                          $referencing as element()?)
        as element()* {
    let $doc := $doc/ancestor-or-self::*[last()]
    let $withFragment := contains($reference, '#')
    let $resource := 
        if ($withFragment) then substring-before($reference, '#') else $reference
    let $path :=
        if ($withFragment) then replace($reference, '.*?#/', '') else ()
    let $context :=
        if (not($resource)) then $doc else
            try {
                resolve-uri($resource, $doc/base-uri(.)) 
                ! json:doc(.)/*
            } catch * {
                (: Second try - replace '-' with '/' in base URI;
                   motivation: maybe this document has been downloaded to a file
                   with a name obtained by replacing in an internet address
                   / with - :)
                let $baseUri2 := $doc/base-uri(.) ! replace(., '-', '/')
                return
                    try {
                        let $baseUri2 := $doc/base-uri(.) ! replace(., '-', '/')
                        let $dirPart := replace($baseUri2, '/[^/]+$', '')
                        let $uri := resolve-uri($resource, $baseUri2)
                        let $uriAdjusted := replace($uri, $dirPart||'/', $dirPart||'-')
                        return json:doc($uriAdjusted)/*
                    } catch * {
                        trace((), '___WARNING - CANNOT RESOLVE REFERENCE: ' || $reference ||
                              ' ; CONTEXT: ' || $doc/base-uri(.))
                    }                     
            }
    where $context            
    return   
        if (not($path)) then $context else
            let $steps := tokenize($path, '\s*/\s*')
            let $target := f:resolveJsonRefSteps($steps, $context)
            return 
                if ($mode eq 'single') then $target
                else if ($target intersect $visited) then 
                    (: 'recursive' mode - return referencing object :)
                    if ($mode eq 'recursive') then $referencing else ()                
                else
                    if ($target/_0024ref) then (
                        $target[$mode eq 'recursive-collecting'], 
                        $target/_0024ref/f:resolveJsonRefRC(., $doc, $mode, ($visited, $target), ..)
                        )/.   (: Remove duplicates :)
                    else $target
};

(:~
 : Recursive helper function of 'resolveJsonRef'.
 :
 : @param steps the steps of the path (JSON Pointer steps)
 : @param context the context in which to resolve the path
 : @return the targets addressed by the path
 :)
declare function f:resolveJsonRefSteps($steps as xs:string+, 
                                       $context as element()*)
        as element()* {
    let $head := head($steps)
    let $tail := tail($steps)
    let $refToken := $head 
                     ! web:decode-url(.)
                     ! replace(., '~1', '/') 
                     ! replace(., '~0', '~')
    let $elem :=
        if ($context/@type eq 'array') then
            if (matches($refToken, '^\d+$')) then $context/_[1 + xs:integer($refToken)]
            else () (: Invalid JSON Pointer syntax :)
        else 
            let $elemName := $refToken ! convert:encode-key(.)
            return $context/*[name() eq $elemName]
    return
        if (not($elem)) then ()
        else if (empty($tail)) then $elem
        else f:resolveJsonRefSteps($tail, $elem)
};

(:~
 : Resolves a link to a resource. If the link cannot be resolved,
 : the empty sequence is returned. 
 :
 : Options:
 : xml - the XML content is returned, not the URI
 :
 : @param nodes nodes containing the links
 : @param replaceString if specified, this substring will be replaced
 : @param replaceWith if specified, used as a replacement
 : @param options options controlling the execution
 : @return the resolved path or the XML document node
 :)
declare function f:resolveLink($nodes as node()*,
                               $replaceString as xs:string?,
                               $replaceWith as xs:string?,
                               $options as xs:string?)
        as item()* {
    let $ops := f:getOps($options, ('xml', 'ignore-nofind'), 'resolve-link')    
    let $ignoreNofind := $ops?ignore-nofind
    
    for $node in $nodes
    let $base := $node/ancestor-or-self::*[1]        
    let $uriRaw := try {
        if ($base) then resolve-uri($node, $base/base-uri(.))
        else resolve-uri($node)
        } catch * {}
    where $uriRaw
    let $uri :=
        if (not($replaceString)) then $uriRaw
        else
            let $fname := file:name($uriRaw)
            let $dir := file:parent($uriRaw)
            let $fname2 := $fname ! replace(., $replaceString, $replaceWith)
            return $dir||'/'||$fname2
    let $uriRETR := $uri[not(starts-with(., 'news:/'))] ! replace(., '#.*', '')            
    where empty($uriRETR) or $ignoreNofind or i:fox-file-exists($uriRETR, ())            
    return
        if ($ops?xml) then $uriRETR ! i:fox-doc(., ())
        else $uri
};        

(:~
 : Resolves an XSD type reference to the referenced type definition.
 :)
declare function f:resolveXsdTypeRef($reference as attribute(type), 
                                     $schema as element(xs:schema)?)
        as element()? {
    if (not($reference)) then () else
    
    let $schema := ($schema, $reference/ancestor::xs:schema[1])[1]
    let $refQname := $reference/resolve-QName(., ..)
    let $refNs := string(namespace-uri-from-QName($refQname))
    let $refName := local-name-from-QName($refQname)
    let $result := f:resolveXsdTypeRefRC($refNs, $refName, $schema, (), (), ())
    return $result[self::xs:simpleType, xs:complexType][1]
};

declare function f:resolveXsdTypeRefRC($refNs as xs:string,
                                       $refName as xs:string,
                                       $schema as element(xs:schema),
                                       $schemasSameLevel as element(xs:schema)*,
                                       $chameleonNs as xs:string?,
                                       $visited as element(xs:schema)*)
        as element()? {
    if ($visited intersect $schema) then $visited else
    
    let $tns := ($schema/@targetNamespace, $chameleonNs, '')[1]
    let $typeDefHere :=
        if ($refNs ne $tns) then () else
            $schema/(xs:simpleType, xs:complexType)[@name eq $refName]            
    return
        if ($typeDefHere) then $typeDefHere else

            let $visitedNew := ($visited, $schema)
            let $resultSSL := 
                if (not($schemasSameLevel)) then () else
                    f:resolveXsdTypeRefRC($refNs, $refName, 
                        head($schemasSameLevel), tail($schemasSameLevel), $chameleonNs, $visitedNew)
            let $typeDefSSL := $resultSSL[self::xs:simpleType, self::xs:complexType]
            return
                if ($typeDefSSL) then $typeDefSSL
                else                
                    let $visitedNew := ($visitedNew, $resultSSL)
                    let $schemaLocationsNextLevel :=
                        if ($tns eq $refNs) then $schema/xs:include/@schemaLocation
                        else $schema/xs:import[@namespace eq $tns]/@schemaLocation
                    let $schemasNextLevel := 
                        $schemaLocationsNextLevel/resolve-uri(., ..)
                        ! (try {doc(.)} catch * {()})
                        [not(. intersect $visited)]
                    let $resultSNL := 
                        if (not($schemasNextLevel)) then () else
                            f:resolveXsdTypeRefRC($refNs, $refName, 
                                head($schemasNextLevel), tail($schemasNextLevel), $tns, $visitedNew)
                    return $resultSNL                                
};        

declare function f:row($items as item()*)
        as array(*) {
    array{$items}
};

(:~
 : Returns a URI so that the relative paths from $sourceFolder to $uri and
 : from $targetFolder to the result URI are the same.
 :
 : @param uri the URI to be shifted
 : @param sourceFolder a folder containing the resource with uri $uri
 : @param targetFolder a folder containing the resource with a URI obtained by
 :   shifting the URI  
 : @return the URI under $targetFolder
 :)
declare function f:shiftURI($uri as xs:string, $sourceFolder as xs:string, $targetFolder as xs:string)
    as item()* {
    let $relPath := f:relPath($sourceFolder, $uri)
    let $shifted := (
        switch($relPath)
        case '.' return $targetFolder
        case () return ()
        default  return $targetFolder||'/'||$relPath
    ) ! f:normalizeURIPath(.)
    return $shifted[i:fox-file-exists(.,())]
};

(:~
 : Returns the size of a subset of values. The subset
 : consists of those items in a given value for which
 : a filter expression has a true effective boolean value.
 :
 : @param values the set a subset of which is measured
 : @param filterExpr a Foxpath expression defining the subset
 : @param valueFormat the format expressing the subset size;
 :     f, p, c for fraction, percent or count
 : @return the subset size
 :)
declare function f:subsetFraction(
                             $values as item()*, 
                             $filterExpr as xs:string, 
                             $valueFormat as xs:string?,
                             $processingOptions as map(*))
        as item()? {
    if (empty($values)) then () else

    let $valueFormat := ($valueFormat, 'f')[1]
    let $countValues := count($values)
    let $filteredValues := $values[f:resolveFoxpath(., $filterExpr, (), $processingOptions)]
    let $countFilteredValues := count($filteredValues)
    let $result :=
        if ($valueFormat = ('c', 'count')) then $countFilteredValues
        else if ($valueFormat = ('f', 'fraction')) then ($countFilteredValues div $countValues) ! format-number(., '0.00')
        else if ($valueFormat = ('p', 'precent')) then ($countFilteredValues div $countValues * 100) ! format-number(., '0.0')
        else error()
    return $result
};        

(:~
 : Transforms a sequence of values into a table. Each value is a concatenated 
 : list of items, created using function row().
 :)
declare function f:table($rows as item()*, 
                         $headers as xs:string*,
                         $options as xs:string?)
        as item() {
    let $ops := f:getOptions($options, ('sort', 'sortd', 'distinct', 'xml'), 'table')        
    let $sort := $ops = 'sort'
    let $sortd := $ops = 'sortd'
    let $distinct := $ops = 'distinct'
    let $headersPlus :=
        if (count($headers) eq 1) then tokenize($headers, ',\s*') else $headers
    return if (($rows ! array:size(.)) => distinct-values() => count() gt 1) then
        error(QName((), 'INVALID_ARG'), concat('Invalid call of "table" - ',
            'all rows must contain the same number of columns; use string(...) ',
            'in order to enforce a column in case of an empty column value; ',
            'example: row(string(foo), string(bar))'))
        else

    let $headers := $headersPlus[not(matches(., '^(table|row)='))]
    let $countCols := $rows[1] ! array:size(.)
    return    
        if ($ops = 'xml') then
            let $tableName := ($headersPlus[starts-with(., 'table=')] 
                              ! replace(., '^table=', ''), 'table')[1]
            let $rowName := ($headersPlus[starts-with(., 'row=')] 
                              ! replace(., '^row=', ''), 'row')[1]        
            let $colnames :=
                if (exists($headers)) then $headers
                else 1 to $countCols ! ('col'||.)
            let $rows :=
                for $row in $rows return
                    element {$rowName}{
                        for $c in 1 to $countCols return 
                            element {$colnames[$c]} {$row($c) ! string()}
                    }
            let $rows :=
                if (not($ops = 'distinct')) then $rows else
                for $row in $rows
                group by $content := string-join($row/*, '~~~')
                return $row
            let $rows :=
                if (not($ops = ('sort', 'sortd'))) then $rows 
                else if ($ops = 'sort') then 
                for $row in $rows order by string-join($row/*, '~~~') 
                    return $row
                else 
                for $row in $rows order by string-join($row/*, '~~~') descending
                    return $row
            return
                element {$tableName} {$rows}
        else
    let $widths :=
        for $i in 1 to $countCols return
        ($rows?($i) ! string() ! string-length(.)) => max()
    let $startPos :=
        for $i in 1 to $countCols
        let $preColWidth := subsequence($widths, 1, $i - 1) => sum()
        let $preSepWidth := 2 + 3 * ($i - 1)
        return 1 + $preColWidth + $preSepWidth
    let $rowLines :=        
        for $row in $rows
        return concat(
            '| ',
            string-join(
                for $i in 1 to $countCols return 
                    $row($i) ! util:rpad(., $widths[$i], ' '), ' | '),
            ' |')
    let $rowLines := 
        if ($distinct) then $rowLines => distinct-values() 
        else $rowLines 
    let $rowLines :=
        if ($sort or $sortd) then 
            let $sorted := $rowLines => sort()
            return if ($sort) then $sorted else $sorted => reverse()
        else $rowLines
    let $tableWidth := 4 + sum($widths) + ($countCols - 1) * 3
    let $frameLine := '#'||f:repeat('-', $tableWidth - 2)||'#'
    let $headLines :=
        if (empty($headers)) then ()
        else if (every $i in (1 to count($headers)) satisfies 
                    string-length($headers[$i]) lt $widths[$i] + 1) then
                concat(
                    '| ', 
                    string-join(
                        for $header at $pos in $headers return 
                            util:rpad($header, $widths[$pos] - 0, ' '), ' | '),
                ' |')        
        else ( 
            for $header at $pos in $headers
            let $prefix := f:repeat(' ', $startPos[$pos] - 3) ! replace(., '^.', '|')
            return ($prefix || '| '||$header) ! (util:rpad(., $tableWidth - 1, ' ')||'|')
        )
   
    return 
        string-join((    
            if (empty($headLines)) then () else        
            ($frameLine, $headLines),
            $frameLine,
            $rowLines,
            $frameLine
        ), '&#xA;')            
};

(:~
 : Transforms a sequence of rows into a CSV text document.
 :)
declare function f:csv($rows as item()*, 
                       $headers as xs:string*,
                       $options as xs:string?)
        as xs:string {
    let $ops := f:getOptions($options, ('sort', 'sortd', 'distinct', 'semicolon', 'colon'), 'table')        
    let $sort := $ops = 'sort'
    let $sortd := $ops = 'sortd'
    let $distinct := $ops = 'distinct'
    let $sep := codepoints-to-string(30000) (:  ($sep, '#')[1] :)
    let $sep := 
        if ($ops = 'semicolon') then ';' 
        else if ($ops = 'colon') then ':' 
        else ','
    let $headers :=
        if (count($headers) eq 1) then tokenize($headers, ',\s*') else $headers
    let $ncols := $rows[1] ! array:size(.)        
    return if (some $row in tail($rows) satisfies $ncols != array:size($row)) then
        error(QName((), 'INVALID_ARG'), concat('Invalid call of "table" - ',
            'all rows must contain the same number of columns; use string(...) ',
            'in order to enforce a column in case of an empty column value; ',
            'example: row(string(foo), string(bar))'))
        else

    let $textRows :=
        for $row in $rows 
        return string-join( 
            for $c in 1 to $ncols
            let $cval := string($row($c))
            return if (not(contains($cval, $sep))) then $cval else
                '"'||replace($cval, '["\\]', '\\$0')||'"'
                   
        , $sep)
    let $textRows := 
        if ($distinct) then $textRows => distinct-values() 
        else $textRows 
    let $textRows :=
        if ($sort or $sortd) then 
            let $sorted := $textRows => sort()
            return if ($sort) then $sorted else $sorted => reverse()
        else $textRows
    return (
        if (empty($headers)) then () else $headers => string-join($sep),
        $textRows
    ) => string-join('&#xA;')
};

(:~
 : Maps each item of the input value to a pair of strings, the first 
 : containing each character of the original string, separated by 5 
 : blanks, the second containing the unicode codepoints, padded to a 
 : string of 6 characters. Example:
 : "'b!" is mapped to:
 : '     b     !
 : 39    98    33 
 :)
declare function f:textToCodepoints($text as xs:string*) as xs:string+ {
    let $fnPad := function($s, $w) {
        string($s) ! (. || 
        (for $i in 1 to $w - string-length(.) return ' ') => string-join())}

    let $fnFoldLeft := function($accum, $item) {
        let $char := $item||'     '
        let $codepoint := string-to-codepoints($item) ! $fnPad(., 6) 
        return (
            $accum[1]||$char,
            $accum[2]||$codepoint
        )
    }
    
    for $line in $text
    let $len := string-length($line)
    let $chars := for $i in 1 to $len return substring($line, $i, 1)
    return fold-left($chars, ('', ''), $fnFoldLeft) 
};

(:~
 : Truncates a string if longer than a maximum length, appending '...'.
 :
 : By default, a truncated string consists of the first $len characters,
 : followed by ' ...'. If option 'e' is used, the substring contains
 : ($len - 4) characters, so that the truncated string including the
 : indication of truncation has length $len.
 :
 : @param name a lexical QName
 : @return the name with the prefix removed
 :)
declare function f:truncate($string as xs:string?, $len as xs:integer?, $flags as xs:string?)
        as xs:string? {
    let $len := ($len, 80)[1]
    let $evenLength := $flags = 'e'
    let $actlen := string-length($string)
    return
        if ($actlen le $len) then $string
        else
            let $cutlen := if ($evenLength) then $len - 4 else $len        
            let $suffix := 
                if (contains($flags, 't')) then ' ('||(string-length($string) - $cutlen)||' more chars)'
                else ' ...'
            return substring($string, 1, $cutlen) ||$suffix
};        

(:~
 : Truncates a name path by replacing all element steps following
 : the first step matching a name filter by '/*'
 :)
declare function f:truncateNamePath($paths as xs:string*, 
                                    $lastElemFilter as xs:string?, 
                                    $options as xs:string?)
        as xs:string* {
    let $ops := f:getOptions($options, ('att'), 'truncate-name-path')
    let $att := $ops = 'att'        
    let $leFilter := $lastElemFilter ! use:compileUnifiedStringExpression(., true(), (), ()) 
    for $path in $paths
    let $steps := tokenize($path, '/')
    let $step := $steps[use:matchesUnifiedStringExpression(., $leFilter)][1]
    return
        if (not($step)) then $path else
 
        let $stepNr := index-of($steps, $step)[1]
        let $stepNrTruncate :=
            let $try := $stepNr + 1
            let $stepNext := $steps[$try]
            return if (not($stepNext) or (starts-with($stepNext, '@') and not($att))) then ()
                   else $try
        return
            if (not($stepNrTruncate)) then $path else
                let $stepAfterTruncate := $steps[$stepNrTruncate + 1]
                let $append := if (starts-with($stepAfterTruncate, '@')) then '*' else '*'
                return
                    string-join(($steps[position() lt $stepNrTruncate], $append), '/')
};        

(:~
 : Transforms a string by reversing character replacements used by 
 : the BaseX JSON representation (conversion format 'direct') for 
 : representing the names of object members.
 :
 : @param item a string
 : @return the result of character replacements reversed
 :)
declare function f:unescapeJsonName($item as item()) as xs:string { 
    string-join(
        analyze-string($item, '_[0-9a-f]{4}')/*/(typeswitch(.)
        case element(fn:match) return substring(., 2) ! concat('"\u', ., '"') ! parse-json(.)
        default return replace(., '__', '_')), '')
};

declare function f:writeDoc($item as item()*,
                            $filePath as xs:string?,
                            $options as xs:string?)
        as empty-sequence() {           
    let $ops := $options ! tokenize(.)        
    let $inputNode :=
        if ($item instance of node()) then $item else i:fox-doc($item, ())

    let $indent := ('no'[$ops = 'noindent'], 'yes')[1]
    let $skipws := ('yes'[$ops = 'skipws'], 'no')[1]
    
    let $node := if (not($skipws)) then $inputNode else $inputNode ! util:prettyNode(., ())
    return
        file:write($filePath, $node, map{'method': 'xml', 'indent': $indent})
};

(:~
 : Writes a collection of files into a folder.
 :
 : @param files the file URIs
 : @param dir the folder into which to write
 : @return 0 if no errors were observed, 1 otherwise
 :)
declare function f:writeFiles($files as item()*, 
                              $dir as xs:string?,
                              $fileNameExpr as item()?,
                              $encoding as xs:string?,
                              $options as xs:string?,
                              $processingOptions as map(*)?)
        as empty-sequence() {
    let $ops := $options ! tokenize(.)
    let $noindent := $ops = 'noindent'
    for $file in $files
    let $fileName := 
        if (not($fileNameExpr)) then
            if ($file instance of node()) then $file ! base-uri(.) ! f:fileName(.)
            else error(QName((), 'INVALID_ARG'), 
                'Writing a file with non-node content requires a file name expr')
        else f:resolveFoxpath($file, $fileNameExpr, $processingOptions)
    let $dir := ($dir, '.')[1]
    let $_CREATE := if (file:exists($dir)) then () else file:create-dir($dir) 
    let $path := $dir||'/'||$fileName
    let $writeOptions := if ($noindent) then () else map{'indent': 'yes'}
    return
        file:write($path, $file, $writeOptions)
};

(:~
 : Writes documents into files.
 :
 : @param urisOrNodes document URIs or nodes
 : @param dir the output folder
 : @param path the file path of the file to be written
 : @param nameFrom when deriving the file name, replace 
 :   this part of the current file name
 : @param nameTo when deriving the file name, let this
 :   string replace the file name part specified by
 :   $nameFrom
 : @param options options controlling the function behaviour
 : @param processing options options controlling Foxpath processing
 : @param extFuncName name of the extension functions called
 : @return empty sequence
 :)
declare function f:writeDoc($urisOrNodes as item()*, 
                            $dir as xs:string?,
                            $name as xs:string?,
                            $nameExpr as item()?,
                            $nameFrom as xs:string?,
                            $nameTo as xs:string?,
                            $options as xs:string?,
                            $processingOptions as map(*)?,
                            $extFuncName as xs:string)
        as empty-sequence() {
    let $ops := f:getOptions($options, ('noindent', 'unbase', 'docbase'), $extFuncName)
    let $noindent := $ops = 'noindent'
    let $unbase := $ops = 'unbase'
    let $docbase := $ops = 'docbase'
    for $uriOrNode in $urisOrNodes
    let $baseUri :=
        if ($uriOrNode instance of node()) then $uriOrNode ! base-uri(.)
        else $uriOrNode
    let $dir := 
        let $raw := ($dir, '.')[1] return
            if (not($docbase)) then $raw else resolve-uri($raw, $baseUri)
    let $node :=
        if ($uriOrNode instance of node()) then $uriOrNode
        else i:fox-doc($uriOrNode, $processingOptions)    
    let $fileName :=
        if ($name) then $name
        else if ($nameExpr) then $nameExpr ! f:resolveFoxpath($node, ., $processingOptions)
        else 
            let $_CHECK := if ($baseUri) then () else error(QName((), 'INVALID_ARG'),
                'Function '||$extFuncName||' requires documents with a base URI, but '||
                'received a document without one.')                
            let $previousFileName := file:name($baseUri)
            return
                if ($nameFrom) then
                    let $previousFileName := replace($baseUri, '.*/', '')
                    return replace($previousFileName, $nameFrom, $nameTo)
                else $previousFileName
    let $path := $dir||'/'||$fileName                
    let $_CREATE := if ($dir eq '.') then () else 
        file:create-dir($dir)[not(file:exists($dir))]
    let $writeOptions := map{'indent': if ($noindent) then 'no' else 'yes'}
    let $wnode :=
        if (not($unbase)) then $node else
            copy $_node := $node
            modify delete node $_node//@xml:base
            return $_node
    return file:write($path, $wnode, $writeOptions)
};

(:~
 : Writes a collection of files into a folder.
 :
 : @param files the file URIs
 : @param dir the folder into which to write
 : @return 0 if no errors were observed, 1 otherwise
 :)
declare function f:writeFilesXXX($files as item()*, 
                                 $dir as xs:string?,
                                 $encoding as xs:string?)
        as xs:integer {
    let $tocItems :=        
        for $file at $pos in $files
        let $file := 
            if ($file instance of attribute()) then string($file) else $file
        let $path :=
            if ($file instance of node()) then 
                let $raw := $file/root()/document-uri(.)
                return if ($raw) then $raw else concat('__file__', $pos)
            else $file        
        let $fname := replace($path, '^.+/', '')
        group by $fname
        return
            if (count($file) eq 1) then 
                <file name="{$fname}" path="{$path}"/>
            else
                <files originalName="{$fname}" count="{count($file)}">{
                    let $prePostfix := replace($fname, '(.+)(\.[^.]*$)', '$1~~~$2')
                    let $pre := substring-before($prePostfix, '~~~')
                    let $post := substring-after($prePostfix, '~~~')
                    for $f at $pos in $file
                    let $hereName := if ($pos eq 1) then $fname else concat($pre, '___', $pos, '___', $post)
                    return
                        <file originalName="{$fname}" name="{$hereName}" path="{$f}"/>
                }</files> 
    let $toc := <toc countFnames="{count($tocItems)}" countFiles="{count($files)}">{$tocItems}</toc>
    let $tocFname := concat($dir, '/', '___toc.write-files.xml')
    let $_ := file:write($tocFname, $toc)
    
    let $errors :=
        for $file at $pos in $files
        let $file := 
            if ($file instance of attribute()) then string($file) else $file
        let $path :=
            if ($file instance of node()) then 
                let $raw := $file/root()/document-uri(.)
                return if ($raw) then $raw else concat('__file__', $pos)
            else $file   
        let $fname := $toc//file[@path eq $path]/@name/string()
        let $fname_ := string-join(($dir, $fname), '/')        
        let $fileContent := 
            if ($file instance of node()) then serialize($file)
            else i:fox-unparsed-text($file, $encoding, ())        
        return
            try {
                trace(file:write-text($fname_, $fileContent) , concat('Write file: ', $fname_, ' '))
            } catch * {trace(1, concat('ERR:CODE: ', $err:code, ', ERR:DESCRIPTION: ', $err:description, ' - '))}
    return
        ($errors[1], 0)[1]
};

(:~
 : Writes a collection of json documents as json docs into a folder.
 :
 : @param files the file URIs
 : @param dir the folder into which to write
 : @return 0 if no errors were observed, 1 otherwise
 :)
declare function f:writeJsonDocs($files as xs:string*, 
                                 $dir as xs:string?,
                                 $encoding as xs:string?)
        as xs:integer {
    let $tocItems :=        
        for $file at $pos in $files
        let $file := 
            if ($file instance of attribute()) then string($file) else $file
        let $path :=
            if ($file instance of node()) then 
                let $raw := $file/root()/document-uri(.)
                return if ($raw) then $raw else concat('__file__', $pos)
            else $file        
        let $fnameOrig := replace($path, '^.+/', '')
        let $fname := 
            if ($file instance of node()) then $fnameOrig 
            else concat($fnameOrig, '.xml')
        group by $fnameOrig
        return
            if (count($file) eq 1) then 
                <file name="{$fname}" originalName="{$fnameOrig}" path="{$path}"/>
            else
                <files originalName="{$fnameOrig}" count="{count($file)}">{
                    let $prePostfix := replace($fnameOrig, '(.+)(\.[^.]*$)', '$1~~~$2')
                    let $pre := substring-before($prePostfix, '~~~')
                    let $post := substring-after($prePostfix, '~~~')
                    for $f at $pos in $file
                    let $name := 
                        let $raw :=
                            if ($pos eq 1) then $fnameOrig else 
                                concat($pre, '___', $pos, '___', $post)
                        return
                             if ($f instance of node()) then $raw else concat($raw, '.xml')
                    return
                        <file name="{$name}" originalName="{$fnameOrig[1]}" path="{$f}"/>
                }</files> 
    let $toc := <toc countFnames="{count($tocItems)}" countFiles="{count($files)}">{$tocItems}</toc>
    let $tocFname := concat($dir, '/', '___toc.write-json-docs.xml')
    let $_ := file:write($tocFname, $toc)
    
    let $errors :=
        for $file at $pos in $files
        let $file := 
            if ($file instance of attribute()) then string($file) else $file
        let $path :=
            if ($file instance of node()) then 
                let $raw := $file/root()/document-uri(.)
                return if ($raw) then $raw else concat('__file__', $pos)
            else $file   
        let $fname := $toc//file[@path eq $path]/@name/string()
        let $fname_ := string-join(($dir, $fname), '/')        
        let $fileContent := 
            if ($file instance of node()) then serialize($file)
            else 
                try {
                    let $fileContent := i:fox-unparsed-text($file, $encoding, ())
                    return
                        json:parse($fileContent) ! serialize(.)
                } catch * {trace((), 
                    concat('ERR:CODE: ', $err:code, ', ERR:DESCRIPTION: ', $err:description, ' - '))}
        where $fileContent                    
        return
            try {
                trace(file:write-text($fname_, $fileContent) , concat('Write file: ', $fname_, ' '))
            } catch * {trace(1, concat('ERR:CODE: ', $err:code, ', ERR:DESCRIPTION: ', $err:description, ' - '))}
    return
        ($errors[1], 0)[1]
(:        
    let $errors :=
        for $file in $files
        let $path := $file
        let $fname := replace($path, '^.+/', '')
        let $fname_ := trace(concat(string-join(($dir, $fname), '/'), '.xml') , 'PATH#: ')
        let $fileContent := f:fox-unparsed-text($file, $encoding, ())
        let $fileContentXml := json:parse($fileContent) ! serialize(.)
        return
            try {
                file:write-text($fname_, $fileContentXml)
            } catch * {1}
    return
        ($errors[1], 0)[1]
:)        
};

(:~
 : Constructs an element with content given by $content. Each pair of items in $atts
 : provides the name and value of an attribute to be added.
 :
 : @param content the element content
 : @param name the element name
 : @return the constructed element
 :)
declare function f:xattribute($content as item()*, $name as xs:string)
        as attribute() {
    attribute {$name} {$content}
};      


(:~
 : Constructs an element with given content and name.
 :
 : @param content the element content
 : @param name the element name
 : @param repeat options controling the function behaviour
 :   repeat - create an element for every item in $content
 : @return the constructed element
 :)
declare function f:xelement($content as item()*, 
                            $name as xs:string, 
                            $options as xs:string?)
        as element()* {
    let $ops := f:getOptions($options, ('repeat', 'pretty'), 'xelem')
    let $repeat := $ops = 'repeat'
    let $pretty := $ops = 'pretty'
    let $element :=
        if ($repeat) then $content ! element {$name} {.}
        else
            let $atts := $content[. instance of attribute()]
            let $nonatts := $content[not(. instance of attribute())]
            return
                element {$name} {$atts, $nonatts}
    return
        if ($pretty) then $element ! util:prettyNode(., ())
        else $element
};      

(:~
 : Wraps items in elements.
 :
 : @param items value items (atoms and/or nodes)
 : @param name the element name
 : @return the constructed elements
 :)
declare function f:xitemElems($items as item()*, 
                              $name as xs:string?,
                              $options as xs:string?)
        as element()* {
    let $ops := $options ! tokenize(.)        
    let $fnContent :=
        if ($ops = 'string') then function($item) {string($item)}
        else function($item) {$item}
    return
    
    if ($name) then $items ! element {$name} {$fnContent(.)}
    else
        (: Use node name, if possible :)
        for $item in $items
        let $name := $item[. instance of node()] ! name() 
        return element {($name, 'item')[1]} {$fnContent($item)}
};      

(:~
 : Returns the parsed XML representation of an XQuery module.
 :
 : @param uri the URI of the module
 : @param options processing options
 : @return the parsed module content
 :)
declare function f:xqDoc($uri as xs:string, $options as map(*)?)
    as item()* {
    let $text := i:fox-unparsed-text($uri, (), $options)
    return
        try {xquery:parse($text)} catch * {()}
};

(:~
 : Foxpath function `xwrap#3`. Collects the items of $items into an XML document.
 :
 : Sorting:
 : (1) if flag 's' is used: item representations are sorted by the string value of the item
 : (2) if flag 'S' is used: item representations are sorted by the string value of the item, case-insensitively
 : (3) otherwise no sorting is performed
 :
 : Before copying into the result document, every item from $items is processed as follows:
 : (A) if an item is a node:
 :   (1) if flag 'b' is set, a copy enhanced by an @xml:base attribute is created
 :   (2) if flag 'n' is set, a copy enhanced by a @fileName attribute is created 
 :   (3) if flag 'p' is set, a copy enhanced by a @fox:path attribute is created
 :   (4) if flag 'j' is set, a copy enhanced by a @fox:jpath attribute is created
 :   (5) if flag 'f' is set, the copy is "flattened" - child nodes are discarded  
 :   (6) if flag 'a' is set, the item is not modified if it is not an attribute;
 :       if it is an attribute, it is mapped to an element which has a name 
 :       equal to the name of the parent of the attribute, and which contains a 
 :       copy of the attribute 
 :   (7) if flag 'A' is set, treatment as with flag 'a', but the constructed element
 :       has no namespace URI 
 :   (8) otherwise, the item is not modified (except for possible pretty-printing, see (C))
 : (B) if an item is atomic: 
 :   (1) if flag 'd' is set, the item is interpreted as URI and it is attempted to be
 :       parsed into a document, with an @xml:base attribute added to the root element,
 :       if flag 'b' is set, and without @xml:base otherwise; if parsing fails, a 
 :       <PARSE-ERROR> element is created with the item value as content
 :   (2) if flag 'w' is set, the item is interpreted as URI and the text found at
 :       this URI is retrieved and wrapped in an element with an @xml:base attribute
 :       element name given by parameter $name2, default _text_
 :   (3) if flag 't' is set, the item is interpreted as URI and the text found at 
 :       this URI is retrieved (not wrapped in an element)
 :   (4) if flag 'c' is set, the item is treated as a text and wrapped in an element;
 :       element name given by parameter $name2, default _text_
 :   (5) if none of the flags 'd', 'w', 't', 'c' is set: the item is not modified 
 :
 : (C) if flag 'P' is set, the result document is pretty-printed
 : 
 : @param items the items from which to create the content of the result document
 : @param name the name of the root element of the result document
 : @param flags flags controlling the representation of the items and possible sorting
 : @param name2 the name of inner wrapper elements, wrapping an individual item (only in case of flags c and w)
 : @param options foxpath processing options
 : @return the result document
 :)
declare function f:xwrap($items as item()*, 
                         $name as xs:QName, 
                         $flags as xs:string?, 
                         $name2 as xs:QName?, $options as map(*)?) 
        as element()? {
    (: name2 is the name of inner wrapper elements, wrapping an individual item :)
    let $name2 := if (empty($name2)) then '_text_' else $name2   
    
    let $pretty := contains($flags, 'P')
    let $sortRule := if (contains($flags, 's')) then 's' else if (contains($flags, 'S')) then 'S' else ()        
    let $val :=
        for $item in $items 
        order by if ($sortRule eq 's') then $item 
                 else if ($sortRule eq 'S') then lower-case($item) 
                 else ()
        return 

        typeswitch($item)
        
        (: item a node => copy item :)        
        case element() | attribute() | document-node() return
            let $item := if ($item/self::document-node()) then $item/* else $item
            let $additionalAtts := (
                if (not(contains($flags, 'b'))) then () else
                    attribute xml:base {$item/base-uri(.)},
                if (not(contains($flags, 'n'))) then () else
                    attribute {QName($const:NS_FOX, 'fox:fileName')} {$item/base-uri(.) ! replace(., '.*/', '')},
                if (not(contains($flags, 'p'))) then () else
                    attribute {QName($const:NS_FOX, 'fox:path')} {$item/f:indexedNamePath(., (), 'name')},
                if (not(contains($flags, 'j'))) then () else
                    attribute {QName($const:NS_FOX, 'fox:jpath')} {$item/f:namePath(., (), 'jname')}
            )
            let $atts :=
                if (empty($additionalAtts) or empty($item/@*)) then $item/@*
                else
                    let $additionalAttNames := $additionalAtts ! node-name(.)
                    return $item/@*[not(node-name() = $additionalAttNames)]
            let $namespaces :=
                if (not($item/self::element())) then () else
                    for $prefix in in-scope-prefixes($item)[string()] return
                        namespace {$prefix} {namespace-uri-for-prefix($prefix, $item)}
            return
                (: Flags aA - attribute item is turned into an element :)
                if (contains($flags, 'a') or contains($flags, 'A')) then    
                    if (not($item/self::attribute())) then $item
                    else 
                        let $elemName := $item/../(
                            if (contains($flags, 'A')) then local-name(.)
                            else QName(namespace-uri(.), local-name(.)))
                        return element {$elemName} {$namespaces, $additionalAtts, $item}
                        
                (: Flag f - discard child nodes :)
                else if (contains($flags, 'f')) then
                    element {node-name($item)} {$namespaces, $additionalAtts, $atts}
                    
                (: With additional attributes :)
                else if (not($additionalAtts)) then $item
                
                (: Plain copy :)
                else
                    $item/element {node-name(.)} {$namespaces, $additionalAtts, $atts, node()}
                
        (: item a URI, flag 'd' => parse document at that URI :)
        default return
            if (contains($flags, 'd')) then
                let $doc := try {i:fox-doc($item, $options)/*} catch * {()}
                return if (not($doc)) then <PARSE-ERROR uri="{$item}"/> else
 
                if (contains($flags, 'b')) then
                    let $xmlBase := if ($doc/@xml:base) then () else attribute xml:base {$item}
                    return
                        if (not($xmlBase)) then $doc else
                            element {node-name($doc)} {
                                $doc/@*, $xmlBase, $doc/node()
                                    }
                else $doc
                    
            (: item a URI, flag 'w' => read text at that URI, write it into a wrapper element :)                    
            else if (contains($flags, 'w')) then
                let $text := try {i:fox-unparsed-text($item, (), $options)} catch * {()}
                return
                    if ($text) then element {$name2} {attribute xml:base {$item}, $text}
                    else <READ-ERROR uri="{$item}"/>
                
            (: item a URI, flag 't' => read text at that URI, copy it into result :)                
            else if (contains($flags, 't')) then
                let $text := try {i:fox-unparsed-text($item, (), $options)} catch * {()}
                return
                    if ($text) then $text
                    else <READ-ERROR uri="{$item}"/>
                
            (: flag 'c' => wrap item in an element :)                
            else if (contains($flags, 'c')) then
                element {$name2} {$item}
            
            else $item
            
    (: Write wrapper :)            
    let $namespaces :=  
        let $nns := f:extractNamespaceNodes($val[. instance of element()])
        for $nn in $nns        
        group by $prefix := name($nn)
        let $nn1:= $nn[1]
        where $prefix ne 'xml' and $nn1
        (: Default namespace is suppressed if $name is in no namespace :)
        where $prefix or string(namespace-uri-from-QName($name))
        return $nn1
    let $result :=
        element {$name} {
            $namespaces,        
            attribute countItems {count($val)},
            $val
        }
    return if ($pretty) then $result/util:prettyNode(., ()) else $result        
};

(:~
 : Validates a set of documents against an XSD.
 :)
declare function f:xsdValidate($docs as item()*,
                               $xsds as item()*,
                               $options as xs:string?)
        as item()* {
    if (empty($xsds)) then error(QName((), 'INVALID_CALL'), 'Function validate-xsd - no XSDs specified')
    else

    let $ops := f:getOptions($options, ('fname', 'summary'), 'xsd-validate')
    let $view := $ops[. = ('summary')]
    let $useFname := $ops = 'fname'    
    let $fnIdentAtt :=
        if ($useFname) then function($uri) {attribute file-name {replace($uri, '.*/', '')}}
        else function($uri) {attribute uri {$uri}}
    let $xsdNodes :=
        for $xsd in $xsds return 
            if ($xsd instance of node()) then $xsd/descendant-or-self::xs:schema[1]
            else doc($xsd)/*
    let $reports := 
        for $doc in $docs
        let $docNode :=
            if ($doc instance of node()) then $doc
            else try {doc($doc)/*} catch * {()}
        return if (not($docNode)) then
            <validationReport>{
                $fnIdentAtt($doc),
                <status>xml_not_wellformed</status>
            }</validationReport>
            else
            
        let $uri := $docNode/namespace-uri(.)
        let $docPath := $doc[. instance of node()]/f:indexedNamePath($doc, (), ())
        let $lname := $docNode/local-name(.)
        let $myxsds := 
            let $raw := $xsdNodes
                [if (not($uri)) then not(@targetNamespace) else $uri eq @targetNamespace]
                [xs:element/@name = $lname]
            return
                if (exists($raw)) then $raw else $xsdNodes[1]
        let $result :=
            if (count($myxsds) gt 1) then <status>xsd_ambiguous</status>
            else if (not($myxsds)) then <status>xsd_nofind</status>
            else try {validate:xsd-report($doc, $myxsds/base-uri(.))/*} 
                 catch * {<status>validation_failed</status>}
        let $docuri := if (not($doc instance of node())) then $doc else base-uri($doc)
        return 
            <validationReport>{
                $fnIdentAtt($docuri),
                $docPath ! attribute nodePath {.}, 
                attribute xsd {$myxsds/base-uri(.)},
                $result
            }</validationReport>
    let $messagesDistinct :=
        for $message in $reports//message
        group by $text := string($message)
        return <message count="{count($message)}">{$text}</message>
    let $reports2 :=
        if (count($reports) gt 1) then 
            let $invalid := $reports[status eq 'invalid']
            let $ambiguous := $reports[status eq 'xsd_ambiguous']            
            let $nofind := $reports[status eq 'xsd_nofind']
            let $valid := $reports except ($invalid, $ambiguous, $nofind)

            return
                <validationReports countDocs="{count($reports)}"
                                   countValid="{count($valid)}"
                                   countInvalid="{count($invalid)}"
                                   countNofind="{count($nofind)}"
                                   countAmbiguous="{count($ambiguous)}">{
                    if (not($messagesDistinct)) then () else
                    <distinctMessages count="{count($messagesDistinct)}">{$messagesDistinct}</distinctMessages>,
                    if (count($reports) eq 1) then $reports
                    else (
                        <invalid count="{count($invalid)}">{
                            for $doc in $invalid 
                            let $ename := if ($doc/@nodePath) then 'node' else 'doc'
                            order by $doc/@uri, $doc/@file-name, $doc/@nodePath
                            return element {$ename} {$doc/(@uri, @file-name, @nodePath, @xsd, $doc/*)}
                        }</invalid>[count($invalid) gt 0],
                        <valid count="{count($valid)}">{
                            for $doc in $valid 
                            let $ename := if ($doc/@nodePath) then 'node' else 'doc'
                            order by $doc/@uri, $doc/@file-name, $doc/@nodePath
                            return element {$ename} {$doc/(@uri, @file-name, @nodePath, @xsd)}
                        }</valid>,
                        if (empty($nofind)) then () else
                        <nofind count="{count($nofind)}">{
                            for $doc in $nofind 
                            let $ename := if ($doc/@nodePath) then 'node' else 'doc'
                            order by $doc/@uri, $doc/@file-name, $doc/@nodePath
                            return element {$ename} {$doc/(@uri, @file-name, @nodePath, @xsd)}
                        }</nofind>,
                        <ambiguous count="{count($ambiguous)}">{
                            for $doc in $ambiguous 
                            let $ename := if ($doc/@nodePath) then 'node' else 'doc'
                            order by $doc/@uri, $doc/@file-name, $doc/@nodePath
                            return element {$ename} {$doc/(@uri, @file-name,  @nodePath, @xsd)}
                        }</ambiguous>
                    )
                }</validationReports>
        else $reports
    return
        if ($view eq 'summary') then (
            $reports2//invalid/('invalid (#'||@count||')', doc/(@uri, @file-name)/('  '||.)),
            $reports2//nofind/('nofind (#'||@count||')', doc/(@uri, @file-name)/('  '||.)),            
            $reports2//ambiguous/('ambiguous (#'||@count||')', doc/(@uri, @file-name)/('  '||.)),
            $reports2//valid/('valid (#'||@count||')')
        )
        else    
            copy $reports2_ := $reports2
            modify delete nodes $reports2_//message/@url
            return $reports2_
 };

(:~
 : Validates a set of documents against a DTD.
 :)
declare function f:dtdValidate($docs as item()*,
                               $dtd as item()?,
                               $options as xs:string?)
        as item()* {
    if (empty($dtd)) then error(QName((), 'INVALID_CALL'), 'Function dtd-validate - no DTD specified')
    else

    let $ops := f:getOptions($options, ('fname', 'summary'), 'dtd-validate')
    let $view := $ops[. = ('summary')]
    let $useFname := $ops = 'fname'    
    let $fnIdentAtt :=
        if ($useFname) then function($uri) {attribute file-name {replace($uri, '.*/', '')}}
        else function($uri) {attribute uri {$uri}}
    (:
    let $xsdNodes :=
        for $xsd in $xsds return 
            if ($xsd instance of node()) then $xsd/descendant-or-self::xs:schema[1]
            else doc($xsd)/*
     :)
    let $reports := 
        for $doc in $docs
        let $docNode :=
            if ($doc instance of node()) then $doc
            else try {doc($doc)/*} catch * {()}
        return if (not($docNode)) then
            <validationReport>{
                $fnIdentAtt($doc),
                <status>xml_not_wellformed</status>
            }</validationReport>
            else
            
        let $uri := $docNode/namespace-uri(.)
        let $docPath := $doc[. instance of node()]/f:indexedNamePath($doc, (), ())
        let $lname := $docNode/local-name(.)
        let $result :=
            try {validate:dtd-report($doc, $dtd)} 
            catch * {<status>validation_failed</status>}
        let $docuri := if (not($doc instance of node())) then $doc else base-uri($doc)
        return 
            <validationReport>{
                $fnIdentAtt($docuri),
                $docPath ! attribute nodePath {.}, 
                attribute dtd {$dtd},
                $result
            }</validationReport>
    let $messagesDistinct :=
        for $message in $reports//message
        group by $text := string($message)
        return <message count="{count($message)}">{$text}</message>
    let $reports2 :=
        if (count($reports) gt 1) then 
            let $invalid := $reports[status eq 'invalid']
            let $nofind := $reports[status eq 'dtd_nofind']
            let $valid := $reports except ($invalid, $nofind)

            return
                <validationReports countDocs="{count($reports)}"
                                   countValid="{count($valid)}"
                                   countInvalid="{count($invalid)}"
                                   countNofind="{count($nofind)}">{
                    if (not($messagesDistinct)) then () else
                    <distinctMessages count="{count($messagesDistinct)}">{$messagesDistinct}</distinctMessages>,
                    if (count($reports) eq 1) then $reports
                    else (
                        <invalid count="{count($invalid)}">{
                            for $doc in $invalid 
                            let $ename := if ($doc/@nodePath) then 'node' else 'doc'
                            order by $doc/@uri, $doc/@file-name, $doc/@nodePath
                            return element {$ename} {$doc/(@uri, @file-name, @nodePath, @xsd, $doc/*)}
                        }</invalid>[count($invalid) gt 0],
                        <valid count="{count($valid)}">{
                            for $doc in $valid 
                            let $ename := if ($doc/@nodePath) then 'node' else 'doc'
                            order by $doc/@uri, $doc/@file-name, $doc/@nodePath
                            return element {$ename} {$doc/(@uri, @file-name, @nodePath, @xsd)}
                        }</valid>,
                        if (empty($nofind)) then () else
                        <nofind count="{count($nofind)}">{
                            for $doc in $nofind 
                            let $ename := if ($doc/@nodePath) then 'node' else 'doc'
                            order by $doc/@uri, $doc/@file-name, $doc/@nodePath
                            return element {$ename} {$doc/(@uri, @file-name, @nodePath, @xsd)}
                        }</nofind>
                    )
                }</validationReports>
        else $reports
    return
        if ($view eq 'summary') then (
            $reports2//invalid/('invalid (#'||@count||')', doc/(@uri, @file-name)/('  '||.)),
            $reports2//nofind/('nofind (#'||@count||')', doc/(@uri, @file-name)/('  '||.)),            
            $reports2//ambiguous/('ambiguous (#'||@count||')', doc/(@uri, @file-name)/('  '||.)),
            $reports2//valid/('valid (#'||@count||')')
        )
        else    
            copy $reports2_ := $reports2
            modify delete nodes $reports2_//message/@url
            return $reports2_
 };

(:~
 :
 : ===    U t i l i t i e s ===
 :
 :)

(:~
 : Returns for given items all descendants and their attributes. Atomic
 : items are ignored.
 :
 : @param a sequence of items
 : @return descendant nodes and their attributes
 :) 
declare function f:allDescendants($items as item()*)
        as node()* {
    $items[. instance of node()]//(@*, *)        
};        

(:~
 : Returns the relative path leading from $uri1 to $uri2.
 :)
declare function f:relPath($uri1 as xs:string, $uri2 as xs:string)
        as xs:string? {
    if ($uri1 eq $uri2) then '.' else
    
    let $uri1Slash := replace($uri1, '[^/]$', '$0/')
    return
        if (starts-with($uri2, $uri1Slash)) then substring-after($uri2, $uri1Slash)
        else if (not(matches($uri1Slash, '/.*/'))) then ()
        else string-join(
            let $nextUri1 := (replace($uri1Slash, '^(.*)/.*?/$', '$1')[string()], '/')[1]
            return ('..', f:relPath($nextUri1, $uri2)[. ne '.'][string()]), '/')       
};

(:~
 : Normalizes a URI by removing . and .. steps. No changes are made if the
 : URI starts with ..
 :)
declare function f:normalizeURIPath($uri as xs:string)
        as xs:string? {
    let $uri2 := 
        if (starts-with($uri, '..')) then $uri
        else if ($uri eq '.') then $uri
        else if (matches($uri, '^.*/?\.\.')) then replace($uri, '^(.*?/)([^/]+?/\.\./?)(.*)$', '$1$3') ! replace(., '(.+)/$', '$1')
        else if (matches($uri, '^.*/?\.')) then replace($uri, '^(.*/)?(\./?)(.*)$', '$1$3') ! replace(., '(.+)/$', '$1')
        else $uri
    return
        if ($uri eq $uri2) then $uri else f:normalizeURIPath($uri2)
};

(:~
 : Normalizes file system path:
 : - replaces \ with /
 : - removes trailing /
 : - removes "file://", if present
 : The result is either a relative path, or a path starting
 : with "/" (Unix), or a path starting with d:/ (Window,
 : where "d" represents the drive letter).
 :
 : @param path a file system path, or a file URI
 : @return the normalized path
 :) 
declare function f:normalizePath($path as xs:string)
        as xs:string {
    $path
    ! replace(., '\\', '/')
    ! replace(., '/$', '')
    ! replace(., 
      '^file:/*? ((/([a-zA-Z]:/.*))$  |  (/([^/].*)?$))', '$3$4', 'x')
    ! replace(., '/$', '')
};

(:~
 : Returns namespace nodes which apply to all elements in the
 : input sequence of elements.
 :
 : @param elems a sequence of elements
 : @return a sequence of namespace nodes
 :)
declare function f:extractNamespaceNodes($elems as element()*)
        as namespace-node()* {
    let $elems := $elems/descendant-or-self::*        
    let $nspairs := (
        for $elem in $elems
        let $prefixes := in-scope-prefixes($elem)
        let $nspair := $prefixes ! concat(., '#', namespace-uri-for-prefix(., $elem))
        return $nspair 
    ) => distinct-values()

    for $nspair in $nspairs
    group by $prefix := substring-before($nspair, '#')
    where not($prefix eq 'xml')
    where 1 eq ($nspair => distinct-values() => count())
    return
        let $nsuri := $nspair[1] ! substring-after(., '#')
        return
            if ($prefix eq '' and 
                (some $elem in $elems satisfies not('' = in-scope-prefixes($elem)))) 
            then () else namespace {$prefix} {$nsuri}
               
};

(:~
 :
 : ===    f t r e e ===
 :
 :)

(:~
 : Creates a file system tree document. Return an <ftree> or
 : an <ftrees> document.
 :
 : File properties are described by (a) an optional file name
 : pattern, (b) a property name, (c) a property retrieval
 : expression.
 :)
declare function f:ftree($folders as xs:string*,
                         $fileProperties as item()*,
                         $processingOptions as map(*)) as element(*)? {
    let $filePropertiesMap := 
        f:ftreeUtil_filePropertyMap($fileProperties, $processingOptions)
    let $useOptions := map:merge((
        $filePropertiesMap ! map:entry('_file-properties', $filePropertiesMap)
    ))
    let $ftrees :=
        for $folder in $folders
        let $content := $folder ! f:ftreeREC(., $useOptions)
        let $rootAttributes := f:getFtreeAttributes($folder, $content, ())
        return <ftree>{$rootAttributes, $content}</ftree>
    return
        if (count($ftrees) le 1) then $ftrees
        else <ftrees count="{count($ftrees)}">{$ftrees}</ftrees>
};

(:~
 : RECursive helper function of `f:ftree`.
 :)
declare function f:ftreeREC($folder as xs:string, $options as map(*)) as element()? {
    let $members := i:childUriCollection($folder, (), (), ()) ! concat($folder, '/', .)
    let $subfolders := $members[i:fox-is-dir(., ())] ! f:ftreeREC(., $options)
    let $filePropertiesMap := $options?_file-properties
    let $files := $members[i:fox-is-file(., ())] !
        <fi name="{util:fileName(.)}">{            
            if (empty($filePropertiesMap)) then () else
                for $p in array:flatten($filePropertiesMap)
                let $pname := map:keys($p)
                let $pmap := $p($pname)
                let $fileNameFilter := $pmap?fileName                
                return
                    if (not(use:matchesUnifiedStringExpression(util:fileName(.), $fileNameFilter))) then ()
                    else
                        let $itemElemName := $pmap?itemElemName[string()]
                        let $occs := $pmap?occs[string()]
                        let $pvalueP := f:resolveFoxpath(., $pmap?exprTree, $options)
                        return 
                            if (empty($pvalueP) and $occs = ('?', '*')) then ()
                            else if ($pmap?isAtt) then attribute {$pname} {$pvalueP}
                            else if ($itemElemName) then
                                element {$pname} {$pvalueP ! element {$itemElemName} {.}}
                            else if ($occs eq '*') then $pvalueP ! element {$pname} {.}                            
                            else element {$pname} {$pvalueP}
        }</fi>
    return
        <fo name="{util:fileName($folder)}">{$subfolders, $files}</fo>
};

(:~
 : Creates a file system tree document.
 :)
declare function f:ftreeSelective(
                         $folders as xs:string*,
                         $uris as xs:string*,
                         $fileNamesFilter as xs:string?,
                         $folderNamesFilter as xs:string?,
                         $fileProperties as item()*,
                         $options as map(*)?,
                         $processingOptions as map(*)) as element()? {
    let $filePropertiesMap := 
        f:ftreeUtil_filePropertyMap($fileProperties, $processingOptions)    
    let $cfileNamesFilter := $fileNamesFilter ! use:compileUnifiedStringExpression(., true(), (), ())     
    let $cfolderNamesFilter := $folderNamesFilter! use:compileUnifiedStringExpression(., true(), (), ())
    let $folders :=
        if (exists($folders)) then $folders
        else if (exists($uris)) then f:getRootUri($uris)
        else error(QName((), 'INVALID_ARG'), 'Writing ftrees - either root folders or URIs must be specified')
    let $useOptions := map:merge((
        $processingOptions,
        $options,
        $cfolderNamesFilter ! map:entry('_folderNames', .),
        $filePropertiesMap ! map:entry('_file-properties', $filePropertiesMap)
    ))
    let $ftrees :=
        for $folder in $folders
        let $descendantUris := 
            if (exists($uris)) then $uris
            else
                i:descendantUriCollection($folder, (), (), ()) ! concat($folder, '/', .)
                [replace(., '.+/', '') ! use:matchesUnifiedStringExpression(., $cfileNamesFilter)]
        let $descendants := $descendantUris ! replace(., '^'||$folder||'/', '')
        let $content := $folder ! f:ftreeSelectiveREC(., $descendants, $useOptions)
        let $rootAttributes := f:getFtreeAttributes($folder, $content, $options)
        return <ftree>{$rootAttributes, $content}</ftree>
    return
        if (count($ftrees) le 1) then $ftrees
        else <ftrees count="{count($ftrees)}">{$ftrees}</ftrees>
};

(:~
 : RECursive helper function of `f:ftreeSelective`.
 :)
declare function f:ftreeSelectiveREC(
        $folder as xs:string,
        $descendants as xs:string*,
        $options as map(*)) as element()? {
    if ($folder 
        ! util:fileName(.) 
        ! (not(use:matchesUnifiedStringExpression(., $options?_folderNames)))) then () else
    
    let $filePropertiesMap := $options?_file-properties    
    let $folderName := replace($folder, '.*/', '')
    let $subfoldersAndFiles :=
        for $d in $descendants
        group by $childName := replace($d, '/.*', '')
        where $childName
        return
            let $childUri := $folder||'/'||$childName return        
            if (empty($d[contains(., '/')])) then
                let $ename := if (i:fox-is-dir($childUri, ())) then 'fo' else 'fi' return
                element {$ename} {
                    attribute name {$childName},
                    if (empty($filePropertiesMap)) then () else
                        for $p in array:flatten($filePropertiesMap)
                        let $pname := map:keys($p)
                        let $pmap := $p($pname)
                        let $fileNameFilter := $pmap?fileName
                        return
                            if (not(use:matchesUnifiedStringExpression($childName, $fileNameFilter))) then ()
                            else
                                let $itemElemName := $pmap?itemElemName[string()]
                                let $occs := $pmap?occs[string()]
                                let $pvalueP := $childUri ! f:resolveFoxpath(., $pmap?exprTree/*, $options)
                                return 
                                    if (empty($pvalueP) and $occs = ('?', '*')) then ()
                                    else if ($pmap?isAtt) then attribute {$pname} {$pvalueP}
                                    else if ($itemElemName) then
                                        element {$pname} {$pvalueP ! element {$itemElemName} {.}}
                                    else if ($occs eq '*') then $pvalueP ! element {$pname} {.}                                        
                                    else element {$pname} {$pvalueP}
                }
            else
                let $newFolder := $folder||'/'||$childName
                let $newDescendants := $d ! substring-after(., $childName||'/')                
                return f:ftreeSelectiveREC($newFolder, $newDescendants, $options)
    let $files := $subfoldersAndFiles/self::fi => sort((), function($f) {$f/@name})
    let $folders := $subfoldersAndFiles/self::fo => sort((), function($f) {$f/@name})
    return
        <fo name="{$folderName}">{
            $files,
            $folders
        }</fo>
};

(:~
 : Returns an array of maps, each one describing a file property.
 : A file property is described by a name and a Foxpath expression
 : returning the property value, as well as an optional file
 : name filter selecting files for which the property is assigned:
 :     name=expr
 :     filter name=expr
 :
 : @param exprTrees parsed expression trees - each child element provides
 :   the expression tree for the file property named like the element 
 : @param options the options map received by the ftree* function
 : @return an array of maps
 :)
declare function f:ftreeUtil_filePropertyMap($fileProperties as item()*, 
                                             $processingOptions as map(*))
        as array(map(*))? {
    if (empty($fileProperties)) then () else
    
    let $countProperties := (count($fileProperties) div 2) ! xs:integer(.)
    let $entries :=
        for $p in 1 to $countProperties
        let $fnameAndPname := $fileProperties[$p * 2 - 1]
        let $propertyExpression := $fileProperties[$p * 2]
        
        let $withFname := matches($fnameAndPname, '\s')
        (: File name filter :)
        let $fname := (
            if (not($withFname)) then '*' 
            else replace($fnameAndPname, '^(.*)\s.*', '$1')
        ) ! use:compileUnifiedStringExpression(., true(), (), ())
        (: Property name :)
        let $pnameRaw := 
            if (not($withFname)) then $fnameAndPname 
            else replace($fnameAndPname, '.*\s', '')
        (: occs - optional ? or * :)
        let $occs := replace($pnameRaw, '.*([?*])$', '$1')[. ne $pnameRaw]
        let $isAtt := starts-with($pnameRaw, '@')        
        let $pname := $pnameRaw ! replace(., '^@|\?|\*$', '')       
        let $pname2 := $pname[contains(., '/')] ! replace(., '.*/\s*', '')
        let $pname1 := if (empty($pname2)) then $pname else replace($pname, '\s*/.*', '')
        
        (: Expression or expression tree :)
        let $expr := 
            if ($propertyExpression instance of element(contextExpression)) then 
                $propertyExpression/@text
            else $propertyExpression
        let $exprTree := 
            if ($propertyExpression instance of element(contextExpression)) then 
                $propertyExpression
            else 
                let $processingOptions := map:put($processingOptions, 'IS_CONTEXT_URI', ())
                return i:parseSeqExpr($propertyExpression, $processingOptions)
        return
            map:entry($pname1, map{'isAtt': $isAtt,
                                   'occs': $occs,            
                                   'expr': $expr, 
                                   'exprTree': $exprTree, 
                                   'fileName': $fname,                                   
                                   'itemElemName': $pname2
                                  })
    let $entriesAtt := $entries[?(map:keys(.))?isAtt]                
    let $entriesElem := $entries[not(?(map:keys(.))?isAtt)]
    return
        array {$entriesAtt, $entriesElem}
};

(:~
 : Returns the info attributes of the ftree report root element.
 :
 : @param folder the folder to be reported
 : @param content the content of the folder element
 : @param options the options representing user options
 : @return attributes describing the report invocation
 :)
declare function f:getFtreeAttributes($folder as xs:string, 
                                      $content as element()*, 
                                      $options as map(*)?)
        as attribute()* {
    attribute context {$folder ! i:parentUri(., ())},
    attribute countFo {count($content//fo) + 1},
    attribute countFi {count($content//fi)},
    $options ! f:getUserInputAttributes(.)
};

(:~
 : Returns attributes representing all options with a key name
 : which does not start with an underscore.
 :)
declare function f:getUserInputAttributes($options as map(*)) as attribute()* {
    map:keys($options)[not(starts-with(., '_'))] ! attribute {.} {$options(.)}
};

(:~
 : Returns the option values extracted from an $options
 : parameter. The parameter value contains a whitespace-
 : separated list of option values.
 :
 : @param options option values
 : @param validOptions valid option values; a trailing *
 :   is interpreted as wildcard
 : @functionName the name of the function whose options are evaluated
 : @return the option values
 :) 
declare function f:getOptions($options as xs:string*, 
                              $validOptions as xs:string*,
                              $functionName as xs:string)
        as xs:string* {
    let $ops := $options ! tokenize(.) ! lower-case(.) 
    let $voNames := $validOptions[not(ends-with(., '*'))]
    let $voPrefixes := $validOptions[ends-with(., '*')] ! replace(., '\*$', '')
    let $invalid := $ops[not(. = $validOptions or 
        (some $prefix in $voPrefixes satisfies starts-with(., $prefix)))]
    return
        if (empty($invalid)) then $ops else
            let $text1 :=
                if (count($invalid) eq 1) then 'invalid option ('||$invalid||')'
                else 'invalid options ('||string-join($invalid, ', ')||')'
            return error(QName((), 'UNKNOWN_OPTION'), concat(
                'Function "', $functionName, '" - ', $text1,  
                '; valid options: ', string-join($validOptions, ', '), '.'))
};        

(:~
 : Returns the options encoded by an $options parameter
 : as a map.
 :) 
declare function f:getOps($optionsString as xs:string?, 
                          $validOptions as xs:string*,
                          $functionName as xs:string)
        as map(*)? {
    if (not(normalize-space($optionsString))) then () else
    
    let $o := $optionsString ! replace(., '\s*=\s*', '=')        
    let $items := $o ! tokenize(.) ! lower-case(.)
    let $entries :=
        for $item in $items
        let $name := $item ! replace(., '=.*', '')
        return if (exists($validOptions) and not($name = $validOptions)) then
            error(QName((), 'UNKNOWN_OPTION'), concat(
                'Function "', $functionName, '" - invalid option ("'||$name||'")'||  
                '; valid options: ', string-join($validOptions, ', '), '.'))
            else
        let $value := 
            if (not(contains($item, '='))) then true() 
            else $item ! replace(., '.*?=', '') ! replace(., '\\s', ' ')
        return map:entry($name, $value)
    return map:merge($entries)
};        

(:
##################################################################################################
 :)
 
(:~
 : Returns the attribute names of a node. If $separator is specified, the sorted
 : names are concatenated, using this separator, otherwise the names are returned
 : as a sequence. If $localNames is true, the local names are returned, otherwise 
 : the lexical names. 
 : 
 : When using $namePattern, only those child elements are considered which have
 : a local name matching the pattern.
 :
 : Example: .../foo/att-names(., ', ', false(), '*put')
 : Example: .../foo/att-names(., ', ', false(), 'input|output') 
 :
 : @param nodes a sequence of nodes (only element nodes contribute to the result)
 : @param separator if used, the names are concatenated, using this separator
 : @param localNames if true, the local names are returned, otherwise the lexical names 
 : @param namePattern an optional name pattern filtering the attributes to be considered 
 : @return the names as a sequence, or as a concatenated string
 :)
declare function f:zzzAttNamesOld($nodes as node()*, 
                            $concat as xs:boolean?, 
                            $nameKind as xs:string?,   (: name | lname | jname :)
                            $namePatterns as xs:string*,
                            $excludedNamePatterns as xs:string*)
        as xs:string* {
    let $nameRegexes := $namePatterns 
       ! replace(., '\*', '.*') ! replace(., '\?', '.') 
       ! concat('^', ., '$')        
    let $excludedNameRegexes := $excludedNamePatterns 
       ! replace(., '\*', '.*') ! replace(., '\?', '.') 
       ! concat('^', ., '$')    
       
    for $node in $nodes       
    let $items := $node/@*
       [empty($nameRegexes) or 
            (some $r in $nameRegexes satisfies matches(local-name(.), $r, 'i'))]
       [empty($excludedNameRegexes) or 
            not(some $r in $excludedNameRegexes satisfies matches(local-name(.), $r, 'i'))]
    let $separator := ', '[$concat]
    let $names := 
        if ($nameKind eq 'lname') then 
            ($items/local-name(.)) => distinct-values() => sort()
        else if ($nameKind eq 'jname') then 
            ($items/f:unescapeJsonName(local-name(.))) => distinct-values() => sort()
        else ($items/name(.)) => distinct-values() => sort()
    return
        if (exists($separator)) then string-join($names, $separator)
        else $names
};  

(:~
 : Create a dcat document (document catalog).
 :)
declare function f:dcat($uris as xs:string*, 
                        $basePath as xs:string?)
        as element(dcat) {
    let $_DEBUG := trace($basePath, '_BASE_PATH: ')
    let $uris_ := $uris ! replace(., '^basex://', '')            
    let $refs := 
        if (not($basePath)) then $uris_
        else $uris_ ! f:relPath($basePath, .)
    let $docs := $refs ! <doc href="{.}"/>
    return
        <dcat count="{count($uris)}" t="{current-dateTime()}">{$docs}</dcat>
};

(:~
 : Concatenates the arguments into a string, using an "improbable"
 : separator (codepoint 30000)
 :)
declare function f:xxxRow($items as item()*)
        as xs:string {
    let $sep := codepoints-to-string(30000)
    return
        string-join($items, $sep)
};
