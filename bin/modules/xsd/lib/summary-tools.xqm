module namespace suto="http://www.parsqube.de/xspy/util/summary-tools";
import module namespace coto="http://www.parsqube.de/xspy/util/component-tools"    
    at "component-tools.xqm";
import module namespace util="http://www.parsqube.de/xspy/util"
    at "util.xqm";
import module namespace unamef="http://www.parsqube.de/xquery/util/name-filter"
    at "../util/util-nameFilter.xqm";
import module namespace uns="http://www.parsqube.de/xspy/util/namespace"
    at "util-namespace.xqm";
    
declare namespace z="http://www.parsqube.de/xspy/structure";

(:
(:~
 : Returns a set of attributes describing a type:
 : - base - the base type
 : - bbase - the ultimate, built-in base type
 : - ki - type kind
 : - re - type relationship: restriction/extension/list/union
 : - co - type content summary
 : - elem, att, group, agroup - attributes if a single element, attribute group, attribute group
 :
 : The attributes can be filtered via $filter or
 : $filterObject. Parameter $filter is a name filter
 : selecting the attributes by name. Parameter $filterObject
 : is a compiled filter selecting the attributes by name.
 :)
declare function suto:getTypeContentSummaryAtts(
                         $typeDef as element(),
                         $compDict as map(*),
                         $filter as xs:string?,
                         $filterObject as element()*,
                         $nsmap as element(z:nsMap),
                         $options as map(*)?)
        as attribute()* {
    let $anamePrefix := $options?anamePrefix    
    let $prefix := $anamePrefix ! concat(., ':')    
    let $filter :=
        if ($filterObject) then $filterObject
        else if ($filter) then $filter ! unamef:parseNameFilter(.)
        else ()
        
    let $skips := ( 
        'base'[$filter ! not(unamef:matchesNameFilterObject('base', $filter))],
        'bbase'[$filter ! not(unamef:matchesNameFilterObject('bbase', $filter))],        
        'ki'[$filter ! not(unamef:matchesNameFilterObject('ki', $filter))],
        (: 're'[$filter ! not(unamef:matchesNameFilterObject('re', $filter))], :)
        'co'[$filter ! not(unamef:matchesNameFilterObject('co', $filter))],
        'details'[$filter ! not(unamef:matchesNameFilterObject('details', $filter))]
    )    
    let $contentElem := coto:getTypeContentElem($typeDef)
    let $base := $contentElem/@base
    let $baseQName := $base ! resolve-QName(., ..)
    let $baseQNameNorm := $baseQName ! uns:normalizeQName(., $nsmap)
        
    let $bbase := $typeDef/coto:getBuiltinBaseQName(., $compDict)     
    let $ki := util:getTypeKind($typeDef)
    (: let $re := $typeDef/coto:getTypeReluc(.) :)        
    let $co := $typeDef ! suto:getTypeContentSummary(., $compDict)
    let $details := 
        if ($filter and not(unamef:matchesNameFilterObject('details', $filter))) then ()
        else suto:getContentSummaryAtts($typeDef, $co, $nsmap, $compDict, $options)
    return (
        $baseQNameNorm[not($skips = 'base')] ! attribute {$prefix||'base'} {.},
        if ($baseQName ! uns:isQNameBuiltin(.) and not($skips = 'base')) then () else
        $bbase[not($skips = 'bbase')] ! attribute {$prefix||'bbase'} {.},
        $ki[not($skips = 'ki')] ! attribute {$prefix||'ki'} {.},
        $co[not($skips = 'co')] ! attribute {$prefix||'co'} {.},
        if ($skips = 'details') then () else $details
    )
};

:)  

(:~
 : Returns a set of attributes describing a type:
 : - base - the base type
 : - bbase - the ultimate, built-in base type
 : - ki - type kind
 : - co - type content summary
 : - aeg atts: att, attGroup, elem, group, elemChoice 
 :     (attributes if a single attribute, attribute group, 
 :      element, group, single-element choice)
 :
 : The attributes can be filtered via $filter or
 : $filterObject. Parameter $filter is a name filter
 : selecting the attributes by name. Parameter $filterObject
 : is a compiled filter selecting the attributes by name.
 :)
declare function suto:getTypeContentSummaryAtts2(
                         $typeDef as element(),
                         $compDict as map(*),
                         $tsummary as xs:string*,
                         $nsmap as element(z:nsMap),
                         $options as map(*)?)
        as attribute()* {
    let $anamePrefix := $options?anamePrefix    
    let $prefix := $anamePrefix ! concat(., ':')    
    let $contentElem := coto:getTypeContentElem($typeDef)
    let $base := $contentElem/@base
    let $baseQName := $base ! resolve-QName(., ..)
    let $baseQNameNorm := $baseQName ! uns:normalizeQName(., $nsmap)
    let $bbase := 
        if ($baseQName ! uns:isQNameBuiltin(.)) then ()
        else$typeDef/coto:getBuiltinBaseQName(., $compDict)     
    let $ki := util:getTypeKind($typeDef)
    let $co := $typeDef ! suto:getTypeContentSummary(., $compDict)
    let $aegAtts := 
        if (not($tsummary = 'aeg')) then ()
        else suto:getAegAtts($typeDef, $co, $nsmap, $compDict, $options)
    return (
        $baseQNameNorm[$tsummary = 'base'] ! attribute {$prefix||'base'} {.},
        $bbase[$tsummary = 'bbase'] ! attribute {$prefix||'bbase'} {.},
        $ki[$tsummary = 'ki'] ! attribute {$prefix||'ki'} {.},
        $co[$tsummary = 'co'] ! attribute {$prefix||'co'} {.},
        $aegAtts
    )
};

