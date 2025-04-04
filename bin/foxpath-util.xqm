module namespace f="http://www.ttools.org/xquery-functions/util";

declare namespace fox="http://www.foxpath.org/ns/annotations";

declare variable $f:DEBUG := ''; 
declare variable $f:DG :=
    for $item in tokenize(normalize-space($f:DEBUG), ' ') 
    return concat('^', replace($item, '\*', '.*'), '$');
declare variable $f:ARCHIVE_TOKEN external := '#archive#';
declare variable $f:PREDECLARED_NAMESPACE_BINDINGS := map{
    "dc": "http://purl.org/dc/elements/1.1/",
    "docbook": "http://docbook.org/ns/docbook",
    "drg": "http://www.drugbank.ca",
    "fox": "http://www.foxpath.org/ns/1.0", 
    "math": "http://www.w3.org/1998/Math/MathML",
    "owl": "http://www.w3.org/2002/07/owl#",    
    "rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
    "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
    "svrl": "http://purl.oclc.org/dsdl/svrl",
    "tei": "http://www.tei-c.org/ns/1.0",
    "wsdl": "http://schemas.xmlsoap.org/wsdl/",    
    "xml": "http://www.w3.org/XML/1998/namespace",
    "xpl": "http://www.w3.org/ns/xproc",    
    "xplc": "http://www.w3.org/ns/xproc-step",    
    "xs": "http://www.w3.org/2001/XMLSchema",
    "xsi": "http://www.w3.org/2001/XMLSchema-instance",    
    "xsl": "http://www.w3.org/1999/XSL/Transform"
};

(:~
 : Returns a "module function". Module functions are functions
 : which are only parsed and loaded if actually used.
 :)
declare function f:getModuleFunction($fname as xs:string)
        as function(*) {
    let $module :=
        switch($fname)
        case 'parseCss' return
            'modules/css/css-parser.xqm'
        case 'serializeCss' return
            'modules/css/css-serializer.xqm'
        case 'checkUnusedNamespaces' return
            'modules/check/check-namespaces.xqm'
        case 'replaceAndMarkChars' return
            'modules/characters/char-marker.xqm'
        default return error((), 'Unknown function name: '||$fname)
    return
        inspect:functions($module)
            [function-name(.) ! local-name-from-QName(.) eq $fname]
};

(:~
 : Returns all items contained in every array in a given
 : sequence of arrays. Array members are evaluated and
 : returned in atomized form.
 :
 : @param sequences a sequence of arrays
 : @return the items contained by all arrays
 :)
declare function f:atomIntersection($sequences as array(item()*)*)
        as item()* {
    let $seq1 := head($sequences)
    let $seq2 := tail($sequences)
    return fold-left($seq2, array:flatten($seq1), 
        function($sofar, $new) {
            let $t1 := prof:current-ms()
            let $newItems := array:flatten($new)
            let $t2 := prof:current-ms()
            let $newAccum := $sofar[. = $newItems]
            
            let $t3 := prof:current-ms()
            (:
            let $_DEBUG := trace(concat('_NEXT_INTERSECTION; #OLD_ITEMS: ', count($sofar), ' ; #NEW_ITEMS: ', count($newItems)))            
            let $_DEBUG := trace($t2 - $t1, 't(flatten): ')
            let $_DEBUG := trace($t3 - $t2, 't(filter) : ')
             :)
            return $newAccum})
};

(:~
 : Returns the substring preceding or following the first occurrence
 : of a character ($char) which is not escaped by a preceding backslash,
 : or the empty sequence if such a character is not found.
 : 
 : The substring returned is edited by replacing any pair of consecutive 
 : backslashes with a single backslash and any occurrence of $char preceded 
 : by a backslach with the character without preceding backslash. In
 : other words, any escaping of $char or a backslash is removed.
 :
 : @param string the string to be analyzed
 : @param beforeAfter either 'before' or 'after'
 : @param char the character delimiting the substring
 : @return the substring preceding or following the first occurrence
 :   of $char, with any escaping removed
 :)
