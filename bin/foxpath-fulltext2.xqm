module namespace f="http://www.foxpath.org/ns/fulltext";

(:~
 : Checks if given text items match a full-text selection.
 :
 : @param text the text to be checked
 : @param selections full-text selections (will be ANDed)
 : @param flags flag characters: M - merge consecutive text nodes; T - test mode
 : @return true, if the text matches the full-text selections
 :)
declare function f:containsText($text as item()*, 
                                $selections as xs:string+, 
                                $flags as xs:string?)
        as xs:boolean {
    f:fnContainsText($selections, (), $flags)($text)
};    

(:~
 : Returns a function applying full-text selection to text items.
 :
 : @param selections full-text selections (will be ANDed)
 : @param toplevelOr selections are ORed, rather than ANDed
 : @param flags flag characters: M - merge consecutive text nodes; T - test mode;
 :                               P - return parse tree
 : @return function item implementing the selections
 :)
declare function f:fnContainsText($selections as xs:string+, 
                                  $toplevelOr as xs:boolean?, 
                                  $flags as xs:string?)
        as item() {
    let $TESTMODUS := contains($flags, 'T')
    let $mergeTextnodes := contains($flags, 'M') 
    let $toplevelBool := if ($toplevelOr) then 'ftor' else 'ftand'        
    let $sels := $selections ! f:parseFt(.) ! f:serializeFt(.)
    let $expr := 
        if (count($sels) eq 1) then $sels
        else ($sels ! concat('(', ., ')')) => string-join(' '||$toplevelBool||' ') 
    (: let $_DEBUG := trace($expr, '_EXPR: ') :)
    let $funcText :=
        if ($mergeTextnodes) then 'function($text) {$text contains text '||$expr||'}'
        else 
        'function($text) {
            let $useText :=
                if (not($text instance of element() or $text instance of document-node())) then $text        
                else $text//text() => string-join(" ")
            return $useText contains text '||$expr ||'}'
    let $func := xquery:eval($funcText)
    return 
        if ($TESTMODUS) then map{'function': $func, 'expression': $expr}
        else $func
};

(:
 :    S e r i a l i z e    p a r s e    t r e e
 :    =========================================
 :)
 
(:~
 : Serializes an FT tree, created by 'parseFt'.
 :
 : @param tree FT tree
 : @return FT expression
 :)
