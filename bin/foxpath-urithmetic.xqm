module namespace f="http://www.foxpath.org/ns/urithmetic";

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
 : @param path a path
 : @return the normalized path
 :)
declare function f:normalizePath($path as xs:string?) as xs:string? {
    $path ! replace(., '\\', '/') ! replace(., '/$', '')                 
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
    return if ($scheme1 ne $scheme2) then $uriOrPath1 else
    
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