(:~
 : Returns for a type name attributes describing the use of the type by
 : other types, elements and attributes.
 :)
declare function suto:getTypeUseAtts($qname as xs:QName, 
                                     $typeUseCountsDict as map(*), 
                                     $typeUsingItemsDict as map(*))
        as attribute()* {
    suto:getTypeUseSummary($qname, $typeUseCountsDict) ! attribute use {.}, 
    $typeUsingItemsDict($qname)?namesElemsWithType ! attribute elemsWithType {.},
    $typeUsingItemsDict($qname)?namesElemsWithBase ! attribute elemsWithBase {.},
    $typeUsingItemsDict($qname)?namesAttsWithType ! attribute attsWithType {.},
    $typeUsingItemsDict($qname)?namesAttsWithBase ! attribute attsWithBase {.}
};        

(:~
 : Creates a type congtent summary. The summary is a descriptive
 : string. Building blocks (replace # with an integer number):
 :
 : a# - # attributes
 : A# - # attribute groups
 :)
declare function suto:getTypeContentSummary(
                             $typeDef as element(), 
                             $compDict as map(*))
        as xs:string? {
    let $cont := coto:getTypeContentElem($typeDef)
    let $atts := $cont/xs:attribute
    let $agroups := $cont/xs:attributeGroup
    let $group := $cont/xs:group
    let $groupDef := $group ! resolve-QName(@ref, .) ! $compDict?group(.)    
    let $modelGroup := ($cont, $groupDef)/(xs:sequence, xs:choice, xs:all)
    let $contentModel := 
        if (not($modelGroup)) then () else
        let $contentItems := $modelGroup/coto:getModelContentItems(.)
        let $contentElemsDeep := $modelGroup/coto:getDeepContentElemItems(., $compDict)  
        let $contentElemQNames := $contentElemsDeep/coto:getComponentQName(.)
        let $counts := (count($contentItems/self::xs:element),
                        count($contentItems/self::xs:group),
                        count($contentElemQNames))
                        
        let $postfix := 
            if ($counts[2] eq 0) then '('||$counts[1]||')'
            else '('||$counts[1]||'/'||$counts[2]||'/'||$counts[3]||')'                        
        let $mgroup := $modelGroup/local-name() ! substring(., 1, 3)
        return ($mgroup||$postfix)[string()]
    let $attContent :=
        let $countAtts := $cont/xs:attribute => count()
        let $countAgroups := $cont/xs:attributeGroup => count()
        return if (0 = $countAtts + $countAgroups) then () else
        
        let $countAttsDeep :=
            if (not($countAgroups)) then $countAtts else
                let $deepAtts := $cont/coto:getDeepContentAtts(., $compDict)
                return count($deepAtts)
        let $postfix := 
            if (not($countAgroups)) then '('||$countAtts||')'
            else '('||$countAtts||'/'||$countAgroups||'/'||$countAttsDeep||')'                        
        return 'att'||$postfix
    let $facets := 
        $cont/(* except (xs:annotation, xs:group, 
                         xs:sequence, xs:choice, xs:all, 
                         xs:attribute, xs:attributeGroup))
        ! local-name(.) => distinct-values() => sort()
    let $summary := 
        if ($cont[empty(* except xs:annotation)]) then '---' else
        string-join((
        $facets,
        (($group ! 'grp-')||$contentModel)[string()],
        $attContent
        ), '~')
    return
        $summary
};

(:~
 : Returns the "aeg attributes" of a type description, @att, @attGroup, @elem, 
 : @group, @elemChoice :)
declare function suto:getAegAtts($typeDef as element(),
                                 $contentSummary as xs:string,
                                 $nsmap as element(z:nsMap),
                                 $compDict as map(*),
                                 $options as map(*)?)
        as attribute()* {
    let $anamePrefix := $options?anamePrefix    
    let $prefix := $anamePrefix ! concat(., ':')    
        
    let $contentElem := $typeDef/coto:getTypeContentElem(.)        
    let $elem :=
        if (matches($contentSummary, '^grp-...\(1[/)]')) then
            let $groupName := $contentElem/xs:group/coto:getComponentQName(.)
            let $groupDef := $compDict?group($groupName)
            let $elems := $groupDef/coto:getModelContentItems(.)/self::xs:element
            let $elemName := $elems[1]/coto:getNormalizedComponentQName(., $nsmap)
            return $elemName
        else if (matches($contentSummary, '(seq|cho|all)\(1[/)]')) then 
            $contentElem/coto:getModelContentItems(.)/self::xs:element/
                coto:getNormalizedComponentQName(., $nsmap)
        else if (matches($contentSummary, '^(seq|cho|all)\(.*?/.*?/1\)')) then 
            let $elems := $contentElem/coto:getDeepContentElemItems(., $compDict)
            let $elemName := $elems[1]/coto:getNormalizedComponentQName(., $nsmap)
            return $elemName
        else ()
    let $att := 
        if (matches($contentSummary, 'att\(1[/)]')) then 
            $contentElem/xs:attribute/coto:getNormalizedComponentQName(., $nsmap)
        else if (matches($contentSummary, 'att\(\d+/\d+/1\)')) then
            let $atts := $contentElem/coto:getDeepContentAtts(., $compDict)
            let $attName := $atts[1]/coto:getNormalizedComponentQName(., $nsmap)
            return $attName
        else ()
    let $group := 
        if (matches($contentSummary, '^grp-seq')) then
            $typeDef/coto:getTypeContentElem(.)/xs:group/
                coto:getNormalizedComponentQName(., $nsmap)
        else if (matches($contentSummary, '^seq\(\d*?/1[/)]')) then 
            let $contentItems := $typeDef/coto:getTypeContentElem(.)/*/coto:getModelContentItems(.)
            let $group := $contentItems/self::xs:group
            return $group/coto:getNormalizedComponentQName(., $nsmap)
        else ()
    let $attGroup :=
        if (matches($contentSummary, 'att\(\d+/1[/)]')) then 
            $typeDef/coto:getTypeContentElem(.)
            /xs:attributeGroup/coto:getNormalizedComponentQName(., $nsmap)
        else ()
    let $elemChoice := 
        if (matches($contentSummary, '^grp-cho\(2\)')) then
            let $groupQName := $typeDef/coto:getTypeContentElem(.)/xs:group/@ref/resolve-QName(., ..)
            let $groupDef := $compDict?group($groupQName)
            return
                $groupDef/*/xs:element/@name/resolve-QName(., ..) 
                ! uns:normalizeQName(., $nsmap) ! string()
                => sort() => string-join(', ')
        else if (matches($contentSummary, '^cho\(2\)')) then 
            $typeDef/coto:getTypeContentElem(.)
            /xs:choice/xs:element/(@ref, @name)/resolve-QName(., ..) 
            ! uns:normalizeQName(., $nsmap)! string()
            => sort() => string-join(', ')
        else ()
    return (
        $elem ! attribute {$prefix||'elem'} {.},
        $elemChoice ! attribute {$prefix||'elemChoice'} {.},        
        $group ! attribute {$prefix||'group'} {.},
        $att ! attribute {$prefix||'att'} {.},        
        $attGroup ! attribute {$prefix||'attGroup'} {.}
    )        
};

declare function suto:getTypeUseSummary($qname as xs:QName, 
                                        $typeUseCountsDict as map(*))
        as item() {
    let $asType := $typeUseCountsDict?type($qname) ! ('t'||.)
    let $asBaseE := $typeUseCountsDict?baseE($qname) ! ('e'||.)    
    let $asAnonBaseE := $typeUseCountsDict?anonBaseE($qname) ! ('E'||.)
    let $asBaseR := $typeUseCountsDict?baseR($qname) ! ('r'||.)    
    let $asAnonBaseR := $typeUseCountsDict?anonBaseR($qname) ! ('R'||.)
    let $asItemType := $typeUseCountsDict?itemType($qname) ! ('l'||.)        
    let $asMemberType := $typeUseCountsDict?memberType($qname) ! ('m'||.)
    let $typeUse := (
         string-join(($asType, $asBaseE, $asAnonBaseE, $asBaseR, $asAnonBaseR, 
                      $asItemType, $asMemberType), '~')[string()]
         , '---')[1]
    return $typeUse        
};

(:~
 : Returns an occurrence indicator:
 : 1, ?, 0, ...-..., ...-
 :) 
declare function suto:getOcc($item as element())
        as xs:string? {
    if ($item/parent::xs:schema) then ()
    
    else if ($item/self::xs:attribute) then
        if ($item/@fixed or $item/@use eq 'required') then '1' else '?'
        
    else
        let $min := ($item/@minOccurs, '1')[1]
        let $max := ($item/@maxOccurs, '1')[1]
        return
            if ($max eq '0') then '0'
            else if ($min eq '0') then
                if ($max eq '1') then '?'
                else if ($max eq 'unbounded') then '*'
                else '0-'||$max
            else if ($min eq '1') then
                if ($max eq '1') then '1'
                else if ($max eq 'unbounded') then '+' 
                else $min||'-'||$max
            else if ($min eq $max) then $min
            else $min||'-'||$max[not(. eq 'unbounded')]
};        