declare function f:serializeFt($tree as element())
        as xs:string {

    let $options := ($tree ! f:serializeFtOptions(.))[string()] return
    
    typeswitch($tree)
    case element(words) return 
        let $expr := $tree/string-join(("'"||.||"'", $options), ' ')
        return
            if ($tree/(@atStart, @atEnd, @entire)) 
            then '('||$expr||')'
            else $expr
    case element(ftor) return 'ftor'
    case element(ftand) return 'ftand'
    case element(notin) return 'not in'
    default return (
        let $content :=
            let $ops := $tree/*        
            for $op at $pos in $ops
            let $addedFtand := 'ftand'
                [$pos gt 1 
                 and $op/name() = ('words', 'parex', 'ftnot')
                 and $ops[$pos - 1]/name() =  ('words', 'parex', 'ftnot')]
            return ($addedFtand, $op/f:serializeFt(.))
        return
            if ($tree/self::parex) then 
                string-join(('('||string-join($content, ' ')||')', $options), ' ')
            else if ($tree/self::ftnot) then ('ftnot', $content)
            else if ($tree/self::ft) then 
                let $query := ($content  ! replace(., '\(\s+', '(') ! replace(., '\s+\)', ')')) => string-join(' ') 
                return
                    if (not($options)) then $query 
                    else if ($tree/parex and count($tree/*) eq 1) then $query||' '||$options 
                    else '('||$query||') '||$options
            else error()
    ) => string-join(' ')        
};

(:~
 : Serializes the FT options stored in the attributes of
 : a FT parse tree. Each attribute contains the text
 : of a FT option (e.g. "using stemming").
 :
 : Note that the order of options is constrained to
 : conform to the syntax rules.
 :
 : @param node a node from the FT parse tree
 : @return the concatenated text of all options
 :) 
declare function f:serializeFtOptions($node as element())
        as xs:string {
    $node ! (
    @mode, 
    @occurs,
    @wildscards,
    @case,
    @diacritics,
    @language,
    @stemming,
    @stemming-and-language,    
    @stop,
    @fuzzy,    
    @ordered,
    @distance,
    @window,
    @sentence,
    @paragraph,
    @atStart,
    @atEnd, 
    @entire
    ) => string-join(' ')        
};

(:
 :    P a r s e
 :    =========
 :)

(:~
 : Parses a full-text selection.
 :)
declare function f:parseFt($text as xs:string?) 
        as element()* {
    if (not($text)) then () else

    let $sep := '#'
    let $textNOOP := $text ! replace(., $sep||'.*', '') ! normalize-space(.)
    let $optionsText := $text[contains(., $sep)] ! replace(., '^.*?'||$sep, '') ! normalize-space(.)

    let $tar := f:parseFtOr($textNOOP)
    let $tree := $tar[. instance of node()]
    let $rest := $tar[not(. instance of node())]
    return
        if ($rest) then error(QName((), 'SYNTAX_ERROR'), 
            concat('Full text syntax error - unexpected rest: ', $rest))
        else
        
    let $isFtWords := count($tree) eq 1 and $tree/self::words     
    let $optionsAtts :=
        $optionsText
        ! f:parseFtOptions(., $isFtWords, false(), ())
        ! f:optionsAtts(.)
    return
        if (not($isFtWords)) then <ft text="{$text}">{$optionsAtts, $tree}</ft>
        else
            let $treeAtts := $tree/@*
            let $treeAttNames := $treeAtts/name()
            return
                <words text="{$text}">{
                    $treeAtts,
                    $optionsAtts[not(name() = $treeAttNames)],
                    $tree/string()
                }</words>
};

(:~
 : Parses an FtWords expression.
 :)
declare function f:parseFtWords($text as xs:string?)
        as item()* {
    if (not($text)) then () else

    let $textBefore := f:textBeforeOperator($text)
    let $rest:= substring($text, 1 + string-length($textBefore))
    return if (not(normalize-space($textBefore))) then $rest else
        
    let $sep := '@'    
    let $words := $textBefore ! replace(., $sep||'.*', '') ! normalize-space(.)
    let $optionsText := $textBefore[contains(., $sep)] ! replace(., '^.*?'||$sep, '') ! normalize-space(.)
    let $anchors := (
        replace($words, '^(\^+).*', '$1'),
        replace($words, '.*?(\$+)$', '$1')
        )[. ne $words]
    let $wordsCleansed := replace($words, '^\^+|\$+$', '')
    let $usingWildcards := contains($wordsCleansed, '.')
    let $optionsMap := f:parseFtOptions($optionsText, true(), $usingWildcards, $anchors)
    let $optionsAtts := f:optionsAtts($optionsMap)
    let $tree := <words>{$optionsAtts, $wordsCleansed}</words>
    return ($tree, $rest)    
};

(:~
 : Parses an FtOr expression. An FtOr expression is a sequence
 : of primary expressions separated by one of the operators
 : {/|>}, or adjacent without separator, which means separated
 : by an implicit <ftand/>. A primary expression is an FTWords
 : expression or a not expression.
 :)
declare function f:parseFtOr($text as xs:string?) 
        as item()* {
    if (not($text)) then () else

    let $primTreeAndRest := f:parseFtPrim($text)
    let $primTree := $primTreeAndRest[. instance of node()]
    let $primRest := $primTreeAndRest[not(. instance of node())]
    return (
        $primTree,
        if (not($primRest)) then () else
        
        let $char1 := substring($primRest, 1, 1) return
        switch($char1)
        case '|' return (<ftor/>, f:parseFtOr($primRest ! f:removeChar(.)))
        case '&amp;' return (<ftand/>, f:parseFtOr($primRest ! f:removeChar(.)))
        case '/' return (<ftand/>, f:parseFtOr($primRest ! f:removeChar(.)))
        case '>' return (<notin/>, f:parseFtOr($primRest ! f:removeChar(.)))
        case ')' return $primRest
        default return (<ftand/>, f:parseFtOr($primRest))
    )        
};

(:~
 : Parses a primary expression. It is one of the following
 : expressions: 
 :   FtWords, parenthesized expressions, FtNot expression.
 :)
declare function f:parseFtPrim($text as xs:string?) 
        as item()* {
    if (not($text)) then () else
    
    let $ftWordsTreeAndRest := f:parseFtWords($text)
    let $ftWordsTree := $ftWordsTreeAndRest[. instance of node()]
    return
        if ($ftWordsTree) then $ftWordsTreeAndRest else
        
    let $text := $ftWordsTreeAndRest
    let $char1 := substring($text, 1, 1)
    return if (not($char1)) then () else
        
    switch($char1)
    case '(' return f:parseFtParex($text)
    case '~' return f:parseFtNotex($text)
    default return $text
};

(:~
 : Parses a parenthesized expression.
 :)
declare function f:parseFtParex($text as xs:string?)
        as item()* {
    if (not(substring($text, 1, 1) eq'(')) then $text else
    
    let $text := f:removeChar($text)
    let $ftorTreeAndRest := f:parseFtOr($text)
    let $ftorTree := $ftorTreeAndRest[. instance of node()]
    let $ftorRest := $ftorTreeAndRest[not(. instance of node())]
    return
        if (not(substring($ftorRest, 1, 1) eq ')')) then 
            error(QName((), 'SYNTAX_ERROR'), 'Invalid syntax - missing )')
        else
            let $rest := f:removeChar($ftorRest)   
            let $optionsText :=
                if (not(substring($rest, 1, 1) eq '{')) then ''
                else replace($rest, '^(\{.*?\}).*', '$1')
            let $newRest := 
                if (not($optionsText)) then $rest
                else f:removeChars($rest, string-length($optionsText))
            let $optionsAtts :=
                let $optionsText := replace($optionsText, '\{\s*|\s*\}', '')
                let $optionsMap := f:parseFtOptions($optionsText, false(), false(), ())
                return f:optionsAtts($optionsMap)
            return (
                <parex>{$optionsAtts, $ftorTree}</parex>,
                $newRest
            )
};    

(:~
 : Parses an FtNot expression.
 :)
declare function f:parseFtNotex($text as xs:string?)
        as item()* {
    let $content := substring($text, 2)
    let $petc := f:parseFtPrim($content)
    return (
        <ftnot>{$petc[. instance of node()]}</ftnot>,
        $petc[not(. instance of node())][string()]
    )        
};

(:
 :    P a r s e    o p t i o n s
 :    ==========================
 :)
 
(:~
 : Parses a string containing FT options in the syntax
 : expected by the contains-text function.
 :)
declare function f:parseFtOptions($optionsText as xs:string?,
                                  $isTargetFtwords as xs:boolean?,
                                  $withWildcard as xs:boolean?,
                                  $anchors as xs:string*)
        as map(*)? {
    if (not($optionsText) and not($withWildcard) and empty($anchors)) then map{} else
    
    let $options :=
        if (matches($optionsText, 'stop\(.*\)')) then
            let $sep := codepoints-to-string(30000) return
            let $items :=
                replace($optionsText, '^(.*?)(stop\(.*?\))(.*)', '$1'||$sep||'$2'||$sep||'$3')
                ! tokenize(., $sep)
            return (tokenize($items[1]), $items[2], tokenize($items[3]))
        else tokenize($optionsText)            
    (: let $_DEBUG := trace($options, '_OPTIONS: ') :)
    
    (: Evaluate anchors :)
    let $anchors := $anchors ! normalize-space(.)
    let $entire := $anchors = '^' and $anchors = '$'
    let $atStart := not ($entire) and $anchors = '^'
    let $atEnd := not ($entire) and $anchors = '$'
    
    let $omap := map:merge(
        for $o in $options
        return
            if (starts-with($o, 'lang-')) then 
                map:entry('language', 'using language '||substring($o, 6) ! ('"'||.||'"'))
            else if (starts-with($o, 's-')) then 
                map:entry('stemming-and-language', 'using stemming using language '||substring($o, 3) ! ('"'||.||'"'))
            else if (starts-with($o, 'wild-')) then 
                map:entry('stop', 'using stop words '||substring($o, 6) ! ('("'||.||'")'))            
            else if (starts-with($o, 'f')) then 
                map:entry('fuzzy', 'using fuzzy '||(substring($o, 2)[string()], '1')[1] ! (.||' errors'))
            else if (starts-with($o, 'stop')) then
                let $spec := substring($o, 5)
                return map:entry('stop',
                    if (starts-with($spec, '@')) then 'using stop words at "'||substring($o, 6)||'"'
                    else if (not($spec)) then 'using stop words default'
                    else if (starts-with($spec, '(')) then 'using stop words ('||((
                        replace($spec, '^\(\s*|\s*\)\s*$', '') ! tokenize(., ',\s*') ! concat("'", ., "'")
                        ) => string-join(', '))||')'
                    else error())
            else if (starts-with($o, 'occ')) then 
                map:entry('occurs', 'occurs '||f:parseFtRange(substring($o, 4), ())||' times')
            else if (starts-with($o, 'win')) then 
                map:entry('window', f:parseFtWindow($o))
            else if (starts-with($o, 'dist')) then 
                map:entry('distance', 'distance '||f:parseFtRange(substring($o, 5), true()))
            else if (starts-with($o, 'phrase')) then
                let $spec := substring($o, 7) ! replace(., '\s+$', '')
                return (
                    map:entry('additional-flags', 'W'[$isTargetFtwords]||'o'),
                    if (matches($spec, '^\d+$')) then map:entry('distance', 'distance at most '||$spec||' words')
                    else if (matches($spec, '^\d+win$')) then map:entry('window', 'window '||replace($spec, '\D+', '')||' words')
                    else ()
                )
            else map:entry('flags', $o)
    )
    let $flags := $omap?flags||$omap?additional-flags
                  ||('a'[$atStart])
                  ||('z'[$atEnd])
                  ||('e'[$entire])
                  ||('Q'[$withWildcard])
    let $omap :=
        if (not($flags)) then $omap else map:merge((
        $omap,
        
        if (not(matches($flags, '[wW]'))) then () else
        map:entry('mode', if (contains($flags, 'w')) then 'any word' else 'all words'),

        map:entry('wildcards', 'using wildcards')[contains($flags, 'Q')],
        map:entry('stemming', 'using stemming')[contains($flags, 's')][not($omap?stemming-and-language)],

        if (not(matches($flags, '[cC]'))) then () else
        map:entry('case', 'using case '||(if (contains($flags, 'c')) then 'sensitive' else 'insensitive')),
            
        if (not(matches($flags, '[dD]'))) then () else
        map:entry('diacritics', 'using diacritics '||(if (contains($flags, 'd')) then 'sensitive' else 'insensitive')),
            
        map:entry('ordered', 'ordered')[contains($flags, 'o')],
        
        if (not(matches($flags, '[xX]'))) then () else
        map:entry('sentence', if (contains($flags, 'x')) then 'same sentence' else 'different sentence'),

        if (not(matches($flags, '[yY]'))) then () else
        map:entry('paragraph', if (contains($flags, 'y')) then 'same paragraph' else 'different paragraph'),

        map:entry('atStart', 'at start')[contains($flags, 'a')],
        map:entry('atEnd', 'at end')[contains($flags, 'z')],
        map:entry('entire', 'entire content')[contains($flags, 'e')]
    )) ! map:remove(., 'flags')
    
    (: let $_DEBUG := trace($omap, '_OMAP: ') :)
    return map:remove($omap, 'additional-flags')
};

(:~
 : Transforms a map of options into a sequence of attributes.
 :)
declare function f:optionsAtts($options as map(*)?) as attribute()* {
    if (empty($options)) then () else
    for $key in map:keys($options) return attribute {$key} {$options($key)}
};

(:
 :    P a r s e    u t i l i t i e s
 :    ==============================
 :)
 
(:~
 : Parses a range specification.
 :)
declare function f:parseFtRange($text as xs:string, $withUnit as xs:boolean?) 
        as xs:string {
    let $ftUnit := 
        if (not($withUnit)) then () else 
            ' '||f:parseFtUnit(replace($text, '\D+$', '$0')[. ne $text])
    let $useText :=
        if (not($withUnit)) then $text else replace($text, '\D+$', '')
    return (
        (: ..9 => at most 9 :)
        if (starts-with($useText, '..')) then 'at most '||substring($useText, 3)
        else
            let $parts := 
                (: 77 | 77.. | 77..88 :)
                replace($useText, '\s*(\d+)((\.\.)(\d+)?)?\s*$', '$1~$3~$4')[not(. eq $useText)] 
                ! tokenize(., '~')
            return
                if (empty($parts)) then error()
                (: 77 => exactly 77 :)
                else if (not($parts[2])) then 'exactly '||$parts[1]
                (: 77.. => at least 77 :)
                else if (not($parts[3])) then 'at least '||$parts[1]
                (: 77..88 => from 77 to 88 :)
                else 'from '||$parts[1]||' to '||$parts[3]
    )||$ftUnit                
};

(:~
 : Parses a unit specification.
 :)
declare function f:parseFtUnit($text as xs:string?) as xs:string? {
    if (not($text)) then 'words'
    else switch($text) 
         case 'w' return 'words' 
         case 's' return 'sentences' 
         case 'p' return 'paragraphs' 
         default return error()
};

(:~
 : Parses a window specification. Examples: win9, win9s, win9p.
 :)
declare function f:parseFtWindow($text as xs:string) as xs:string {
    let $parts := replace($text, '^win(\d+)(.*)?', '$1~$2')[. ne $text] ! tokenize(., '~')
    return
        if (empty($parts)) then error()
        else 
            let $unit := f:parseFtUnit($parts[2])
            return $parts[1]||' '||$unit
};

(:
 :    U t i l i t y    f u n c t i o n s
 :    ==================================
 :)

(: Removes the first character and any whitespace characters
 : immediately following it.
 :)
declare function f:removeChar($text as xs:string) as xs:string? {
    substring($text, 2) ! replace(., '^\s+', '')
};

(: Removes leading characters and any whitespace characters
 : immediately following them.
 :)
declare function f:removeChars($text as xs:string, 
                               $numChars as xs:integer) as xs:string? {
    substring($text, 1 + $numChars) ! replace(., '^\s+', '')
};

(:~
 : Returns the substring preceding the first occurrence of an
 : operator character.
 :)
declare function f:textBeforeOperator($text as xs:string?)
        as xs:string? {
    replace($text, '^(.*?)[()|/&amp;>~].*', '$1')        
};

(:~
 : Returns true if a given string is an FtWords expression.
 :)
declare function f:isFtWords($query as xs:string) as xs:boolean {
    not(matches($query, '[()|/&amp;>~]'))
};
