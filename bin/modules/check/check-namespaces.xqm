module namespace f="http://www.foxpath.org/ns/fox-functions/check-namespaces";
import module namespace i="http://www.ttools.org/xquery-functions" 
at "../../foxpath-uri-operations.xqm";

(:~
 : Writes a set of standard attributes. Can be useful when working
 : with `xelement`.
 :
 : @param node element or document node
 : @param format result format; p|u|pu for prefixes, URIs, prefix=URI items
 : @param flags flags for future use
 : @return the attributes
 :)
declare function f:checkUnusedNamespaces($items as item()*, 
                                         $format as xs:string?, 
                                         $flags as xs:string?)
        as item()* {
    if (empty($items)) then () else
    
    let $format := ($format, 'pu')[1]
    let $roots :=
        $items ! ( 
        typeswitch(.) 
        case node() return root(.)/descendant-or-self::*[1]
        default return i:fox-doc(., ())/*)
                
    let $bindings := (
        for $e in $roots
        for $prefix in in-scope-prefixes($e)[string(.)][. ne 'xml']
        let $uri := namespace-uri-for-prefix($prefix, $e)
        let $binding := $prefix||'='||$uri
        return $binding 
        ) => distinct-values() => sort()
        
    let $nameUses := (
        for $e in $roots/descendant-or-self::*/(., @*)
        let $uri := namespace-uri($e)
        where string($uri)
        let $name := $e/name()
        where $e/contains(name(.), ':')
        return replace($name, ':.*', '')||'='||$uri 
        ) => distinct-values() => sort()
    let $bindingsUnused := $bindings[not(. = $nameUses)] 
    return $bindingsUnused
};
