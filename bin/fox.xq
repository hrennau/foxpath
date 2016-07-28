import module namespace f="http://www.ttools.org/xquery-functions" at "foxpath.xqm", "foxpath-parser.xqm", "foxpath-util.xqm";
declare namespace soap="http://schemas.xmlsoap.org/soap/envelope/";

declare variable $foxpath external;
declare variable $mode as xs:string? external := 'eval';   (: eval | parse :)
declare variable $sep as xs:string? external := '/';       (: / | \ :)

let $options := map:merge((
    map:entry('IS_CONTEXT_URI', true()),
    if ($sep eq '\') then (
        map:entry('FOXSTEP_SEPERATOR', '\'),
        map:entry('NODESTEP_SEPERATOR', '/')
    ) else (
        map:entry('FOXSTEP_SEPERATOR', '/'),
        map:entry('NODESTEP_SEPERATOR', '\')
    )
))
(: let $DUMMY := trace($options, 'OPTIONS: ') :) 
return    
    if ($mode eq 'parse') then f:parseFoxpath($foxpath, $options)
    else f:resolveFoxpath($foxpath, $options)
