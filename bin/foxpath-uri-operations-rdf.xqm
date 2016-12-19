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
    "foxpath-util.xqm";

(: 
 : ===============================================================================
 :
 :     r e s o u r c e    p r o p e r t i e s
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
declare function f:fox-file-exists_rdf($uri as xs:string?, $options as map(*)?)
        as xs:boolean? {
    let $endpoint := $options ! map:get(., 'UGRAPH_ENDPOINT')        
    let $query := ``[
PREFIX fs: <http://www.foxpath.org/ns/rdf/filesystem/>

SELECT ?exists
WHERE
{
    OPTIONAL {?res fs:navURI "`{$uri}`"}
    BIND( IF(BOUND(?res), true, false ) as ?exists)
}]``
    let $response := f:sparql2strings($query, $endpoint, ())
    return
        $response ! xs:boolean(.)
};

(:~
 : Returns true if a resource is a file, rather than a directory.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return true if the resource exists and is a file
 :)
declare function f:fox-is-file_rdf($uri as xs:string?, $options as map(*)?)
        as xs:boolean? {
    let $endpoint := $options ! map:get(., 'UGRAPH_ENDPOINT')        
    let $uriString := concat('"', $uri, '"')
    let $query := ``[
PREFIX fs: <http://www.foxpath.org/ns/rdf/filesystem/>

SELECT ?isFile
WHERE
{
    ?res fs:navURI "`{$uri}`" .
    OPTIONAL {?res a fs:file . BIND(true as ?isFile)}
    OPTIONAL {?res a fs:dir . BIND(false as ?isFile)}
}]``
    let $response := f:sparql2strings($query, $endpoint, ())
    return
        $response ! xs:boolean(.)
};

(:~
 : Returns true if a resource is a directory, rather than a file.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return true if the resource exists and is a file
 :)
declare function f:fox-is-dir_rdf($uri as xs:string?, $options as map(*)?)
        as xs:boolean? {
    let $endpoint := $options ! map:get(., 'UGRAPH_ENDPOINT')        
    let $uriString := concat('"', $uri, '"')
    let $query := ``[
PREFIX fs: <http://www.foxpath.org/ns/rdf/filesystem/>

SELECT ?isDir
WHERE
{
    ?res fs:navURI "`{$uri}`" .
    OPTIONAL {?res a fs:dir . BIND(true as ?isDir)}
    OPTIONAL {?res a fs:file . BIND(false as ?isDir)}
}]``
    let $response := f:sparql2strings($query, $endpoint, ())
    return
        $response ! xs:boolean(.)
};

(:~
 : Returns the last modification date of a resource.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return the last update date of the resource
 :)
 declare function f:fox-file-date_rdf($uri as xs:string?, $options as map(*)?)
        as xs:dateTime? {
    let $endpoint := $options ! map:get(., 'UGRAPH_ENDPOINT')        
    let $uriString := concat('"', $uri, '"')
    let $query := ``[
PREFIX fs: <http://www.foxpath.org/ns/rdf/filesystem/>

SELECT DISTINCT ?date
WHERE
{
    ?res fs:navURI `{$uriString}` .
    ?res fs:lastModified ?date .
}]``
    let $response := f:sparql2strings($query, $endpoint, ())
    return
        $response ! xs:dateTime(.)
};

declare function f:fox-file-size_rdf($uri as xs:string?, $options as map(*)?)
        as xs:integer? {
    let $endpoint := $options ! map:get(., 'UGRAPH_ENDPOINT')        
    let $uriString := concat('"', $uri, '"')
    let $query := ``[
PREFIX fs: <http://www.foxpath.org/ns/rdf/filesystem/>

SELECT DISTINCT ?size
WHERE
{
    ?res fs:navURI `{$uriString}` .
    ?res fs:fileSize ?size .
}]``
    let $response := f:sparql2strings($query, $endpoint, ())
    return
        $response ! xs:integer(.)
};

(: 
 : ===============================================================================
 :
 :     r e s o u r c e    r e t r i e v a l
 :
 : ===============================================================================
 :)
 
 (:~
  : Returns the access URI associated with a given navigation URI.
  :)
declare function f:fox-get-access-uri_rdf($uri as xs:string?, $options as map(*)?)
        as xs:string? {
    let $endpoint := $options ! map:get(., 'UGRAPH_ENDPOINT')        
    let $query := ``[
PREFIX fs: <http://www.foxpath.org/ns/rdf/filesystem/>

SELECT ?accessURI
WHERE
{
    ?file fs:navURI "`{$uri}`" .
    ?file fs:accessURI ?accessURI
}]``
    let $response := f:sparql2strings($query, $endpoint, ())
    return
        $response ! xs:string(.)
};
(: 
 : ===============================================================================
 :
 :     r e s o u r c e    t r e e    n a v i g a t i o n 
 :
 : ===============================================================================
 :)

(: 
 : ===============================================================================
 :
 :     r e s o u r c e    t r e e    n a v i g a t i o n    /    r d f 
 :
 : ===============================================================================
 :)
declare function f:childUriCollection_rdf($uri as xs:string, 
                                          $name as xs:string?,
                                          $stepDescriptor as element()?,
                                          $options as map(*)?) {
    f:childOrDescendantUriCollection_rdf('child', $uri, $name, $stepDescriptor, $options)
};

declare function f:descendantUriCollection_rdf($uri as xs:string, 
                                               $name as xs:string?,
                                               $stepDescriptor as element()?,
                                               $options as map(*)?) {
    f:childOrDescendantUriCollection_rdf('descendant', $uri, $name, $stepDescriptor, $options)
};

declare function f:childOrDescendantUriCollection_rdf($axis as xs:string,
                                                      $uri as xs:string, 
                                                      $name as xs:string?,
                                                      $stepDescriptor as element()?,
                                                      $options as map(*)?) {
    (: let $DUMMY := trace($uri, concat('axis=', $axis, ' ; URI: ')) :)
    let $endpoint := $options ! map:get(., 'UGRAPH_ENDPOINT')    
    let $pattern :=
        if (not($name)) then () 
        else concat('^', replace($name, '\*', '.*'), '$')
    let $kindFilter := $stepDescriptor/@kindFilter

    let $sparql_up_navigator :=
        if ($axis eq 'child') then 'fs:parentDir'
        else 'fs:parentDir+'
    let $sparql_filter_name := 
        if (not($pattern)) then () 
        else "?res fs:name ?name .&#xA;" || "FILTER (regex(?name, '" || $pattern || "', 'i'))"
    let $sparql_filter_kind :=
        if ($kindFilter eq 'file') then '?res a fs:file .'
        else if ($kindFilter eq 'dir') then '?res a fs:dir .'
        else ()
    let $query := ``[
PREFIX fs: <http://www.foxpath.org/ns/rdf/filesystem/>

SELECT DISTINCT ?navURI
WHERE
{
?dir fs:navURI "`{$uri}`" .
?res `{$sparql_up_navigator}` ?dir .
`{$sparql_filter_kind}`
`{$sparql_filter_name}`
?res fs:navURI ?navURI
}]`` ! replace(., '&#xD;', '')
    let $DUMMY := file:write('/projects/foxbug/foxbug.txt', $query, map{'method':'text'})
    let $response := f:sparql2strings($query, $endpoint, ())   
    let $uriWithTrailingSlash := replace($uri, '([^/])$', '$1/')
    return
        $response ! substring-after(., $uriWithTrailingSlash)
};

(: 
 : ===============================================================================
 :
 :     u t i l i t i e s 
 :
 : ===============================================================================
 :)

(:~
 : Executes a SPARQL query and returns the result as a sequence of strings.
 :)
declare function f:sparql2strings($query as xs:string,
                                  $endpoint as xs:string?,
                                  $encoding as xs:string?) 
        as xs:string* {
    let $endpoint := ($endpoint, 'http://localhost:3030/moly')[1]
    let $encoding := ($encoding, 'iso-8859-1')[1]
    let $sparql := replace($query, '&#xD;', '')
    
    let $request :=
        <http:request href='{$endpoint}'    
                      method='post'>    
            <http:body media-type='application/sparql-query' 
                       method='text' 
                       encoding="{$encoding}">{$sparql}</http:body>
        </http:request>  (: , 'REQUEST: ') :)
    let $rs := http:send-request($request)[2]
    return
        convert:binary-to-string($rs) ! json:parse(.)//value/string()
};

 (:~
  : Returns the URI prefixes covered by a UGRAPH endpoint.
  :)
declare function f:get-ugraph-uri-prefixes($endpoint as xs:string, $options as map(*)?)
        as xs:string? {
    let $query := ``[
PREFIX fs: <http://www.foxpath.org/ns/rdf/filesystem/> 

SELECT ?navURI
WHERE
{
    ?dir a fs:dir .
    FILTER NOT EXISTS {?dir fs:parentDir ?pdir}
    ?dir fs:navURI ?navURI .    
}]``
    let $response := f:sparql2strings($query, $endpoint, ())
    return
        $response ! xs:string(.)
};

