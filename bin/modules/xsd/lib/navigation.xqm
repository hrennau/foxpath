module namespace navi="http://www.parsqube.de/xspy/util/navigation";
import module namespace coto="http://www.parsqube.de/xspy/util/component-tools"    
    at "component-tools.xqm";
import module namespace const="http://www.parsqube.de/xspy/constants"
    at "constants.xqm";
import module namespace dict="http://www.parsqube.de/xspy/util/dictionaries"
    at "dictionaries.xqm";
import module namespace uns="http://www.parsqube.de/xspy/util/namespace"
    at "util-namespace.xqm";
import module namespace unamef="http://www.parsqube.de/xquery/util/name-filter"
    at "../util/util-nameFilter.xqm";

declare namespace z="http://www.parsqube.de/xspy/structure";
declare namespace xspy="http://www.parsqube.de/xspy/structure";

declare function navi:getElemPaths($item as element(xs:element)*,
                                   $length as xs:integer?,
                                   $compDict as map(*),
                                   $nsmap as element(z:nsMap),
                                   $options as map(*)?)
        as xs:string* {
    let $noprefix := $options?noprefix        
    for $elem in $item
    let $name := $elem/(@name, @ref)
    (: let $_DEBUG := trace($name, '_ Process element (path): ') :)
    let $ancestors := $elem ! 
        navi:getAncestorElems(., $length, $compDict, $nsmap, $options)
    let $paths :=
        for $ancestor in $ancestors
        let $items := array:flatten($ancestor)
        let $path := (
            if ($noprefix) then $items ! (@name, @ref)/replace(., '.+:', '') 
            else $items ! coto:getNormalizedComponentQName(., $nsmap) 
            ) => string-join('/')
        (: 
        let $idpath := $items ! generate-id(.) => string-join('/')
        let $path := $path||' #'||$idpath 
         :)
        order by $path
        return (
            $path
        )
    return $paths => distinct-values() => sort()
};

declare function navi:getAncestorElems($item as element(),
                                       $count as xs:integer?,
                                       $compDict as map(*),
                                       $nsmap as element(z:nsMap),
                                       $options as map(*)?)
        as array(*)* {
    let $initialChain := array{$item}
    let $chains := navi:getAncestorElemsREC(
        $initialChain, $count, $compDict, $nsmap, $options)
    return $chains
};

declare function navi:getAncestorElemsREC(
                                       $chains as array(*)+,
                                       $count as xs:integer?,
                                       $compDict as map(*),
                                       $nsmap as element(z:nsMap),
                                       $options as map(*)?)
        as array(*)* {
    for $chain in $chains
    let $items := array:flatten($chain)
    let $item1 := $items[1]
    let $nodeId := $item1/generate-id(.)
    group by $nodeId
    let $parents := navi:getParentElem($item1, $compDict, $nsmap, $options)   
    return
        if (empty($parents)) then $chain else
        
    for $chain_ in $chain
    let $chainsExtended := 
        for $parent in $parents
        let $chainExtendedRaw := $parent ! array:insert-before($chain_, 1, .)
        let $isCyclic := exists($parent intersect $items)
        return
            if ($isCyclic) then 
                array:insert-before($chainExtendedRaw, 1, <_cycle_/>)
            else if (count($items) + 1 ge $count) then $chainExtendedRaw
            else $chainExtendedRaw
    let $chainsCyclic := $chainsExtended[array:head(.)/self::_cycle_]
    let $chainsAcyclic := $chainsExtended[not(array:head(.)/self::_cycle_)]
    return (
        $chainsCyclic,

        if (count($items) + 1 lt $count) then
            $chainsAcyclic ! navi:getAncestorElemsREC(., $count, $compDict, $nsmap, $options)
        else $chainsAcyclic
    )
};

