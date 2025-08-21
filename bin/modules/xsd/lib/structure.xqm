(:
 : Creatures "structure reports".
 :)
module namespace struct="http://www.parsqube.de/xspy/report/structure";
import module namespace path="http://www.parsqube.de/xspy/report/path"
    at "path.xqm";
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
declare function struct:getStructureReport($schemas as element(xs:schema)*,  
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
        case 'itree' return
        let $_DEBUG := trace('Going to write inheritance tree...') return
            dict:compDict_inheritanceTree($compDict, $nsmap)
        case 'sgtree' return
            dict:compDict_sgroupTree($compDict, $nsmap)
        default return error()
    return $result
};
