(:
 : util-namespace.xqm - namespace-related tool functions.
 :)
module namespace uns="http://www.parsqube.de/xquery/util/namespace";

declare variable $uns:NAMESPACE_URIS := map{
    'xsl': 'http://www.w3.org/1999/XSL/Transform'
};

(: 
   === addNamespaceContext()======================================= 
 :)
(:~
 : Adds to an element the namespace bindings described by a namespace map.
 :
 : @param elem the element to be modified
 : @param nsmap a namespace map, associating prefixes with URIs
 : @param options currently not evaluated
 : @return a copy of the element with namespace bindings added
 :)
declare function uns:addNamespaceContext($elem as element(), 
                                         $nsmap as element(nsMap),
                                         $options as map(xs:string, item()*)?)
        as element() {
    element {node-name($elem)} {
        if ($options?discard) then () else
        $elem/in-scope-prefixes(.) 
            ! namespace {.} {namespace-uri-for-prefix(., $elem)},
        $nsmap/xquery/namespace {@prefix} {@uri},
        $elem/@*,
        ($options?baseUri ! attribute xml:base {.})[not($elem/@xml:base)],
        $elem/node()
    }
};  

(: 
   === getNamespaceMap()========================================== 
 :)
(:~
 : Defines the association of namespace URIs with normalized prefixes. The
 : namespaces are extracted from supplied qualified names.
 :
 : A normalized prefix is either a customized prefix or a computed prefix. 
 : Customized namespace bindings are defined by config data:
 :   <namespaces>/<namespace>/(@prefix, @uri)
 : 
 : The map contains two additional entries, associating the prefixes 'xml' and 
 : 'xs' with the official XML and XSD namespaces.
 :
 : @param qnames a set of qualified names
 : @param custom an optional element defining customized namespace bindings 
 : @return an element with child elements defining prefix/uri pairs via 
 :   attributes @prefix and @uri
 :)
declare function uns:getNamespaceMap($qnames as xs:QName*,
                                     $custom as element(namespaces)?)
      as element(nsMap) {
    let $customBindings := $custom/namespace
    let $uris := (
        for $qname in distinct-values($qnames)
        let $ns := $qname ! namespace-uri-from-QName(.)
        where $ns
        return $ns
        ) => distinct-values() => sort()
   let $urisCustom := $uris[. = $customBindings/@uri]      
   return
      <nsMap>{
         (: Customized bindings :)
         for $uri in $urisCustom
         return $customBindings[@uri eq $uri]/<ns prefix="{@prefix}" uri="{$uri}"/>,
         (: Computed bindings :)
         let $prefixUriPairs := $uris[not(. = $urisCustom)] => uns:_getPrefixUriPairs()
         for $pair in $prefixUriPairs
         let $prefix := substring-before($pair, ':')
         let $uri := substring-after($pair, ':')
         return
            <ns>{
               attribute prefix {$prefix},
               attribute uri {$uri}
            }</ns>,
         (: Standard bindings :)
         <ns prefix="xml" uri="http://www.w3.org/XML/1998/namespace"/>,
         <ns prefix="xs" uri="http://www.w3.org/2001/XMLSchema"/>
      }</nsMap>
};

(:~
 : Returns for a sequence of namespace URIs the normalized prefixes. For each 
 : namespace a colon-separated concatenation of prefix and namespace URI is 
 : returned. Normalized prefixes are the lower case letters corresponding to 
 : the position of the namespace URI within the list of namespace URIs. If 
 : the position is gt 25, the letters are reused and a suffix is appended 
 : which indicates the number of the current letter cycle (2, 3, ...). The 
 : prefixses therefore are:
 : 'a', 'b', 'c', ..., 'x', 'y', 'a2', 'b2', .....
 :
 : @param sequence of namespace URIs
 : @return sequence of prefix/uri pairs
 :)
declare function uns:_getPrefixUriPairs($uris as xs:string*) 
      as xs:string* {
   for $uri at $pos in $uris
   let $seriesNr := ($pos - 1) idiv 25
   let $postfix := if (not($seriesNr)) then () else $seriesNr + 1
   let $p := 1 + ($pos - 1) mod 25
   let $char := substring('abcdefghijklmnopqrstuvwxy', $p, 1)
   let $prefix := concat($char, $postfix)
   where not($uri eq 'http://www.w3.org/XML/1998/namespace')
   return concat($prefix, ':', $uri)
};