declare function navi:getParentElem($item as element(),
                                    $compDict as map(*),
                                    $nsmap as element(z:nsMap),
                                    $options as map(*)?)
        as element()* {
    if ($item/parent::xs:schema) then () else
    let $sgroupHeadElems := navi:getSubstitutionGroups($item, $compDict, $nsmap, $options)
    let $itemWSG := ($item, $sgroupHeadElems)/.
    let $contypes := $itemWSG ! navi:getContainingType(., $compDict, $options)
    (:
    let $_DEBUG := if (empty($sgroupHeadElems)) then () else
                   trace('Elem: '||$item/coto:getNormalizedComponentQName(., $nsmap)||
                         ' - #sg='||count($sgroupHeadElems)||
                         ' - #ty='||count($contypes))
     :)
    let $typesNotUsed := $options?typesNotUsed
    let $elems :=
        for $contype in $contypes/.
        return
            if (not($contype/@name)) then 
                $contype/ancestor::xs:element[1]
            else
                let $qname := $contype/QName(ancestor::xs:schema/@targetNamespace, @name)
                where empty($typesNotUsed) or not($qname = $typesNotUsed)
                let $_DEBUG := trace($qname, '_ look for elements using type: ')
                let $elems := navi:getElementsUsingType($qname, $compDict, $nsmap, $options)
                let $_DEBUG := if ($elems) then () else 
                    trace($qname, '_ # No elements using type: ')
                return $elems
    return $elems/.                
};

declare function navi:getContainingType($item as element(), 
                                        $compDict as map(*),
                                        $options as map(*))
        as element()* {
    navi:getContainingTypeREC($item, $compDict, $options)        
};

declare function navi:getContainingTypeREC($item as element(), 
                                           $compDict as map(*),
                                           $options as map(*))
        as element()* {
    (: let $_DEBUG := trace($item/name(), '_GET_CONTAINING_TYPE_REC: NAME=') return :)        
    typeswitch($item)
    case element(xs:schema) return ()    
    case element(xs:attributeGroup) return
        if ($item/@name) then
            let $name := $item/coto:getComponentQName(.)
            let $refs := navi:getAttributeRefs($name, $compDict, $options)
            return $refs ! navi:getContainingTypeREC(., $compDict, $options)
        else
            $item/.. ! navi:getContainingTypeREC(., $compDict, $options)
    case element(xs:group) return
        if ($item/@name) then
            let $name := $item/coto:getComponentQName(.)
            return if ($options?groupsNotUsed = $name) then () else
            
            let $refs := navi:getGroupRefs($name, $compDict, $options)
            let $_DEBUG := 
                if ($refs) then () else trace($name, '_ ### No group refs for group: ')
            return $refs ! navi:getContainingTypeREC(., $compDict, $options)
        else
            $item/.. ! navi:getContainingTypeREC(., $compDict, $options)
    case element(xs:attribute) return
        if ($item/parent::xs:schema) then
            let $name := $item/coto:getComponentQName(.)
            let $refs := navi:getAttributeRefs($name, $compDict, $options)
            return $refs ! navi:getContainingTypeREC(., $compDict, $options)
        else
            $item/.. ! navi:getContainingTypeREC(., $compDict, $options)
    case element(xs:element) return
        if ($item/parent::xs:schema) then
            let $name := $item/coto:getComponentQName(.)
            let $refs := navi:getElementRefs($name, $compDict, $options)
            return $refs ! navi:getContainingTypeREC(., $compDict, $options)
        else
            $item/.. ! navi:getContainingTypeREC(., $compDict, $options)
            
    case element(xs:simpleType) | element(xs:complexType) return $item
    
    default return $item/.. ! navi:getContainingTypeREC(., $compDict, $options)
};

declare  function navi:getAttributeRefs($name as xs:QName,
                                        $compDict as map(*),
                                        $options as map(*)?)
        as element(xs:attributeSet)* {
    (
        $compDict?attributeGroup?* /xs:attributeGroup[@ref/resolve-QName(., ..) eq $name],
        $compDict?group?*         //xs:attributeGroup[@ref/resolve-QName(., ..) eq $name],        
        $compDict?element?*       //xs:attributeGroup[@ref/resolve-QName(., ..) eq $name],
        $compDict?type?*          //xs:attributeGroup[@ref/resolve-QName(., ..) eq $name]
    )
};        

