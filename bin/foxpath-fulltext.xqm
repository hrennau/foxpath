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
 : @param flags flag characters: M - merge consecutive text nodes; T - test mode
 : @return function item implementing the selections
 :)
declare function f:fnContainsText($selections as xs:string+, 
                                  $toplevelOr as xs:boolean?, 
                                  $flags as xs:string?)
        as item() {
    let $TESTMODUS := contains($flags, 'T')
    let $mergeTextnodes := contains($flags, 'M') 
    let $toplevelBool := if ($toplevelOr) then 'ftor' else 'ftand'        
    let $osep := ';'        
    let $sels :=
        for $selection in $selections
        
        let $selCore := 
            $selection
            ! replace(., '#.*', '') 
            ! normalize-space(.)
            
        return
            if (not(matches($selection, '[()|&amp;>~]'))) then
                f:parseFtSelection($selection, '#', true())
            else            
                let $selOptions := 
                    $selection[contains(., '#')]
                    ! replace(., '^.*#', '') 
                    ! normalize-space(.)
                let $wordsAndOptions := f:parseFtOptions($selCore, $selOptions, false()) 
                let $selOptionsMap := $wordsAndOptions[. instance of map(*)]
                let $selCore := $wordsAndOptions[. instance of xs:string]
                
                let $selCoreTree := f:parseFt($selCore)
                let $selCoreParsed := f:serializeFt($selCoreTree)
                let $selOptionsParsed := f:serializeFtOptions($selOptionsMap)                
                return
                    if ($selOptionsParsed) then '('||$selCoreParsed||') '||$selOptionsParsed 
                    else $selCoreParsed
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
            return $useText contains text '||$expr
        ||'}'

    let $func := xquery:eval($funcText)
    return 
        if ($TESTMODUS) then map{'function': $func, 'expression': $expr}
        else $func
};

(:~
 : Parses a full-text selection, which is a string consisting of words
 : (FTWords), optionally followed by options. Words and options are separated 
 : by $sep1, individual options are separated by $sep2. Note that the input 
 : selection is not composed of parts (e.g. separated by | signs) - it is a 
 : simple unit consisting of words and optonal options.
 :
 : The function separates words and options and launches the 
 : parsing of the options. 
 :
 : @param selection the description of a full-text selection
 : @param opsep separator between words and options
 : @topLevel if true, the selection is the top-level selection
 : @return the full-text expression represented by the selection
 :)
declare function f:parseFtSelection($selection as xs:string, 
                                    $opsep as xs:string, 
                                    $topLevel as xs:boolean?)
        as xs:string {
    let $words := replace($selection, $opsep||'.*', '') ! normalize-space(.)
    let $optionsConcat := replace($selection, '^.*?'||$opsep||'\s*', '')[contains($selection, $opsep)]
    let $isTargetFtwords := not($topLevel) or not(matches($words, '[()|&amp;]'))
    let $wordsAndOptions := f:parseFtOptions($words, $optionsConcat, $isTargetFtwords)
    let $words := $wordsAndOptions[. instance of xs:string] ! concat('"', ., '"')
    let $optionsMap := $wordsAndOptions[. instance of map(*)]
    (: let $_DEBUG := trace($optionsMap, '__OPTIONS_MAP2: ') :)
    let $optionsParsed := f:serializeFtOptions($optionsMap)
    let $sel := ($words, $optionsParsed) => string-join(' ')
    return
        if ($topLevel) then $sel
        else '('||$sel||')'
};

