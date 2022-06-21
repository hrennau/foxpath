module namespace f="http://www.foxpath.org/ns/urithmetic";

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
 : Normalizes a URI by removing the file scheme, if present. 
 :
 : @param uri a URI
 : @return the normalized URI
 :)
declare function f:normalizeUri($uri as xs:string?) as xs:string? {
    if (not($uri)) then $uri else
    
    replace($uri, '^file:/*(/.*|.:($|/.*))', '$1')
    ! trace(replace(., '^[^/]:', '$0/'), '_REP2: ')
};    
