module namespace f="http://www.ttools.org/xquery-functions";
import module namespace i="http://www.ttools.org/xquery-functions" at 
    "foxpath-processorDependent.xqm",
    "foxpath-util.xqm";
    
declare variable $f:UNAME external := 'hrennau';    
declare variable $f:TOKEN external := '5fde26dd75b57032f3a53d744527ef991592bc00';

declare function f:getResponse($path as xs:string, $uname as xs:string?, $token as xs:string)
        as node()+ {
    let $rq := 
        <http:request method="get" href="{$path}">{
            $uname ! <http:header name="User-Agent" value="{.}"/>,
            <http:header name="Authorization" value="{concat('Token ', $token)}"/>
        }</http:request>
    let $rs := http:send-request($rq)
    let $rsHeader := $rs[1]
    let $body := $rs[position() gt 1]
    return
        ($body, $rsHeader)[1]
};        

declare function f:fox-doc($uri as xs:string, $options as map(*)?)
        as document-node()? {
    let $text := f:redirectedRetrieval($uri, $options)
    return
        try {if ($text) then parse-xml($text) else doc($uri)} 
        catch * {()}
};

declare function f:fox-doc-available($uri as xs:string, $options as map(*)?)
        as xs:boolean {
    let $text := f:redirectedRetrieval($uri, $options)
    return
        try {if ($text) then exists(parse-xml($text)) else doc-available($uri)} 
        catch * {false()}
};

declare function f:redirectedRetrieval($uri as xs:string, $options as map(*)?)
        as xs:string? {
    let $rtrees := 
        if (empty($options)) then ()
        else map:get($options, 'URI_TREES')
    let $redirect := $rtrees//file[$uri eq concat(ancestor::tree/@baseURI, @path)]/@uri
    return
        if ($redirect) then 
            let $doc := f:getResponse($redirect, $f:UNAME, $f:TOKEN)
            return $doc//content/convert:binary-to-string(xs:base64Binary(.))  
        else ()
};

declare function f:childUriCollection($uri as xs:string, $name as xs:string?, $options as map(*)?) {
    (: let $DUMMY := trace($uri, 'CHILD_URI_COLLECTION; URI: ') return :)
    if (matches($uri, '^https://')) then
        f:childUriCollection_uriTree($uri, $name, $options) else
        
    try {file:list($uri, false(), $name)           
        ! replace(., '\\', '/')
        ! replace(., '/$', '')
    } catch * {()}
};

declare function f:descendantUriCollection($uri as xs:string, $name as xs:string?, $options as map(*)?) {
    if (matches($uri, '^https://')) then
        f:descendantUriCollection_uriTree($uri, $name, $options) else
    try {
        file:list($uri, true(), $name)           
        ! replace(., '\\', '/')
        ! replace(., '/$', '')
    } catch * {()}        
};

declare function f:childUriCollection_uriTree($uri as xs:string, $name as xs:string?, $options as map(*)?) {
    (: let $DUMMY := trace($uri, 'CHILD_FROM_URI_TREE, URI: ') :)
    let $rtrees := 
        if (empty($options)) then ()
        else map:get($options, 'URI_TREES')
    return if (empty($rtrees)) then () else
    
    let $baseUris := $rtrees/tree/@baseURI
    
    let $ignNameTest := distinct-values(
        let $uri_ := 
            if (ends-with($uri, '/')) then $uri else concat($uri, '/')    
        let $precedingTreeBaseUris := $baseUris[starts-with($uri_, .)]
        return
            if ($precedingTreeBaseUris) then
                for $bu in $precedingTreeBaseUris
                let $tree := $bu/..
                let $matches := 
                    if ($bu eq $uri_) then $tree
                    else $tree//*[concat($bu, @path) eq $uri]
                return
                    $matches/*/@name
            else
                let $continuingTreeBaseUris := $baseUris[starts-with(., $uri_)]
                return
                    if (not($continuingTreeBaseUris)) then ()
                    else
                        $continuingTreeBaseUris ! substring-after(., $uri_) ! replace(., '/.*', '')
    )
    return
        if (not($name) or empty($ignNameTest)) then $ignNameTest
        else
            let $regex := concat('^', replace(replace($name, '\*', '.*', 's'), '\?', '.'), '$')
            return $ignNameTest[matches(., $regex, 'is')]
};

declare function f:descendantUriCollection_uriTree($uri as xs:string, $name as xs:string?, $options as map(*)?) {
    (: let $DUMMY := trace($uri, 'DESCENDANT_FROM_URI_TREE, URI: ') :)
    let $rtrees := 
        if (empty($options)) then ()
        else map:get($options, 'URI_TREES')
    return if (empty($rtrees)) then () else
    
    let $baseUris := $rtrees/tree/@baseURI
    
    let $ignNameTest := distinct-values(
        let $uri_ := 
            if (ends-with($uri, '/')) then $uri else concat($uri, '/')    
        let $precedingTreeBaseUris := $baseUris[starts-with($uri_, .)]       
        return
            if ($precedingTreeBaseUris) then
                for $bu in $precedingTreeBaseUris
                let $tree := $bu/..
                let $matches := 
                    if ($bu eq $uri_) then $tree
                    else $tree//*[concat($bu, @path) eq $uri]
                return
                    $matches//*/@path
            else
                let $continuingTreeBaseUris := $baseUris[starts-with(., $uri_)]
                return
                    if (not($continuingTreeBaseUris)) then ()
                    else
                        for $bu in $continuingTreeBaseUris
                        let $tree := $bu/..
                        let $suffix := substring-after($bu, $uri_)
                        let $suffixSteps := tokenize($suffix, '/')[string()]
                        return (
                            for $i in 1 to count($suffixSteps)
                            return
                                string-join($suffixSteps[position() le $i], '/'),
                            $tree//*/@path ! concat($suffix, .)
                        )
    )
    return
        if (not($name) or empty($ignNameTest)) then $ignNameTest
        else
            let $regex := concat('^', replace(replace($name, '\*', '.*', 's'), '\?', '.'), '$')
            let $result := $ignNameTest[matches(replace(., '^.*/', ''), $regex, 'is')]
            return $result
};