(:~
 : Parses an options string and returns the part of the containsText
 : expression text representing these options (e.g. 'using stemming
 : at start'). If also a tokens text is received, the edited tokens
 : text is also returned. (Editing means the removal of any anchors.)
 : Note that some options may be inferred from the tokens text (at start, 
 : at end, entire content).
 :
 : - ^ at the begin of $tokensText: at start
 : - $ at the end of $tokensText: at end  
 : - ^^ at the begin and $$ at the end of $tokensText: entire content 
 : - lang-foo  - language: foo
 : - wild-foo  - token "foo" will be treated as wildcard token (using stop('foo'))
 : - stop      - stop: default
 : - stop@foo  - stop: at "foo"
 : - stop(foo, bar) - stop: ("foo", "bar")
 : - occ9      - occ: exactly 9 
 : - occ9..    - occ: at least 9
 : - occ..9    - occ: at most 9 
 : - occ8..9   - occ: from 8 to 9
 : - dist1w    - distance: exactly 1 word ("w"; alternative units: s, p)
 : - dist1..w  - distance: at least 1 word ("w"; alternative units: s, p)
 : - dist..2w  - distance: at most 2 words ("w"; alternative units: s, p) 
 : - dist1..2w - occ: from 1 to 2 ("w"; alternative units: s, p)
 : - win5w
 : - win5s
 : - win5p
 : - s         - stemming
 : - s-foo     - stemming, language "foo"
 :)
declare function f:parseFtOptions($tokensText as xs:string?, 
                                  $optionsText as xs:string?,
                                  $isTargetFtwords as xs:boolean?)
        as item()* {
    (: The options string uses whitespace as separator. With
     : one exception: a stop(...) clause may contain whitespace.
     : For this reason, the text is partioned into a part
     : preceding stop(...), the stop part and a part following
     : stop(...).
     :)
    let $options :=
        if (matches($optionsText, 'stop\(.*\)')) then
            let $sep := codepoints-to-string(30000) return
            let $items :=
                replace($optionsText, '^(.*?)(stop\(.*?\))(.*)', '$1'||$sep||'$2'||$sep||'$3')
                ! tokenize(., $sep)
            return (tokenize($items[1]), $items[2], tokenize($items[3]))
        else tokenize($optionsText)            
    (: let $_DEBUG := trace($options, '_OPTIONS: ') :)            
(:            
    let $options := tokenize($optionsText, '\s*'||$optionsSep||'\s*')
:)    
    (: Evaluate anchors :)
    let $entire := $tokensText ! (matches(., '^\^\^') and matches(., '\$\$$'))
    let $atStart := $tokensText ! (not($entire) and matches(., '^\^'))
    let $atEnd := $tokensText ! (not($entire) and matches(., '\$$'))
    let $cleansedTokensText := (
        if (not($tokensText)) then ()
        else if (not($atStart) and not($atEnd) and not($entire)) then $tokensText
        else replace($tokensText, '^\^+\s*|\s*\$+$', '')
        ) ! . (: concat('"', ., '"') :)
        
    let $omap := map:merge(
        for $o in $options
        return
            if 
                    (starts-with($o, 'lang-')) then map:entry('language', substring($o, 6) ! ('"'||.||'"'))
            else if (starts-with($o, 's-')) then map:entry('stemming-and-language', substring($o, 3) ! ('"'||.||'"'))
            else if (starts-with($o, 'wild-')) then map:entry('stop', substring($o, 6) ! ('("'||.||'")'))            
            else if (starts-with($o, 'f')) then map:entry('fuzzy', substring($o, 2) ! (.||' errors'))
            else if (starts-with($o, 'stop')) then
                let $spec := substring($o, 5)
                return map:entry('stop',
                    if (starts-with($spec, '@')) then 'at "'||substring($o, 6)||'"'
                    else if (not($spec)) then 'default'
                    else if (starts-with($spec, '(')) then '('||((
                        replace($spec, '^\(\s*|\s*\)\s*$', '') ! tokenize(., ',\s*') ! concat("'", ., "'")
                        ) => string-join(', '))||')'
                    else error())
            else if (starts-with($o, 'occ')) then map:entry('occurs', f:parseFtRange(substring($o, 4), ())||' times')
            else if (starts-with($o, 'win')) then map:entry('window', f:parseFtWindow($o))
            else if (starts-with($o, 'dist')) then map:entry('distance', f:parseFtRange(substring($o, 5), true()))
            else if (starts-with($o, 'phrase')) then
                let $spec := substring($o, 7) ! replace(., '\s+$', '')
                return (
                    map:entry('additional-flags', 'W'[$isTargetFtwords]||'o'),
                    if (matches($spec, '^\d+$')) then map:entry('distance', 'at most '||$spec||' words')
                    else if (matches($spec, '^\d+win$')) then map:entry('window', replace($spec, '\D+', '')||' words')
                    else ()
                )
            else map:entry('flags', $o)
    )
    let $usingWildcards := 'using wildcards'[contains($tokensText, '.')]    
    let $flags := $omap?flags||$omap?additional-flags
                  ||('a'[$atStart])
                  ||('z'[$atEnd])
                  ||('e'[$entire])
                  ||('Q'[$usingWildcards])
    let $omap :=
        if (not($flags)) then $omap else map:put($omap, 'flags', $flags)
    (: let $_DEBUG := trace($omap, '_OMAP: ') :)
    return ($cleansedTokensText, $omap)
};

(:~
 : Serializes a set of full-text options.
 :)
declare function f:serializeFtOptions($omap as map(*)) as xs:string {
    let $flags := $omap?flags return
    
    string-join((
        'any word'[contains($flags, 'w')],
        'all words'[contains($flags, 'W')],
        $omap?occurs ! ('occurs '||.),
        $omap[not(?stemming-and-language)]?language ! ('using language '||.),
        $omap?fuzzy ! ('using fuzzy '||.),      
        $omap?stemming-and-language ! ('using stemming using language '||.),
        'using wildcards'[contains($flags, 'Q')],
        'using stemming'[contains($flags, 's')][not($omap?stemming-and-language)],
        'using case sensitive'[contains($flags, 'c')],
        'using case insensitive'[contains($flags, 'C')],                
        'using diacritics sensitive'[contains($flags, 'd')],
        'using diacritics insensitive'[contains($flags, 'D')],
        'using fuzzy 1 errors'[contains($flags, 'f')][not($omap?fuzzy)],
        $omap?stop ! ('using stop words '||.),
        'ordered'[contains($flags, 'o')],
        $omap?window ! ('window '||.),
        $omap?distance ! ('distance '||.),
        'same sentence'[contains($flags, 'x')],
        'different sentence'[contains($flags, 'X')],
        'same paragraph'[contains($flags, 'y')],
        'different paragraph'[contains($flags, 'Y')],
        'at start'[contains($flags, 'a')],
        'at end'[contains($flags, 'z')],
        'entire content'[contains($flags, 'e')]
    ), ' ')
};

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

(:~
 : Serializes an FT tree, created by 'parseFt'.
 :
 : @param tree FT tree
 : @return FT expression
 :)
declare function f:serializeFt($tree as element())
        as xs:string {

    typeswitch($tree)
    case element(words) return f:parseFtSelection($tree, '@', false())
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
            if ($tree/self::parex) then ('(', $content, ')')
            else if ($tree/self::ftnot) then ('ftnot', $content)
            else if ($tree/self::ft) then $content  ! replace(., '\(\s+', '(') ! replace(., '\s+\)', ')')
            else error()
    ) => string-join(' ')        
};