declare  function navi:getGroupRefs($name as xs:QName,
                                    $compDict as map(*),
                                    $options as map(*)?)
        as element(xs:group)* {
    if (exists($options?groupRefDict)) then $options?groupRefDict($name) else  
    let $_DEBUG := trace('Not use group ref dict') return
    (
        $compDict?group?*  //xs:group[@ref/resolve-QName(., ..) eq $name],
        $compDict?element?*//xs:group[@ref/resolve-QName(., ..) eq $name],
        $compDict?type?*   //xs:group[@ref/resolve-QName(., ..) eq $name]
    )
};        

declare  function navi:getElementRefs($name as xs:QName,
                                      $compDict as map(*),
                                      $options as map(*)?)
        as element(xs:element)* {
    if (exists($options?elemRefDict)) then $options?elemRefDict($name) else
    let $_DEBUG := trace('Not use elem ref dict') return    
    (
        $compDict?group?*  //xs:element[@ref/resolve-QName(., ..) eq $name],
        $compDict?element?*//xs:element[@ref/resolve-QName(., ..) eq $name],
        $compDict?type?*   //xs:element[@ref/resolve-QName(., ..) eq $name]
    )
};        

declare  function navi:getAttributeRef($name as xs:QName,
                                       $compDict as map(*),
                                       $options as map(*)?)
        as element(xs:attribute)* {
    (
        $compDict?attributeGroup?* /xs:attribute[@ref/resolve-QName(., ..) eq $name],
        $compDict?group?*         //xs:attribute[@ref/resolve-QName(., ..) eq $name],       
        $compDict?element?*       //xs:attribute[@ref/resolve-QName(., ..) eq $name],
        $compDict?type?*          //xs:attribute[@ref/resolve-QName(., ..) eq $name]       
    )
};        

declare function navi:getElementsUsingType($name as xs:QName,
                                           $compDict as map(*),
                                           $nsmap as element(z:nsMap),
                                           $options as map(*)?)
        as element()* {
    let $inheritanceTree :=
        if (exists($options?inheritanceTree)) then $options?inheritanceTree
        else dict:compDict_inheritanceTree($compDict, $nsmap)
    let $name := $name ! uns:normalizeQName(., $nsmap)        
    let $derivedTypeNames := 
        let $nameS := string($name)
        return 
            $inheritanceTree//*[@name eq $nameS]//*/@name !
            uns:resolveNormalizedQName(., $nsmap)
    
    let $_DEBUG := if (local-name-from-QName($name) = (
                          'DeadRun_VersionStructure', 
                          'Assignment_VersionStructure_')) then (
                       trace(string($name), '_ type name: '),
                       trace($derivedTypeNames, '_ derived type names: '))
                   else ()
    return
    if (exists($options?elemTypeDict)) then (
        let $elemTypeDict := $options?elemTypeDict
        for $typeName in ($name, $derivedTypeNames)
        return
            $elemTypeDict($typeName)
        )/.
    else
    let $_DEBUG := trace('Not use elem ref dict') return        
    (
        $compDict?element?*/descendant-or-self::xs:element,
        $compDict?type?*   /descendant::xs:element,
        $compDict?group?*  /descendant::xs:element
    )
    [coto:getElemTypeOrBaseAttNormalized(., $compDict, $nsmap) = ($name, $derivedTypeNames)]
};        

declare function navi:getSubstitutionGroups($elem as element(), 
                                            $compDict as map(*),
                                            $nsmap as element(z:nsMap),
                                            $options as map(*))
        as element(xs:element)* {        
    if (exists($options?sgroupDict)) then 
        let $sgroups := $elem/coto:getNormalizedComponentQName(., $nsmap) ! $options?sgroupDict(.)
        for $sgroup in $sgroups return $compDict('element')($sgroup)                             
    else        
        
    let $sgroupHead := $elem/coto:getElemDecl(., $compDict)/@substitutionGroup/resolve-QName(., ..)
    let $sgroupHeadElem := $sgroupHead ! $compDict('element')(.)
    (:
    let $_DEBUG := 
        if (empty($sgroupHead)) then () else (
        trace('### Elem: '||coto:getNormalizedComponentQName($elem, $nsmap)||
              ' - sgroup: '||$sgroupHead||' - '||count($sgroupHeadElem)))
     :)             
    return (
        $sgroupHeadElem,
        $sgroupHeadElem[@substitutionGroup] ! 
        navi:getSubstitutionGroups(., $compDict, $nsmap, $options)
    )
};        