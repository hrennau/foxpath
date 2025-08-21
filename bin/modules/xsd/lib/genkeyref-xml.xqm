(:
 : Functions creating a keyref report
 :)
module namespace kreg="http://www.parsqube.de/xspy/report/genkeyref-xml";
import module namespace uns="http://www.parsqube.de/xspy/util/namespace"
    at "util-namespace.xqm";

import module namespace navi="http://www.parsqube.de/xspy/util/navigation"
    at "navigation.xqm";
import module namespace navi2="http://www.parsqube.de/xspy/util/navigation2"
    at "navigation2.xqm";
import module namespace dict="http://www.parsqube.de/xspy/util/dictionaries"
    at "dictionaries.xqm";
import module namespace coto="http://www.parsqube.de/xspy/util/component-tools"    
    at "component-tools.xqm";
import module namespace const="http://www.parsqube.de/xspy/constants"
    at "constants.xqm";
import module namespace ufpath="http://www.parsqube.de/xquery/util/file-path"
    at "../util/util-filePath.xqm";
import module namespace unamef="http://www.parsqube.de/xquery/util/name-filter"
    at "../util/util-nameFilter.xqm";
import module namespace ustr="http://www.parsqube.de/xquery/util/string"
    at "../util/util-string.xqm";
import module namespace util="http://www.parsqube.de/xspy/util"
    at "util.xqm";
declare namespace z="http://www.parsqube.de/xspy/structure";

declare variable $kreg:PATHMODE := 'path';
declare variable $kreg:DISAMBIG_PATH_LENGTH_MAX as xs:integer := 4;
declare variable $kreg:NAVIMODE := 2;

(:~
 : Creates a keyrefgen report.
 :)
