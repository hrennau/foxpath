(:
foxpath-uri-operation.xqm - library of functions operating on URIs

Overview:

Group: resource properties
  uriDomain
  fox-is-file
  fox-is-dir
  fox-file-size
  fox-file-date
  fox-file-sdate

Group: resource retrieval
  fox-unparsed-text
  fox-unparsed-text-lines
  
:)
module namespace f="http://www.ttools.org/xquery-functions";
import module namespace i="http://www.ttools.org/xquery-functions" at 
    "foxpath-processorDependent.xqm",
    "foxpath-uri-operations-basex.xqm",
    "foxpath-util.xqm";
    
declare variable $f:UNAME external := 'hrennau';    
declare variable $f:TOKEN external := try {unparsed-text('/git/token')} catch * {()};

(: 
 : ===============================================================================
 :
 :     r e s o u r c e    p r o p e r t i e s
 :
 : ===============================================================================
 :)

(:~
 : Returns the domain of an URI. This is one of these:
 :    SIMPLE_URI_TREE
 :    REDIRECTING_URI_TREE
 :    FILE_SYSTEM
 :    SVN_REPO
 :
 : @param uri the URI
 : @param options options controlling the evaluation
 : @return the domain
 :)
declare function f:uriDomain($uri as xs:string, $options as map(*)?)
        as xs:string {              
    if (matches($uri, '^https?://')) then 'REDIRECTING_URI_TREE'
    else if (starts-with($uri, 'basex://')) then 'BASEX'    
    else if (starts-with($uri, 'svn-')) then 'SVN'    
    else 'FILE_SYSTEM'
};

(:~
 : Returns true if a resource is a file, rather than a directory.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return true if the resource exists and is a file
 :)
 declare function f:fox-is-file($uri as xs:string, $options as map(*)?)
        as xs:boolean? {    
    let $mode := 1  (: 1 is better ! :) 
    let $uriDomain := f:uriDomain($uri, $options)
    return
    
    if ($uriDomain eq 'FILE_SYSTEM') then 
        file:is-file($uri)        
    else if ($uriDomain eq 'BASEX') then
        f:fox-is-file_basex($uri, $options)  
    else if ($uriDomain eq 'SVN') then 
        let $useUri := substring($uri, 5)
        let $listUri := 
            proc:system('svn', ('list', $useUri))
            ! replace(., '\s+$', '')
        return
            $listUri and not(ends-with($listUri, '/'))
            
    else if (empty($options)) then ()
    
    else if ($mode ne 1) then exists(
        for $uriPrefix in map:get($options, 'URI_TREES_PREFIXES')[starts-with($uri, .)] return
        for $buri in map:get(map:get($options, 'URI_TREES_PREFIX_TO_BASE_URIS'), $uriPrefix) return
        $buri/..//file[$uri eq concat($buri, @path)]/@size/xs:integer(.)
        )      
    else 
        exists(
            for $buri in map:get($options, 'URI_TREES_BASE_URIS')[starts-with($uri, .)]
            let $path := substring($uri, string-length($buri) + 1)
            return
                $buri/..//file[$path eq @path]
         )         
};

(:~
 : Returns true if a resource is a directory, rather than a file.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return true if the resource exists and is a directory
 :)
 declare function f:fox-is-dir($uri as xs:string, $options as map(*)?)
        as xs:boolean? {    
    let $mode := 1  (: 1 is better ! :) 
    let $uriDomain := f:uriDomain($uri, $options)
    return
    
    if ($uriDomain eq 'FILE_SYSTEM') then 
        file:is-dir($uri)
    else if ($uriDomain eq 'BASEX') then 
        f:fox-is-dir_basex($uri, $options)   
    else if ($uriDomain eq 'SVN') then 
        let $useUri := substring($uri, 5)
        let $listUri := 
            proc:system('svn', ('list', $useUri))
            ! replace(., '\s+$', '')
        return
            $listUri and ends-with($listUri, '/')
    
    else if (empty($options)) then ()
    
    else if ($mode ne 1) then exists(
        for $uriPrefix in map:get($options, 'URI_TREES_PREFIXES')[starts-with($uri, .)] return
        for $buri in map:get(map:get($options, 'URI_TREES_PREFIX_TO_BASE_URIS'), $uriPrefix) return
        $buri/..//dir[$uri eq concat($buri, @path)]/@size/xs:integer(.)
        )      
    else 
        exists(
            for $buri in map:get($options, 'URI_TREES_BASE_URIS')[starts-with($uri, .)]
            let $path := substring($uri, string-length($buri) + 1)
            return
                $buri/..//dir[$path eq @path]
         )         
};

