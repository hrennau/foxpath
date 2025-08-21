(:
 : util-nodeContent.xqm - tools for reporting node content
 :)
module namespace uncont="http://www.parsqube.de/xquery/util/node-content";
import module namespace unfilter="http://www.parsqube.de/xquery/util/name-filter"
  at "util-nameFilter.xqm";
import module namespace uns="http://www.parsqube.de/xquery/util/namespace"
  at "util-namespace.xqm";
import module namespace ufpath="http://www.parsqube.de/xquery/util/file-path"
  at "util-filePath.xqm";
import module namespace unpath="http://www.parsqube.de/xquery/util/node-path"
  at "util-nodePath.xqm";

(:~
 : Returns the qualified paths of a given node and its
 : content nodes. A qualified path is a path using
 : normalized namespace prefixes.
 :
 : Options:
 : - customNamespaceBindings - an element containing
 :     <namespace> elements with @prefix and @uri
 :     attributes defining a namespace binding
 :)
declare function uncont:qualifiedContentPaths(
                        $node as node(),
                        $options as map(xs:string, item()*)?)
        as xs:string+ {
    let $nodes := $node/descendant-or-self::node()/(*, @*)    
    let $nsmap := 
        let $customNsBindings := $options?customNsBindings return
            $nodes         
            ! node-name(.)
            => distinct-values()
            => uns:getNamespaceMap($options?customNsBindings)
    return $nodes/unpath:qualifiedNodePath(., $nsmap, $options)
           => sort()        
};        

(:~
 : Returns descriptions of the leaf nodes contained by a given node.
 : Here, leaf nodes are understood as attributes and simple content 
 : elements.
 :
 : Options:
 : - customNamespaceBindings - an element containing
 :     <namespace> elements with @prefix and @uri
 :     attributes defining a namespace binding
 : - wrapper - 'yes' or 'no', indicating if the descriptors
 :     are wrapped in the following way:
 :     <nodeContent uri="base-URI of $node">
 :         <nsmap><!-- namespace map --></nsmap>
 :         <items>
 :             <item path="..." value="..."/>
 :             ...
 :         </items>
 :     </nodeContent>
 : - ignoreEmptyElems - a sequence of name filters;
 :       element nodes which have empty content are
 :       not reported if their local name matches
 :       one of the specified name filters
 : - ignoreEmptyAtts - a sequence of name filters;
 :       attribute nodes which have an empty value are
 :       not reported if their local name matches
 :       one of the specified name filters
 :)
declare function uncont:nodeContentReport(
                        $node as node(), 
                        $options as map(xs:string, item()*)?) 
        as element()* {
    let $ignEmptyElems := $options?ignoreEmptyElems
    let $ignEmptyElemsNF := $ignEmptyElems ! unfilter:parseNameFilter(.)
    let $ignEmptyAtts := $options?ignoreEmptyAtts
    let $ignEmptyAttsNF := $ignEmptyAtts ! unfilter:parseNameFilter(.)
    let $nodes := $node/descendant-or-self::node()/(*[not(*)], @*)   
    let $nsmap :=
        let $customNsBindings := $options?customNsBindings return    
            $nodes         
            ! node-name(.)
            => distinct-values()
            => uns:getNamespaceMap($options?customNsBindings)
    let $fnPath :=
        if ($options?indexed) then unpath:indexedQualifiedNodePath#3
        else unpath:qualifiedNodePath#3
    let $descriptors := 
        for $node in $nodes
        let $path := $node/$fnPath(., $nsmap, $options)
        let $value := $node/string()
        where $value or
              $node instance of element() and (
                  empty($ignEmptyElemsNF) or 
                      not(unfilter:matchesNameFilters(
                          $node/local-name(.), $ignEmptyElemsNF)))
              or $node instance of attribute() and (
                  empty($ignEmptyAttsNF) or 
                      not(unfilter:matchesNameFilters(
                          $node/local-name(.), $ignEmptyAttsNF)))
        order by $path
        return <item path="{$path}" value="{$node}"/>
    return
        if ($options?wrapper) then
            let $contextPath := $options?contextPath
            let $rootName := ($options?rootName, 'docContent')[1]
            let $docUri := 
                let $baseUri := $node ! base-uri(.)
                return
                    if ($contextPath) then ufpath:relativePath($baseUri, $contextPath)
                    else $baseUri
            let $fragmentPath :=
                if ($node/parent::*) then unpath:qualifiedNodePath($node, $nsmap, ()) else ()
            let $uri := string-join(($docUri, $fragmentPath), '#')
            return
                element {$rootName} {
                    uns:getNamespaceNodesForNsMap($nsmap),
                    attribute uri {$uri},
                    attribute countItems {count($descriptors)},                    
                    $descriptors
                }
        else $descriptors
};        

