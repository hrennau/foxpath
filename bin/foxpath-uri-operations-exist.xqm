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
 declare function f:fox-file-exists_exist($uri as xs:string, $options as map(*)?)
        as xs:boolean? {    
    let $useUri := substring($uri, 5)
    return
    (: false if `proc:system` throws an exception, true otherwise :)
    let $test :=
        try {
            1, proc:system('svn', ('list', $useUri))
        } catch * {()}
    return exists($test)
};

(:~
 : Returns true if a resource is a file, rather than a directory.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return true if the resource exists and is a file
 :)
 declare function f:fox-is-file_exist($uri as xs:string, $options as map(*)?)
        as xs:boolean? {    
    let $useUri := substring($uri, 5)
    let $list :=
        try {
            proc:system('svn', ('list', $useUri)) ! replace(., '\s+$', '')
        } catch * {()}
    return
        $list eq replace($useUri, '.*/', '') (:  and not(ends-with($listUri, '/')) :)
};

(:~
 : Returns true if a resource is a directory, rather than a file.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return true if the resource exists and is a file
 :)
 declare function f:fox-is-dir_exist($uri as xs:string, $options as map(*)?)
        as xs:boolean? {    
    let $useUri := substring($uri, 5)
    let $list :=
        try {
            proc:system('svn', ('list', $useUri)) ! replace(., '\s+$', '')
        } catch * {()}
    return
        exists($list) and not($list eq replace($useUri, '.*/', ''))
};

(:~
 : Returns the size of a resource.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return true if the resource exists and is a file
 :)
 declare function f:fox-file-size_exist($uri as xs:string, $options as map(*)?)
        as xs:integer? {    
    let $useUri := substring($uri, 5)
    let $list :=
        try {
            proc:system('svn', ('list', $useUri, '--xml'))
            ! parse-xml(.)/descendant::list[1]
        } catch * {()}
    return 
        if ($list/@path/lower-case(.) eq lower-case($useUri) 
            and count($list/entry) eq 1 
            and $list/entry/name eq replace($useUri, '.*/', ''))
            then $list/entry[1]/size/xs:integer(.)
        else ()
};

(:~
 : Returns the last modification date of a resource.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return true if the resource exists and is a file
 :)
 declare function f:fox-file-date_exist($uri as xs:string, $options as map(*)?)
        as xs:dateTime? {    
    let $useUri := substring($uri, 5)
    let $list :=
        try {
            proc:system('svn', ('list', $useUri, '--xml'))
            ! parse-xml(.)/descendant::list[1]
        } catch * {()}
    return 
        if ($list/@path/lower-case(.) eq lower-case($useUri) 
            and count($list/entry) eq 1 
            and $list/entry/name eq replace($useUri, '.*/', ''))
            then $list/entry[1]/commit/date/xs:dateTime(.)
        else ()
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
 : @return true if the resource exists and is a file
 :)
 declare function f:fox-doc_exist($uri as xs:string, $options as map(*)?)
        as document-node()? {    
    let $useUri := substring($uri, 5)
    return
        try {
            proc:system('svn', ('cat', $useUri)) ! parse-xml(.)
        } catch * {()}
};

(:~
 : Returns true if a given URI or file path points to a well-formed XML document.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return true if the resource exists and is a file
 :)
 declare function f:fox-doc-available_exist($uri as xs:string, $options as map(*)?)
        as xs:boolean {    
    let $useUri := substring($uri, 5)
    return
        exists(
            try {
                proc:system('svn', ('cat', $useUri)) ! parse-xml(.)
            } catch * {()})
};

(:~
 : Returns the string representation of a resource.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return true if the resource exists and is a file
 :)
 declare function f:fox-unparsed-text_exist($uri as xs:string,
                                            $encoding as xs:string?, 
                                            $options as map(*)?)
        as xs:string? {    
    let $useUri := substring($uri, 5)
    return
        try {
            proc:system('svn', ('cat', $useUri))
        } catch * {()}
};

(:~
 : Returns the lines of the string representation of a resource.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return true if the resource exists and is a file
 :)
 declare function f:fox-unparsed-text-lines_exist($uri as xs:string,
                                                  $encoding as xs:string?, 
                                                  $options as map(*)?)
        as xs:string* {    
    let $useUri := substring($uri, 5)
    return
        try {
            proc:system('svn', ('cat', $useUri)) ! tokenize(., '&#xD;?&#xA;')
        } catch * {()}
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
declare function f:childUriCollection_exist($uri as xs:string, 
                                            $name as xs:string?,
                                            $stepDescriptor as element()?,
                                            $options as map(*)?) {                                        
    let $pattern :=
        if (not($name)) then () else 
            concat('^', replace($name, '\*', '.*'), '$')

    let $useUri := substring($uri, 5) ! replace(., '/$', '')
    let $kindFilter := $stepDescriptor/@kindFilter
    let $raw := f:_getChildUris_svn($useUri, $pattern, $kindFilter, $options)
    return
        $raw ! replace(., '/\s*$', '')
};

declare function f:descendantUriCollection_exist($uri as xs:string, 
                                                 $name as xs:string?,
                                                 $stepDescriptor as element()?,
                                                 $options as map(*)?) {
    let $pattern :=
        if (not($name)) then () else concat('^', replace($name, '\*', '.*'), '$')

    let $uri := substring($uri, 5) ! replace(., '/$', '')
    let $kindFilter := $stepDescriptor/@kindFilter
    let $raw := f:_getDescendantUris_svn($uri, $pattern, $kindFilter, $options)
    return
        $raw ! replace(., '/\s*$', '')
};

(:~
 : Returns the child URIs of a given svn URI, matching an optional name pattern
 : and matching an optional kind test (file or folder).
 :
 : Note. Private function, called by public function f:childUriCollection.
 :)
declare function f:_getChildUris_exist($uri as xs:string,
                                       $pattern as xs:string?,
                                       $kindFilter as xs:string?,
                                       $options as map(*)?)                                     
        as xs:string* {
    (: all child URIs :)
    let $all := tokenize(proc:system('svn', ('list', $uri)), '\s*&#xA;\s*')[string()]
    
    (: if $uri is a file, the list has a single item which is the file name ...;
       inversely, if the list contains only the file name, check if the
       URI is a directory (otherwise, return the empty sequence :)
    let $all :=
        if (count($all) eq 1 and $all[1] eq replace($uri, '.*/', '')) then
            $all[f:fox-is-dir_svn(concat('svn-', $uri), $options)]
        else $all
            
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

declare function f:_getDescendantUris_exist($uri as xs:string,
                                            $pattern as xs:string?,
                                            $kindFilter as xs:string?,
                                            $options as map(*)?)                                          
        as xs:string* {
    (: all child URIs :)        
    let $all := 
        tokenize(
            proc:system('svn', ('list', '--recursive', $uri)), 
            '\s*&#xA;\s*')
        [string()]

    (: check - if $uri is a file, the list command yields the file name ... :)
    let $all :=
        if (count($all) eq 1 and $all[1] eq replace($uri, '.*/', '')) then
            $all[f:fox-is-dir_svn(concat('svn-', $uri), $options)]
        else $all

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