declare function kreg:genKeyrefXmlReport($schemas as element(xs:schema)*,
                                         $ops as map(*)?)
        as element() {
    let $nsmap := uns:getTnsPrefixMap($schemas, ())
    let $compDict := dict:getCompDict($schemas, ())
    let $itree := dict:compDict_inheritanceTree($compDict, $nsmap)    
    let $irdict := dict:itree_inheritanceTreeNodeDict($itree)
    
    let $_DEBUG := trace($irdict ! (map:keys(.) => count()), 'Count Inheritance Dictionary entries: ')
    (: txdict - maps every type name to the expanded type definition :)
    let $txrep := $ops?txrep
    let $txdoc := $txrep ! util:getDoc(.)
    let $txdict :=
        if (not($txdoc)) then () else map:merge(
        $txdoc//type/@name/map:entry(., ..))
    
    let $elemTypeDict := dict:getElementTypeDict($compDict, $nsmap)
    let $elemRefDict := dict:getElementRefDict($compDict, $nsmap)
    let $groupRefDict := dict:getGroupRefDict($compDict, $nsmap) 
    let $typesUsingGroupDict := dict:getTypesUsingGroupDict($compDict, $groupRefDict, $nsmap)
    let $sgroupDict := dict:getSgroupDict($compDict, $nsmap)
    let $typesNotUsed := dict:compDict_typesNotUsed($compDict)
    let $groupsNotUsed := dict:compDict_groupsNotUsed($compDict)
    let $options := 
        map{'elemTypeDict': $elemTypeDict, 
            'elemRefDict': $elemRefDict,
            'groupRefDict': $groupRefDict,
            'typesUsingGroupDict': $typesUsingGroupDict,
            'sgroupDict': $sgroupDict,
            'itree': $itree,
            'irdict': $irdict,
            'txdict': $txdict,
            'typesNotUsed': $typesNotUsed,
            'groupsNotUsed': $groupsNotUsed,
            'limitCount': $ops?limitCount,
            'pointerType': $ops?pointerType,
            'entityType': $ops?entityType,
            'compDict': $compDict, 
            'dirExamples': $ops?dirExamples,
            'nsmap': $nsmap}
            
    let $pointersReport := kreg:getPointersReport($options)
    let $entitiesReport := kreg:getEntitiesReport($pointersReport, $options)
    let $report :=
        <keyrefgen xmlns:xs="http://www.w3.org/2001/XMLSchema">{
            $pointersReport,
            $entitiesReport
        }</keyrefgen>
    let $reportAug1 := $report ! kreg:addSelectorElems(., $options)        
    let $reportAug2 := $reportAug1 ! kreg:finalizeReport(., $options)
    let $reportAug3 := $reportAug2 ! kreg:addItemFrequencies(., $options)
    return $reportAug3
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
 : Writes a pointer type info element.
 :
 : @param typeName the normalized name string of the entity type
 : @return an entityType element
 :)
declare function kreg:getPointerTypeInfo($typeName as xs:QName,
                                         $pointerElems as element(xs:element)+, 
                                         $options)
        as element(pointerType) {
    let $compDict := $options?compDict
    let $txdict := $options?txdict
    let $nsmap := $options?nsmap
    let $elemTypeDict := $options?elemTypeDict
        
    let $entityType := $typeName ! kreg:refTypeNameToEntityTypeName(., $compDict, $nsmap)
    let $entityTypeDef := $entityType ! $txdict(.)
    let $fields := (
        '@ref',
        '@version'[$entityTypeDef//xs:attribute/@name = 'b:version'],
        '@order'[$entityTypeDef//xs:attribute[@name = 'b:order' (: and @use = 'required' :)]] 
                [not($const:SUPPRESS_FIELD_ORDER)]
    )   
    (: For each distinct element name an <elems> summary :)    
    let $elemsWithTypeInfo :=
        let $elems := $elemTypeDict($typeName)
        return kreg:writeElemsForTypeName($elems, $typeName,$options)
    let $keyrefName := kreg:pointerTypeNameToKeyrefName(string($typeName), string($entityType))    
    return
        <pointerType name="{$typeName}" entityType="{$entityType}">{
            attribute fields {$fields},
            attribute keyrefName {$keyrefName},
            $elemsWithTypeInfo
        }</pointerType>
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
    let $txdict := $options?txdict
    
    let $typeQName := $typeName[not(. eq '?')] ! uns:resolveNormalizedQName(., $nsmap)
    let $descendantTypes :=
        let $typeNames := kreg:getDescendantEntityTypes($typeName, $irdict)
        where exists($typeNames)
        return
            <derivedEntityTypes count="{count($typeNames)}">{
                $typeNames ! <derivedEntityType name="{.}"/>
            }</derivedEntityTypes>

    (: For each distinct element name an <elems> summary :)
    let $elemsWithTypeInfo :=
        let $elems := $elemTypeDict($typeQName)
        return kreg:writeElemsForTypeName($elems, $typeQName, $options)
        
    let $entityTypeDef := $typeName ! $txdict(.)
    let $fields := (
        '@id',
        '@version'[$entityTypeDef//xs:attribute/@name = 'b:version'],
        '@order'[$entityTypeDef//xs:attribute[@name = 'b:order' (: and @use = 'required' :)]]
                [not($const:SUPPRESS_FIELD_ORDER)]
    )   
    let $keyName := kreg:entityTypeNameToKeyName(string($typeName))    
    return
        <entityType name="{$typeName}">{
            attribute fields {$fields},
            attribute keyName {$keyName},
            $elemsWithTypeInfo,
            $descendantTypes
        }</entityType>
};

(:~
 : Write "elems" elements for each element name
 : of elements using a given type.
 :)
declare function kreg:writeElemsForTypeName($elems, 
                                            $typeQName, 
                                            $options)
        as element(elems)* {
    let $compDict := $options?compDict
    let $elemTypeDict := $options?elemTypeDict
    let $nsmap := $options?nsmap
    let $irdict := $options?irdict    
    return
    
    (: Loop over elements with a type name :)
    for $elem in $elems
    let $elemQName := $elem/coto:getNormalizedComponentQName(., $nsmap)
    (: Grouping by element name :)
    group by $elemQName
    let $elemsForName := kreg:writeElemsForTypeAndElemName(
        $elem, $typeQName, $elemQName, 2, $options)
    order by string($elemQName)            
    return $elemsForName        
};

(:~
 : Write an "elems" element describing the elements
 : with a given name using a type with a given name.
 :)
declare function kreg:writeElemsForTypeAndElemName(
                                $elems, 
                                $typeQName,
                                $elemQName,
                                $disambigPathLength as xs:integer,
                                $options)
        as element(elems)* {
    let $compDict := $options?compDict
    let $elemTypeDict := $options?elemTypeDict
    let $nsmap := $options?nsmap
    let $irdict := $options?irdict 
    let $itree := $options?itree
    let $fnGetElemPaths :=
        if ($kreg:NAVIMODE eq 1) then navi:getElemPaths#5
        else navi2:getElemPaths#5
    return
    
    (: Loop over elements with a type name :)
    let $elemsWithOtherType := $typeQName !
        kreg:getElemsWithDifferentType($elemQName, ., $compDict, $nsmap)
    let $elemsWithOtherTypeInfo := 
        if (not($elemsWithOtherType)) then () else            
        <elemsWithOtherType>{
          for $elem in $elemsWithOtherType
          let $type := $elem/coto:getElemTypeOrBaseAttNormalized(., $compDict, $nsmap)
          let $typeRel := dict:itree_typeRel($type, $typeQName, $itree, $nsmap)
          return         
            $elem/<elem type="{$type}"
                        typeRel="{$typeRel}"
                        context="{coto:componentContext(., $nsmap)}">{
                      $elem/@ref ! attribute isRef {true()}                            
                  }</elem>
        }</elemsWithOtherType>    
     
    let $elemsWithOtherTypeInfoAug :=     
        if (not($elemsWithOtherTypeInfo) or (
            every $typeRel in $elemsWithOtherTypeInfo/elem/@typeRel
            satisfies $typeRel = ('child', 'descendant')))
        then $elemsWithOtherTypeInfo
        else
            copy $ewot := $elemsWithOtherTypeInfo
            modify
                for $elem at $pos in $ewot/elem
                let $parentElemName :=
                    $elem/$fnGetElemPaths($elemsWithOtherType[$pos], 
                        $disambigPathLength, $compDict, $nsmap, $options)[contains(., '/')] 
                        ! replace(., '/[^/]+$', '') => distinct-values() => string-join(' ')     
                (:
                return insert node attribute parentElem {$parentElemName} as last into $elem
                :)
                return replace node $elem with
                    $elem/element {node-name(.)} {@*, attribute parentElem {$parentElemName}}
            return $ewot
        
    let $elemInstances :=
        for $elem in $elems
        let $elemContext := $elem/coto:componentContext(., $nsmap)
        let $parentElemName :=
            if (not($elemsWithOtherTypeInfoAug)) then () else            
                $elem/$fnGetElemPaths(., $disambigPathLength, 
                     $compDict, $nsmap, $options)[contains(., '/')] 
                     ! replace(., '/[^/]+$', '') => distinct-values() => string-join(' ')
        return 
            <elem elemContext="{$elemContext}">{
                $parentElemName[string()] ! attribute parentElem {$parentElemName},
                $elem/@ref ! attribute isRef {true()}
            }</elem>
                   
    let $elemsForName :=
        <elems elemName="{$elemQName}">{
            $elemInstances,
            $elemsWithOtherTypeInfoAug
        }</elems>
    let $ambiguous :=
        if (not($elemsForName/elemsWithOtherType)) then ()
        else 
            let $paths1 := $elemsForName/elem//@parentElem[string()] ! tokenize(.)
            let $paths2 := $elemsForName/elemsWithOtherType//@parentElem[string()] ! tokenize(.)
            return $paths1[. = $paths2] => distinct-values() => sort()
    let $elemsForName :=
        if (empty($ambiguous)) then $elemsForName
        else
            element {node-name($elemsForName)} {
                $elemsForName/@*,
                let $ambPaths := ($ambiguous => string-join(', ')) ! ustr:truncate(., 120) 
                return
                    attribute WARNINGX 
                        {count($ambiguous)||' ambiguous paths: '||$ambPaths},
                $elemsForName/node()
            }
    return 
        if (not($elemsForName/@WARNINGX)) then $elemsForName
        else if ($disambigPathLength eq $kreg:DISAMBIG_PATH_LENGTH_MAX) then $elemsForName
        (: Increase disambiguation path length :)
        else kreg:writeElemsForTypeAndElemName(
            $elems, $typeQName, $elemQName, $disambigPathLength + 1, $options)
};        

declare function kreg:getPointersReport($options as map(*))
        as element() {
    let $compDict := $options?compDict
    let $nsmap := $options?nsmap
    let $ptypeWhitelistFilter := $const:PTYPE_WHITELIST ! unamef:parseNameFilter(.)
    let $ptypeBlacklistFilter := $const:PTYPE_BLACKLIST ! unamef:parseNameFilter(.)
    
    let $limitCount := $options?limitCount
    let $ptype := $options?pointerType
    let $ptypeFilter := $ptype ! unamef:parseNameFilter(.)

    let $allTypeNames := dict:compDict_getNormalizedTypeNames($compDict, $nsmap)
    let $pointerNamePattern := '*Ref'
    let $pointerElems := 
        for $elem in dict:compDict_getElemsMatchingName($pointerNamePattern, $compDict)
        order by $elem/(@name, @ref)
        return $elem
    let $pointerTypeInfos :=
        for $pointerElem in $pointerElems
            [empty($limitCount) or position() le $limitCount]
        let $typeAtt := $pointerElem/coto:getElemTypeOrBaseAtt(., $compDict)
        let $utype := $typeAtt/self::attribute(type)/uns:normalizeAttValueQName(., $nsmap)
        let $btype := $typeAtt/self::attribute(base)/uns:normalizeAttValueQName(., $nsmap)
        let $type := ($utype, $btype)
        let $typeLN := local-name-from-QName($type)
        where not($ptypeFilter) or 
            $typeLN ! unamef:matchesNameFilterObject(., $ptypeFilter)
        where not($ptypeWhitelistFilter) or 
            $typeLN ! unamef:matchesNameFilterObject(., $ptypeWhitelistFilter) 
        where not($ptypeBlacklistFilter) or 
            $typeLN ! not(unamef:matchesNameFilterObject(., $ptypeBlacklistFilter)) 
        group by $type
        order by string($type)
        
        let $_DEBUG := trace($type, 'Process pointer type: ')
        let $pointerTypeInfo := kreg:getPointerTypeInfo($type, $pointerElem, $options)
        return $pointerTypeInfo
    let $report :=
        <pointerTypes count="{count($pointerTypeInfos)}">{
            $pointerTypeInfos
        }</pointerTypes>
    return $report        
};

(:~
 : Writes an entities report.
 :)
declare function kreg:getEntitiesReport($keyrefReport as element()?,
                                        $options as map(*))
        as element() {
    let $nsmap := $options?nsmap
    let $irdict := $options?irdict
    let $itree := $options?itree
    let $etype := $options?entityType
    let $etypeFilter := $etype ! unamef:parseNameFilter(.)
    let $entityRootTypes := 
        <types>
            <type name="EntityStructure" namespace="http://www.netex.org.uk/netex"/>
        </types>
    let $entityRootTypesQ := $entityRootTypes/type/QName(@namespace, @name)
    
    let $entityTypes1 := $keyrefReport//pointerType/@entityType[not(. eq '?')]
    let $entityTypes1 := 
        let $rootTypes := 
            $itree//type[@name/uns:resolveNormalizedQName(., $nsmap) = $entityRootTypesQ]
        let $_DEBUG := trace($rootTypes/@name/string(), '_ root types: ')            
        return $rootTypes/descendant-or-self::*/@name
        
    let $entityTypes2 := () (: $entityTypes1 ! kreg:getDescendantEntityTypes(., $irdict) :)
    let $entityTypes := ($entityTypes1, $entityTypes2) => distinct-values() => sort()
    let $entityInfos :=
        for $entityType in $entityTypes
        where not($etypeFilter) or 
              $entityType ! unamef:matchesNameFilterObject(., $etypeFilter)
        let $_DEBUG := trace($entityType, 'Process entity type: ')
        let $entityTypeInfo := $entityType ! kreg:getEntityTypeInfo(., $options)
        return $entityTypeInfo
    let $report :=
        <entityTypes count="{count($entityInfos)}">{
            $entityInfos
        }</entityTypes>
    return $report        
};

declare function kreg:addSelectorElems($report as element(),
                                       $options as map(*))
        as element() {
    $report ! kreg:addSelectorElemsREC($report, $options)        
};        

declare function kreg:addSelectorElemsREC($n as node(),
                                          $options as map(*))
        as node()* {        
    typeswitch($n)
    case document-node() return 
        document {$n/node() ! kreg:addSelectorElemsREC(., $options)}
    case element(pointerType) | element(entityType) return
        let $selector :=
            let $expressions := (
                for $elems in $n/elems[elem/@elemContext != 'schemaXXX']
                return
                    if ($elems/elem/@parentElem) then
                        for $elem in $elems/elem[@elemContext ne 'schemaXXX'] 
                        for $parentElem in $elem/@parentElem/tokenize(.)
                        let $slashes := './/'   (: [not(starts-with($parentElem, '/'))] :)
                        return $elem/($slashes||$parentElem||'/'||../@elemName)
                    else './/'||$elems/@elemName
            ) => distinct-values()
            let $otherTypeExpressions := (
                for $parentElems in $n/elems/elemsWithOtherType/elem/@parentElem[string()]
                for $parentElem in $parentElems ! tokenize(.)
                return
                    '//'||$parentElem||'/'||$parentElems/ancestor::elems[1]/@elemName
            ) => distinct-values()
            let $warning :=
                let $ambiguous := $expressions[. = $otherTypeExpressions]
                where exists($ambiguous)
                let $ambPaths := ($ambiguous => string-join(', ')) ! ustr:truncate(., 120) 
                return
                    attribute WARNING {count($ambiguous)||' ambiguous paths: '||$ambPaths}
            return
                if (empty($expressions)) then ()
                else if (count($expressions) eq 1) then
                    <xs:selector xpath="{$expressions}"/>
                else
                    <selectors count="{count($expressions)}">{
                        $warning,
                        for $expr in $expressions
                        order by $expr
                        return $expr ! <xs:selector xpath="{.}"/>
                    }</selectors>
        return
            element {node-name($n)} {
                $n/@* ! kreg:addSelectorElemsREC(., $options),
                $selector,
                $n/node() ! kreg:addSelectorElemsREC(., $options)
        }        
    case element() return
        element {node-name($n)} {
            $n/@* ! kreg:addSelectorElemsREC(., $options),
            $n/node() ! kreg:addSelectorElemsREC(., $options)
        }
    default return $n
};        

declare function kreg:finalizeReport($report as element(),
                                     $options as map(*))
        as element() {
    $report/element {node-name(.)} {
        namespace xs {$const:URI_XSD},
        @*,
        node()
    }
};        

declare function kreg:addItemFrequencies($report as element(), $options)
        as element() {
    let $_LOG := trace('Augment report with item frequencies ...')
    let $nsmap := $options?nsmap
    let $dirExamples := $options?dirExamples
    let $docs := util:getExampleDocs($dirExamples)
    let $_DEBUG := trace(count($docs), '_ #example docs: ')
    let $optionsEff := 
        map:put($options, 'docExamples', $docs) !
        map:put(., 'xqprolog', uns:getNamespaceProlog($nsmap))
    let $_DEBUG := trace($optionsEff?xqprolog, '_ namespace prolog: ')
    return kreg:addItemFrequenciesREC($report, $optionsEff)
};

declare function kreg:addItemFrequenciesREC($n as node(), $options)
        as node()* {
    typeswitch($n)
    case document-node() return 
        document {$n/node() ! kreg:addItemFrequenciesREC(., $options)}
    case element(xs:selector) return
        let $xpath := $n/@xpath
        let $xq := $options?xqprolog||$xpath
        let $docs := $options?docExamples
        let $elems := $docs/xquery:eval($xq, map{'': .})
        let $fields := $n/ancestor::*[@fields][1]/@fields
        let $fieldItems := $fields ! tokenize(.) ! replace(., '^@', '')
        let $count := count($elems)
        let $fieldCounts :=
            if (not($count)) then () else
            for $field in $fieldItems return 
                count($elems[@*[local-name(.) eq $field]])
        let $missingFieldCounts := $fieldCounts ! ($count - .)                
        let $fieldCountsInfo :=
            if (not($count)) then () else 
                let $counts := if (sum($missingFieldCounts) eq 0) then '0'
                               else string-join($missingFieldCounts, '/')
                return ' #missingFields='||$counts
        let $countAttValue := 
            '#elems='||$count||$fieldCountsInfo
        return
            element {node-name($n)} {
                $n/@*,
                attribute counts {$countAttValue}
            }
    case element() return 
        element {node-name($n)} {
            $n/@* ! kreg:addItemFrequenciesREC(., $options),
            $n/uns:copyNamespaces(.),
            $n/node() ! kreg:addItemFrequenciesREC(., $options)
        }
    default return $n
};

declare function kreg:entityTypeNameToKeyName($name as xs:string)
        as xs:string {
    let $existingKeys := ('TypeOfValue_Key')        
    let $keyName := 
        if (ends-with($name, '_VersionStructure')) then replace($name, '_VersionStructure', '_Key')
        else if (ends-with($name, '_VersionFrameStructure')) then replace($name, '_VersionFrameStructure', '_VfsKey')        
        else if (ends-with($name, '_VersionedChildStructure')) then replace($name, '_VersionedChildStructure', '_VcsKey')
        else if (ends-with($name, '_ValueStructure')) then replace($name, '_ValueStructure', '_VasKey')
        else if (ends-with($name, '_ViewStructure')) then replace($name, '_ViewStructure', '_VisKey')
        else if (contains($name, '_')) then replace($name, '_[^_]+$', '_Key')
        else $name||'_Key'
    let $keyName := $keyName ! replace(., '.+:', '')        
    let $keyName := if ($keyName = $existingKeys) then $keyName||'2' else $keyName   
    
    let $_DEBUG := if (not(contains($keyName, 'TypeOfValueXXX'))) then () 
                   else trace($keyName, '_ keyName: ')
    return $keyName
};        

declare function kreg:pointerTypeNameToKeyrefName($pointerName as xs:string, $entityName as xs:string)
        as xs:string {
    if ($entityName eq '?') then '?' else
    
    let $keyrefName := 
        if (ends-with($pointerName, 'RefStructure')) then replace($pointerName, 'RefStructure', '_Ref')
        else $pointerName||'_Ref'
    let $keyrefName := $keyrefName ! replace(., '.+:', '')        
    return $keyrefName
};        