(:~
 : Returns the size of a resource.
 :
 : @param uri the URI or file path
 : @param options options controlling the evaluation
 : @return the size of the resource as number of bytes
 :)
 declare function f:fox-file-size($uri as xs:string, $options as map(*)?)
        as xs:integer? {    
    let $mode := 1  (: 1 is better ! :) 
    let $uriDomain := f:uriDomain($uri, $options)
    return
    
    if ($uriDomain eq 'FILE_SYSTEM') then 
        file:size($uri)
    else if ($uriDomain eq 'BASEX') then
        f:fox-file-size_basex($uri, $options)
    else if (empty($options)) then ()
(:    
    else (
        for $tree in map:get($options, 'URI_TREES')[starts-with($uri, @baseURI)] return
            $tree//file[$uri eq concat($tree/@baseURI, @path)]
         )[1]
:)         
    else if ($mode ne 1) then (
        for $uriPrefix in map:get($options, 'URI_TREES_PREFIXES')[starts-with($uri, .)] return
        for $buri in map:get(map:get($options, 'URI_TREES_PREFIX_TO_BASE_URIS'), $uriPrefix) return
        $buri/..//file[$uri eq concat($buri, @path)]/@size/xs:integer(.)
         )[1]        
    else (
        for $buri in map:get($options, 'URI_TREES_BASE_URIS')[starts-with($uri, .)]
        let $path := substring($uri, string-length($buri) + 1)
        return
            $buri/..//file[$path eq @path]/@size/xs:integer(.)
    )[1]
         
};

(:~
 : Returns the last modification date of a resource.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return the last update date of the resource
 :)
 declare function f:fox-file-date($uri as xs:string?, $options as map(*)?)
        as xs:dateTime? {       
    if (not($uri)) then () else
    
    let $uriDomain := f:uriDomain($uri, $options)
    return
    
    if ($uriDomain eq 'FILE_SYSTEM') then 
        file:last-modified($uri)
    else if ($uriDomain eq 'BASEX') then 
        f:fox-file-date_basex($uri, $options)
    else if ($uriDomain eq 'REDIRECTING_URI_TREE') then (
        for $buri in map:get($options, 'URI_TREES_BASE_URIS')[starts-with($uri, .)]
        where $buri/..//file[$uri eq concat($buri, @path)]
        return $buri/../@lastModified/xs:dateTime(.)
    )[1]
    else if (empty($options)) then ()
    else ()    
};

(:~
 : Returns the last modification date of a resource as a string.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return the last update date of the resource
 :)
 declare function f:fox-file-sdate($uri as xs:string?, $options as map(*)?)
        as xs:string? {  
    f:fox-file-date($uri, $options) ! string(.)
};

(: 
 : ===============================================================================
 :
 :     r e s o u r c e    r e t r i e v a l
 :
 : ===============================================================================
 :)

(:~
 : Returns an XML document identified by URI or file path.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return the document, or the empty sequence if retrieval or parsing fails
 :)
declare function f:fox-doc($uri as xs:string, $options as map(*)?)
        as document-node()? {
    let $uriDomain := f:uriDomain($uri, $options)
    return

    if ($uriDomain eq 'BASEX') then 
        f:fox-doc_basex($uri, $options)
    else if ($uriDomain eq 'REDIRECTING_URI_TREE') then 
        let $text := f:fox-unparsed-text_github($uri, (), $options)
        return
            try {parse-xml($text)} catch * {()}        
    else if (doc-available($uri)) then doc($uri)
    else ()
};

(:~
 : Returns true if a given URI or file path points to a well-formed XML document.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return true if the URI points to a well-formed XML document
 :)
declare function f:fox-doc-available($uri as xs:string, $options as map(*)?)
        as xs:boolean {
    let $uriDomain := f:uriDomain($uri, $options)
    return

    if ($uriDomain eq 'BASEX') then 
        f:fox-doc-available_basex($uri, $options)
    else if ($uriDomain eq 'REDIRECTING_URI_TREE') then 
        let $text := f:fox-unparsed-text_github($uri, (), $options)
        return
            exists(try {parse-xml($text)} catch * {()})        
    else doc-available($uri)
};

(:~
 : Returns the string representation of a resource.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return the text of the resource, or the empty sequence if retrieval fails
 :)
