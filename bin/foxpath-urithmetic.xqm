module namespace f="http://www.foxpath.org/ns/urithmetic";

import module namespace i="http://www.ttools.org/xquery-functions" 
at "foxpath-uri-operations.xqm";

import module namespace use="http://www.foxpath.org/ns/unified-string-expression" 
at  "foxpath-unified-string-expression.xqm";

import module namespace util="http://www.ttools.org/xquery-functions/util" 
at  "foxpath-util.xqm";

(:~
 : Returns the normalized path of the folder containing
 : a node.
 :)
declare function f:baseDir($items as item()*,
                           $options as map(*))
        as xs:string* {
    $items ! f:baseFile(., $options) ! f:parentPath(.)
};

(:~
 : Returns the name of the folder containing a node.
 :)
declare function f:baseDirName($items as item()*,
                               $options as map(*))
        as xs:string* {
    $items ! f:baseDir(., $options) ! f:parentPath(.) ! file:name(.)
};

(:~
 : Returns the normalized path of the file containing
 : a node.
 :)
declare function f:baseFile($items as item()*,
                            $options as map(*))
        as xs:string* {
    $items !
    (if (. instance of node()) then . 
     else i:fox-doc(., $options)) !
     base-uri(.) !
     file:path-to-native(.) !
     f:normalizedFilePath(.)
};

(:~
 : Returns the name of the file containing a node.
 :)
declare function f:baseFileName($items as item()*,
                                $options as map(*))
        as xs:string* {
    $items !    
    (if (. instance of node()) then . 
     else i:fox-doc(., $options)) !
     base-uri(.) !
     file:name(.)
};

(:~
 : Returns the relative path of the file or folder
 : containing a node. The path context defaults to the 
 : current working directory. It can be specified as 
 : a name pattern - the context is the closest containing
 : folder matching the pattern.
 :)
declare function f:baseFileRelative($items as item()*, 
                                    $contextName as xs:string?,
                                    $folder as xs:boolean?,
                                    $options as map(*))
        as xs:string* {
    let $nodes :=
        for $item in $items return
        if ($item instance of node()) then $item 
        else i:fox-doc($item, $options)         
    let $baseUris := $nodes ! base-uri(.) ! file:path-to-native(.) ! (
        if (not($folder)) then f:normalizedFilePath(.)
        else f:parentPath(.))
    return
      if (not($contextName)) then
         let $curDir := f:currentDir()
         return $baseUris ! f:relPath($curDir, .)
      else $baseUris ! f:relPathToContext($contextName, .)
};

(:~
 : Returns the relative URI of the file or folder
 : containing a node. The URI context defaults to the 
 : current working directory. It can be specified as 
 : a name pattern - the context is the closest containing
 : folder matching the pattern.
 :
 : @param item a node or a URI
 : @param contextName as xs:string?
 : @param folder if true, the folder URI is returned, not the file URI
 : @param options the processing options
 : @return relative URI
 :)
declare function f:baseUriRelative($items as item()*, 
                                   $contextName as xs:string?,
                                   $folder as xs:boolean?,
                                   $options as map(*))
        as xs:string* {
    let $nodes := 
        for $item in $items return    
        if ($item instance of node()) then $item 
        else i:fox-doc($item, $options)        
    let $baseUris :=
         $nodes ! base-uri(.) ! (
         if (not($folder)) then . else f:parentPath(.))
    return    
      if (not($contextName)) then
         let $curUri := f:currentUri()      
         return $baseUris ! f:relPath($curUri, .)
      else $baseUris ! f:relPathToContext($contextName, .)
};

(:~
 : Returns the normalized file path of the current directory.
 :) 
declare function f:currentDir()
        as xs:string {
    file:current-dir() ! 
    file:path-to-native(.) !
    f:normalizedFilePath(.)
};

(:~
 : Returns the URI of the current directory.
 :) 
