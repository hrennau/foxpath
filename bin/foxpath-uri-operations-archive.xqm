(:
foxpath-uri-operation-archive.xqm - functions operating on URIs pointing to archives contents

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
 : Returns true if a given URI pointing into an archive references a file,
 : rather than a directory.
 :
 : @param archive an archive file
 : @param archivePath a within-archive data path (e.g. a/b/c)
 : @param options options controlling the evaluation
 : @return true if the resource exists and is a file
 :)
  declare function f:fox-is-file_archive($archive as xs:base64Binary, 
                                         $archivePath as xs:string?, 
                                         $options as map(*)?)
        as xs:boolean { 
    let $entries := archive:entries($archive)
    return
        if ($entries = $archivePath) then true()
        else false()
};

 (:~
 : Returns true if a given URI pointing into an archive references a directory,
 : rather than a file.
 :
 : @param archive an archive file
 : @param archivePath a within-archive data path (e.g. a/b/c)
 : @param options options controlling the evaluation
 : @return true if the resource exists and is a directory
 :)
  declare function f:fox-is-dir_archive($archive as xs:base64Binary, 
                                        $archivePath as xs:string?, 
                                        $options as map(*)?)
        as xs:boolean { 
    let $entries := archive:entries($archive)
    return
        if ($entries = $archivePath) then false()
        else 
            let $prefix := concat($archivePath, '/')
            return
                some $entry in $entries satisfies starts-with($entry, $prefix) 
};

 (:~
 : Returns the size in bytes of a resource contained by an archive.
 :
 : @param archive an archive file
 : @param archivePath a within-archive data path (e.g. a/b/c)
 : @param options options controlling the evaluation
 : @return the size of the resource as number of bytes
 :)
 declare function f:fox-file-size_archive($archive as xs:base64Binary, 
                                          $archivePath as xs:string?,
                                          $options as map(*)?)
        as xs:integer? {    
    let $entry := archive:entries($archive)[. eq $archivePath]
    return
        if (not($entry)) then () else $entry/@size/xs:integer(.)
};


(:~
 : Returns the last modification time of a resource contained by an archive.
 :
 : @param uri the resource URI
 : @param options options controlling the evaluation
 : @return true if the resource exists and is a file
 :)
 declare function f:fox-file-date_archive($archive as xs:base64Binary, 
                                          $archivePath as xs:string?,
                                          $options as map(*)?)
        as xs:dateTime? {    
    let $entry := archive:entries($archive)[. eq $archivePath]
    return
        if (not($entry)) then () else $entry/@last-modified/xs:dateTime(.)
};

(: 
 : ===============================================================================
 :
 :     r e s o u r c e    r e t r i e v a l
 :
 : ===============================================================================
 :)
 
 (:~
 : Returns true if an archive contains a resource matching a given 
 : within-archive data path.
 :
 : @param archive an archive file
 : @param archivePath a within-archive data path (e.g. a/b/c)
 : @param options options controlling the evaluation
 : @return true if the resource exists and is a file
 :)
  declare function f:fox-file-exists_archive($archive as xs:base64Binary, 
                                             $archivePath as xs:string?, 
                                             $options as map(*)?)
        as xs:boolean { 
    let $entries := archive:entries($archive)
    return
        if ($entries = $archivePath) then true()
        else 
            let $prefix := concat($archivePath, '/')
            return
                some $entry in $entries satisfies starts-with($entry, $prefix) 
};

 (:~
 : Returns the XML document obtained by parsing a resource contained by an archive.
 :
 : @param archive an archive file
 : @param archivePath a within-archive data path (e.g. a/b/c)
 : @param options options controlling the evaluation
 : @return the document node, if the resource exists and is a well-formed XML document
 :)
 declare function f:fox-doc_archive($archive as xs:base64Binary, 
                                    $archivePath as xs:string?, 
                                    $options as map(*)?)
        as document-node()? {    
    let $text := f:fox-unparsed-text_archive($archive, $archivePath, (), $options)
    return    
        try {$text ! parse-xml(.)} catch * {()}
};