declare function f:fox-unparsed-text($uri as xs:string, 
                                     $encoding as xs:string?, 
                                     $options as map(*)?)
        as xs:string? {
    let $uriDomain := f:uriDomain($uri, $options)
    return
    
    if ($uriDomain eq 'REDIRECTING_URI_TREE') then 
        f:fox-unparsed-text_github($uri, $encoding, $options)    
    else if ($uriDomain eq 'BASEX') then
        f:fox-unparsed-text_basex($uri, $encoding, $options)
    else 
        try {
            if ($encoding) then unparsed-text($uri, $encoding)
            else unparsed-text($uri)
        } catch * {()}
};

(:~
 : Returns the lines of the string representation of a resource.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return the text lines, or the empty sequence if retrieval fails
 :)
declare function f:fox-unparsed-text-lines($uri as xs:string, 
                                           $encoding as xs:string?, 
                                           $options as map(*)?)
        as xs:string* {
    let $uriDomain := f:uriDomain($uri, $options)
    return
    
    if ($uriDomain eq 'REDIRECTING_URI_TREE') then 
        f:fox-unparsed-text_github($uri, $encoding, $options) ! tokenize(., '&#xA;&#xD;?')
    else if ($uriDomain eq 'BASEX') then
        f:fox-unparsed-text-lines_basex($uri, $encoding, $options)
    else
        try {
            if ($encoding) then unparsed-text-lines($uri, $encoding)
            else unparsed-text-lines($uri)
        } catch * {()}
};

(:~
 : Returns the lines of the string representation of a resource.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return the text lines, or the empty sequence if retrieval fails
 :)
declare function f:fox-file-lines($uri as xs:string,
                                  $encoding as xs:string?,
                                  $options as map(*)?)
        as xs:string* {
    f:fox-unparsed-text-lines($uri, $encoding, $options)
};

(:~
 : Returns an XML representation of the JSON record identified by URI or file path.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return an XML document representing JSON data, or the empty sequence if 
 :     retrieval or parsing fails
 :)
declare function f:fox-json-doc($uri as xs:string,
                                $options as map(*)?)
        as document-node()? {
    let $uriDomain := f:uriDomain($uri, $options)
    return

    if ($uriDomain eq 'REDIRECTING_URI_TREE') then 
        let $text := f:fox-unparsed-text_github($uri, (), $options)
        return
            try {$text ! json:parse(.)} catch * {()}        
    else 
        try {unparsed-text($uri) ! json:parse(.)} catch * {()}
};

(:~
 : Returns true if a given URI or file path points to a valid JSON record.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return true if a JSON record can be retrieved
 :)
declare function f:fox-json-doc-available($uri as xs:string, 
                                          $options as map(*)?)
        as document-node()? {
    let $uriDomain := f:uriDomain($uri, $options)
    return

    if ($uriDomain eq 'REDIRECTING_URI_TREE') then 
        let $text := f:fox-unparsed-text_github($uri, (), $options)
        return
            try {exists($text ! json:parse(.))} catch * {()}        
    else 
        try {exists(unparsed-text($uri) ! json:parse(.))} catch * {()}
};

(:~
 : Retrieves the text of a resource whose URI is found in a redirecting URI tree.
 :
 : @param uri the URI
 : @param options options controlling the evaluation
 : @return the domain
 :)
declare function f:fox-unparsed-text_github($uri as xs:string,
                                            $encoding as xs:string?,
                                            $options as map(*)?)
        as xs:string? {
    let $redirect :=
        if (not(f:uriDomain($uri, $options) eq 'REDIRECTING_URI_TREE')) then ()
        else if (empty($options)) then ()
        else
            for $buri in map:get($options, 'URI_TREES_BASE_URIS')[starts-with($uri, .)] return
            $buri/..//file[$uri eq concat($buri, @path)]/@uri
            
    return
        try {
            if ($redirect) then
                let $response := f:get-request_github($redirect, $f:TOKEN)
                return $response//content/convert:binary-to-string(xs:base64Binary(.))  
            else ()
        } catch * {()}            
};

(:~
 : Sends a github API - GET request and returns the response. Returns the response body,
 : if there is one, otherwise the response header.
 
 : @param uri the URI
 : @param token if specified, used for authorization
 : @return the response
 :)
