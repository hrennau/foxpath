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
import module namespace i="http://www.ttools.org/xquery-functions" 
at  "foxpath-processorDependent.xqm";
    
import module namespace util="http://www.ttools.org/xquery-functions/util" 
at  "foxpath-util.xqm";

(: 
 : ===============================================================================
 :
 :     r e s o u r c e    p r o p e r t i e s
 :
 : ===============================================================================
 :)
 
 (:~
 : Returns true if a resource is a file, rather than a directory.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return true if the resource exists and is a file
 :)
 declare function f:fox-is-file_utree($uri as xs:string, $options as map(*)?)
        as xs:boolean? {    
    let $mode := 1  (: 1 is better ! :) 
    return

    if ($mode ne 1) then exists(
        for $uriPrefix in map:get($options, 'URI_TREES_PREFIXES')[starts-with($uri, .)] return
        for $buri in map:get(map:get($options, 'URI_TREES_PREFIX_TO_BASE_URIS'), $uriPrefix) return
        $buri/..//file[$uri eq concat($buri, @path)]/@size/xs:integer(.)
        )      
    else
    
    exists(
        (: find the matching base URI ... :)    
        for $buri in map:get($options, 'URI_TREES_BASE_URIS')[starts-with($uri, .)]
        let $path := substring($uri, string-length($buri) + 1)
        return
            (: ... and navigate to the matching file element :)        
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
 declare function f:fox-is-dir_utree($uri as xs:string, $options as map(*)?)
        as xs:boolean? {    
    exists(
        (: find the matching base URI ... :)    
        for $buri in map:get($options, 'URI_TREES_BASE_URIS')[starts-with($uri, .)]
        let $path := substring($uri, string-length($buri) + 1)
        return
            (: ... and navigate to the matching dir element :)        
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
 declare function f:fox-file-size_utree($uri as xs:string, $options as map(*)?)
        as xs:integer? {
    let $mode := 1  (: 1 is better ! :)
    return
    
    if ($mode ne 1) then (
        for $uriPrefix in map:get($options, 'URI_TREES_PREFIXES')[starts-with($uri, .)] return
        for $buri in map:get(map:get($options, 'URI_TREES_PREFIX_TO_BASE_URIS'), $uriPrefix) return
        $buri/..//file[$uri eq concat($buri, @path)]/@fileSize/xs:integer(.)
         )[1]        
    else 
    
    (
        (: find the matching base URI ... :)
        for $buri in map:get($options, 'URI_TREES_BASE_URIS')[starts-with($uri, .)]
        let $path := substring($uri, string-length($buri) + 1)
        return
            (: ... and navigate to the matching file element :)
            $buri/..//file[$path eq @path]/@fileSize/xs:integer(.)
    )[1]
         
};

(:~
 : Returns the last modification date of a resource. 
 : If the element representing the resource has not @lastModified
 : attribute, the date is retrieved from the nearest ancestor with 
 : such an attribute.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return the last update date of the resource
 :)
 declare function f:fox-file-date_utree($uri as xs:string?, $options as map(*)?)
        as xs:dateTime? {
    let $resource := (
        (: find the matching base URI ... :)
        for $buri in map:get($options, 'URI_TREES_BASE_URIS')[starts-with($uri, .)]
        let $path := substring($uri, string-length($buri) + 1)
        return
            (: ... and navigate to the matching file element :)
            $buri/..//(dir, file)[$path eq @path]
    ) [1]            
    return
        if (not($resource)) then () else    

        let $date := 
            let $try := $resource/@lastModified
            return
                if (exists($try)) then $try else
                    $resource/ancestor::*[@lastModified][1]/@lastModified 
        return
            $date ! xs:dateTime(.)
};

(: 
 : ===============================================================================
 :
 :     r e s o u r c e    r e t r i e v a l
 :
 : ===============================================================================
 :)
 
  (:~
 : Returns true if a resource exists.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return true if the resource exists and is a file
 :)
declare function f:fox-file-exists_utree($uri as xs:string?, $options as map(*)?)
        as xs:boolean? {
    exists(
        (: find the matching base URI ... :)    
        for $buri in map:get($options, 'URI_TREES_BASE_URIS')[starts-with($uri, .)]
        let $path := substring($uri, string-length($buri) + 1)
        return
            (: ... and navigate to the matching dir element :)        
            $buri/..//(dir, file)[$path eq @path]
     )         
        
};
 
(:~
  : Returns the access URI associated with a given navigation URI.
  :)
declare function f:fox-get-access-uri_utree($uri as xs:string?, $options as map(*)?)
        as xs:string? {
    let $uri :=
        (: find the matching base URI ... :)
        for $buri in map:get($options, 'URI_TREES_BASE_URIS')[starts-with($uri, .)]
        let $path := substring($uri, string-length($buri) + 1)
        return
            (: ... and navigate to the matching file element :)
            $buri/..//file[$path eq @path]/@accessURI
            
    return $uri[1]
};

(: 
 : ===============================================================================
 :
 :     r e s o u r c e    t r e e    n a v i g a t i o n 
 :
 : ===============================================================================
 :)
declare function f:childUriCollection_utree($uri as xs:string, 
                                            $name as xs:string?,
                                            $stepDescriptor as element()?,
                                            $options as map(*)?) {
    (: let $DUMMY := trace($uri, 'UTREE_CHILD; URI: ') :)
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

declare function f:descendantUriCollection_utree($uri as xs:string, 
                                                 $name as xs:string?,
                                                 $stepDescriptor as element()?,
                                                 $options as map(*)?) {
    (: let $DUMMY := trace($uri, 'UTREE_DESCENDANT; URI: ') :)
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
 :     r e s o u r c e    t r e e    n a v i g a t i o n    /    u r i T r e e 
 :
 : ===============================================================================
 :)


(: 
 : ===============================================================================
 :
 :     r e s o u r c e    t r e e    n a v i g a t i o n    /    b a s e x 
 :
 : ===============================================================================
 :)

(: 
 : ===============================================================================
 :
 :     r e s o u r c e    t r e e    n a v i g a t i o n    /    s v n 
 :
 : ===============================================================================
 :)