(:~
 : Returns true if an archive contains at a within-archive data path a well-formed 
 : XML document.
 :
 : @param archive an archive file
 : @param archivePath a within-archive data path (e.g. a/b/c)
 : @param options options controlling the evaluation
 : @return the document node, if the resource exists and is a well-formed XML document
 :)
 declare function f:fox-doc-available_archive($archive as xs:base64Binary, 
                                              $archivePath as xs:string?, 
                                              $options as map(*)?)
        as xs:boolean {    
    let $text := f:fox-unparsed-text_archive($archive, $archivePath, (), $options)
    return    
        exists(
            try {$text ! parse-xml(.)} catch * {()}
        )
};

(:~
 : Returns a string representation of a resource contained by an archive.
 :
 : @param archive an archive file
 : @param archivePath a within-archive data path (e.g. a/b/c)
 : @param encoding the encoding of the file to be retrieved
 : @param options options controlling the evaluation
 : @return the document, or the empty sequence if retrieval or parsing fails
 :)
declare function f:fox-unparsed-text_archive($archive as xs:base64Binary, 
                                             $archivePath as xs:string?, 
                                             $encoding as xs:string?,
                                             $options as map(*)?)
        as xs:string? {                                             
    let $entry := archive:entries($archive)[. eq $archivePath]
    return
        if (not($entry)) then ()
        else       
            if ($encoding) then
                archive:extract-text($archive, $entry, $encoding)
            else
                archive:extract-text($archive, $entry)        
};

(:~
 : Returns the lines of a string representation of a resource contained 
 : by an archive.
 :
 : @param archive an archive file
 : @param archivePath a within-archive data path (e.g. a/b/c)
 : @param encoding the encoding of the file to be retrieved 
 : @param options options controlling the evaluation
 : @return the document, or the empty sequence if retrieval or parsing fails
 :)
declare function f:fox-unparsed-text-lines_archive($archive as xs:base64Binary, 
                                                   $archivePath as xs:string?, 
                                                   $encoding as xs:string?,
                                                   $options as map(*)?)
        as xs:string* {
    let $text := f:fox-unparsed-text_archive($archive, $archivePath, $encoding, $options)
    return
        $text ! tokenize(., '&#xD;?&#xA;')
};

(:~
 : Returns the content of a file contained by an archive as the 
 : Base64 representation of its bytes.
 :
 : @param archive an archive file
 : @param archivePath a within-archive data path (e.g. a/b/c)
 : @param options options controlling the evaluation
 : @return the Base64 representation, if available, the empty sequence otherwise
 :)
declare function f:fox-binary_archive($archive as xs:base64Binary, 
                                      $archivePath as xs:string?,
                                      $options as map(*)?)
        as xs:base64Binary? {
    let $entry := archive:entries($archive)[. eq $archivePath]
    return
        if (not($entry)) then ()
        else archive:extract-binary($archive, $entry)        
};

(: 
 : ===============================================================================
 :
 :     r e s o u r c e    t r e e    n a v i g a t i o n 
 :
 : ===============================================================================
 :)
 (:~
 : Returns the child URIs of a resource identified by containing
 : archive and the within-archive data path.
 :
 : Note. A kind filter is currently received via a `stepDescriptor` element.
 : This approach is meant to be extensible, allowing the future addition of 
 : other filters 
 :
 : @param archive an archive file
 : @param archivePath a within-archive data path (e.g. a/b/c)
 : @param name a name pattern to be matched by the resource names
 : @param stepDescriptor describes the step and may contain a kind filter
 : @param options options controlling the evaluation 
 : @return the child URIs
 :)
