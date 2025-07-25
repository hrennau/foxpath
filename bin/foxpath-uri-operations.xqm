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
  fox-file-exists
  fox-doc
  fox-doc-available  
  fox-unparsed-text
  fox-unparsed-text-lines
  
:)
module namespace f="http://www.ttools.org/xquery-functions";
import module namespace i="http://www.ttools.org/xquery-functions" 
at  "foxpath-processorDependent.xqm",
    "foxpath-uri-operations-basex.xqm",
    "foxpath-uri-operations-github.xqm",    
    "foxpath-uri-operations-svn.xqm",    
    "foxpath-uri-operations-rdf.xqm",    
    "foxpath-uri-operations-utree.xqm",    
    "foxpath-uri-operations-archive.xqm";
import module namespace foxf="http://www.foxpath.org/ns/fox-functions"
at  "foxpath-fox-functions.xqm";

import module namespace util="http://www.ttools.org/xquery-functions/util" 
at  "foxpath-util.xqm";

import module namespace is="http://www.foxpath.org/ns/ispace"
    at "foxpath-ispace.xqm";
    
declare namespace ixml="http://invisiblexml.org/NS";
declare variable $f:OLD_FOX_DOC := false();
declare variable $f:UNAME external := 'hrennau';
declare variable $f:githubTokenLocation external := 'github-token-location';   
   (: text file containing the location of a file containing the github token :)
declare variable $f:TOKEN external := 
    try {
        let $lines := unparsed-text-lines($f:githubTokenLocation) ! normalize-space(.)
        return
            $lines[not(starts-with(., '#'))][1]
            ! unparsed-text(.) 
            ! normalize-space(.)        
    } catch * {()};
(:    
        if (not($f:githubTokenLocation)) then () else
            error(QName((), 'INVALID_TOKEN_LOCATION'), concat(
                'Cannot retrieve token from here: ', $f:githubTokenLocation))};
:)                
(: 
 : ===============================================================================
 :
 :     r e s o u r c e    p r o p e r t i e s
 :
 : ===============================================================================
 :)

(:~
 : Returns the domain of an URI. This is one of these:
 :    FILE_SYSTEM
 :    ARCHIVE
 :    BASEX
 :    HTTP
 :    HTTPS
 :    SVN
 :    RDF
 :    GITHUB
 :    UTREE
 :    RAW
 :
 : @param uri the URI
 : @param options options controlling the evaluation
 : @return the domain
 :)
