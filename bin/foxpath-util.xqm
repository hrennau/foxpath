module namespace f="http://www.ttools.org/xquery-functions";

declare variable $f:DEBUG := ''; 
declare variable $f:DG :=
    for $item in tokenize(normalize-space($f:DEBUG), ' ') 
    return concat('^', replace($item, '\*', '.*'), '$');
declare variable $f:ARCHIVE_TOKEN external := '#archive#';
declare variable $f:PREDECLARED_NAMESPACES := (
    <namespace prefix="xs" uri="http://www.w3.org/2001/XMLSchema"/>,
    <namespace prefix="xsi" uri="http://www.w3.org/2001/XMLSchema-instance"/>,    
    <namespace prefix="rdfs" uri="http://www.w3.org/2000/01/rdf-schema#"/>,
    <namespace prefix="rdf" uri="http://www.w3.org/1999/02/22-rdf-syntax-ns#"/>,
    <namespace prefix="owl" uri="http://www.w3.org/2002/07/owl#"/>
);

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