declare function f:parseFt($text) as element()? {
    normalize-space($text) ! <ft text="{.}">{f:parseFtSel(.)}</ft>
};

(:~
 : Parses a full-text selection.
 :)
declare function f:parseFtSel($text as xs:string?) 
        as element()* {
    if (not($text)) then () else

    let $petc := f:parseFtOr($text)
    return (
        $petc[. instance of node()],
        $petc[not(. instance of node())][string()] ! f:parseFtSel(.)
    )
};

(:~
 : Parses an FtOr expression.
 :)
declare function f:parseFtOr($text as xs:string?) 
        as item()* {
    if (not($text)) then () else

    let $petc := f:parseFtPrim($text)
    let $primTree := $petc[. instance of node()]
    let $remainder := $petc[not(. instance of node())]
    return (
        $primTree,
        if (not($remainder)) then () else
        
        let $char1 := substring($remainder, 1, 1) return
        switch($char1)
        case '|' return (<ftor/>, f:parseFtOr($remainder ! substring(., 2)))
        case '&amp;' return (<ftand/>, f:parseFtOr($remainder ! substring(., 2)))
        case '>' return (<notin/>, f:parseFtOr($remainder ! substring(., 2)))
        default return $remainder
    )        
};

(:~
 : Parses a primary expression.
 :)
declare function f:parseFtPrim($text as xs:string?) 
        as item()* {
    if (not($text)) then () else
    
    let $before := replace($text, '^(.*?)[()|&amp;>~].*', '$1')
    let $len := string-length($before)
    return (
        ($before ! normalize-space(.))[string()] ! <words>{.}</words>,
        if ($before[string()]) then substring($text, $len + 1) else
        
        let $nextChar := substring($text, $len + 1, 1)
        return if (not($nextChar)) then () else
        
        switch($nextChar)
        case '(' return
            let $petc := f:parseFtParex(substring($text, $len + 1))
            return (
                $petc[. instance of node()],
                $petc[not(. instance of node())][string()]
            )
        case '~' return (
            let $petc := f:parseFtNotex(substring($text, $len + 1))
            return (
                $petc[. instance of node()],
                $petc[not(. instance of node())][string()]
            )
        )
        default return substring($text, $len + 1) ! replace(., '\s+', '')
    )        
};

declare function f:parseFtParex($text as xs:string?)
        as item()* {
    let $content := substring($text, 2)
    let $petc := f:parseFtParexRC($content)
    return (
        <parex>{
            $petc[. instance of node()]
        }</parex>,
        $petc[not(. instance of node())][string()]
    )        
};

declare function f:parseFtParexRC($text as xs:string?)
        as item()* {
    let $before := replace($text, '^(.*?)[()].*', '$1')
    let $len := string-length($before)
    let $nextChar := substring($text, $len + 1, 1)
    return (
        $before[string()] ! f:parseFtSel(.),
        switch($nextChar)
        case ')' return (
            substring($text, $len + 2) ! replace(., '^\s+', ''))
        case '(' return
            let $petc := f:parseFtParex(substring($text, $len + 1))
            return (
                $petc[. instance of node()],
                $petc[not(. instance of node())][string()] ! f:parseFtParexRC(.)
            )

        default return error()
    )
};

declare function f:parseFtNotex($text as xs:string?)
        as item()* {
    let $content := substring($text, 2)
    let $petc := f:parseFtPrim($content)
    return (
        <ftnot>{
            $petc[. instance of node()]
        }</ftnot>,
        $petc[not(. instance of node())][string()]
    )        
};

