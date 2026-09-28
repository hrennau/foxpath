module namespace ur="http://www.foxpath.org/ns/urithmetic";

import module namespace i="http://www.ttools.org/xquery-functions" 
at "foxpath-uri-operations.xqm";

import module namespace use="http://www.foxpath.org/ns/unified-string-expression" 
at  "foxpath-unified-string-expression.xqm";

import module namespace util="http://www.ttools.org/xquery-functions/util" 
at  "foxpath-util.xqm";

(:~
 : Returns for each input node the name of the folder containing it.
 :)
declare function ur:basedirName($items as item()*,
                               $options as map(*))
        as xs:string* {
    $items ! ur:basedirPath(., $options) ! file:name(.)
};

(:~
 : Returns for each input node the file path of the folder containing it.
 :)
declare function ur:basedirPath($items as item()*,
                               $options as map(*))
        as xs:string* {
    $items ! ur:basePath(., $options) ! ur:parentPath(.)
};

(:~
 : Returns for each input node the file URI of the folder containing it.
 :)
declare function ur:basedirUri($items as item()*,
                              $options as map(*))
        as xs:string* {
    ur:baseUri($items, $options) ! ur:parentPath(.)
};

(:~
 : Returns for each input node the name of the file containing it.
 :)
declare function ur:baseName($items as item()*,
                            $options as map(*))
        as xs:string* {
    $items ! (
    if (. instance of node()) then . else i:fox-doc(., $options)) !
    base-uri(.) !
    file:name(.)
};

(:~
 : Returns for each input node the file path of the file containing it. 
 :)
declare function ur:basePath($items as item()*,
                            $options as map(*))
        as xs:string* {
    $items ! (
    if (. instance of node()) then . else i:fox-doc(., $options)) !
    base-uri(.) !
    file:path-to-native(.) !
    ur:normalizedFilePath(.)
};

(:~
 : Returns for each input node the relative file path of the file or folder
 : containing it. The path context defaults to the current working directory. 
 : It can be specified as a name pattern - the context is the closest 
 : containing folder matching the pattern.
 :)
declare function ur:baseRelpath($items as item()*, 
                               $contextName as xs:string?,
                               $basedir as xs:boolean?,
                               $options as map(*))
        as xs:string* {
    let $nodes := $items ! (
        if (. instance of node()) then . else i:fox-doc(., $options))
    let $baseUris := 
        $nodes ! base-uri(.) ! file:path-to-native(.) ! (
        if (not($basedir)) then ur:normalizedFilePath(.)
        else ur:parentPath(.))
    return
      if (not($contextName)) then
         let $curDir := ur:currentDir()
         return $baseUris ! ur:relPath($curDir, .)
      else $baseUris ! ur:relPathToContext($contextName, .)
};

(:~
 : Returns for each input node the relative URI of the file or folder
 : containing it. The URI context defaults to the file URI of the current 
 : working directory. It can be specified explicitly as a name filter, 
 : selecting the closest containing folder with a name matching the pattern.
 :
 : @param item a node or a URI
 : @param contextName as xs:string?
 : @param basedir if true, the folder URI is returned, not the file URI
 : @param options the processing options
 : @return relative URI
 :)
declare function ur:baseReluri($items as item()*, 
                              $contextName as xs:string?,
                              $basedir as xs:boolean?,
                              $options as map(*))
        as xs:string* {
    let $nodes := $items ! (
        if (. instance of node()) then . else i:fox-doc(., $options))
    let $baseUris :=
         $nodes ! base-uri(.) ! (
         if (not($basedir)) then . else ur:parentPath(.))
    return    
      if (not($contextName)) then
         let $curUri := ur:currentUri()      
         return $baseUris ! ur:relPath($curUri, .)
      else $baseUris ! ur:relPathToContext($contextName, .)
};

(:~
 : Returns for each input node its base URI. 
 :)
declare function ur:baseUri($items as item()*,
                           $options as map(*))
        as xs:string* {
    $items ! (
    if (. instance of node()) then . else i:fox-doc(., $options)) !
    trace(base-uri(.), '_ base-uri(): ')
};

(:~
 : Returns the normalized file path of the current directory.
 :) 
declare function ur:currentDir()
        as xs:string {
    file:current-dir() ! 
    file:path-to-native(.) !
    ur:normalizedFilePath(.)
};