declare function f:currentUri()
        as xs:string {
    file:current-dir() ! 
    file:path-to-native(.) !
    file:path-to-uri(.) !
    f:normalizePath(.)
};

(:~
 : Maps a URI or path to an absolute URI. 
 :
 : If the input has a URI scheme, it is returned as is.
 : Otherwise the input is resolved to an absolute path and the file
 : scheme is prepended. Resolving is against the current working directory.
 :
 : @param pathOrUri a relative or absolute path or URI
 :)
declare function f:absoluteUri($uriOrPath as xs:string?) as xs:string? {
    if (not($uriOrPath)) then () else    
    if (f:isAbsoluteUri($uriOrPath)) then $uriOrPath else
    
    let $apath :=
        if (starts-with($uriOrPath, '/') or file:is-absolute($uriOrPath)) then $uriOrPath
        else file:resolve-path($uriOrPath) ! f:normalizePath(.)
    return (
        if (starts-with($apath, '/')) then 'file://' else 'file:///')
        ||$apath
};

(:~
 : Returns a resource URI. The input may be a node or
 : a "doc resource" wrapper, which is a map containing
 : a node and a URI.
 :)
declare function f:resourceUri($resource as item()) as xs:string {
    typeswitch($resource)
    case map(*) return $resource?uri
    case node() return $resource/base-uri(.)
    default return $resource
};

(:~
 : Returns the closest ancestor URI containing a sequence of URIs.
 :)
declare function f:commonContextUri($uris as item()*) as xs:string? {
    let $uris := $uris ! f:resourceUri(.)
    let $try := $uris[1] ! f:parentPath(.)
    return f:commonContextUriREC($uris, $try)
};

declare function f:commonContextUriREC($uris as xs:string*, $try as xs:string) 
        as xs:string? {
    if (every $uri in $uris satisfies starts-with($uri, $try||'/')) then $try else
    let $try2 := $try ! f:parentPath(.)
    return
        if ($try2 eq $try) then () else f:commonContextUriREC($uris, $try2)
};

(:~
 : Extracts from a URI or path the path and returns a normalized
 : representation. 
 :
 : @param uriOrPath a relative or absolute URI or path
 : @return the normalized path
 :)
declare function f:extractUriPath($uriOrPath as xs:string?) as xs:string? {
    if (not(f:isAbsoluteUri($uriOrPath))) then f:normalizePath($uriOrPath) 
    else f:removeUriScheme($uriOrPath) ! f:normalizePath(.)                 
};    

(:~
 : Extracts from a path or URI the URI scheme. If the input item is
 : not an absolute URI, the empty sequence is returned.
 :
 : @param pathOrUri a relative or absolute path or URI
 : @return the URI scheme, or the empty sequence
 :)
declare function f:extractUriScheme($uriOrPath as xs:string?) as xs:string? {
    if (not(f:isAbsoluteUri($uriOrPath))) then () else
    replace($uriOrPath, '^([a-z][a-z]+):/.*', '$1')
};

(:~
 : Extracts from a URI or file path the file name.
 :
 : @param uri a URI or file path
 : @return the file base name
 :)
declare function f:fileName($uri as xs:string?) as xs:string? {
    replace($uri, '.*[/\\]', '')
};

(:~
 : Extracts from a URI or file path the file base name.
 :
 : @param uri a URI or file path
 : @return the file base name
 :)
declare function f:fileBaseName($uri as xs:string?) as xs:string? {
    f:fileName($uri) ! replace(., '\.[^.]+$', '')  
};

(:~
 : Returns true if a given URI or path is an absolute URI, starting
 : with a URI schema.
 :
 : @param pathOrUri a relative or absolute path or URI
 : @return true or false
 :)
declare function f:isAbsoluteUri($uriOrPath as xs:string?) as xs:boolean {
    matches($uriOrPath, '^[a-z][a-z]+:/')
};