declare function f:substringBeforeAfterEscableChar(
                    $string as xs:string, 
                    $beforeAfter as xs:string, 
                    $char as xs:string)
        as xs:string {
    if (not(contains($string, '\'))) then 
        if ($beforeAfter eq 'before') then substring-before($string, $char)
        else substring-after($string, $char)
    else ( 
        let $patternBefore := '^((\\\\|\\'||$char||'|[^'||$char||'])*)'
        return
            if ($beforeAfter eq 'before') then
                replace($string, $patternBefore||$char||'.*', '$1')
            else        
                replace($string, $patternBefore||$char||'(.*)', '$3')    
        ) ! replace(., '\\\\', '\\') ! replace(., '\\'||$char, $char)
};        

(:~
 : Returns the substrings preceding and following the first occurrence
 : of a character ($char) which is not escaped by a preceding backslash.
 : If the string does not contain the character without preceding backslash,
 : the original string and a zero-length string are returned.
 : 
 : The substring returned is edited by replacing any pair of consecutive 
 : backslashes with a single backslash and any occurrence of $char preceded 
 : by a backslach with the character without preceding backslash. In
 : other words, any escaping of $char or a backslash is removed.
 :
 : @param string the string to be analyzed
 : @param char the character delimiting the substring
 : @return the strings preceding and following the character
 :)
declare function f:splitStringAtBackslashEscapableChar(
                    $string as xs:string, 
                    $char as xs:string)
        as xs:string+ {
    if (not(contains($string, $char))) then (
        $string ! replace(., '\\\\', '\\'), '')        
    else if (not(contains($string, '\'))) then (
            substring-before($string, $char), substring-after($string, $char))
    else (
        let $patternBefore := '^(\\\\|\\'||$char||'|[^'||$char||'])+'
        return 
            let $substringBefore := replace($string, '('||$patternBefore||').*', '$1')
            return (
                $substringBefore,
                substring($string, string-length($substringBefore) + 2))
    ) ! replace(., '\\\\', '\\') ! replace(., '\\'||$char, $char)
};        

(:
declare variable $f:STDLIB := map{
    'lower-case#1' : map{'funcItem' : lower-case#1, 'args' : ['xs:string?'], 'result' : 'xs:string'}
};
:)
declare variable $f:STD-FUNC-ITEMS := map{
    'lower-case#1' : lower-case#1,
    'number#1' : number#1,
    'upper-case#1' : upper-case#1,
    'xs:integer#1' : xs:integer#1
};

(:~
 : Resolves the text of a function item to a function item.
 : Examples:
 :     lower-case#1
 :     bslash#1
 :)
declare function f:resolveFuncItemText($itemText as xs:string)
        as function(*)? {
    let $item := f:resolveStandardFuncItemText($itemText)
    return
        if (exists($item)) then $item 
        else
            f:resolveFoxFuncItemText($itemText)
(:            
    if ($itemText eq 'bslash#1') then f:foxfunc_bslash#1
    else ()
:)    
};

(:~
 : Resolves the text of a standard function item to a function item.
 : If the text does not reference a standard function, the empty
 : sequence is returned.
 :
 : Examples:
 :     lower-case#1
 :)
declare function f:resolveStandardFuncItemText($itemText as xs:string)
        as function(*)? {
    try {
        xquery:eval($itemText) treat as function(*)
    } catch * {
        ()
    }
};

(:~
 : Resolves the text of a foxpath function item to a function item.
 : If the text does not reference a foxpath function, the empty
 : sequence is returned.
 :
 : Examples:
 :     lower-case#1
 :)
declare function f:resolveFoxFuncItemText($itemText as xs:string)
        as function(*)? {
    let $query := 
        'import module namespace f="http://www.ttools.org/xquery-functions" '
        || '    at "foxpath-fox-functions.xqm"; ' 
        || 'f:foxfunc_' || $itemText 
    let $funcItem :=
        try {xquery:eval($query)} catch * {()}
    return
        $funcItem
};        

(:~
 : Constructs an error element conveying an error code and an
 : error message.
 :)
declare function f:createFoxpathError($code as xs:string, $msg as xs:string)
        as element() {
    <error code="{$code}" msg="{$msg}"/>
};

(:~
 : Constructs an error list containing a single error element.
 :)
declare function f:createFoxpathErrors($code as xs:string, $msg as xs:string)
        as element(errors) {
    <errors>{f:createFoxpathError($code, $msg)}</errors>            
};

(:~
 : Wraps a sequence of `error` elements in an `errors` element.
 :)
declare function f:finalizeFoxpathErrors($errors as element()*)
        as element(errors)? {
    if (not($errors)) then () else <errors>{$errors}</errors>    
};


declare function f:trace($items as item()*, 
                         $logFilter as xs:string, 
                         $logLabel as xs:string)
        as item()* {
    if (exists($f:DG) and 
        (some $d in $f:DG satisfies matches($logFilter, $d))) 
        then trace($items, $logLabel)
    else $items        
};        

(:~
 : Applies the function conversion rules to a value given a sequence type specificationb.
 : @TODO - shift call of `xquery:eval` into foxpath-processorDependent.xqm.
 :)
declare function f:applyFunctionConversionRules(
    $value as item()*, 
    $seqType as element(sequenceType)?)
        as item()* {
    if (not($seqType)) then $value else
    
    let $funcText := 'function($value as ' || $seqType/@text || '){$value}'
    let $func := xquery:eval($funcText, map{'value': $value})
    return $func($value)
};

(:~
 : Returns the prefix of a URI identifying the root of an SVN repository.
 :
 : Example: Assume that URI "file:///c:/foo/bar" identifies the root of an
 : SVN repository; various values of $path produce a return value
 : as follows:
 : file:///c:                  -> () 
 : file:///c:/foo              -> ()
 : file:///c:/foo/bar          -> file:///c:/foo/bar
 : file:///c:/foo/bar/foobar   -> file:///c:/foo/bar 
 :
 : @param uri an URI supposed to address an SVN repository or some resource within it
 : @return a report describing ...
 :) 
declare function f:getSvnRootUri($uri as xs:string)
        as xs:string? {
    let $prefix := replace($uri, '(^(file|https?):/+).*', '$1')
    let $steps := substring($uri, 1 + string-length($prefix))
    return
        f:getSvnRootUriRC($prefix, $steps)           
};        

declare function f:getSvnRootUriRC($prefix as xs:string, $steps as xs:string)
        as xs:string? {
    if (not($steps)) then () else
    let $step1 := replace($steps, '^(.*?)/.*', '$1')
    let $tryPath := $prefix || $step1
    return
        if (proc:execute('svn', ('list', $tryPath))/code = '0') then $tryPath
        else f:getSvnRootUriRC($tryPath || '/', substring($steps, 2 + string-length($step1)))
};        

(:~
 : Maps an atomic value to a boolean value. Intended for convenient
 : entry of boolean parameters.
 :)
declare function f:booleanValue($s as xs:anyAtomicType?, $default as xs:boolean?) as xs:boolean {
    if (empty($s)) then boolean($default)
    else if ($s instance of xs:boolean) then $s
    else if ($s instance of xs:decimal) then $s ne 0
    else string($s) = ('true', 'y', '1')
};

(:~
 : Extracts the file name from a file path. Note that function file:name
 : cannot always be used for paths which are not file system paths.
 :)
declare function f:fileName($path as xs:string) as xs:string {
    $path ! replace(., '^.*/', '')
};

(:~
 : Maps a relative or absolute file path to a normalized representation.
 :)
declare function f:fpath($path as xs:string) as xs:string {
    file:resolve-path($path) ! file:path-to-uri(.) ! 
    replace(., '^file:/+((.:/.*)|(/[^/].*))', '$1')
};

(:~
 : Transforms a glob pattern into a regex.
 :
 : @param pattern a glob pattern
 : @return the equivalent regex
 :)
declare function f:glob2regex($pattern as xs:string)
        as xs:string {
    replace($pattern, '\.', '\\.')
    ! replace(., '\*', '.*') 
    ! replace(., '\?', '.')
    ! replace(., '[()\[\]{}^$]', '\\$0')
    ! concat('^', ., '$')
};   

(:~
 : Transforms a pattern-or-regex into a regex and flags. The pattern-or-regex
 : consists of a pattern text, optionally followed by an unescaped # character
 : and a flags string. Literal \ and # characters must be escaped by a 
 : preceding \. Flags:
 : - r - the pattern text is a regular expression
 : - c - perform case-sensitive matching (flags without 'i')
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
 : @param pattern a glob pattern
 : @param withAnchors if true, use anchors ^ and $
 : @return the equivalent regex
 :)
declare function f:glob2regex($pattern as xs:string,
                              $withAnchors as xs:boolean,
                              $withDotAll as xs:boolean)
        as xs:string+ {
    let $flags := ((
        if ($pattern[contains(., '\')]) then f:substringBeforeAfterEscableChar($pattern, 'after', '#')
        else substring-after($pattern, '#')
    ) ! normalize-space(.)) => string-join('')
    let $patternText :=
        if (not(contains($pattern, '#'))) then $pattern
        else if ($pattern[contains(., '\#')]) then 
            f:substringBeforeAfterEscableChar($pattern, 'before', '#')
        else 
            (substring-before($pattern, '#')[string()], $pattern)[1]

    let $patternIsRegex := contains($flags, 'r')
    let $ignoreCase := not(contains($flags, 'c'))
    let $regexFlags := 'i'[$ignoreCase]||'s'[$withDotAll]    
    let $regexText :=        
        if ($patternIsRegex) then $patternText else

        $patternText
        ! replace(., '[.+|\\(){}\[\]\^$]', '\\$0')    
        ! replace(., '\*', '.*')
        ! replace(., '\?', '.')
    let $regex := if ($withAnchors) then concat('^', $regexText, '$') else $regexText
    return ($regex, $regexFlags)
};   

(: EXPERIMENTAL NEW GENERATION OF STRING MATCHER :)

(:~
 : Translates a whitespace-separated list of string patterns
 : into a map describing string matching. The string patterns may
 : be followed by a '#' character followed by flags. Flags:
 : c - case sensitive
 : r - patterns are regular expressions
 :
 : Escaping rules: in the patterns, # and \ must be escaped by
 : a preceding \.
 :
 : @param patterns a list of strings and/or patterns, whitespace concatenated
 : @param ignoreCase if true, the filter ignores case 
 : @return a map with entries 'names', 'regexes' and 'flags' 
 :)
declare function f:compileStringFilter($patterns as xs:string)
        as map(xs:string, item()*)? {
    let $patternTextAndFlags := f:splitStringAtBackslashEscapableChar($patterns, '#')
    let $items := ($patternTextAndFlags[1] ! tokenize(.))[string()]
    return if (empty($items)) then () else
    
    let $flags := $patternTextAndFlags[2] ! normalize-space(.)
    let $isRegex := contains($flags, 'r')
    let $ignoreCase := not(contains($flags, 'c'))
    let $strings := if ($isRegex) then () else
        let $raw := $items[not(contains(., '*')) and not(contains(., '?'))]
        return
            if (not($ignoreCase)) then $raw else $raw ! lower-case(.)
    let $regexes := if ($isRegex) then $items else    
    $items[contains(., '*') or contains(., '?')]
    ! replace(., '[.+|\\(){}\[\]\^$]', '\\$0')    
    ! replace(., '\*', '.*')
    ! replace(., '\?', '.')
    ! concat('^', ., '$')
    let $regexFlags := if ($ignoreCase) then 'i' else ''     
    return 
        map{'strings': $strings, 
            'regexes': $regexes, 
            'empty': empty(($strings, $regexes)), 
            'flags': $regexFlags}
};

(:~
 : Matches a string against a name filter constructed by `patternsToNameFilter()`.
 :
 : @param string the string to match
 : @param nameFilter the name filter 
 : @return true if the name filter is matched, false otherwise
 :)
declare function f:matchesStringFilter($string as xs:string, 
                                       $stringFilter as map(xs:string, item()*)?)
        as xs:boolean {
    let $flags := $stringFilter?flags
    let $string := if ($stringFilter?ignoreCase) then lower-case($string) else $string 
    return
        $stringFilter?empty
        or exists($stringFilter?strings) and $string = $stringFilter?strings
        or exists($stringFilter?substrings) and (some $sstr in $stringFilter?substrings satisfies contains($string, $sstr))
        or exists($stringFilter?regexes) and (some $r in $stringFilter?regexes satisfies matches($string, $r, $flags))
};

(: ============================================= :)
(:~
 : Returns true if a string matches at least one of the
 : regular expressions supplied.
 :)
declare function f:multiMatches($string as xs:string, 
                                $patterns as xs:string*, 
                                $flags as xs:string?)
        as xs:boolean {
    some $p in $patterns satisfies matches($string, $p, string($flags))        
};

(:~
 : Maps a pattern string to a regular expression.
 :)
declare function f:pattern2Regex($pattern as xs:string?) 
        as xs:string? {
    $pattern
    ! replace(., '[.\\(){}\[\]\^$]', '\\$0')    
    ! replace(., '\*', '.*')
    ! replace(., '\?', '.')
    ! concat('^', ., '$')
};

(:~
 : Returns the expression contained by a string, or the empty sequence if the
 : string does not contain an expression. The string contains an expression if
 : it starts with character { and ends with character }, ignoring leading or
 : trailing whitespace. The expression is the content between the curly braces, 
 : with leading and trailing whitespace removed.
 :
 : @param string a string
 : @return the expression contained, or the empty sequence,
 :   if the string does not contain an expression
 :)
declare function f:extractExpr($string as xs:string?)
        as xs:string? {
    if (not($string)) then ()        
    else if (matches($string, '^\s*\{.*\}\s*$')) then
        replace($string, '^\s*\{\s*|\s*\}\s*$', '')
    else ()        
};

(:~
 : Creates a copy of a node with all "whitespace only" text nodes
 : which are element siblings removed. 
 :)
declare function f:prettyFoxPrint($n as node())
        as node()? {
    copy $n_ := $n
    modify delete nodes $n_//text()[not(matches(., '\S'))][../*]
    return $n_
};        

declare function f:prettyNode($n as node(), $options as xs:string*)
        as node()? {
    copy $n_ := $n
    modify
        if ($options = 'weak') then
            delete nodes $n_//text()[not(matches(., '\S'))][../*][empty(../text()[matches(., '\S')])]
        else
            delete nodes $n_//text()[not(matches(., '\S'))][../*]
    return $n_
};        

declare function f:removeIndent($n as node(), $options as xs:string*)
        as node()? {
    copy $n_ := $n
    modify
        if ($options = 'weak') then
            delete nodes $n_//text()[not(matches(., '\S'))][../*][empty(../text()[matches(., '\S')])]
        else
            delete nodes $n_//text()[not(matches(., '\S'))][../*]
    return $n_
};        

(:~
 : Pads a string on the lefthand side.
 :)
declare function f:lpad($s as xs:anyAtomicType?, 
                        $width as xs:integer, 
                        $char as xs:string?)
        as xs:string? {
    let $s := string($s)    
    let $len := string-length($s) 
    return
        if ($len ge $width) then $s else    
            let $char := ($char, ' ')[1]
            let $pad := concat(string-join(for $i in 1 to $width - $len - 1 return $char, ''), ' ')
            return
                concat($pad, $s)
};

(:~
 : Pads a string on the righthand side.
 :)
declare function f:rpad($s as xs:anyAtomicType?, 
                        $width as xs:integer?, 
                        $char as xs:string?)
        as xs:string? {
    let $s := string($s)
    let $len := string-length($s) 
    return
        if ($len ge $width) then $s else    
            let $char := ($char, ' ')[1]
            let $pad := concat(' ', string-join(for $i in 1 to $width - $len - 1 return $char, ''), '')
            return
                concat($s, $pad)
};


