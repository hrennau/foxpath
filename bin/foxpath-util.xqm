module namespace f="http://www.ttools.org/xquery-functions/util";

declare namespace fox="http://www.foxpath.org/ns/annotations";

declare variable $f:DEBUG := ''; 
declare variable $f:DG :=
    for $item in tokenize(normalize-space($f:DEBUG), ' ') 
    return concat('^', replace($item, '\*', '.*'), '$');
declare variable $f:ARCHIVE_TOKEN external := '#archive#';
declare variable $f:PREDECLARED_NAMESPACES := (
    <namespace prefix="xml" uri="http://www.w3.org/XML/1998/namespace"/>,
    <namespace prefix="xs" uri="http://www.w3.org/2001/XMLSchema"/>,
    <namespace prefix="xsl" uri="http://www.w3.org/1999/XSL/Transform"/>,    
    <namespace prefix="xsi" uri="http://www.w3.org/2001/XMLSchema-instance"/>,    
    <namespace prefix="rdfs" uri="http://www.w3.org/2000/01/rdf-schema,#"/>,
    <namespace prefix="rdf" uri="http://www.w3.org/1999/02/22-rdf-syntax-ns#"/>,
    <namespace prefix="owl" uri="http://www.w3.org/2002/07/owl#"/>,
    <namespace prefix="wsdl" uri="http://schemas.xmlsoap.org/wsdl/"/>,
    <namespace prefix="docbook" uri="http://docbook.org/ns/docbook"/>    
);

(:~
 : Translates a whitespace-separated list of string patterns
 : into a list of regular expressions and a list of literal strings.
 :
 : @param patterns a list of names and/or patterns, whitespace concatenated
 : @param ignoreCase if true, the filter ignores case 
 : @return a map with entries 'names', 'regexes' and 'flags' 
 :)
declare function f:compileNameFilter($patterns as xs:string?, 
                                     $ignoreCase as xs:boolean?)
        as map(xs:string, item()*)? {
    if (not($patterns)) then () else
    
    let $items := $patterns ! normalize-space(.) ! tokenize(.)
    let $names := 
        let $raw := $items[not(contains(., '*')) and not(contains(., '?'))]
        return
            if (not($ignoreCase)) then $raw else $raw ! lower-case(.)
    let $regexes := $items[contains(., '*') or contains(., '?')]
    ! replace(., '\*', '.*')
    ! replace(., '\?', '.')
    ! concat('^', ., '$')
    let $flags := if ($ignoreCase) then 'i' else ''     
    return 
        map{'names': $names, 'regexes': $regexes, 'empty': empty(($names, $regexes)), 'flags': $flags}
};

(:~
 : Matches a string against a name filter constructed by `patternsToNameFilter()`.
 :
 : @param string the string to match
 : @param nameFilter the name filter 
 : @return true if the name filter is matched, false otherwise
 :)
declare function f:matchesNameFilter($string as xs:string, 
                                     $nameFilter as map(xs:string, item()*)?)
        as xs:boolean {
    let $flags := $nameFilter?flags return
    
    $nameFilter?empty
     or exists($nameFilter?names) and $string = $nameFilter?names
     or exists($nameFilter?regexes) and (some $r in $nameFilter?regexes satisfies matches($string, $r, $flags))
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
            let $_DEBUG := trace(concat('_NEXT_INTERSECTION; #OLD_ITEMS: ', count($sofar), ' ; #NEW_ITEMS: ', count($newItems)))            
            let $_DEBUG := trace($t2 - $t1, 't(flatten): ')
            let $_DEBUG := trace($t3 - $t2, 't(filter) : ')
            
            return $newAccum})
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
 : Creates a copy of a node with all "whitespace only" text nodes
 : which are element siblings removed. 
 :)
declare function f:prettyFoxPrint($n as node())
        as node()? {
    copy $n_ := $n
    modify delete nodes $n_//text()[not(matches(., '\S'))][../*]
    return $n_
};        