(:~
 : Normalizes a path, replacing backslash with slash and removing
 : trailing slash.
 :
 : Note: a file URI remains a file URI, it is not transformed
 : into a file path.
 :
 : @param path a path
 : @return the normalized path
 :)
declare function f:normalizePath($path as xs:string?) as xs:string? {
    $path ! replace(., '\\', '/') ! replace(., '/$', '')                 
};    

(:~
 : Normalizes file system path:
 : - replaces \ with /
 : - removes trailing /
 : - removes "file://", if present
 : The result is either a relative path, or a path starting
 : with "/" (Unix), or a path starting with d:/ (Window,
 : where "d" represents the drive letter).
 :
 : @param path a file system path, or a file URI
 : @return the normalized path
 :) 
declare function f:normalizedFilePath($path as xs:string)
        as xs:string {
    $path
    ! replace(., '\\', '/')
    ! replace(.,
      '^file:/*? ((/([a-zA-Z]:/.*))$  |  (/([^/].*)?$))', '$3$4', 'x')
    ! replace(., '/$', '')
};

(:~
 : Returns the parent path of a given path.
 :)
declare function f:parentPath($path as xs:string?) as xs:string? {
    $path ! f:normalizePath(.) ! replace(., '/[^/]*$', '')
};

(:~
 : Returns the parent path of a given path, as a normalized path.
 :)
declare function f:parentFilePath($path as xs:string?) as xs:string? {
    f:parentPath($path) ! f:normalizedFilePath(.)
};

(:~
 : Returns the relative path leading from $path1 to $path2.
 :
 : @param path1 a path
 : @param path2 another path
 : @return the relative path leading from $path1 to $path2
 :)
declare function f:relPath($path1 as xs:string, $path2 as xs:string)
        as xs:string? {
    let $path1 := f:normalizePath($path1)        
    let $path2 := f:normalizePath($path2)
    return if ($path1 eq $path2) then '.' else f:relPathREC($path1, $path2)
};

declare function f:relPathToContext($context as xs:string, 
                                    $path as xs:string)
        as xs:string {
    let $filter := $context ! use:compileUSE(., true())
    let $steps := tokenize($path, '/')
    let $countSteps := count($steps)
    let $lastMatchingStep := 
        (for $i in 1 to $countSteps 
         return $steps[$i][use:matchesUSE(., $filter)] ! $i)[last()]
    return
        if (empty($lastMatchingStep)) then $path
        else if ($lastMatchingStep eq $countSteps) then '.'
        else string-join($steps[position() gt $lastMatchingStep], '/')
};        

(:~
 : Recursive helper function of function 'relPath'.
 :)
declare function f:relPathREC($path1 as xs:string, $path2 as xs:string)
        as xs:string? {
    if ($path1 eq $path2) then '.' else
    
    let $path1Slash := replace($path1, '[^/]$', '$0/')
    return
        if (starts-with($path2, $path1Slash)) then substring-after($path2, $path1Slash)
        else if (not(matches($path1Slash, '/.*/'))) then ()
        else string-join(
            let $nextPath1 := (replace($path1Slash, '^(.*)/.*?/$', '$1')[string()], '/')[1]
            return ('..', f:relPathREC($nextPath1, $path2)[. ne '.'][string()]), '/')       
};

(:~
 : Returns the relative path leading from $uri1 to $uri2.
 :)
declare function f:relUri($uriOrPath1 as xs:string, $uriOrPath2 as xs:string)
        as xs:string? {
    if ($uriOrPath1 eq $uriOrPath2) then '.' else
    
    let $scheme1 := f:extractUriScheme($uriOrPath1)
    let $scheme2 := f:extractUriScheme($uriOrPath2)
    return if ($scheme1 ne $scheme2 or $scheme2 ne 'file') then $uriOrPath2 else
    
    let $path1 := f:removeUriScheme($uriOrPath1)
    let $path2 := f:removeUriScheme($uriOrPath2)
    return f:relPath($path1, $path2)
};    
(:~
 : Removes the URI schema from a URI or path.
 :
 : @param pathOrUri a relative or absolute path or URI
 : @return the URI scheme, or the empty sequence
 :)
