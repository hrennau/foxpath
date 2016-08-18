module namespace f="http://www.ttools.org/xquery-functions";
import module namespace i="http://www.ttools.org/xquery-functions" at 
    "foxpath-processorDependent.xqm",
    "foxpath-util.xqm";

declare function f:childUriCollection($uri as xs:string, $name as xs:string?) {
    try {
        file:list($uri, false(), $name)           
        ! replace(., '\\', '/')
        ! replace(., '/$', '')
    } catch * {()}
};

declare function f:descendantUriCollection($uri as xs:string, $name as xs:string?) {
    try {
        file:list($uri, true(), $name)           
        ! replace(., '\\', '/')
        ! replace(., '/$', '')
    } catch * {()}        
};
