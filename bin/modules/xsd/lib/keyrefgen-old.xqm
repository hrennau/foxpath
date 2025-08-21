(:
 : Functions creating a keyref report
 :)
module namespace kreg="http://www.parsqube.de/xspy/report/keyrefgen-old";
import module namespace uns="http://www.parsqube.de/xspy/util/namespace"
    at "util-namespace.xqm";

import module namespace navi="http://www.parsqube.de/xspy/util/navigation"
    at "navigation.xqm";
import module namespace typa="http://www.parsqube.de/xspy/report/type-pattern"
    at "type-pattern.xqm";
import module namespace suto="http://www.parsqube.de/xspy/util/summary-tools"
    at "summary-tools.xqm";
import module namespace dict="http://www.parsqube.de/xspy/util/dictionaries"
    at "dictionaries.xqm";
import module namespace coto="http://www.parsqube.de/xspy/util/component-tools"    
    at "component-tools.xqm";
import module namespace ufpath="http://www.parsqube.de/xquery/util/file-path"
    at "../util/util-filePath.xqm";
import module namespace unamef="http://www.parsqube.de/xquery/util/name-filter"
    at "../util/util-nameFilter.xqm";
import module namespace util="http://www.parsqube.de/xspy/util"
    at "util.xqm";
declare namespace z="http://www.parsqube.de/xspy/structure";

declare variable $kreg:DEBUG_ENTITYTYPE as xs:string? := 
'b:AccessVehicleEquipment_VersionStructure';
(:  'b:TypeOfValue_VersionStructure';    :)
declare variable $kreg:DEBUG_ENTITYTYPE_FILTER := 
 (); (:       $kreg:DEBUG_ENTITYTYPE ! unamef:parseNameFilter(.); :)
    

(:~
 : Creates a type resolution report.
 :)