(:~
 : Returns a namespace map representing the namespace bindings defined by a
 : node and (optionally) all content nodes.
 :
 : The function returns the empty sequence if conflicting namespace bindings
 : are encountered, that is, if a prefix is bound to more than one namespace
 : URI, or more than one default namespaces are encountered.
 :
 : @param node a node
 : @param deep if true, also the namespace bindings defined by descendant 
 :   nodes of $node are considered
 : @return a namespace map representing the namespace bindings, or the
 :   empty sequence, if conflicting namespace bindings are encountered
 :)
declare function uns:getNamespaceBindings($node as node(), $deep as xs:boolean?)
      as element(nsMap)? {
    let $nodes := if ($deep) then $node/descendant-or-self::* else $node      
    let $bindings := (      
        for $cnode in $nodes
        let $prefixes := in-scope-prefixes($cnode)
        return $prefixes ! (.||':'||namespace-uri-for-prefix(., $cnode))
        ) => distinct-values() => sort()
    let $nsElems :=
        for $binding in $bindings
        let $prefix := substring-before($binding, ':')
        group by $prefix
        order by $prefix
        return
            if (count($binding) gt 1) then <ERROR/>
            else <ns prefix="{$prefix}" uri="{substring-after($binding, ':')}"/>
    return
        if ($nsElems/self::ERROR) then ()
        else <nsMap>{$nsElems}</nsMap>
};

(: 
   === getNamespaceNodes()======================================== 
 :)
(:~
 : Returns the namespace nodes of an element.
 :
 : @param elem an element
 : @return a copy of its namespace nodes
 :)
declare function uns:getNamespaceNodes($elem as element())
        as node()* {
    $elem/in-scope-prefixes(.)[string()]
    ! namespace {.} {namespace-uri-for-prefix(., $elem)}
};        

(: 
   === getNamespaceNodesForNsMap()================================ 
 :)
declare function uns:getNamespaceNodesForNsMap($nsmap as element(nsMap))
        as node()* {
    $nsmap/ns ! namespace {@prefix} {@uri}
};        

(: 
   === normalizeQName()=========================================== 
 :)
(:~
 : Normalizes a QName in accordance with a map of namespace bindings.
 :
 : @param qname the QName to be normalized
 : @param nsmap a map representing the binding of namespace prefixes
 : @return the normalized QName
 :)
declare function uns:normalizeQName(
                        $qname as xs:QName, 
                        $nsmap as element(nsMap)?) 
        as xs:QName {
        
   if (empty($nsmap)) then $qname
   else
      let $uri := namespace-uri-from-QName($qname)[string()]
                    (: if no namespace, the URI must be empty sequence :)
      return
         if (empty($uri)) then $qname else

         let $prefix := $nsmap/ns[@uri eq $uri]/@prefix
         return
             if (empty($prefix)) then $qname else
             let $lexName := string-join(
                ($prefix[string()], local-name-from-QName($qname)), ':')
             return QName($uri, $lexName)
};

(: 
   === resolveLexName()=========================================== 
 :)
(:~
 : Resolves a lexical name to a QName, based on a namespace map.
 :
 : @param name a lexical name
 : @param nsmap a map representing the binding of namespace prefixes
 : @return a QName
 :)
declare function uns:resolveLexName(
                        $name as xs:string, 
                        $nsmap as element(nsMap)?,
                        $ignDefaultNamespace as xs:boolean?) 
        as xs:QName {
    let $prefix := $name ! substring-before(., ':')
    let $uri := $nsmap/ns
                [@prefix/string() or not($ignDefaultNamespace)]
                [@prefix eq $prefix]/@uri
    return QName($uri, $name)
};

(: 
   === resolveNormalizedLexName()================================= 
 :)
(:~
 : Resolves a normalized lexical name to a QName.
 :
 : @param name a normalized lexical name
 : @param nsmap a map representing the binding of namespace prefixes
 : @return a QName
 :)
declare function uns:resolveNormalizedLexName(
                        $name as xs:string, 
                        $nsmap as element(nsMap)?) 
        as xs:QName {
    if (not(contains($name, ':'))) then QName((), $name) else        
    
    let $prefix := replace($name, '^(.+):.*', '$1')
    let $uri := $nsmap/ns[@prefix eq $prefix]/@uri
    return QName($uri, $name)
};