declare function f:get-request_github($uri as xs:string, $token as xs:string)
        as node()+ {
    let $rq :=
        <http:request method="get" href="{$uri}">{
            <http:header name="Authorization" value="{concat('Token ', $token)}"/>[$token]
        }</http:request>
    let $rs := try {http:send-request($rq)} catch * {trace((), 'EXCEPTION_IN_SEND_REQUEST: ')} 
    let $rsHeader := $rs[1]
    let $body := $rs[position() gt 1]
    return
        ($body, $rsHeader)[1]
};        

(: 
 : ===============================================================================
 :
 :     r e s o u r c e    t r e e    n a v i g a t i o n 
 :
 : ===============================================================================
 :)

(:~
 : Returns the child URIs of a given URI, matching an optional name pattern
 : and matching an optional kind test (file or folder).
 :
 : Note. The kind test is currently received via a `stepDescriptor` element.
 : This approach is meant to be extensible, allowing the future addition of 
 : other filters 
 :)
declare function f:childUriCollection($uri as xs:string, 
                                      $name as xs:string?,
                                      $stepDescriptor as element()?,
                                      $options as map(*)?) {
    let $uriDomain := f:uriDomain($uri, $options)
    return    
        if ($uriDomain eq 'REDIRECTING_URI_TREE') then
            f:childUriCollection_uriTree($uri, $name, $stepDescriptor, $options) 
        else if ($uriDomain eq 'BASEX') then
            f:childUriCollection_basex($uri, $name, $stepDescriptor, $options) 
        else if ($uriDomain eq 'SVN') then
            f:childUriCollection_svn($uri, $name, $stepDescriptor, $options) 
        else
        
    let $kindFilter := $stepDescriptor/@kindFilter
    let $ignKindTest :=        
        try {file:list($uri, false(), $name)           
            ! replace(., '\\', '/')
            ! replace(., '/$', '')
        } catch * {()}
    return
        if (not($kindFilter)) then $ignKindTest
        else 
            let $useUri := replace($uri, '/$', '')   (: normalization :)
            return
                if ($kindFilter eq 'file') then
                    $ignKindTest[file:is-file(concat($useUri, '/', .))]
                else if ($kindFilter eq 'dir') then
                    $ignKindTest[file:is-dir(concat($useUri, '/', .))]
                else
                    error(QName((), 'PROGRAM_ERROR'), concat('Unexpected kind filter: ', $kindFilter))
};

(:~
 : Returns the descendant URIs of a given URI, matching an optional name pattern
 : and matching an optional kind test (file or folder).
 :
 : Note. The kind test is currently received via a `stepDescriptor` element.
 : This approach is meant to be extensible, allowing the future addition of 
 : other filters 
 :)
declare function f:descendantUriCollection($uri as xs:string, 
                                           $name as xs:string?, 
                                           $stepDescriptor as element()?,
                                           $options as map(*)?) {   
    let $uriDomain := f:uriDomain($uri, $options)
    return    
        if ($uriDomain eq 'REDIRECTING_URI_TREE') then
            f:descendantUriCollection_uriTree($uri, $name, $stepDescriptor, $options) 
        else if ($uriDomain eq 'BASEX') then
            f:descendantUriCollection_basex($uri, $name, $stepDescriptor, $options) 
        else if ($uriDomain eq 'SVN') then
            f:descendantUriCollection_svn($uri, $name, $stepDescriptor, $options) 
        else
        
    let $kindFilter := $stepDescriptor/@kindFilter
    let $ignKindTest :=
        try {
            file:list($uri, true(), $name)           
            ! replace(., '\\', '/')
            ! replace(., '/$', '')
        } catch * {()}
    return
        if (not($kindFilter)) then $ignKindTest
        else 
            let $useUri := replace($uri, '/$', '')
            return
                if ($kindFilter eq 'file') then
                    $ignKindTest[file:is-file(concat($useUri, '/', .))]
                else if ($kindFilter eq 'dir') then
                    $ignKindTest[file:is-dir(concat($useUri, '/', .))]
                else
                    error(QName((), 'PROGRAM_ERROR'), concat('Unexpected kind filter: ', $kindFilter))
};

(: 
 : ===============================================================================
 :
 :     r e s o u r c e    t r e e    n a v i g a t i o n    /    u r i T r e e 
 :
 : ===============================================================================
 :)