declare function f:childUriCollection_archive($archive as xs:base64Binary, 
                                              $archivePath as xs:string?,
                                              $name as xs:string?,
                                              $stepDescriptor as element()?,
                                              $options as map(*)?) {

    (: let $DUMMY := trace($archivePath, 'CHILD_URIS_ARCHIVE; ARCHIVE_PATH: ') :)                                              
    let $kindFilter := $stepDescriptor/@kindFilter                                            
    let $pattern :=
        if (not($name)) then () else 
            concat('^', replace(replace($name, '\*', '.*'), '\?', '.'), '$')
    let $entries := archive:entries($archive) ! string()
    let $children :=
        let $relPaths := 
            if (not($archivePath)) then $entries else 
                $entries [matches(., concat('^', $archivePath, '(/|$)'))] 
                ! substring(., 2 + string-length($archivePath))   
        let $fileChildren := $relPaths[not(contains(., '/'))]
        return (
            if ($kindFilter eq 'file') then $fileChildren
            else 
                let $folderChildren := $relPaths[contains(., '/')] ! replace(., '/.*', '') 
                return
                    if ($kindFilter eq 'dir') then $folderChildren
                    else ($fileChildren, $folderChildren)
        ) [string()]
    let $matchName :=
        if (not($pattern)) then $children else
            $children[matches(replace(replace(., '/$', ''), '.*/', ''), $pattern, 'i')]
    return
        $matchName
};

(:~
 : Returns the descendant URIs of a resource identified by containing
 : archive and the within-archive data path.
 :
 : Note. The kind test is currently received via a `stepDescriptor` element.
 : This approach is meant to be extensible, allowing the future addition of 
 : other filters 
 :
 : @param archive an archive file
 : @param archivePath a within-archive data path (e.g. a/b/c)
 : @param name a name pattern to be matched by the resource names
 : @param stepDescriptor describes the step and may contain a kind filter
 : @param options options controlling the evaluation 
 : @return the descendant URIs 
 :)
declare function f:descendantUriCollection_archive(
                                              $archive as xs:base64Binary, 
                                              $archivePath as xs:string?,
                                              $name as xs:string?,
                                              $stepDescriptor as element()?,
                                              $options as map(*)?) {
    (: let $DUMMY := trace($archivePath, 'DESCENDANT_URIS_ARCHIVE; URI: ') :)                                              
    let $kindFilter := $stepDescriptor/@kindFilter                                                 
    let $pattern :=
        if (not($name)) then () else 
            concat('^', replace(replace($name, '\*', '.*'), '\?', '.'), '$')

    let $entries := archive:entries($archive) ! string()    
    let $relPaths := 
        if (not($archivePath)) then $entries else 
            $entries ! substring(., 2 + string-length($archivePath))   
        
    let $files := distinct-values($relPaths)
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
(:              hjr, 20180102: bugfix, deliver *all* paths (consisting of 1, 2, ... steps) :)       
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
 :     a r c h i v e    u t i l i t i e s 
 :
 : ===============================================================================
 :)
 (:~
  : Parses an archive content URI and returns two items - the URI of the archive resource
  : and the path within the archive.
  :
  : @param uri the URI to be parsed
  : @param options options controlling the parsing and evaluation of a FOXpath expression
  :)
 declare function f:parseArchiveURI($uri as xs:string, $options as map(*)?)
        as xs:string+ {
    let $sep := '~~~~~~~'
    let $comps :=
        replace($uri, concat('^(.*)\s*/\s*', $f:ARCHIVE_TOKEN, '(\s*/(.*$))?'), 
                concat('$1', $sep, '$3'), 's')        
    return
        (substring-before($comps, $sep), substring-after($comps, $sep))
};



declare function f:my-get-request_github($uri as xs:string, $token as xs:string)
        as node()+ {
    let $rq :=
        <http:request method="get" href="{trace($uri, 'GIT_URI: ')}">{
            <http:header name="Authorization" value="{concat('Token ', $token)}"/>[$token]
        }</http:request>
    let $rs := try {http:send-request($rq)} catch * {
        trace((), concat('EXCEPTION_IN_SEND_REQUEST; ',
                         'CODE=', $err:code, 
                         ' ; DESC=',
                         ()))} 
    let $rsHeader := $rs[1]
    let $body := $rs[position() gt 1]
    return
        ($body, $rsHeader)[1]
};        

