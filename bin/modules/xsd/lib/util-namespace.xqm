module namespace uns="http://www.parsqube.de/xspy/util/namespace";
import module namespace const="http://www.parsqube.de/xspy/constants"
    at "constants.xqm";
declare namespace z="http://www.parsqube.de/xspy/structure";

declare variable $uns:URI_XSD := "http://www.w3.org/2001/XMLSchema";

(:~
 : Creates a map associating all target namespaces with normalized prefixes.
 : A normalized prefix is either customized prefix or a computed prefix. 
 : Customized namespace bindings are defined by config data:
 :   config/namespaces/namespace/(@prefix, @uri)
 : 
 : The map contains additional entries, associating the prefix 'z' with the 
 : namespace of xco structures, 'xml' and 'xs' with the official xml and XSD
 : namespaces.
 :
 : @schemas the schemas to be evaluated
 : @return a map containing prefix/uri pairs
 :)
declare function uns:getTnsPrefixMap($schemas as element(xs:schema)*,
                                     $custom as element()?)
      as element(z:nsMap) {
   let $customBindings := $custom/namespaces/namespace
   let $tnss := 
      for $t in distinct-values($schemas/@targetNamespace)
      order by lower-case($t) 
      return $t
    let $tnssCustom := $tnss[. = $customBindings/@uri]      
   return
      <z:nsMap>{
         (: Customized bindings :)
         for $tns in $tnssCustom
         return $customBindings[@uri eq $tns]/<z:ns prefix="{@prefix}" uri="{$tns}"/>,
         (: Computed bindings :)
         let $prefixTnsPairs := $tnss[not(. = $tnssCustom)] => uns:_getPrefixTnsPairs()
         for $pair in $prefixTnsPairs
         let $prefix := substring-before($pair, ':')
         let $tns := substring-after($pair, ':')
         where not($tns eq $uns:URI_XSD)         
         return
            <z:ns>{
               attribute prefix {$prefix},
               attribute uri {$tns}
            }</z:ns>,
         (: Standard bindings :)
         <z:ns prefix="xml" uri="http://www.w3.org/XML/1998/namespace"/>,
         <z:ns prefix="xs" uri="http://www.w3.org/2001/XMLSchema"/>,
         <z:ns prefix="z" uri="http://www.parsqube.de/xspy/structure"/>
      }</z:nsMap>
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
 : @tnss the target namespaces
 : @return the prefix/tns pairs
 :)
declare function uns:_getPrefixTnsPairs($tnss as xs:string*) 
      as xs:string* {
   for $tns at $pos in $tnss
   let $seriesNr := ($pos - 1) idiv 25
   let $postfix := if (not($seriesNr)) then () else $seriesNr + 1
   let $p := 1 + ($pos - 1) mod 25
   let $char := substring('abcdefghijklmnopqrstuvwxy', $p, 1)
   let $prefix := concat($char, $postfix)
   where not($tns eq 'http://www.w3.org/XML/1998/namespace')
   return concat($prefix, ':', $tns)
};

(:~
 : Normalizes a QName in accordance with a map of namespace bindings.
 :
 : @param qname the QName to be normalized
 : @param nsmap a map representing the binding of namespace prefixes
 : @return the normalized QName
 :)
declare function uns:normalizeQName(
                        $qname as xs:QName, 
                        $nsmap as element(z:nsMap)?) 
        as xs:QName {
        
   if (empty($nsmap)) then $qname
   else
      let $uri := namespace-uri-from-QName($qname)[string()]
                    (: if no namespace, the URI must be empty sequence :)
      return
         if (empty($uri)) then $qname else

         let $prefix := $nsmap/z:ns[@uri eq $uri]/@prefix
         return
             if (empty($prefix)) then $qname else
             let $lexName := string-join(($prefix, local-name-from-QName($qname)), ':')
             return QName($uri, $lexName)
};

(:~
 : Normalizes the attribute value which is a qualified name.
 :
 : @param qname the QName to be normalized
 : @param nsmap a map representing the binding of namespace prefixes
 : @return the normalized QName
 :)
declare function uns:normalizeAttValueQName(
                        $att as attribute(), 
                        $nsmap as element(z:nsMap)?) 
        as xs:QName {
    $att ! resolve-QName(.,..) ! uns:normalizeQName(., $nsmap)
};    

(:~
 : Normalizes a component name in accordance with a map of namespace bindings.
 :
 : @param comp the component element
 : @param nsmap a map representing the binding of namespace prefixes
 : @return the normalized QName
 :)
declare function uns:normalizeCompName(
                        $comp as element(), 
                        $nsmap as element(z:nsMap)?) 
        as xs:QName {
    let $tns := $comp/ancestor::xs:schema/@targetNamespace
    return $comp/QName($tns, @name) ! uns:normalizeQName(., $nsmap)
};

(:~
 : Resolves the lexical form of a normalized QName to a QName.
 : The prefix is retained.
 :) 
declare function uns:resolveNormalizedQName($name as xs:string,
                                            $nsmap as element(z:nsMap))
        as xs:QName {
    let $prefix := $name ! replace(., ':.*', '')[. ne $name]
    return
        if (not($prefix)) then
            let $ns := $nsmap/z:ns[@prefix/normalize-space(.) eq '']
            let $uri := $ns/@uri
            return QName($uri, $name)
        else
            let $ns := $nsmap/z:ns[@prefix eq $prefix]
            return
                if (not($ns)) then error(QName((), 'INVALID_ARG'), 
                        'Cannot resolve namespace of name: '||$name) 
                else
                    let $lname := $name ! replace(., '^.*:', '')
                    return QName($ns/@uri, $name) 
};  

(:~
 : Creates a set of namespace nodes corresponding to a namespace map.
 :)
declare function uns:namespaceMapToNodes($nsmap as element(z:nsMap))
        as namespace-node()* {
    for $ns in $nsmap/* return $ns/namespace {@prefix} {@uri}        
};   

(:~
 : Copies the namespace nodes of an element.
 :)
declare function uns:copyNamespaces($elem as element())
        as namespace-node()* {
    $elem/in-scope-prefixes(.) ! namespace {.} {namespace-uri-for-prefix(., $elem)}        
};

declare function uns:isQNameBuiltin($qname as xs:QName)
        as xs:boolean {
    $qname ! (namespace-uri-from-QName(.) eq $const:URI_XSD)        
};      

declare function uns:getNamespaceProlog($nsmap as element(z:nsMap))
        as xs:string {
    let $decls := $nsmap/*[@prefix ne 'xml']/('declare namespace '||@prefix||'="'||@uri||'";')
    return ($decls => string-join('&#xA;'))||'&#xA;'
};        