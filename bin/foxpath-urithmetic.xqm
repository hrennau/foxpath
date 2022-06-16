module namespace f="http://www.foxpath.org/ns/urithmetic";

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