declare function f:removeUriScheme($uriOrPath as xs:string?) as xs:string? {
    replace($uriOrPath, '^[a-z][a-z]+:/+([a-zA-Z]:.*|/.*)', '$1')
};

(:~
 : Returns a "doc resource", which is a map with entries
 : '_objecttype', 'doc' and 'uri'.
 :)
declare function f:docResource($resource as item()?,
                               $options as map(*))
        as map(*)? {
    if ($resource instance of map(*)) then $resource else
    let $doc := 
        if ($resource instance of node()) then $resource
        else try {i:fox-doc($resource, $options)} catch * {()}
    return if (not($doc)) then () else
    let $uri := $doc/base-uri(.)
    return map{'_objecttype': 'doc-resource', 'doc': $doc, 'uri': $uri}
};  

(:~
 : Returns a "textfile resource", which is a map with entries
 : '_objecttype', 'content' and 'uri'.
 :)
declare function f:textfileResource($resource as item()?)
        as map(*)? {
    if ($resource instance of map(*)) then $resource else
    
    let $content :=
        try {i:fox-unparsed-text($resource, (), ())} catch * {()}
    return if (not($content)) then () else
    
    let $uri := $resource
    return map{'_objecttype': 'textfile-resource', 'content': $content, 'uri': $uri}
};  

(:~
 : Replaces a doc-resource's content node with another node.
 :)
declare function f:updateDocResourceContent($resource as map(*), 
                                            $doc as node())
        as map(*) {
    map:put($resource, 'doc', $doc)            
};        

(:~
 : Returns true if a given item is an instance of a doc-resource.
 :)
declare function f:instanceOfDocResource($item as item())
        as xs:boolean {
    if ($item instance of map(*)) then
        if ($item?_objecttype eq 'doc-resource') then true()
        else if ($item?_objecttype eq 'cssdoc-resource') then true()
        else false()
    else false()        
};

(:~
 : Maps an item to a node. If the item is a node, the
 : node is returned; it is a doc-resource, the resource's
 : content node is returned; otherwise, the item is interpreted
 : as a document URI and the corresponding document node is
 : returned. 
 :) 
declare function f:itemToNode($item as item(), $options as map(*))
        as node()? {
    if ($item instance of node()) then $item 
    else if (f:instanceOfDocResource($item))then $item?doc
    else i:fox-doc($item, $options)
};        

(:~
 : Returns true if a file exists, false otherwise.
 : Wraps the file:exists function, catching exceptions.
 :)
declare function f:fileExists($uri as xs:string)
        as xs:boolean {
    try {file:exists($uri)} catch * {false()}        
};

(:~
 : Writes a document resource to the file system.
 :)
declare function f:writeDocResource($path as xs:string, 
                                    $resource as map(*), 
                                    $flags as xs:string?)
        as empty-sequence() {
    let $doc := $resource?doc
    return if (not($doc)) then () else
    
    let $flagItems := $flags ! tokenize(.)        
    let $ser := map:merge(
        if (not($flagItems = 'indent')) then () else map:entry('indent', 'yes')
    )
    return file:write($path, $doc, $ser)
};        

(:~
 : Writes a document resource to the file system.
 :)
declare function f:writeTextfileResource($path as xs:string, 
                                         $resource as map(*), 
                                         $flags as xs:string?)
        as empty-sequence() {
    if (not($resource?_objecttype eq 'textfile-resource')) then 
        error(QName((), 'INVALID_ARG'), 'Invalid argument - not a textfile resource.')
        else
        
    let $content := $resource?content
    return 
        if (not($content)) then ()
        else file:write($path, $content)
};        

        
