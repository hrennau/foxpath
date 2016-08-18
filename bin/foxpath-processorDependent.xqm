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

(:~
 : Tests if $path points to a directory.
 :
 : @param path the path to be checked
 :)
declare function f:isDirectory($path as xs:string) as xs:boolean {
    file:is-dir($path)
};

(:~
 : Tests if $path points to a file.
 :
 : @param path the path to be checked
 :)
declare function f:isFile($path as xs:string) as xs:boolean {
    file:is-file($path)
};

(:~
 : Returns the last modification time of a file or directory.
 :
 : @param path the path of the file or directory
 :)
declare function f:fileLastModified($path as xs:string) as xs:dateTime? {
    $path ! file:last-modified($path)
};

(:~
 : Returns the byte size of a file, or the value 0 for a directory.
 :
 : @param path the path of the file or directory
 :)
declare function f:fileSize($path as xs:string?) as xs:integer? {
    $path ! file:size($path)
};