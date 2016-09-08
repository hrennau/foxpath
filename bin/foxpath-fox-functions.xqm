module namespace f="http://www.ttools.org/xquery-functions";
import module namespace i="http://www.ttools.org/xquery-functions" at 
    "foxpath-processorDependent.xqm",
    "foxpath-resourceTreeTypeDependent.xqm",
    "foxpath-util.xqm";

(:~
 : Foxpath function `bslash#1'. Edits a text, replacing forward slashes by 
 : back slashes.
 :
 : @param arg text to be edited
 : @return edited text
 :)
declare function f:foxfunc_bslash($arg as xs:string?)
        as xs:string? {
    replace($arg, '/', '\\')        
};        