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