(:~
 : Returns the URI of the current directory.
 :) 
declare function ur:currentUri()
        as xs:string {
    file:current-dir() ! 
    file:path-to-native(.) !
    file:path-to-uri(.) !
    ur:normalizePath(.)
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
declare function ur:absoluteUri($uriOrPath as xs:string?) as xs:string? {
    if (not($uriOrPath)) then () else    
    if (ur:isAbsoluteUri($uriOrPath)) then $uriOrPath else
    
    let $apath :=
        if (starts-with($uriOrPath, '/') or file:is-absolute($uriOrPath)) then $uriOrPath
        else file:resolve-path($uriOrPath) ! ur:normalizePath(.)
    return (
        if (starts-with($apath, '/')) then 'file://' else 'file:///')
        ||$apath
};

(:~
 : Returns a resource URI. The input may be a node or
 : a "doc resource" wrapper, which is a map containing
 : a node and a URI.
 :)
declare function ur:resourceUri($resource as item()) as xs:string {
    typeswitch($resource)
    case map(*) return $resource?uri
    case node() return $resource/base-uri(.)
    default return $resource
};

(:~
 : Returns the closest ancestor URI containing a sequence of URIs.
 :)
declare function ur:commonContextUri($uris as item()*) as xs:string? {
    let $uris := $uris ! ur:resourceUri(.)
    let $try := $uris[1] ! ur:parentPath(.)
    return ur:commonContextUriREC($uris, $try)
};

declare function ur:commonContextUriREC($uris as xs:string*, $try as xs:string) 
        as xs:string? {
    if (every $uri in $uris satisfies starts-with($uri, $try||'/')) then $try else
    let $try2 := $try ! ur:parentPath(.)
    return
        if ($try2 eq $try) then () else ur:commonContextUriREC($uris, $try2)
};

(:~
 : Extracts from a URI or path the path and returns a normalized
 : representation. 
 :
 : @param uriOrPath a relative or absolute URI or path
 : @return the normalized path
 :)
declare function ur:extractUriPath($uriOrPath as xs:string?) as xs:string? {
    if (not(ur:isAbsoluteUri($uriOrPath))) then ur:normalizePath($uriOrPath) 
    else ur:removeUriScheme($uriOrPath) ! ur:normalizePath(.)                 
};    

(:~
 : Extracts from a path or URI the URI scheme. If the input item is
 : not an absolute URI, the empty sequence is returned.
 :
 : @param pathOrUri a relative or absolute path or URI
 : @return the URI scheme, or the empty sequence
 :)
declare function ur:extractUriScheme($uriOrPath as xs:string?) as xs:string? {
    if (not(ur:isAbsoluteUri($uriOrPath))) then () else
    replace($uriOrPath, '^([a-z][a-z]+):/.*', '$1')
};

(:~
 : Extracts from a URI or file path the file name.
 :
 : @param uri a URI or file path
 : @return the file base name
 :)
declare function ur:fileName($uri as xs:string?) as xs:string? {
    replace($uri, '.*[/\\]', '')
};

(:~
 : Extracts from a URI or file path the file base name.
 :
 : @param uri a URI or file path
 : @return the file base name
 :)
declare function ur:fileBaseName($uri as xs:string?) as xs:string? {
    ur:fileName($uri) ! replace(., '\.[^.]+$', '')  
};

(:~
 : Returns true if a given URI or path is an absolute URI, starting
 : with a URI schema.
 :
 : @param pathOrUri a relative or absolute path or URI
 : @return true or false
 :)
declare function ur:isAbsoluteUri($uriOrPath as xs:string?) as xs:boolean {
    matches($uriOrPath, '^[a-z][a-z]+:/')
};

(:~
 : Normalizes a file path or URI reference, replacing backslash with slash 
 : and removing trailing slash.
 :
 : Note: if the input is a URI reference, the output is also a URI reference -
 : the URI schema is retained.
 :
 : @param path a path
 : @return the normalized path
 :)
declare function ur:normalizePath($path as xs:string?) as xs:string? {
    $path ! replace(., '\\', '/') ! replace(., '/$', '')                 
};    

(:~
 : Normalizes file system path:
 : - replaces \ with /
 : - removes trailing /
 : - removes URI scheme (e.t. "file://"), if present
 : The result is either a relative path, or a path starting
 : with "/" (Unix), or a path starting with d:/ (Window,
 : where "d" represents the drive letter).
 :
 : @param path a file system path or a file URI
 : @return the normalized path
 :) 
declare function ur:normalizedFilePath($path as xs:string)
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
declare function ur:parentPath($path as xs:string?) as xs:string? {
    $path ! ur:normalizePath(.) ! replace(., '/[^/]*$', '')
};

(:~
 : Returns the parent path of a given path, as a normalized path.
 :)
declare function ur:parentFilePath($path as xs:string?) as xs:string? {
    ur:parentPath($path) ! ur:normalizedFilePath(.)
};

(:~
 : Returns the relative path leading from $path1 to $path2.
 :
 : @param path1 a path
 : @param path2 another path
 : @return the relative path leading from $path1 to $path2
 :)
declare function ur:relPath($path1 as xs:string, $path2 as xs:string)
        as xs:string? {
    let $path1 := ur:normalizePath($path1)        
    let $path2 := ur:normalizePath($path2)
    return if ($path1 eq $path2) then '.' else ur:relPathREC($path1, $path2)
};

declare function ur:relPathToContext($context as xs:string, 
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
declare function ur:relPathREC($path1 as xs:string, $path2 as xs:string)
        as xs:string? {
    if ($path1 eq $path2) then '.' else
    
    let $path1Slash := replace($path1, '[^/]$', '$0/')
    return
        if (starts-with($path2, $path1Slash)) then substring-after($path2, $path1Slash)
        else if (not(matches($path1Slash, '/.*/'))) then ()
        else string-join(
            let $nextPath1 := (replace($path1Slash, '^(.*)/.*?/$', '$1')[string()], '/')[1]
            return ('..', ur:relPathREC($nextPath1, $path2)[. ne '.'][string()]), '/')       
};

(:~
 : Returns the relative path leading from $uri1 to $uri2.
 :)
declare function ur:relUri($uriOrPath1 as xs:string, $uriOrPath2 as xs:string)
        as xs:string? {
    if ($uriOrPath1 eq $uriOrPath2) then '.' else
    
    let $scheme1 := ur:extractUriScheme($uriOrPath1)
    let $scheme2 := ur:extractUriScheme($uriOrPath2)
    return if ($scheme1 ne $scheme2 or $scheme2 ne 'file') then $uriOrPath2 else
    
    let $path1 := ur:removeUriScheme($uriOrPath1)
    let $path2 := ur:removeUriScheme($uriOrPath2)
    return ur:relPath($path1, $path2)
};    
(:~
 : Removes the URI schema from a URI or path.
 :
 : @param pathOrUri a relative or absolute path or URI
 : @return the URI scheme, or the empty sequence
 :)
declare function ur:removeUriScheme($uriOrPath as xs:string?) as xs:string? {
    replace($uriOrPath, '^[a-z][a-z]+:/+([a-zA-Z]:.*|/.*)', '$1')
};

(:~
 : Returns a "doc resource", which is a map with entries
 : '_objecttype', 'doc' and 'uri'.
 :)
declare function ur:docResource($resource as item()?,
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
declare function ur:textfileResource($resource as item()?)
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
declare function ur:updateDocResourceContent($resource as map(*), 
                                            $doc as node())
        as map(*) {
    map:put($resource, 'doc', $doc)            
};        

(:~
 : Returns true if a given item is an instance of a doc-resource.
 :)
declare function ur:instanceOfDocResource($item as item())
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
declare function ur:itemToNode($item as item(), $options as map(*))
        as node()? {
    if ($item instance of node()) then $item 
    else if (ur:instanceOfDocResource($item))then $item?doc
    else i:fox-doc($item, $options)
};        

(:~
 : Returns true if a file exists, false otherwise.
 : Wraps the file:exists function, catching exceptions.
 :)
declare function ur:fileExists($uri as xs:string)
        as xs:boolean {
    try {file:exists($uri)} catch * {false()}        
};

(:~
 : Writes a document resource to the file system.
 :)
declare function ur:writeDocResource($path as xs:string, 
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
declare function ur:writeTextfileResource($path as xs:string, 
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

        
