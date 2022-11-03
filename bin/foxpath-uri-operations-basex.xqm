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
 : Returns true if a resource exists.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return true if the resource exists and is a file
 :)
 declare function f:fox-file-exists_basex($uri as xs:string, $options as map(*)?)
        as xs:boolean? {    
    let $useUri := substring($uri, 9)
    let $dbPath := f:basex_uri_2_db_path($uri, $options)
    let $crit := db:list($dbPath[1], $dbPath[2])
    return
        count($crit) ge 1
};

(:~
 : Returns true if a resource is a file, rather than a directory.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return true if the resource exists and is a file
 :)
 declare function f:fox-is-file_basex($uri as xs:string, $options as map(*)?)
        as xs:boolean? {    
    let $useUri := substring($uri, 9)
    let $dbPath := f:basex_uri_2_db_path($uri, $options)
    let $crit := db:list($dbPath[1], $dbPath[2])
    return
        if (count($crit) eq 1) then $crit eq $dbPath[2]
        else if (count($crit) gt 1) then false()
        else ()
};

(:~
 : Returns true if a resource is a directory, rather than a file.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return true if the resource exists and is a file
 :)
 declare function f:fox-is-dir_basex($uri as xs:string, $options as map(*)?)
        as xs:boolean? {    
    let $useUri := substring($uri, 9)
    let $dbPath := f:basex_uri_2_db_path($uri, $options)
    let $crit := db:list($dbPath[1], $dbPath[2])
    return
        if (count($crit) eq 1) then $crit ne $dbPath[2]
        else if (count($crit) gt 1) then true()
        else ()
};

(:~
 : Returns the size of a resource.
 :
 : @param uri the URI or file path
 : @param options options controlling the evaluation
 : @return the size of the resource as number of bytes
 :)
 declare function f:fox-file-size_basex($uri as xs:string, $options as map(*)?)
        as xs:integer? {
    let $useUri := substring($uri, 9)
    let $dbPath := f:basex_uri_2_db_path($uri, $options)
    let $crit := db:list-details($dbPath[1], $dbPath[2])
    return
        if (count($crit) eq 1 and $crit[1] eq $dbPath[2]) then 
            $crit/@size/xs:integer(.)
        else ()
};

