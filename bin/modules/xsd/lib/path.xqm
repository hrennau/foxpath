(:
 : Functions creating a type inventory
 :)
module namespace path="http://www.parsqube.de/xspy/report/path";
import module namespace uns="http://www.parsqube.de/xspy/util/namespace"
    at "util-namespace.xqm";
import module namespace dict="http://www.parsqube.de/xspy/util/dictionaries"
    at "dictionaries.xqm";
import module namespace coto="http://www.parsqube.de/xspy/util/component-tools"    
    at "component-tools.xqm";
import module namespace navi="http://www.parsqube.de/xspy/util/navigation"
    at "navigation.xqm";
import module namespace navi2="http://www.parsqube.de/xspy/util/navigation2"
    at "navigation2.xqm";
import module namespace ufpath="http://www.parsqube.de/xquery/util/file-path"
    at "../util/util-filePath.xqm";
import module namespace unamef="http://www.parsqube.de/xquery/util/name-filter"
    at "../util/util-nameFilter.xqm";
declare namespace z="http://www.parsqube.de/xspy/structure";

(:~
 : Creates a type inventory.
 :)
declare function path:getPathReport($schemas as element(xs:schema)*,  
                                    $mode as xs:string,
                                    $ops as map(*)?)
        as item()* {
    let $nsmap := uns:getTnsPrefixMap($schemas, ())  
    let $compDict := dict:getCompDict($schemas, ())
    let $elemTypeDict := dict:getElementTypeDict($compDict, $nsmap)
    let $elemRefDict := dict:getElementRefDict($compDict, $nsmap)
    let $groupRefDict := dict:getGroupRefDict($compDict, $nsmap)
    let $typesUsingGroupDict := dict:getTypesUsingGroupDict($compDict, $groupRefDict, $nsmap)
    let $sgroupDict := dict:getSgroupDict($compDict, $nsmap)
    let $inheritanceTree := dict:compDict_inheritanceTree($compDict, $nsmap)    
    let $options :=
        map:put($ops, 'nsmap', $nsmap) !
        map:put(., 'elemTypeDict', $elemTypeDict) ! 
        map:put(., 'elemRefDict', $elemRefDict) !
        map:put(., 'groupRefDict', $groupRefDict) !
        map:put(., 'typesUsingGroupDict', $typesUsingGroupDict) !
        map:put(., 'sgroupDict', $sgroupDict) !
        map:put(., 'compDict', $compDict) ! 
        map:put(., 'inheritanceTree', $inheritanceTree) !
        map:put(., 'nsmap', $nsmap)
        
    let $item := $ops?itemName
    let $elems := if (not($item)) then dict:compDict_getAllElems($compDict)
                  else dict:compDict_getElemsMatchingName($item, $compDict)
    let $result :=
        switch($mode)
        case 'parent' return (
            for $elem in $elems
            let $name := $elem/(@name, @ref)
            let $_DEBUG := trace($name, '_ Process element: ')
            let $parent := $elem ! navi:getParentElem(., $compDict, $nsmap, $options)
            let $parentNames := $parent/(@name, @ref) => distinct-values() => sort()
            for $parentName in $parentNames 
            return $parentName||'/'||$name
            ) => distinct-values() => sort()
        case 'path' return
            let $length := $ops?length
            let $_DEBUG := trace($length, '_ length: ')
            for $elem in $elems
            let $name := $elem/(@name, @ref)
            let $_DEBUG := trace($name, '_ Process element: ')
            let $paths := $elem ! 
                navi:getElemPaths(., $length, $compDict, $nsmap, $options)
            return $paths => sort()
        case 'path2' return
            let $length := $ops?length
            let $_DEBUG := trace($length, '_ length: ')
            for $elem in $elems   (: [ancestor::xs:element[@name eq 'PointOnSection']] :)
            let $name := $elem/(@name, @ref)
            let $paths := $elem ! 
                navi2:getElemPaths(., $length, $compDict, $nsmap, $options)
            return $paths => sort()
        default return error((), 'getPathReport - unknown mode: '||$mode)
    return $result
};