declare function f:childUriCollection_uriTree($uri as xs:string, 
                                              $name as xs:string?,
                                              $stepDescriptor as element()?,
                                              $options as map(*)?) {
    (: let $DUMMY := trace($uri, 'CHILD_FROM_URI_TREE, URI: ') :)
    let $rtrees := 
        if (empty($options)) then ()
        else map:get($options, 'URI_TREES')
    return if (empty($rtrees)) then () else
    
    let $kindFilter := $stepDescriptor/@kindFilter    
    (: let $baseUris := $rtrees/tree/@baseURI :)
    let $baseUris := map:get($options, 'URI_TREES_BASE_URIS')
    
    let $ignNameTest := distinct-values(
        let $uri_ := 
            if (ends-with($uri, '/')) then $uri else concat($uri, '/')    
        let $precedingTreeBaseUris := $baseUris[starts-with($uri_, .)]
        return
            (: case 1: URI starts with base uris :)        
            if ($precedingTreeBaseUris) then
                for $bu in $precedingTreeBaseUris
                let $tree := $bu/..
                
                (: the matching elements :)
                let $matchElems :=
                    if ($bu eq $uri_) then 
                        if ($kindFilter eq 'file') then $tree/file
                        else if ($kindFilter eq 'dir') then $tree/dir
                        else $tree/*
                    else
                        let $match := $tree//*[concat($bu, @path) eq $uri]
                        return
                            if (not($match)) then () else
                                if ($kindFilter eq 'file') then $match/file
                                else if ($kindFilter eq 'dir') then $match/dir
                                else $match/*
                return                                
                    $matchElems/@name   
            (: case 2: URI is the prefix of base uris :)                    
            else
                let $continuingTreeBaseUris := $baseUris[starts-with(., $uri_)][not(. eq $uri_)]
                return
                    if (not($continuingTreeBaseUris)) then ()
                    else if ($kindFilter eq 'dir') then ()
                    else
                        $continuingTreeBaseUris 
                        ! substring-after(., $uri_) 
                        ! replace(., '/.*', '')
    )
    return
        if (not($name) or empty($ignNameTest)) then $ignNameTest
        else
            let $regex := concat('^', replace(replace($name, '\*', '.*', 's'), '\?', '.'), '$')
            return $ignNameTest[matches(., $regex, 'is')]
};

declare function f:descendantUriCollection_uriTree($uri as xs:string, 
                                                   $name as xs:string?,
                                                   $stepDescriptor as element()?,
                                                   $options as map(*)?) {
    (: let $DUMMY := trace($uri, 'DESCENDANT_FROM_URI_TREE, URI: ') :)

    let $rtrees := 
        if (empty($options)) then ()
        else map:get($options, 'URI_TREES')
    return if (empty($rtrees)) then () else

    let $kindFilter := $stepDescriptor/@kindFilter
    (: let $baseUris := $rtrees/tree/@baseURI :)
    let $baseUris := map:get($options, 'URI_TREES_BASE_URIS')
    
    let $ignNameTest := distinct-values(
        let $uri_ := if (ends-with($uri, '/')) then $uri else concat($uri, '/')    
        let $precedingTreeBaseUris := $baseUris[starts-with($uri_, .)]  
        return
            (: case 1: URI starts with base uris :)
            if ($precedingTreeBaseUris) then
                for $bu in $precedingTreeBaseUris
                let $tree := $bu/..
                
                (:  potentially matching elements :)
                let $candidates :=
                    if ($kindFilter eq 'file') then $tree/descendant::file
                    else if ($kindFilter eq 'dir') then $tree/descendant::dir
                    else $tree/descendant::*
                
                (: the matching elements :)
                let $matchElems :=
                    if ($bu eq $uri_) then $candidates
                    else
                        let $match := $tree//*[concat($bu, @path) eq $uri]
                        return
                            if (not($match)) then () else
                                $candidates[not(. << $match)]
                let $fullUris :=                                
                    $matchElems/concat($bu, @path)
   
                (: return the paths as postfix of input URI :)
                let $fromPos := string-length($uri) + 2                
                return
                    $fullUris ! substring(., $fromPos)                    

            (: case 2: URI is the prefix of base uris :)
            else
                let $continuingTreeBaseUris := $baseUris[starts-with(., $uri_)][not(. eq $uri_)]
                return
                    if (not($continuingTreeBaseUris)) then ()
                    else
                        for $bu in $continuingTreeBaseUris
                        let $tree := $bu/..
                        let $suffix := substring-after($bu, $uri_)
                        let $suffixSteps := tokenize($suffix, '/')[string()]
                        return (
                            if ($kindFilter eq 'file') then () else
                                for $i in 1 to count($suffixSteps)
                                return
                                    string-join($suffixSteps[position() le $i], '/'),
                            let $matchElems :=    
                                if ($kindFilter eq 'file') then $tree/descendant::file
                                else if ($kindFilter eq 'dir') then $tree/descendant-or-self::dir
                                else $tree/descendant-or-self::*
                            return
                                $matchElems/@path ! concat($suffix, .)
                                (: return the paths as postfix of input URI :)
                        )
    )
    (: process name test :)
    return
        if (not($name) or empty($ignNameTest)) then $ignNameTest
        else
            let $regex := concat('^', replace(replace($name, '\*', '.*', 's'), '\?', '.'), '$')
            return
                if ($regex eq '^.*$') then $ignNameTest
                else
                    $ignNameTest[matches(replace(., '^.*/', ''), $regex, 'is')]
};

(: 
 : ===============================================================================
 :
 :     r e s o u r c e    t r e e    n a v i g a t i o n    /    s v n 
 :
 : ===============================================================================
 :)

(:~
 : Returns the child URIs of a given svn URI, matching an optional name pattern
 : and matching an optional kind test (file or folder).
 :
 : Note. The kind test is currently received via a `stepDescriptor` element.
 : This approach is meant to be extensible, allowing the future addition of 
 : other filters 
 :)
declare function f:childUriCollection_svn($uri as xs:string, 
                                          $name as xs:string?,
                                          $stepDescriptor as element()?,
                                          $options as map(*)?) {                                        
    let $pattern :=
        if (not($name)) then () else 
            concat('^', replace($name, '\*', '.*'), '$')

    let $uri := substring($uri, 5) ! replace(., '/$', '')
    let $kindFilter := $stepDescriptor/@kindFilter
    let $raw := f:_getChildUris_svn($uri, $pattern, $kindFilter)
    return
        $raw ! replace(., '/\s*$', '')
};

declare function f:descendantUriCollection_svn($uri as xs:string, 
                                               $name as xs:string?,
                                               $stepDescriptor as element()?,
                                               $options as map(*)?) {
    let $pattern :=
        if (not($name)) then () else concat('^', replace($name, '\*', '.*'), '$')

    let $uri := substring($uri, 5) ! replace(., '/$', '')
    let $kindFilter := $stepDescriptor/@kindFilter
    let $raw := f:_getDescendantUris_svn($uri, $pattern, $kindFilter)
    return
        $raw ! replace(., '/\s*$', '')
};

(:~
 : Returns the child URIs of a given svn URI, matching an optional name pattern
 : and matching an optional kind test (file or folder).
 :
 : Note. Private function, called by public function f:childUriCollection.
 :)
declare function f:_getChildUris_svn($uri as xs:string,
                                     $pattern as xs:string?,
                                     $kindFilter as xs:string?)
        as xs:string* {
    (: all child URIs :)
    let $all := tokenize(proc:system('svn', ('list', $uri)), '\s*&#xA;\s*')[string()]
    (: name matching URIs :)
    let $matchName :=
        if ($pattern) then $all[matches(replace(., '/$', ''), $pattern, 'i')]
        else $all
    (: kind matching URIs :)
    let $matchKind :=
        if (not($kindFilter)) then $matchName
        else if ($kindFilter eq 'file') then $matchName[not(ends-with(., '/'))]
        else if ($kindFilter eq 'dir') then $matchName[ends-with(., '/')] ! replace(., '/\s*$', '')
        else
            error(QName((), 'PROGRAM_ERROR'), concat('Unexpected kind filter: ', $kindFilter))
    return
        $matchKind
};

declare function f:_getDescendantUris_svn($uri as xs:string,
                                          $pattern as xs:string?,
                                          $kindFilter as xs:string?)
        as xs:string* {
    (: all child URIs :)        
    let $all := tokenize(proc:system('svn', ('list', '--recursive', $uri)), '\s*&#xA;\s*')[string()]
    (: name matching URIs :)
    let $matchName :=
        if ($pattern) then 
            $all[matches(replace(replace(., '/$', ''), '.*/', ''), $pattern, 'i')]
        else $all
    (: kind matching URIs :)        
    let $matchKind :=
        if (not($kindFilter)) then $matchName
        else if ($kindFilter eq 'file') then $matchName[not(ends-with(., '/'))]
        else if ($kindFilter eq 'dir') then $matchName[ends-with(., '/')] ! replace(., '/\s*$', '')
        else
            error(QName((), 'PROGRAM_ERROR'), concat('Unexpected kind filter: ', $kindFilter))
    return 
        $matchKind
};


