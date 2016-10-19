module namespace f="http://www.ttools.org/xquery-functions";

(:~
 : Evaluates the an XQuery expression supplied as a string.
 :
 : @param xquery the XQuery expression
 : @param context bindings of variables to names; a binding to the zero-length
 :     string is interpreted as context item 
 :)
declare function f:xquery($xquery as xs:string?, $context as map(*)?)
        as item()* {
    if (exists($context)) then xquery:eval($xquery, $context) 
    else xquery:eval($xquery)        
};

(:~
 : Returns the current directory. The directory is represented
 : in a normalized format: using forward slashes and without
 : a trailing slash.
 :)
declare function f:currentDirectory() as xs:string? {
    replace(replace(file:current-dir(), '\\', '/'), '/$', '')
};

(:
(:~
 : Tests if $path points to a directory.
 :
 : Note. For the time being, if $path is a http(s)::// URI the
 : function returns the empty sequence.
 :
 : @param path the path to be checked
 :)
declare function f:isDirectory($path as xs:string) as xs:boolean? {
    if (matches($path, '^https?://')) then ()
    else file:is-dir($path)
};

(:~
 : Tests if $path points to a file.
 :
 : Note. For the time being, if $path is a http(s)::// URI the
 : function returns the empty sequence.
 :
 : @param path the path to be checked
 :)
declare function f:isFile($path as xs:string, $options as map(*)?) as xs:boolean? {
    if (matches($path, '^https?://')) then 
        let $rtrees := 
            if (empty($options)) then ()
            else map:get($options, 'URI_TREES')
        return
            $path = (
                for $rtree in $rtrees
                    [starts-with($path, @uriPrefix)]
                    /tree[starts-with($path, @baseURI)]
                let $baseUri := $rtree/@baseURI
                for $file in $rtree//file
                return concat($baseUri, $file/@path)
                )
    else file:is-file($path)
};
:)

(:
(:~
 : Returns the last modification time of a file or directory.
 :
 : @param path the path of the file or directory
 :)
declare function f:fileLastModified($path as xs:string) as xs:dateTime? {
    $path ! file:last-modified($path)
};
:)

(:
(:~
 : Returns the byte size of a file, or the value 0 for a directory.
 :
 : @param path the path of the file or directory
 :)
declare function f:fileSize($path as xs:string?) as xs:integer? {
    $path ! file:size($path)
};
:)