(:~
 : Returns the last modification date of a resource.
 :
 : @param uri the URI or file path
 : @param options options controlling the evaluation
 : @return the size of the resource as number of bytes
 :)
 declare function f:fox-file-date_basex($uri as xs:string, $options as map(*)?)
        as xs:dateTime? {
    let $useUri := substring($uri, 9)
    let $dbPath := f:basex_uri_2_db_path($uri, $options)
    let $crit := db:list-details($dbPath[1], $dbPath[2])
    let $max := $crit/@modified-date/string() => max()
    return
        $max ! xs:dateTime(.)
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
declare function f:fox-doc_basex($uri as xs:string, $options as map(*)?)
        as document-node()? {
    let $useUri := substring($uri, 9)
    return
        if (not(doc-available($useUri))) then () else doc($useUri) 
};

(:~
 : Returns an XML document identified by URI or file path.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return the document, or the empty sequence if retrieval or parsing fails
 :)
declare function f:fox-doc-available_basex($uri as xs:string, $options as map(*)?)
        as xs:boolean? {
    let $useUri := substring($uri, 9)
    let $raw := doc-available($useUri)
    return
        if ($raw eq false()) then $raw
        else
            (: check that $uri locates a document, not a folder containing a document :)
            let $dbPath := f:basex_uri_2_db_path($uri, $options)
            let $crit := db:list($dbPath[1], $dbPath[2])
            return
                $crit eq $dbPath[2]            
};

(:~
 : Returns the string representation of a resource.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return the document, or the empty sequence if retrieval or parsing fails
 :)
declare function f:fox-unparsed-text_basex($uri as xs:string, 
                                           $encoding as xs:string?,
                                           $options as map(*)?)
        as xs:string? {
    let $doc := f:fox-doc_basex($uri, $options)
    return
        $doc ! serialize(.)
};

(:~
 : Returns the lines of the string representation of a resource.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return the document, or the empty sequence if retrieval or parsing fails
 :)
declare function f:fox-unparsed-text-lines_basex($uri as xs:string, 
                                                 $encoding as xs:string?,
                                                 $options as map(*)?)
        as xs:string* {
    let $doc := f:fox-doc_basex($uri, $options)
    return
        $doc ! serialize(.) ! tokenize(., '&#xD;?&#xA;')
};

(: 
 : ===============================================================================
 :
 :     r e s o u r c e    t r e e    n a v i g a t i o n 
 :
 : ===============================================================================
 :)

(:~
 : Returns the child URIs of a given basex URI, matching an optional name pattern
 : and matching an optional kind test (file or folder).
 :
 : Note. The kind test is currently received via a `stepDescriptor` element.
 : This approach is meant to be extensible, allowing the future addition of 
 : other filters 
 :)
declare function f:childUriCollection_basex($uri as xs:string, 
                                            $name as xs:string?,
                                            $stepDescriptor as element()?,
                                            $options as map(*)?) { 
    let $kindFilter := $stepDescriptor/@kindFilter                                            
    let $pattern :=
        if (not($name)) then () else 
            concat('^', replace(replace($name, '\*', '.*'), '\?', '.'), '$')
    let $dbPath := f:basex_uri_2_db_path($uri, $options)  
    let $children :=
        (: no db => list data bases :)
        if (not($dbPath[1])) then db:list()[not($kindFilter eq 'file')]
        else (       
        
            (: $completePaths - paths within the database 
                                (a name, optionally preceded by steps) :)
            let $completePaths := db:list($dbPath[1], $dbPath[2])
            (: $relPaths - paths relative to the input URI :)
            let $relPaths := 
                if (not($dbPath[2])) then $completePaths else 
                    $completePaths ! substring(., 2 + string-length($dbPath[2]))
            let $fileChildren := $relPaths[not(contains(., '/'))]
            return (
                if ($kindFilter eq 'file') then $fileChildren
                else 
                    let $folderChildren := $relPaths[contains(., '/')] ! replace(., '/.*', '') 
                    return
                        if ($kindFilter eq 'dir') then $folderChildren
                        else ($fileChildren, $folderChildren)
            ) [string()]
        ) => distinct-values()
    let $matchName :=
        if (not($pattern)) then $children else
            $children[matches(replace(replace(., '/$', ''), '.*/', ''), $pattern, 'i')]
    return
        $matchName
};

(:~
 : Returns the child URIs of a given basex URI, matching an optional name pattern
 : and matching an optional kind test (file or folder).
 :
 : Note. The kind test is currently received via a `stepDescriptor` element.
 : This approach is meant to be extensible, allowing the future addition of 
 : other filters 
 :)
declare function f:descendantUriCollection_basex($uri as xs:string, 
                                                 $name as xs:string?,
                                                 $stepDescriptor as element()?,
                                                 $options as map(*)?) {      
    let $kindFilter := $stepDescriptor/@kindFilter                                                 
    let $pattern :=
        if (not($name)) then () else 
            concat('^', replace(replace($name, '\*', '.*'), '\?', '.'), '$')
    let $dbPath := f:basex_uri_2_db_path($uri, $options) 
    
    (: $completePaths - paths within the database 
                        (a name, optionally preceded by steps) :)
    let $completePaths := db:list($dbPath[1], $dbPath[2])
    (: $relPaths - paths relative to the input URI :)    
    let $relPaths := if (not($dbPath[2])) then $completePaths else 
        $completePaths ! substring(., 2 + string-length($dbPath[2]))
        
    let $files := distinct-values($relPaths) (: db:list yields only files ! :)
    let $matchKind :=
        if ($kindFilter eq 'file') then $files
        else
            (: folders - all path prefixes of all files :)
            let $folders := distinct-values(
                for $resource in $files
                let $steps := tokenize($resource, '/')[position() lt last()]
                for $length in 1 to count($steps)
                return
                    $steps[position() le $length] => string-join('/')
(:                  hjr, 20201015: bugfix, copied from foxpath-uri-operations-archive.xqm - 
                                   deliver *all* paths (consisting of 1, 2, ... steps) :)                
            )
            return
                if ($kindFilter eq 'dir') then $folders
                else ($files, $folders)
    let $matchName :=
        if ($pattern) then $matchKind[matches(replace(replace(., '/$', ''), '.*/', ''), $pattern, 'i')]
        else $matchKind
    return
        $matchName ! replace(., '/$', '')
};

(: 
 : ===============================================================================
 :
 :     b a s e x    u t i l i t i e s 
 :
 : ===============================================================================
 :)
 (:~
  : Parses a basex URI and returns two items - the name of the data base and
  : the path within the data base.
  :
  : @param uri the URI to be parsed
  : @param options options controlling the parsing and evaluation of a FOXpath expression
  :)
 declare function f:basex_uri_2_db_path($uri as xs:string, $options as map(*)?)
        as xs:string+ {    
    let $useUri := substring($uri, 9)
    let $db := 
        if (not($useUri)) then ''
        else replace($useUri, '^(.*?)/.*', '$1')   (: substring preceding first slash :)
    let $path := 
        if (not(contains($useUri, '/'))) then ''
        else replace($useUri, '^.*?/(.*)', '$1')   (: substring following first slash :)
    return
        ($db, $path)
};

(:~
 : Returns true if a given node belongs to a BaseX database
 :)
declare function f:isDbNode($node as node())
        as xs:boolean {
    try {db:name($node) ! db:exists(.)} catch * {false()}        
};