declare function f:uriDomain($uri as xs:string, $options as map(*)?)
        as xs:string {
    let $uri_ := $uri || '/' return
    
(:    
    else if (starts-with($uri,
    'https://svn.alfresco.com/repos/' ||
    'alfresco-open-mirror/alfresco/COMMUNITYTAGS/5.1.a/root/projects/3rd-party/greenmail/source/java/com/'))
    then 'RDF'
:)    
    if (tokenize(replace($uri, '^(//[^/]+:/+).*', ''), '/') = $util:ARCHIVE_TOKEN) 
        then 'ARCHIVE'
    else if (starts-with($uri, 'https://svn.alfresco.com/repos/')) 
        then 'RDF'
    else if ($options ! 
            ($options?URI_TREES_PREFIXES, $options?URI_TREES_BASE_URIS)
            [starts-with($uri_, .)])
        then 'UTREE'        
    else if ($options ! 
            $options?UGRAPH_URI_PREFIXES
            [starts-with($uri_, .)])
        then 'RDF'
    else if (starts-with($uri, 'basex://')) then 'BASEX'    
    else if (starts-with($uri, 'svn-')) then 'SVN'
    else if (starts-with($uri, 'rdf-')) then 'RDF'    
    else if (starts-with($uri, 'https://api.github.com/repos/')) then 'GITHUB'
    else if (starts-with($uri, 'https')) then 'HTTPS'    
    else if (starts-with($uri, 'http')) then 'HTTP'    
    else if (starts-with($uri, 'literal-')) then 'RAW'
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
        f:fox-is-file_svn($uri, $options)
    else if ($uriDomain eq 'RDF') then        
        f:fox-is-file_rdf($uri, $options)
    else if ($uriDomain eq 'UTREE') then        
        f:fox-is-file_utree($uri, $options)
    else if ($uriDomain eq 'ARCHIVE') then
        let $archiveURIAndPath := f:parseArchiveURI($uri, $options)
        let $archiveURI := $archiveURIAndPath[1]
        let $archivePath := $archiveURIAndPath[2]
        let $archive := f:fox-binary($archiveURI, $options)
        return
            if (empty($archive)) then false()
            else
                f:fox-is-file_archive($archive, $archivePath, $options)
        
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
        f:fox-is-dir_svn($uri, $options)
    else if ($uriDomain eq 'RDF') then 
        f:fox-is-dir_rdf($uri, $options)
    else if ($uriDomain eq 'UTREE') then 
        f:fox-is-dir_utree($uri, $options)
    else if ($uriDomain eq 'ARCHIVE') then
        let $archiveURIAndPath := f:parseArchiveURI($uri, $options)
        let $archiveURI := $archiveURIAndPath[1]
        let $archivePath := $archiveURIAndPath[2]
        let $archive := f:fox-binary($archiveURI, $options)
        return
            if (empty($archive)) then false()
            else
                f:fox-is-dir_archive($archive, $archivePath, $options)
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
 : Returns the size in bytes of a resource.
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
    else if ($uriDomain eq 'SVN') then
        f:fox-file-size_svn($uri, $options)
    else if ($uriDomain eq 'RDF') then
        f:fox-file-size_rdf($uri, $options)
    else if ($uriDomain eq 'UTREE') then
        f:fox-file-size_utree($uri, $options)
    else if ($uriDomain eq 'ARCHIVE') then
        let $archiveURIAndPath := f:parseArchiveURI($uri, $options)
        let $archiveURI := $archiveURIAndPath[1]
        let $archivePath := $archiveURIAndPath[2]
        let $archive := f:fox-binary($archiveURI, $options)
        return
            if (empty($archive)) then ()
            else
                f:fox-file-size_archive($archive, $archivePath, $options)
    else if (empty($options)) then ()
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
 : Returns the last modification time of a resource.
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
    else if ($uriDomain eq 'SVN') then 
        f:fox-file-date_svn($uri, $options)
    else if ($uriDomain eq 'RDF') then 
        f:fox-file-date_rdf($uri, $options)
    else if ($uriDomain eq 'UTREE') then 
        f:fox-file-date_utree($uri, $options)
    else if ($uriDomain eq 'ARCHIVE') then
        let $archiveURIAndPath := f:parseArchiveURI($uri, $options)
        let $archiveURI := $archiveURIAndPath[1]
        let $archivePath := $archiveURIAndPath[2]
        let $archive := f:fox-binary($archiveURI, $options)
        return
            if (empty($archive)) then ()
            else
                f:fox-file-date_archive($archive, $archivePath, $options)
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

(:~
 : Returns the last modification date of a resource as a string.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return the last update date of the resource
 :)
 declare function f:fox-base-uri($node as node())
        as xs:string? {  
    let $buri := $node/base-uri(.)
    return
        if (i:isDbNode($node)) then 'basex://'||$buri else $buri
};

(: 
 : ===============================================================================
 :
 :     r e s o u r c e    r e t r i e v a l
 :
 : ===============================================================================
 :)

(:     r t y p e :    x m l     :)

(:~
 : Returns an XML document identified by URI or file path.
 :
 : @param uri the URI or file path of the resource
 : @return the document, or the empty sequence if retrieval or parsing fails
 :)
declare function f:fox-xml-doc($uri as xs:string)
        as document-node()? {
    f:fox-xml-doc($uri, ())
};    

(:~
 : Returns an XML document identified by URI or file path.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return the document, or the empty sequence if retrieval or parsing fails
 :)
declare function f:fox-xml-doc($uri as xs:string, $options as map(*)?)
        as document-node()? {
    let $uriDomain := f:uriDomain($uri, $options)
    return switch($uriDomain)
    
    case 'BASEX' return f:fox-doc_basex($uri, $options)
    case 'SVN' return f:fox-doc_svn($uri, $options)
    case 'RDF' return
        f:fox-get-access-uri_rdf($uri, $options) ! f:fox-doc(., $options)
    case 'UTREE' return
        f:fox-get-access-uri_utree($uri, $options) ! f:fox-doc(., $options)
    case 'GITHUB' return f:fox-doc_github($uri, $options)
    case 'ARCHIVE' return f:fox-doc_archive($uri, $options)
    default return doc($uri)
};

(:     r t y p e :    j s o n     :)

(:~
 : Returns an XML representation of the JSON record identified by URI or file path.
 :
 : @param uri the URI or file path of the resource
 : @return an XML document representing JSON data, or the empty sequence if 
 :     retrieval or parsing fails
 :)
declare function f:fox-json-doc($uri as xs:string)
        as document-node()? {
    f:fox-json-doc($uri, ())
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
    return switch($uriDomain)

    case 'REDIRECTING_URI_TREE' return  
        f:fox-navURI-to-text_github($uri, (), $options) 
        ! (try {json:parse(.)} catch * {})  
    case 'RDF' return        
        f:fox-get-access-uri_rdf($uri, $options) ! f:fox-json-doc(., $options)       
    case 'UTREE' return
        f:fox-get-access-uri_utree($uri, $options) ! f:fox-json-doc(., $options)
    case 'GITHUB' return f:fox-json-doc_github($uri, $options)
    case 'ARCHIVE' return f:fox-json-doc_archive($uri, (), $options)
    default return try {json:doc($uri)} catch * {} 
};

(:     r t y p e :    h t m l     :)

(:~
 : Returns an XML representation of the HTML record identified by URI or file path.
 :
 : @param uri the URI or file path of the resource
 : @return an XML document representing HTML data, or the empty sequence if 
 :     retrieval or parsing fails
 :)
 declare function f:fox-html-doc($uri as xs:string)
        as document-node()? {
    f:fox-html-doc($uri, ())
};    

(:~
 : Returns an XML representation of the HTML record identified by URI or file path.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return an XML document representing HTML data, or the empty sequence if 
 :     retrieval or parsing fails
 :)
declare function f:fox-html-doc($uri as xs:string,
                                $options as map(xs:string, item()*)?)
        as document-node()? {
    let $options := ()        
    let $uriDomain := f:uriDomain($uri, $options)
    return switch($uriDomain)

    case 'REDIRECTING_URI_TREE' return  
        f:fox-navURI-to-text_github($uri, (), $options) 
        ! (try {html:parse(.)} catch * {()})  
    case 'RDF' return        
        f:fox-get-access-uri_rdf($uri, $options) ! f:fox-html-doc(., $options)       
    case 'UTREE' return
        f:fox-get-access-uri_utree($uri, $options) ! f:fox-html-doc(.)
    case 'GITHUB' return f:fox-html-doc_github($uri, $options)
    case 'ARCHIVE' return f:fox-html-doc_archive($uri, (), $options)
    default return 
        let $hdoc := function-lookup(QName('http://basex.org/modules/html', 'doc'), 1)
        return
            try {
                if (exists($hdoc)) then $hdoc($uri) else
                    unparsed-text($uri) ! html:parse(.)
            } catch * {()}        
};

(:~
 : Returns true if a resource exists.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return true if the resource exists
 :)
 declare function f:fox-file-exists($uri as xs:string?, $options as map(*)?)
        as xs:boolean? {
    if (not($uri)) then false() else
    
    let $uriDomain := f:uriDomain($uri, $options)
    return
    
    if ($uriDomain eq 'FILE_SYSTEM') then file:exists($uri)
    else if ($uriDomain eq 'BASEX') then f:fox-file-exists_basex($uri, $options)   
    else if ($uriDomain eq 'SVN') then f:fox-file-exists_svn($uri, $options)
    else if ($uriDomain eq 'RDF') then f:fox-file-exists_rdf($uri, $options)
    else if ($uriDomain eq 'ARCHIVE') then
        let $archiveURIAndPath := f:parseArchiveURI($uri, $options)
        let $archiveURI := $archiveURIAndPath[1]
        let $archivePath := $archiveURIAndPath[2]
        return
            if (not($archivePath)) then true()   (: Archive root folder :)
            else
                let $archive := f:fox-binary($archiveURI, $options)
                return
                    if (empty($archive)) then false()
                    else
                        f:fox-file-exists_archive($archive, $archivePath, $options)       
    else 
        true()
};

(:~
 : Returns a string representation of a resource.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return the text of the resource, or the empty sequence if retrieval fails
 :)
declare function f:fox-unparsed-text($uri as xs:string)
        as xs:string? {
    f:fox-unparsed-text($uri, (), ())
};    

(:~
 : Returns a string representation of a resource.
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
    return switch($uriDomain)
    
    case 'REDIRECTING_URI_TREE' return f:fox-navURI-to-text_github($uri, $encoding, $options)    
    case 'BASEX' return f:fox-unparsed-text_basex($uri, $encoding, $options)
    case 'SVN' return f:fox-unparsed-text_svn($uri, $encoding, $options)
    case 'RDF' return        
        f:fox-get-access-uri_rdf($uri, $options) ! f:fox-unparsed-text(., $encoding, $options)        
    case 'UTREE' return
        f:fox-get-access-uri_utree($uri, $options) ! f:fox-unparsed-text(., $encoding, $options)
    case 'GITHUB' return f:fox-unparsed-text_github($uri, $encoding, $options)        
    case 'ARCHIVE' return f:fox-unparsed-text_archive($uri, $encoding, $options)
    default return 
        let $uri := if (starts-with($uri, 'literal-')) then substring($uri, 9) else $uri 
        return
            try {
                if ($encoding) then unparsed-text($uri, $encoding)
                else unparsed-text($uri)
            } catch * {()}
};

(:~
 : Returns a document created by iXML.
 :
 : @param uri the URI or file path of the resource
 : @param grammar the URI of the iXML grammar 
 : @param options options controlling the evaluation
 : @return an XML document representing JSON data, or the empty sequence if 
 :     retrieval or parsing fails
 :)
declare function f:fox-ixml-doc($uri as xs:string,
                                $grammar as xs:string,
                                $options as map(*)?)
        as document-node()? {
    $uri ! f:fox-unparsed-text(.) ! f:fox-ixml-parse(., $grammar, $options)
};

(:~
 : Returns a document created by iXML.
 :
 : @param uri the URI or file path of the resource
 : @param grammar the URI of the iXML grammar 
 : @param options options controlling the evaluation
 : @return an XML document representing JSON data, or the empty sequence if 
 :     retrieval or parsing fails
 :)
declare function f:fox-ixml-parse($text as xs:string,
                                  $grammar as xs:string,
                                  $options as map(*)?)
        as document-node()? {
    let $grammarUri :=
        if (starts-with($grammar, '#')) then 
            $options?ISPACE//grammars/grammar[@name eq substring($grammar, 2)]/@uri 
        else $grammar
    let $grammarText := $grammarUri ! f:fox-unparsed-text(.)            
    let $fnParse := $grammarText ! invisible-xml(.)
    return $text ! $fnParse(.)
};

(:~
 : Returns true/false if a text can be / cannot be parsed by iXML.
 :
 : @param uri the URI or file path of the resource
 : @param grammar the URI of the iXML grammar 
 : @param options options controlling the evaluation
 : @return an XML document representing JSON data, or the empty sequence if 
 :     retrieval or parsing fails
 :)
declare function f:fox-ixml-valid($text as xs:string,
                                  $grammar as xs:string,
                                  $options as map(*)?)
        as xs:boolean {
    let $grammarText := $grammar ! f:fox-unparsed-text(.)            
    let $fnParse := $grammarText ! invisible-xml(.)
    let $parsed := try {$text ! $fnParse(.)} catch * {()}
    return if ($parsed instance of node()) 
           then not($parsed/*/@ixml:state eq 'failed')
           else false()
};

(:~
 : Returns an XML document identified by URI or file path.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return the document, or the empty sequence if retrieval or parsing fails
 :)
declare function f:fox-doc($uri as xs:string, $options as map(*))
        as document-node()? {
    if ($f:OLD_FOX_DOC) then f:fox-doc_old($uri, $options) else
    $options?ISPACE ! is:doc($uri, ., $options)
};

declare function f:fox-doc_old($uri as xs:string, $options as map(*)?)
        as document-node()? {
    let $uriDomain := f:uriDomain($uri, $options)
    return

    if ($uriDomain eq 'BASEX') then 
        f:fox-doc_basex($uri, $options)
    else if ($uriDomain eq 'SVN') then 
        f:fox-doc_svn($uri, $options)
    else if ($uriDomain eq 'RDF') then
        let $accessURI := f:fox-get-access-uri_rdf($uri, $options)
        return $accessURI ! f:fox-doc(., $options)
    else if ($uriDomain eq 'UTREE') then
        let $accessURI := f:fox-get-access-uri_utree($uri, $options)
        return $accessURI ! f:fox-doc(., $options)
    else if ($uriDomain eq 'GITHUB') then
        f:fox-doc_github($uri, $options)
    else if ($uriDomain eq 'ARCHIVE') then
        let $archiveURIAndPath := f:parseArchiveURI($uri, $options)
        let $archiveURI := $archiveURIAndPath[1]
        let $archivePath := $archiveURIAndPath[2]
        let $archive := f:fox-binary($archiveURI, $options)
        return
            if (empty($archive)) then ()
            else f:fox-doc_archive($uri, $archive, $archivePath, $options)
    else if (doc-available($uri)) then doc($uri)
    (: If not parsable as XML, try JSON :)
    else if (unparsed-text-available($uri)) then try {json:doc($uri)} catch * {()}
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
    else if ($uriDomain eq 'SVN') then 
        f:fox-doc-available_svn($uri, $options)
    else if ($uriDomain eq 'RDF') then        
        let $accessURI := f:fox-get-access-uri_rdf($uri, $options)
        return $accessURI ! f:fox-doc-available(., $options)
    else if ($uriDomain eq 'UTREE') then
        let $accessURI := f:fox-get-access-uri_utree($uri, $options)
        return $accessURI ! f:fox-doc-available(., $options)
    else if ($uriDomain eq 'GITHUB') then
        f:fox-doc-available_github($uri, $options)
    else if ($uriDomain eq 'ARCHIVE') then f:fox-doc-available_archive($uri, $options)
(:                
    else if ($uriDomain eq 'REDIRECTING_URI_TREE') then 
        let $text := f:fox-navURI-to-text_github($uri, (), $options)
        return
            exists(try {parse-xml($text)} catch * {()})
:)            
    else doc-available($uri)
};

(:~
 : Returns an XML representation of the CSS record identified by URI or file path.
 :
 : @param uri the URI or file path of the resource
 : @param options currently not evaluated
 : @return an XML document representing the CSS repord
 :)
declare function f:fox-css-doc($uri as xs:string,
                               $options as map(*)?)
        as document-node()? {
    let $text := f:fox-unparsed-text($uri, (), $options)
    return try {document{foxf:cssParse($text, ())}} catch * {}
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
        f:fox-navURI-to-text_github($uri, $encoding, $options) ! tokenize(., '&#xA;&#xD;?')
    else if ($uriDomain eq 'BASEX') then
        f:fox-unparsed-text-lines_basex($uri, $encoding, $options)
    else if ($uriDomain eq 'SVN') then
        f:fox-unparsed-text-lines_svn($uri, $encoding, $options)
    else if ($uriDomain eq 'RDF') then        
        let $accessURI := f:fox-get-access-uri_rdf($uri, $options)
        return $accessURI ! f:fox-unparsed-text-lines(., $encoding, $options) 
    else if ($uriDomain eq 'UTREE') then
        let $accessURI := f:fox-get-access-uri_utree($uri, $options)
        return $accessURI ! f:fox-unparsed-text-lines(., $encoding, $options)
    else if ($uriDomain eq 'GITHUB') then
        f:fox-unparsed-text-lines_github($uri, $encoding, $options)    
    else if ($uriDomain eq 'ARCHIVE') then
            let $archiveURIAndPath := f:parseArchiveURI($uri, $options)
            let $archiveURI := $archiveURIAndPath[1]
            let $archivePath := $archiveURIAndPath[2]
            let $archive := f:fox-binary($archiveURI, $options)
            return
                if (empty($archive)) then ()
                else
                    f:fox-unparsed-text-lines_archive($archive, $archivePath, $encoding, $options)
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
 : Returns an XML representation of the CSV record identified by URI or file path.
 :
 : @param uri the URI or file path of the resource
 : @param separator the separator character (or token `comma` or token `semicolon`)
 : @param withHeader if 'yes', the first row contains column headers
 : @param names if 'direct', column names are used as element names;
 :              if 'attributes', column names are provided by @name
 : @param quotes if 'yes', quotes at start and end of field are treated as control characters
 : @param options options controlling the evaluation
 : @return an XML document representing JSON data, or the empty sequence if 
 :     retrieval or parsing fails
 :)
declare function f:fox-csv-doc2($uri as xs:string,
                                $csvOptions as map(*)?)
        as document-node()? {
    let $options := ()        
    let $uriDomain := f:uriDomain($uri, $options)
    let $separator := ($csvOptions?separator, ',')[1]
    let $withHeader := ($csvOptions?header, 'no')[1]
    let $names := ($csvOptions?names, 'no')[1]
    let $quotes := ($csvOptions?quotes, 'yes')[1]
    let $backslashes := ($csvOptions?backslashes, 'no')[1]
    return switch($uriDomain)

    case 'REDIRECTING_URI_TREE' return 
        let $text := f:fox-navURI-to-text_github($uri, (), $options)
        return
            try {$text ! csv:parse(., $csvOptions)} catch * {()}  
    case 'RDF' return        
        let $accessURI := f:fox-get-access-uri_rdf($uri, $options)
        return $accessURI ! f:fox-csv-doc(., $separator, $withHeader, $names, $quotes, $backslashes, $options)       
    case 'UTREE' return
        let $accessURI := f:fox-get-access-uri_utree($uri, $options)
        return $accessURI ! f:fox-csv-doc(., $separator, $withHeader, $names, $quotes, $backslashes, $options)
    case 'GITHUB' return
        error(QName((), 'NOT_YET_IMPLEMENTED'), 'Not yet implemented: csv@github') (: f:fox-json-doc_github($uri, $options) :)
    case 'ARCHIVE' return
            let $archiveURIAndPath := f:parseArchiveURI($uri, $options)
            let $archiveURI := $archiveURIAndPath[1]
            let $archivePath := $archiveURIAndPath[2]
            let $archive := f:fox-binary($archiveURI, $options)
            return
                if (empty($archive)) then ()
                else
                    f:fox-csv-doc_archive($archive, $archivePath, (), $csvOptions, $options)        
    default return 
        let $cdoc := function-lookup(QName('http://basex.org/modules/csv', 'doc'), 2)
        return
            try {
                if (exists($cdoc)) then (:$cdoc:) csv:doc($uri, $csvOptions) 
                else unparsed-text($uri) ! csv:parse(., $csvOptions)
            } catch * {()}        
};

(:~
 : Returns an XML representation of the CSV record identified by URI or file path.
 :
 : @param uri the URI or file path of the resource
 : @param separator the separator character (or token `comma` or token `semicolon`)
 : @param withHeader if 'yes', the first row contains column headers
 : @return an XML document representing JSON data, or the empty sequence if 
 :     retrieval or parsing fails
 :)
declare function f:fox-csv-doc($uri as xs:string,
                               $options as map(*)?)
        as document-node()? {
    f:fox-csv-doc($uri, 'comma', 'no', 'direct', 'yes', 'no', $options)        
};

(:~
 : Returns an XML representation of the CSV record identified by URI or file path.
 :
 : @param uri the URI or file path of the resource
 : @param separator the separator character (or token `comma` or token `semicolon`)
 : @param withHeader if 'yes', the first row contains column headers
 : @return an XML document representing JSON data, or the empty sequence if 
 :     retrieval or parsing fails
 :)
declare function f:fox-csv-doc($uri as xs:string,
                               $separator as xs:string,
                               $options as map(*)?)
        as document-node()? {
    f:fox-csv-doc($uri, $separator, 'no', 'direct', 'yes', 'no', $options)        
};

(:~
 : Returns an XML representation of the CSV record identified by URI or file path.
 :
 : @param uri the URI or file path of the resource
 : @param separator the separator character (or token `comma` or token `semicolon`)
 : @param withHeader if 'yes', the first row contains column headers
 : @return an XML document representing JSON data, or the empty sequence if 
 :     retrieval or parsing fails
 :)
declare function f:fox-csv-doc($uri as xs:string,
                               $separator as xs:string,
                               $withHeader as xs:string,
                               $options as map(*)?)
        as document-node()? {
    f:fox-csv-doc($uri, $separator, $withHeader, 'direct', 'yes', 'no', $options)        
};

(:~
 : Returns an XML representation of the CSV record identified by URI or file path.
 :
 : @param uri the URI or file path of the resource
 : @param separator the separator character (or token `comma` or token `semicolon`)
 : @param withHeader if 'yes', the first row contains column headers
 : @param names if 'direct', column names are used as element names;
 :              if 'attributes', column names are provided by @name
 : @param options options controlling the evaluation
 : @return an XML document representing JSON data, or the empty sequence if 
 :     retrieval or parsing fails
 :)
declare function f:fox-csv-doc($uri as xs:string,
                               $separator as xs:string,
                               $withHeader as xs:string,
                               $names as xs:string,
                               $options as map(*)?)
        as document-node()? {
    f:fox-csv-doc($uri, $separator, $withHeader, $names, 'yes', 'no', $options)        
};
(:~
 : Returns an XML representation of the CSV record identified by URI or file path.
 :
 : @param uri the URI or file path of the resource
 : @param separator the separator character (or token `comma` or token `semicolon`)
 : @param withHeader if 'yes', the first row contains column headers
 : @param names if 'direct', column names are used as element names;
 :              if 'attributes', column names are provided by @name
 : @param quotes if 'yes', quotes at start and end of field are treated as control characters
 : @param options options controlling the evaluation
 : @return an XML document representing JSON data, or the empty sequence if 
 :     retrieval or parsing fails
 :)
declare function f:fox-csv-doc($uri as xs:string,
                               $separator as xs:string,
                               $withHeader as xs:string,
                               $names as xs:string,
                               $quotes as xs:string,
                               $backslashes as xs:string,
                               $options as map(*)?)
        as document-node()? {
    let $uriDomain := f:uriDomain($uri, $options)
    
    let $csvOptions := map{
        'separator': $separator,
        'header': $withHeader,
        'format': $names,
        'quotes': $quotes,
        'backslashes': $backslashes
    }
    return

    if ($uriDomain eq 'REDIRECTING_URI_TREE') then 
        let $text := f:fox-navURI-to-text_github($uri, (), $options)
        return
            try {$text ! csv:parse(., $csvOptions)} catch * {()}  
    else if ($uriDomain eq 'RDF') then        
        let $accessURI := f:fox-get-access-uri_rdf($uri, $options)
        return $accessURI ! f:fox-csv-doc(., $separator, $withHeader, $names, $quotes, $backslashes, $options)       
    else if ($uriDomain eq 'UTREE') then
        let $accessURI := f:fox-get-access-uri_utree($uri, $options)
        return $accessURI ! f:fox-csv-doc(., $separator, $withHeader, $names, $quotes, $backslashes, $options)
    else if ($uriDomain eq 'GITHUB') then
        error(QName((), 'NOT_YET_IMPLEMENTED'), 'Not yet implemented: csv@github') (: f:fox-json-doc_github($uri, $options) :)
    else if ($uriDomain eq 'ARCHIVE') then
            let $archiveURIAndPath := f:parseArchiveURI($uri, $options)
            let $archiveURI := $archiveURIAndPath[1]
            let $archivePath := $archiveURIAndPath[2]
            let $archive := f:fox-binary($archiveURI, $options)
            return
                if (empty($archive)) then ()
                else
                    f:fox-csv-doc_archive($archive, $archivePath, (), $csvOptions, $options)        
    else 
        let $cdoc := function-lookup(QName('http://basex.org/modules/csv', 'doc'), 2)
        return
            try {
                if (exists($cdoc)) then $cdoc($uri, $csvOptions) else
                    unparsed-text($uri) ! csv:parse(., $csvOptions)
            } catch * {()}        
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
        as xs:boolean {
    let $uriDomain := f:uriDomain($uri, $options)
    return

    if ($uriDomain eq 'REDIRECTING_URI_TREE') then 
        let $text := f:fox-navURI-to-text_github($uri, (), $options)
        return
            try {exists($text ! json:parse(.))} catch * {()}        
    else if ($uriDomain eq 'RDF') then        
        let $accessURI := f:fox-get-access-uri_rdf($uri, $options)
        return $accessURI ! f:fox-json-doc-available(., $options)  
    else if ($uriDomain eq 'UTREE') then
        let $accessURI := f:fox-get-access-uri_utree($uri, $options)
        return $accessURI ! f:fox-json-doc-available(., $options)
    else if ($uriDomain eq 'GITHUB') then
        f:fox-json-doc-available_github($uri, $options)
    else 
        try {exists(unparsed-text($uri) ! json:parse(.))} catch * {false()}
};

(:~
 : Returns the content of a file as the Base64 representation of its bytes.
 :
 : @param uri the navigation URI of the file
 : @param options options controlling the evaluation
 : @return the Base64 representation, if available, the empty sequence otherwise
 :)
declare function f:fox-binary($uri as xs:string, 
                              $options as map(*)?)
        as xs:base64Binary? {
    let $uriDomain := f:uriDomain($uri, $options)
    return
        if ($uriDomain eq 'BASEX') then
            error((), concat('Invalid call, as a BaseX database cannot contain binary files; URI=', $uri))
        else if ($uriDomain eq 'GITHUB') then
            f:fox-binary_github($uri, $options)
        else if ($uriDomain eq 'UTREE') then
            let $accessURI := f:fox-get-access-uri_utree($uri, $options)
            return $accessURI ! f:fox-binary(., $options)            
        else if ($uriDomain eq 'ARCHIVE') then
            let $archiveURIAndPath := f:parseArchiveURI($uri, $options)
            let $archiveURI := $archiveURIAndPath[1]
            let $archivePath := $archiveURIAndPath[2]
            let $archive := f:fox-binary($archiveURI, $options)
            return
                if (empty($archive)) then ()
                else
                    f:fox-binary_archive($archive, $archivePath, $options)
        else
            try {fetch:binary($uri)} catch * {()}
};

(:~
 : Returns the XML representation of a docx document.
 :
 : @param uri the URI of the .docxfile
 : @return the XML document
 :)
declare function f:docx-doc($uri as xs:string)
        as document-node()? {
    archive:extract-text(i:fox-binary($uri, ()), 'word/document.xml')   
    ! parse-xml(.)
};



(: 
 : ===============================================================================
 :
 :     r e s o u r c e    t r e e    n a v i g a t i o n 
 :
 : ===============================================================================
 :)

(:~
 : Returns a given URI, if it matches an optional regex.
 :
 : @param uri the URI to be evaluated
 : @param nameRegex an optional regex constraining the URI name
 : @return the URI, or the empty sequence if the URI does not
 :   match the regex
 :)
declare function f:selfUri($uri as xs:string, $nameRegex as xs:string?) 
        as xs:string? {
    $uri
    [not($nameRegex) or matches(replace(., '.*/', ''), $nameRegex, 'i')]
};

(:~
 : Returns the parent URI of a given URI, with a name matching the
 : optional regex.
 :
 : @param uri the URI for which the ancestors are sought
 : @param nameRegex an optional regex constraining the URI names
 : @return the parent URI, or the empty sequence if the URI does not
 :   match the regex
 :)
declare function f:parentUri($uri as xs:string, $nameRegex as xs:string?) 
        as xs:string? {
    let $raw := replace($uri, '/[^/]*$', '')[string()]
                [not($nameRegex) or matches(replace(., '.*/', ''), $nameRegex, 'i')]
    return
        if (matches($raw, '^.:$')) then concat($raw, '/') else $raw

};

(:~
 : Returns the ancestor URIs of a given URI, with a name matching the
 : optional regex. If $orSelf is true, also the given URI itself is
 : returned, provided it matches the regex. The URIs are returned
 : in reverse document order.
 :
 : @param uri the URI for which the ancestors are sought
 : @param nameRegex an optional regex constraining the URI names
 : @param orSelf if true, also the given URI itself is considered
 : @retrun the ancestor URI, or ancestor-or-self URIs, in reverese document order
 :)
declare function f:ancestorUriCollection($uri as xs:string,
                                         $nameRegex as xs:string?,
                                         $orSelf as xs:boolean?)
        as xs:string* {
    let $items := tokenize($uri, '/')
    let $root := concat(head($items), '/')  
    let $lastStepIndex := count($items) - (if ($orSelf) then 0 else 1)
    let $steps := tail($items)[position() lt $lastStepIndex]
    let $ancestorsIndices :=
        for $pos in 1 to count($steps)
        where not($nameRegex) or matches($steps[$pos], $nameRegex, 'i')
        return $pos
    let $ancestors := (
        $root[not($nameRegex ne '^.*$')], 
        (: the root folder is only considered if there is no, or a wildcard, name test :)
        for $ai in $ancestorsIndices return
            concat($root, string-join(for $index in 1 to $ai return $steps[$index], '/'))
    )
    return $ancestors                    
};

(:~
 : Returns the child URIs of a given URI, as absolute URI.
 : The input URI is expected to be an absolute URI.
 :)
declare function f:childUriCollectionAbsolute($uri as xs:string, $options as map(*)?)
        as xs:string* {
    f:childUriCollection($uri, (), (), $options) ! concat($uri, '/', .)        
};

(:~
 : Returns the child URIs of a given URI, relative to the input URI.
 : The input URI is expected to be an absolute URI.
 :)
declare function f:childUriCollection($uri as xs:string, $options as map(*)?)
        as xs:string* {
    f:childUriCollection($uri, (), (), $options)        
};

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
        if ($uriDomain eq 'UTREE') then
            f:childUriCollection_utree($uri, $name, $stepDescriptor, $options) 
        else if ($uriDomain eq 'REDIRECTING_URI_TREE') then
            f:childUriCollection_uriTree($uri, $name, $stepDescriptor, $options) 
        else if ($uriDomain eq 'BASEX') then
            f:childUriCollection_basex($uri, $name, $stepDescriptor, $options) 
        else if ($uriDomain eq 'SVN') then
            f:childUriCollection_svn($uri, $name, $stepDescriptor, $options) 
        else if ($uriDomain eq 'RDF') then
            f:childUriCollection_rdf($uri, $name, $stepDescriptor, $options) 
        else if ($uriDomain eq 'ARCHIVE') then 
            let $archiveURIAndPath := f:parseArchiveURI($uri, $options)
            let $archiveURI := $archiveURIAndPath[1]
            let $archivePath := $archiveURIAndPath[2]
            let $archive := f:fox-binary($archiveURI, $options)
            return
                if (empty($archive)) then ()
                else (: trace( :)
                    f:childUriCollection_archive(
                        $archive, $archivePath, $name, $stepDescriptor, $options) (: , concat('CHILDREN(', $uri, '): ')) :)
                        
        else
        
    let $kindFilter := $stepDescriptor/@kindFilter
    let $name := ($name, '*')[1]
    let $ignKindTest :=        
        try {file:list($uri, false(), $name)           
            ! replace(., '\\', '/')
            ! replace(., '/$', '')
        } catch * {()}
    return
        if (not($kindFilter)) then 
            (: This check is made because of a BaseX bug - implicit use of a trailing * ... :)
            if ($ignKindTest[1] eq $name) then $ignKindTest[1] else $ignKindTest
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
 : Returns the descendant URIs of a given URI, as absolute URI.
 : The input URI is expected to be an absolute URI.
 :)
declare function f:descendantUriCollectionAbsolute($uri as xs:string, $options as map(*)?)
        as xs:string* {
    f:descendantUriCollection($uri, (), (), $options) ! concat($uri, '/', .)        
};

(:~
 : Returns the descendant URIs of a given URI, relative to the input URI.
 : The input URI is expected to be an absolute URI.
 :)
declare function f:descendantUriCollection($uri as xs:string, $options as map(*)?)
        as xs:string* {
    f:descendantUriCollection($uri, (), (), $options)        
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
        if ($uriDomain eq 'UTREE') then
            f:descendantUriCollection_utree($uri, $name, $stepDescriptor, $options) 
        else if ($uriDomain eq 'REDIRECTING_URI_TREE') then
            f:descendantUriCollection_uriTree($uri, $name, $stepDescriptor, $options) 
        else if ($uriDomain eq 'BASEX') then
            f:descendantUriCollection_basex($uri, $name, $stepDescriptor, $options) 
        else if ($uriDomain eq 'SVN') then
            f:descendantUriCollection_svn($uri, $name, $stepDescriptor, $options) 
        else if ($uriDomain eq 'RDF') then
            f:descendantUriCollection_rdf($uri, $name, $stepDescriptor, $options) 
        else if ($uriDomain eq 'ARCHIVE') then
            let $archiveURIAndPath := f:parseArchiveURI($uri, $options)
            let $archiveURI := $archiveURIAndPath[1]
            let $archivePath := $archiveURIAndPath[2]
            let $archive := f:fox-binary($archiveURI, $options)
            return
                if (empty($archive)) then ()
                else
                    f:descendantUriCollection_archive(
                        $archive, $archivePath, $name, $stepDescriptor, $options) 
        else
        
    let $kindFilter := $stepDescriptor/@kindFilter
    let $name := ($name, '*')[1]    
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

