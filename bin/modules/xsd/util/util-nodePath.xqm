(:
 : util-nodePath.xqm - tools for creating and resolving node paths.
 :)
module namespace unpath="http://www.parsqube.de/xquery/util/node-path";
import module namespace ufpath="http://www.parsqube.de/xquery/util/file-path"
  at "util-filePath.xqm";
import module namespace unfilter="http://www.parsqube.de/xquery/util/name-filter"
  at "util-nameFilter.xqm";
import module namespace uns="http://www.parsqube.de/xquery/util/namespace"
  at "util-namespace.xqm";
import module namespace rgx="http://www.parsqube.de/xquery/util/regex"
  at "util-regex.xqm";

(: 
   === indexedNodePath()========================================== 
 :)
(:~
 : Returns the indexed node path of a given node, using local names.
 :
 : @param node a node
 : @param options options
 : @return a path string
 :)
declare function unpath:indexedNodePath(
                        $node as node(), 
                        $options as map(xs:string, item()*)?)                        
        as xs:string {
    let $fnNamePlusIndex := function($node) {
        let $name := $node ! local-name(.)     
        let $index := 
            if ($node instance of attribute()) then ()
            else 1 + count($node/preceding-sibling::*[local-name(.) eq $name])
        return $name||'['||$index||']'
    }
    let $nameStep := 
        ('@'[$node instance of attribute()]||$fnNamePlusIndex($node))
    let $ancs := $node/ancestor::*                     
    let $ancSteps := $ancs/$fnNamePlusIndex(.)
    let $docStep := ''[$node/root()/self::document-node()]
    return      
        ($docStep, $ancSteps, $nameStep) => string-join('/')
};        

(: 
   === indexedQualifiedNodePath()================================= 
 :)
(:~
 : Returns the indexed node path of a given node, using qualified names with
 : normalized prefixes.
 :
 : @param node a node
 : @param nsmap a map describing normalized namespace bindings
 : @param options options
 : @return a path string
 :)
declare function unpath:indexedQualifiedNodePath(
                        $node as node(), 
                        $nsmap as element(nsMap)?,
                        $options as map(xs:string, item()*)?)                        
        as xs:string {
    let $fnNamePlusIndex := function($node) {
        let $name := 
            $node ! node-name(.) ! uns:normalizeQName(., $nsmap)     
        let $index := 
            if ($node instance of attribute()) then ()
            else 1 + count($node/preceding-sibling::*[node-name(.) eq $name])
        return $name||($index ! ('['||.||']'))
    }
    let $nameStep := 
        ('@'[$node instance of attribute()]||$fnNamePlusIndex($node))
    let $ancs := $node/ancestor::*                     
    let $ancSteps := $ancs/$fnNamePlusIndex(.)
    let $docStep := ''[$node/root()/self::document-node()]
    return      
        ($docStep, $ancSteps, $nameStep) => string-join('/')
};        

(: 
   === nodePath()================================================= 
 :)
(:~
 : Returns the node path of a given node, using local names.
 :
 : @param node a node
 : @param options options
 : @return a path string
 :)
declare function unpath:nodePath(
                        $node as node(), 
                        $options as map(xs:string, item()*)?)                        
        as xs:string {
    let $nameStep := '@'[$node instance of attribute()]||$node/local-name(.)
    let $ancs := $node/ancestor::*                     
    let $ancSteps := $ancs/local-name(.)
    let $docStep := ''[$node/root()/self::document-node()]
    return      
        ($docStep, $ancSteps, $nameStep) => string-join('/')
};        

(: 
   === qualifiedNodePath()======================================== 
 :)
(:~
 : Returns the node path of a given node, using qualified names with
 : normalized prefixes.
 :
 : @param node a node
 : @param nsmap a map describing normalized namespace bindings
 : @param options options
 : @return a path string
 :)
declare function unpath:qualifiedNodePath(
                        $node as node(), 
                        $nsmap as element(nsMap)?,
                        $options as map(xs:string, item()*)?)                        
        as xs:string {
    let $nameStep := '@'[$node instance of attribute()]||
                     $node/uns:normalizeQName(node-name(.), $nsmap)
    let $ancs := $node/ancestor::*                     
    let $ancSteps := $ancs/uns:normalizeQName(node-name(.), $nsmap)
    let $docStep := ''[$node/root()/self::document-node()]
    return      
        ($docStep, $ancSteps, $nameStep) => string-join('/')
};        

(: 
   === resolveIndexedQualifiedNodePath()========================== 
 :)
(:~
 : Resolves an indexed qualified node path to nodes.
 :
 : @param context the context nodes
 : @param path an indexed qualified node path
 : @param nsmap namespace bindings to be used for resolving QNames
 : @return the nodes selected by the path
 :)
declare function unpath:resolveIndexedQualifiedNodePath(
                        $context as node()*,
                        $path as xs:string, 
                        $nsmap as element(nsMap)?)
        as node()* {
    let $context2 :=
        if (starts-with($path, '/')) then $context/root()[self::document-node()]
        else $context
    let $path2 := $path ! replace(., '^/', '')
    let $steps := tokenize($path2, '/')
    return
        unpath:resolveIndexedQualifiedNodePathREC($context2, $steps, $nsmap)        
};

declare %private function unpath:resolveIndexedQualifiedNodePathREC(
                          $context as node()*,
                          $steps as xs:string*, 
                          $nsmap as element(nsMap)?)
        as node()* {
    if (empty($context)) then () else
    let $head := $steps => head()
    let $tail := $steps => tail()
    let $name := $head ! replace(., '^@|\[.*', '')
    let $isAtt := starts-with($head, '@')
    let $contextNew :=

        if ($name eq '.') then $context
        else if ($name eq '..') then $context ! ..
        else
    
        let $fnNametest :=
            if (not(contains($name, '*'))) then
                let $qname := $name ! uns:resolveLexName(., $nsmap, $isAtt)
                return function($node) {node-name($node) eq $qname}
            else
                let $lname := $name ! replace(., '^.*?:', '')
                let $prefix := substring-before($name, ':')
                let $lnameRegex :=
                    if (not(contains($lname, '*'))) then ()
                    else $lname ! rgx:globToRegex(., ())
                let $ns := 
                    if ($prefix eq '*') then '#ANY'
                    else $nsmap/ns[@prefix eq $prefix]/@uri
                return
                    if ($ns eq '#ANY') then
                        if ($lnameRegex) then function($node) { 
                            matches(local-name($node), $lnameRegex)}
                        else function($node) { 
                            local-name($node) eq $lname}
                    else if ($lnameRegex) then function($node) { 
                            $ns eq namespace-uri($node) and 
                            matches(local-name($node), $lnameRegex)}
                    else function($node) { 
                         $ns eq namespace-uri($node) and local-name($node) eq $lname}
        return
            if ($isAtt) then $context/@*[$fnNametest(.)]
            else
                let $index := $head !
                    replace(., '.*\[(.*)\].*', '$1')[not(. eq $head)] ! xs:integer(.)
                return $context/*[$fnNametest(.)][empty($index) or position() eq $index]
    return
        if (empty($tail)) then $contextNew else 
            $contextNew => 
            unpath:resolveIndexedQualifiedNodePathREC($tail, $nsmap) 
};