declare function kreg:keyrefgenReport($schemas as element(xs:schema)*,
                                      $ops as map(*)?)
        as element() {
    let $irep := $ops?irep
    let $irdoc := $irep! util:getDoc(.)
    (: irdict - maps every type name to an element in the hierarchy report :)
    let $irdict :=
        if (not($irdoc)) then () else map:merge(
        $irdoc//typeHierarchies//(type, etype, rtype)/@name/map:entry(., ..))
    let $_DEBUG := trace($irdict ! (map:keys(.) => count()), 'Count Inheritance Dictionary entries: ')
    (: irdict - maps every type name to the expanded type definition :)
    let $txrep := $ops?txrep
    let $txdoc := $txrep ! util:getDoc(.)
    let $txdict :=
        if (not($txdoc)) then () else map:merge(
        $txdoc//type/@name/map:entry(., ..))
    let $limitCount := $ops?limitCount
    
    let $nsmap := uns:getTnsPrefixMap($schemas, ())  
    let $compDict := dict:getCompDict($schemas, ())
    let $elemTypeDict := map:merge(
        for $elem in ($compDict?element?*, $compDict?*?*//xs:element)
        let $typeName := 
            $elem/coto:getElemTypeOrBaseAtt(., $compDict) 
            ! coto:getNormalizedAttQName(., $nsmap)
            ! string(.)
        (: An element may have no type or base type ... :)
        where $typeName
        group by $typeName
        return map:entry($typeName, $elem))
            
    let $allTypeNames := 
        $compDict?type?*[@name]/coto:getComponentQName(.) ! uns:normalizeQName(., $nsmap) ! string(.) 
    let $pointerNamePattern := '*Ref'
    let $pointerNameFilter := $pointerNamePattern ! unamef:parseNameFilter(.)
    
    let $pointerElems := (
        $compDict?element?*[(@name, @ref)/unamef:matchesNameFilterObject(., $pointerNameFilter)],
        $compDict?*?*//xs:element[(@name, @ref)/unamef:matchesNameFilterObject(., $pointerNameFilter)]
    )
    let $pointerElemInfos :=
        for $pointerElem in $pointerElems[empty($limitCount) or position() le $limitCount]
        let $ename := $pointerElem/coto:getNormalizedComponentQName(., $nsmap)
        let $_DEBUG := trace($ename, 'Pointer elem: ')
        let $compContext := $pointerElem/coto:componentContext(., $nsmap)
        (: Determine pointer type :)
        let $typeAtt := $pointerElem/coto:getElemTypeOrBaseAtt(., $compDict)
        let $type := $typeAtt/self::attribute(type)/uns:normalizeAttValueQName(., $nsmap)
        let $btype := $typeAtt/self::attribute(base)/uns:normalizeAttValueQName(., $nsmap)
        let $typeE := ($type, $btype)
        (: Determine entity type :)
        let $entityType := $typeE ! kreg:refTypeNameToEntityTypeName(., $compDict, $nsmap)
        let $entityTypeDef := $entityType ! $txdict(.)
        (: Entity elements with the entity type :)        
        let $fields := (
            '@b:ref',
            '@b:version'[$entityTypeDef//xs:attribute/@name = 'b:version'],
            '@b:order'[$entityTypeDef//xs:attribute/@name = 'b:order']
        )            
        (: Descendant entity types :)
        let $descendantEntityTypes := ()
        (:
            kreg:getDescendantEntityTypes($entityType, $irdict)
            ! <derivedEntityType name="{.}"/>
         :)
        order by string($ename)
        return
            <pointer elemName="{$ename}">{
                attribute elemContext {$compContext},
                $type ! attribute type {.},
                $btype ! attribute btype {.},                
                attribute entityType {$entityType},
                attribute fields {string-join($fields, ' # ')},
                $pointerElem/@ref,
                $descendantEntityTypes
            }</pointer>
    let $pointerElemNames := $pointerElemInfos/@elemName => distinct-values()            
    let $keyrefReport := 
        <keyrefData count="{count($pointerElemInfos)}">{
            attribute countDistinctNames {$pointerElemNames => count()},
            for $elemInfo in $pointerElemInfos
            let $elemName := $elemInfo/@elemName
            group by $elemName
            return if (count($elemInfo) eq 1 and false()) then $elemInfo else

            <pointers elemName="{$elemName}" count="{count($elemInfo)}">{
                for $elemInfo2 in $elemInfo
                let $type := $elemInfo2/(@type, @btype)
                group by $type
                let $derivedEntityTypesInfo :=
                    if (not($elemInfo2[1]/derivedEntityType)) then () else
                    <derivedEntityTypes>{
                        ($elemInfo2[1]/derivedEntityType/@name => sort())
                        ! <derivedEntityType name="{.}"/>
                    }</derivedEntityTypes>                        
                return
                    <ptype>{
                        $elemInfo2[1] ! (@type, @btype,@entityType, @fields),
                        $elemInfo2[1]/@entityType/<entityType name="{.}"/>,
                        $derivedEntityTypesInfo,
                        for $elemInfo3 in $elemInfo2
                        return
                            $elemInfo3/element {node-name(.)} {
                                @* except (@elemName, @type, @btype, @entityType, @fields, @ref),
                                node() except derivedEntityType
                            }
                    }</ptype>
            }</pointers>
        }</keyrefData>
    let $options := 
        map{'elemTypeDict': $elemTypeDict, 
            'irdict': $irdict,
            'txdict': $txdict,
            'limitCount': $ops?limitCount,
            'compDict': $compDict, 
            'nsmap': $nsmap}        
    let $keyrefReport2 := kreg:augmentReport_addEntityElems($keyrefReport, $options)
    
    let $_LOG := trace('Create entities report ...')
    
    let $entitiesReport := kreg:getEntitiesReport($keyrefReport2, $options)
    let $report :=
        <keyrefgen>{
            $keyrefReport2,
            $entitiesReport
        }</keyrefgen>
    return $report        
};

declare function kreg:augmentReport_addEntityElems($report as element(),
                                                   $options as map(*))
        as element() {
    $report ! kreg:augmentReport_addEntityElemsREC($report, $options)         
};        

declare function kreg:augmentReport_addEntityElemsREC($n as node(),
                                                      $options as map(*))
        as node(){
    typeswitch($n)
    case document-node() return document {$n/node() ! 
        kreg:augmentReport_addEntityElemsREC(., $options)}
    case element(ptype) return
        let $compDict := $options?compDict
        let $elemTypeDict := $options?elemTypeDict
        let $nsmap := $options?nsmap

        let $elemQName := $n/ancestor::pointers/@elemName/uns:resolveNormalizedQName(., $nsmap)
        let $typeName := $n/@type 
        let $typeQName := $typeName ! uns:resolveNormalizedQName(., $nsmap)
        let $elemsWithOtherType := $typeQName ! 
            kreg:getElemsWithDifferentType($elemQName, ., $compDict, $nsmap)        
        let $elemsWithOtherTypeInfo :=
            if (not($elemsWithOtherType)) then () else
            <elemsWithOtherType>{        
              for $elem in $elemsWithOtherType
              let $parentElem := navi:getParentElem($elem, $compDict, $nsmap, $options)
              let $parentElemName := $parentElem/coto:getNormalizedComponentQName(., $nsmap) 
                                     ! string() => distinct-values() => sort()
              return         
                  $elem/<elem type="{coto:getElemTypeOrBaseAttNormalized(., $compDict, $nsmap)}"
                              context="{coto:componentContext(., $nsmap)}"
                              parentElem="{$parentElemName}"/>
            }</elemsWithOtherType>
        return
            element {node-name($n)} {
                $n/@* ! kreg:augmentReport_addEntityElemsREC(., $options),
                $n/node() ! kreg:augmentReport_addEntityElemsREC(., $options),
                $elemsWithOtherTypeInfo
            }
    case element(entityType) return $n
    (:
        let $elemInfo := kreg:getEntityTypeInfo($n/@name, $options)
        return $elemInfo
     :)
    case element() return
        element {node-name($n)} {
            $n/@* ! kreg:augmentReport_addEntityElemsREC(., $options),
            $n/node() ! kreg:augmentReport_addEntityElemsREC(., $options)
        }
    default return $n        
};        

(:~
 : Maps the normalized ref type name to a normalized entity type name.
 :)
declare function kreg:refTypeNameToEntityTypeName($refType as xs:QName,
                                                  $compDict as map(*),
                                                  $nsmap as element(z:nsMap))
        as xs:string? {
    let $allTypeNames := 
        $compDict?type?*[@name]/coto:getComponentQName(.) 
        ! uns:normalizeQName(., $nsmap) ! string(.) 
    let $entityType := 
        let $typePrefix := $refType ! string(.) ! replace(., 'RefStructure$', '')
        let $etypeName := 
            let $tryName := $typePrefix||'_VersionStructure'
            let $etype := $allTypeNames[matches(., '^(.*:)?'||$tryName||'$')]
            return $etype
        return if ($etypeName) then $etypeName else
        
        let $etypeName :=
            let $tryName := $typePrefix||'_VersionedChildStructure'
            let $etype := $allTypeNames[matches(., '(.*:)?'||$tryName||'$')]
            return $etype
        return if ($etypeName) then $etypeName else
        
        let $etypeName :=
            let $etypeName := $typePrefix||'_ValueStructure'
            let $etype := $allTypeNames[matches(., '(.*:)?'||$etypeName||'$')]
            return $etype
        return if ($etypeName) then $etypeName else
        
        let $etypeName :=
            let $etypeName := $typePrefix ! replace(., 'Frame$', '_VersionFrameStructure')
            let $etype := $allTypeNames[matches(., '(.*:)?'||$etypeName||'$')]
            return $etype
        return if ($etypeName) then $etypeName else '?'
        
    return $entityType
};        

(:~
 : Returns the descendant entity types of a given
 : entity type.
 :)
declare function kreg:getDescendantEntityTypes(
                                   $entityType, 
                                   $irdict as map(*))
        as xs:string* {
    if ($entityType eq '?') then () else 
    
    let $treeElem := $irdict($entityType)
    return $treeElem//*/@name => sort()
};        

(:~
 : Returns all element declarations with a certain element name,
 : which do not have a certain type name.
 :
 : @param elemQName qualified element name
 : @param typeQName qualified type name
 : @param compDict component dictionary
 : @return the element declarations with a different type
 :)
declare function kreg:getElemsWithDifferentType($elemQName, 
                                                $typeQName, 
                                                $compDict,
                                                $nsmap)
        as element(xs:element)* {
    let $elems := coto:elemsForName($elemQName, $compDict, ())
    let $elemsWithOtherType :=
        for $elem in $elems
        let $elemTypeQName := $elem/coto:getElemTypeOrBaseAttNormalized(., $compDict, $nsmap) 
        where $elemTypeQName ne $typeQName
        return $elem
    return $elemsWithOtherType        
};        

(:~ 
 : Writes an entity type info element.
 :
 : @param typeName the normalized name string of the entity type
 : @return an entityType element
 :)
declare function kreg:getEntityTypeInfo($typeName as xs:string, 
                                        $options)
        as element(entityType) {
    let $compDict := $options?compDict
    let $elemTypeDict := $options?elemTypeDict
    let $nsmap := $options?nsmap
    let $irdict := $options?irdict    
    let $typeQName := $typeName[not(. eq '?')] ! uns:resolveNormalizedQName(., $nsmap)
        
    let $descendantTypes :=
        let $typeNames := kreg:getDescendantEntityTypes($typeName, $irdict)
        where exists($typeNames)
        return
            <derivedEntityTypes count="{count($typeNames)}">{
                $typeNames ! <derivedEntityType name="{.}"/>
            }</derivedEntityTypes>
        
    let $elemInfo :=
        (: All element declarations with a certain type :)
        let $elems := $elemTypeDict($typeName)
        for $elem in $elems
        let $elemQName := $elem/coto:getNormalizedComponentQName(., $nsmap)
        group by $elemQName
        let $elemsWithOtherType := $typeQName !
            kreg:getElemsWithDifferentType($elemQName, ., $compDict, $nsmap)
        let $elemsWithOtherTypeInfo := 
            if (not($elemsWithOtherType)) then () else            
            <elemsWithOtherType>{
              for $elem in $elemsWithOtherType
              let $parentElem := navi:getParentElem($elem, $compDict, $nsmap, $options)
              let $parentElemName := $parentElem/coto:getNormalizedComponentQName(., $nsmap) ! string()
                                     => distinct-values() => sort() => string-join(' ')
              return         
                $elem/<elem type="{coto:getElemTypeOrBaseAttNormalized(., $compDict, $nsmap)}"
                            context="{coto:componentContext(., $nsmap)}"
                            parentElem="{$parentElemName}"/>
            }</elemsWithOtherType>    
                   
        let $elemInstances :=
            for $elem2 in $elem
            let $elemContext := $elem2/coto:componentContext(., $nsmap)
            let $parentElem := 
                if (not($elemsWithOtherType)) then () else
                navi:getParentElem($elem2, $compDict, $nsmap, $options)
            let $parentElemName := 
                $parentElem/coto:getNormalizedComponentQName(., $nsmap) 
                            ! string() => distinct-values() => sort() => string-join(' ')
            return 
                <elem elemContext="{$elemContext}">{
                    $parentElemName[string()] ! attribute parentElem {$parentElemName}
                }</elem>
        order by string($elemQName)                    
        return
            <elems elemName="{$elemQName}">{
                $elemInstances,
                $elemsWithOtherTypeInfo
            }</elems>
    return
        <entityType name="{$typeName}">{
            $elemInfo,
            $descendantTypes
        }</entityType>
};

declare function kreg:getEntitiesReport($keyrefReport as element(),
                                        $options as map(*))
        as element() {
    let $irdict := $options?irdict
    
    let $entityTypes1 := $keyrefReport//ptype/@entityType[not(. eq '?')]
    let $entityTypes2 := () (: $entityTypes1 ! kreg:getDescendantEntityTypes(., $irdict) :)
    let $entityTypes := ($entityTypes1, $entityTypes2) => distinct-values() => sort()
    let $entityInfos :=
        for $entityType in $entityTypes
        where not($kreg:DEBUG_ENTITYTYPE_FILTER) or 
            $entityType ! unamef:matchesNameFilterObject(., $kreg:DEBUG_ENTITYTYPE_FILTER)
        let $_DEBUG := trace($entityType, 'Process entity type: ')
        let $entityTypeInfo := $entityType ! kreg:getEntityTypeInfo(., $options)
        return $entityTypeInfo
    let $report :=
        <entityTypes count="{count($entityInfos)}">{
            $entityInfos
        }</entityTypes>
    return $report        
};

