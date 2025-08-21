(:
 : Functions creating a keyref report
 :)
module namespace kref="http://www.parsqube.de/xspy/report/keyref";
import module namespace uns="http://www.parsqube.de/xspy/util/namespace"
    at "util-namespace.xqm";

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

(:~
 : Creates a type resolution report.
 :)
declare function kref:keyrefReport($schemas as element(xs:schema)*,
                                   $ops as map(*)?)
        as element() {
    let $irep := $ops?irep
    let $irdoc := $irep! util:getDoc(.)
    (: irdict - maps every type name to an element in the hierarchy report :)
    let $irdict :=
        if (not($irdoc)) then () else map:merge(
        $irdoc//typeHierarchies//(type, etype, rtype)/@name/map:entry(., ..))
    let $_DEBUG := trace($irdict ! (map:keys(.) => count()), 'Count Inheritance Dictionary entries: ')
    let $txrep := $ops?txrep
    let $txdoc := $txrep ! util:getDoc(.)
    let $txdict := if (not($txdoc)) then () else 
        map{'type': map:merge($txdoc//type[not(@local)]/@name/map:entry(., ..)),
            'element': map:merge($txdoc//type[@local]/@elementName/map:entry(., ..))}
                
    let $_DEBUG := if (not($txrep)) then error((), 'MISSING TXREP') 
                   else if (not($txdoc)) then error((), 'MISSING TXDOC')
                   else if (empty($txdict)) then error((), 'MISSING TXDICT')
                   else ()
    let $nsmap := uns:getTnsPrefixMap($schemas, ())  
    let $compDict := dict:getCompDict($schemas, ())
    let $multiple := $ops?multiple
    let $multipleFilter := $multiple ! unamef:parseNameFilter(.)
    let $single := $ops?single
    let $singleFilter := $single ! unamef:parseNameFilter(.)
    
    let $optionsKR :=
        map:put($ops, 'compDict', $compDict) !
        map:put(., 'nsmap', $nsmap) !
        map:put(., 'compDict', $compDict) !
        map:put(., 'multiple', $multiple) !
        map:put(., 'multipleFilter', $multipleFilter) !
        map:put(., 'single', $single) !
        map:put(., 'irdict', $irdict) !
        map:put(., 'txdict', $txdict) !
        map:put(., 'singleFilter', $singleFilter)
        
    let $xsdInfos :=
        for $schema in $schemas[//xs:keyref]
        
        let $keyrefs := $schema//xs:keyref ! coto:getNormalizedComp(., $nsmap, $optionsKR)
        let $keys := $schema//xs:key ! coto:getNormalizedComp(., $nsmap, $optionsKR)
        let $uniques := $schema//xs:unique ! coto:getNormalizedComp(., $nsmap, $optionsKR)

        let $elemTypeDict := dict:getElemNameToTypeNamesDict($schemas, $nsmap)
        let $optionsAC := 
            map{'elemDict': $elemTypeDict, 
                'nsmap': $nsmap, 
                'compDict': $compDict,
                'txdict': $txdict} 

        let $keyrefsAug := $keyrefs ! kref:augmentConstraint(., $optionsAC)
        let $keysAug := $keys ! kref:augmentConstraint(., $optionsAC)
        let $uniquesAug := $uniques ! kref:augmentConstraint(., $optionsAC)
        
        let $constraintDict :=
            map{
                'keyref': map:merge($keyrefsAug/map:entry(@name, .)),
                'key': map:merge($keysAug/map:entry(@name, .)),
                'unique': map:merge($uniquesAug/map:entry(@name, .))
            }
        let $keyrefInfos :=
            for $keyref in $keyrefsAug
            let $name := $keyref/@name
            let $keyName := $keyref/@refer
            let $key := $constraintDict?key($keyName)
            order by $name
            return
                <keyref name="{$keyref/@name}">{
                    attribute keyName {$keyName},
                    attribute fields {$keyref/fields/@xpaths},
                    $keyref/(* except fields), 
                    $key/entities
                }</keyref>
        let $keyInfos :=
            for $key in $keysAug
            let $name := $key/@name
            let $keyrefs := $keyrefsAug[@refer eq $name]
            order by $name
            return
                <key name="{$key/@name}">{
                    attribute fields {$key/fields/@xpaths},
                    $key/entities,
                    for $keyref in $keyrefs
                    let $name := $keyref/@name
                    let $countPointerTypes := $keyref/pointers/pointer/(@type, @btype) 
                        => distinct-values() => count()
                    let $countRefTypes := $keyref/pointers/pointer/@refTypes 
                        => distinct-values() => count()
                    return
                        <pointers count="{$keyref/pointers/@count}" 
                                  countTypes="{$countPointerTypes}"
                                  countRefTypes="{$countRefTypes}"
                                  refName="{$name}">{
                            $keyref/pointers/pointer
                        }</pointers>
                }</key>
        return
            <xsd uri="{base-uri($schema)}">{
                <keyrefs count="{count($keyrefsAug)}">{
                    $keyrefInfos
                }</keyrefs>,
                <keys count="{count($keysAug)}">{
                    $keyInfos
                }</keys>,
                <uniques count="{count($uniquesAug)}">{$uniquesAug}</uniques>,                
                ()
            }</xsd>
    let $report :=
        <keyrefReport xmlns:xs="http://www.w3.org/2001/XMLSchema">{
            $xsdInfos
        }</keyrefReport>
    let $reportFinal := $report ! kref:finalizeReport(., $optionsKR)
    return $reportFinal        
};

declare function kref:summaries($report as element(),
                                $options as map(*))
        as element() {
    let $keyrefSummary := kref:keyrefSummary($report)        
    let $entitiesSummary := kref:entitiesSummary($report, $options)
    let $summaries :=
        <summaries>{
            $entitiesSummary,
            $keyrefSummary
        }</summaries>
    return $summaries
};

declare function kref:keyrefSummary($report as element())
        as element() {
    let $xsdReports :=
        for $xsd in $report/xsd
        let $uri := $xsd/@uri
 
        let $keyrefs := $xsd/keyrefs
        let $keys := $xsd/keys      

        let $refLocations := $keyrefs/keyref/pointers/pointer
        let $refLocationsNotype := $refLocations[not((@type, @btype))]
        let $refLocationTypes := $refLocations/(@type, @btype) => distinct-values()
        let $countRefLocations := count($refLocations)        
        let $countRefLocationTypes := count($refLocationTypes)
        let $countRefLocationsNotype := count($refLocationsNotype)   

        let $keyLocations := $keys/key/entities/entity
        let $keyLocationsNotype := $keyLocations[not((@type, @btype))]
        let $keyLocationTypes := $keyLocations/(@type, @btype) => distinct-values()
        let $countKeyLocations := count($keyLocations)        
        let $countKeyLocationTypes := count($keyLocationTypes)
        let $countKeyLocationsNotype := count($keyLocationsNotype)    
        return
            <xsd uri="{$uri}">{
                <keyrefs count="{count($keyrefs/*)}">{
                    <pointers count="{$countRefLocations}"
                              countTypes="{$countRefLocationTypes}"
                              countNOFIND="{$countRefLocationsNotype}">{
                        <pointersNOFIND>{
                            $refLocationsNotype
                        }</pointersNOFIND>
                    }</pointers>
                }</keyrefs>,
                <keys count="{count($keys/*)}">{
                    <entities count="{$countKeyLocations}"
                              countTypes="{$countKeyLocationTypes}"
                              countNOTYPE="{$countKeyLocationsNotype}">{
                        <entitiesNOFIND>{
                            $keyLocationsNotype
                        }</entitiesNOFIND>,
                        ()
                    }</entities>
                }</keys>
            }</xsd>
    return
        <keyrefSummary>{
            $xsdReports
        }</keyrefSummary>
};        

declare function kref:entitiesSummary($report as element(),
                                      $options as map(*))
        as element()? {
    let $entities := $report//keyref//entity[@btype, @type]
    let $entityTypes := $entities/(@btype, @type) => distinct-values() => sort()
    let $categoriesReport := kref:entityCategoriesReport($entities)    

    let $entitiesNofind :=
        let $keyLocations := $report//xsd/keys/key//entity
        let $keyLocationsNotype := $keyLocations[not((@type, @btype))]
        let $countKeyLocationsNotype := count($keyLocationsNotype)   
        return
            <entitiesNOFIND count="{$countKeyLocationsNotype}">{
                $keyLocationsNotype
            }</entitiesNOFIND>            
    
    let $irdict := $options?irdict
    let $irdictDependent :=
        if (empty($irdict)) then () else
        
        let $entityTypeElems := $entityTypes ! $irdict(.)
        let $entityTypesNotEntityStructure :=
            $entityTypeElems[not(ancestor-or-self::type[@name eq 'b:EntityStructure'])] 
        let $estructTypes := $irdict('b:EntityStructure')/descendant-or-self::*/@name
        let $estructTypesUsed := $estructTypes[not(../@use eq '---')]
        let $estructTypesUsedNoKeyref := $estructTypesUsed[not(. = $entityTypes)]
        let $estructTypesUsedNoKeyrefNotAbstract := $estructTypesUsedNoKeyref[not(../@abstract)]
        return (
            <entityStructureTypes 
                count="{count($estructTypes)}"
                countUsed="{count($estructTypesUsed)}"
                countUsedNoKeyref="{count($estructTypesUsedNoKeyref)}"
                countUsedNoKeyrefNotAbstract="{count($estructTypesUsedNoKeyrefNotAbstract)}"
            />,
            <entityTypes count="{count($entityTypes)}">{
                if (not($entityTypesNotEntityStructure)) then () else
                    attribute countNotEntityStructure {count($entityTypesNotEntityStructure)}
            }</entityTypes>
        )
    return
        <entitiesSummary>{
            $irdictDependent,
            $entitiesNofind,
            $categoriesReport
        }</entitiesSummary>
};

declare function kref:augmentConstraint($constraint as element(),
                                        $options as map(*))
        as element() {
    kref:augmentConstraintREC($constraint, $options)        
};

declare function kref:augmentConstraintREC($n as node(),
                                           $options as map(*))
        as node()* {
    typeswitch($n)
    case element(xs:keyref) | element(xs:key) | element(xs:unique) return
        let $locations :=
            $n/xs:selector/@xpath ! normalize-space(.) ! tokenize(., '\s*\|\s*')
        let $fields := <fields xpaths="{$n/xs:field/@xpath => string-join(' # ')}"/>
        let $compDict := $options?compDict
        let $txdict := $options?txdict
        let $nsmap := $options?nsmap
        return
        element {local-name($n)} {
            $n/@* ! kref:augmentConstraintREC(., $options),
            $fields, 
            let $locElemName := if ($n/self::xs:keyref) then 'pointer' else 'entity'
            let $locElemNamePlural := if ($n/self::xs:keyref) then 'pointers' else 'entities'
            let $locElemInfos :=
                for $location in $locations
                let $typeInfo := kref:getElemTypesForXpath($location, $options)
                let $types := $typeInfo?type
                let $btypes := $typeInfo?btype
                let $warning := $typeInfo?warning
                
                (: To do - this function should be refactored to have a simpler interface :)
                let $refTypes := kref:getElemSetAttributeTypes(
                    'b:ref', $location, $types, $btypes, $options)
                let $refTypesInfo := if (empty($refTypes)) then () 
                                     else $refTypes => string-join(', ')                    
(:                
                let $refTypes := if (not($n/self::xs:keyref)) then () else                    
                    let $typeDefs := ($types, $btypes) ! $txdict('type')(.)  
                    return 
                        ($typeDefs//xs:attribute[@name eq 'b:ref'][last()]/@type)[last()] 
                        => distinct-values() => sort() => string-join(' ')
:)                        
                (: To do - this function should be refactored to have a simpler interface :)
                let $idTypes := kref:getElemSetAttributeTypes(
                    'b:id', $location, $types, $btypes, $options)
                let $idTypesInfo := if (empty($idTypes)) then () 
                                    else $idTypes => string-join(', ')
                (:
                let $idTypes := if (not($n/self::xs:key)) then () else
                    let $localTypeBased :=
                        let $elemDecls :=
                            if (empty($btypes)) then () else (
                                kref:getElemDeclsForXpath($location, $options)
                                ! coto:getElemDecl(., $compDict))
                                [xs:complexType, xs:simpleType]
                        let $elemName := 
                            $elemDecls/coto:getNormalizedComponentQName(., $nsmap) ! string()
                            => distinct-values()
                        where exists($elemName)
                        let $localTypeDef := $txdict('element')($elemName)
                        return 
                            ($localTypeDef//xs:attribute[@name eq 'b:id'][last()]/@type)[last()] 
                            => distinct-values() => sort() => string-join(' ')                                          
                    return if ($localTypeBased) then $localTypeBased else
                        
                    let $typeDefs := ($types, $btypes) ! $txdict('type')(.)  
                    return 
                        ($typeDefs//xs:attribute[@name eq 'b:id'][last()]/@type)[last()] 
                        => distinct-values() => sort() => string-join(' ')
                :)                        
                return
                    element {$locElemName} {
                        attribute elem  {$location},
                        if (empty($types)) then () else
                            attribute type {$types},
                        if (empty($btypes)) then () else
                            attribute btype {$btypes},
                        $refTypesInfo ! attribute refTypes {.},                            
                        $idTypesInfo ! attribute idTypes {.},                        
                        $warning ! attribute WARNING {.}
                    }
            let $locElemInfos :=
                if (not($n/self::xs:keyref) or count($locElemInfos) eq 1) then $locElemInfos
                else
                    for $locElemInfo in $locElemInfos
                    let $type := $locElemInfo ! (@type, @btype)[1]
                    group by $type
                    return
                        <ptype name="{$type}">{
                            $locElemInfo
                        }</ptype>
            let $countTypes := $locElemInfos//(@type, @btype) 
                               => distinct-values() => count()
            let $countRefTypes := 
                if (not($n/self::xs:keyref)) then () else
                    $locElemInfos//@refTypes/tokenize(.) 
                                   => distinct-values() => count()
            let $countIdTypes := 
                if (not($n/self::xs:key)) then () else
                    $locElemInfos//@idTypes/tokenize(.) 
                                   => distinct-values() => count()
            return
                element {$locElemNamePlural} {
                    attribute count {count($locations)},
                    attribute countTypes {$countTypes},
                    if (empty($countRefTypes)) then () else
                    $countRefTypes ! attribute countRefTypes {.},
                    if (empty($countIdTypes)) then () else
                    $countIdTypes ! attribute countIdTypes {.},
                    $locElemInfos
                } 
        }
    case element() return
        element {node-name($n)} {
            $n/@* ! kref:augmentConstraintREC(., $options),
            $n/node() ! kref:augmentConstraintREC(., $options)
        }        
    default return $n
};

(:~
 : Returns type information about the element sets selected
 : by an XPath expression. Each element set is defined by
 : an element name or a sequence of element names separated
 : by slash, used in the XPath expression. Each element
 : set is described by a map with entries 'type' and 'btype'.
 :)
declare function kref:getElemTypesForXpath($xpath as xs:string, 
                                           $options as map(*))
        as map(*)? {
    let $elemNames := $xpath ! analyze-string(., '(\i\c*?:)?\i\c*') ! fn:match/string()
    let $elemName := $elemNames[1]
    let $typeInfo :=
        if (count($elemNames) le 1) then
            let $qname := $elemName ! uns:resolveNormalizedQName(., $options?nsmap)
            let $typeInfo := $options?elemDict($qname)
            return $typeInfo
        else
            let $elemQnames := $elemNames ! uns:resolveNormalizedQName(., $options?nsmap)
            let $elemsStep1 := $options?compDict('element')($elemQnames[1])
            let $typeDefs := coto:getItemTypeDefs($elemsStep1, $options?compDict)
            let $elemsStepLast := kref:getElemDeclsForElemNames(tail($elemQnames), $typeDefs, $options)
            where $elemsStepLast
            let $typeDefsStepLast := coto:getItemTypeDefs($elemsStepLast, $options?compDict)
            let $_DEBUG := 
                if (count($typeDefsStepLast) gt 0) then () else
                    trace($xpath, '_NO_TYPE_DEFS_FOR_ELEM_XPATH: ')
            let $typeNames :=
                $typeDefsStepLast[@name]/coto:getNormalizedComponentQName(., $options?nsmap)
                ! string()
            let $btypeNames :=
                $typeDefsStepLast[not(@name)]/coto:getBaseAtt(.)
                    /uns:normalizeAttValueQName(., $options?nsmap)
                ! string()
            return
                map{'type': $typeNames, 'btype': $btypeNames}
    return
        if (exists($typeInfo)) then $typeInfo
        else map{'warning': 'NO ELEMENTS'}
};

(:~
 : Returns element declarations belonging to the element sets 
 : selected by an XPath expression. Each element set is defined 
 : by an element name or a sequence of element names separated
 : by slash, used in the XPath expression.
 :)
declare function kref:getElemDeclsForXpath($xpath as xs:string, 
                                           $options as map(*))
        as element(xs:element)* {
    let $elemNames := $xpath ! analyze-string(., '(\i\c*?:)?\i\c*') ! fn:match/string()
    let $elemName := $elemNames[1]
    let $typeInfo :=
        if (count($elemNames) le 1) then
            let $qname := $elemName ! uns:resolveNormalizedQName(., $options?nsmap)
            let $elemDecl := $options?compDict('element')($qname)
            return $elemDecl
        else
            let $elemQnames := $elemNames ! uns:resolveNormalizedQName(., $options?nsmap)
            let $elemsStep1 := $options?compDict('element')($elemQnames[1])
            let $typeDefs := coto:getItemTypeDefs($elemsStep1, $options?compDict)
            let $elemsStepLast := kref:getElemDeclsForElemNames(tail($elemQnames), $typeDefs, $options)
            return $elemsStepLast
    return $typeInfo            
};

(:~
 : Maps a sequence of element names to element declarations, assuming
 : that each name is the name of a child element, starting with a
 : given set of type definitions.
 :
 : Example: Let $typeDefs be the complex type definition named
 : 'CustomerType' and $elemNames be the element names 'address', 'zip'.
 : The function then returns the element declarations corresponding
 : the element address/zip found within elements with the type
 : 'CustomerType'.
 :)
declare function kref:getElemDeclsForElemNames($elemNames as xs:QName+, 
                                               $typeDefs as element()*, 
                                               $options as map(*))
        as element()* {
    let $elemName := head($elemNames)
    let $elemDecls := $typeDefs/coto:getElemDeclsForElemName(
        $elemName, ., $options?nsmap, $options?compDict, $options)
    return
        if (count($elemNames) eq 1) then $elemDecls
        else
            let $typeDefs2 := coto:getItemTypeDefs($elemDecls, $options?compDict)
            return kref:getElemDeclsForElemNames(
                tail($elemNames), $typeDefs2, $options)
};        

(:~
 : Finalizes the report.
 :)
declare function kref:finalizeReport($report as element(), $ops as map(*))
        as element() {
    let $summaries := $report ! kref:summaries(., $ops)
    let $ops2 := $ops ! map:put(., 'summaries', $summaries)
    return
        $report ! kref:finalizeReportREC(., $ops2)        
};

(:~
 : Recursive helper function of `finalizeReport`.
 :)
declare function kref:finalizeReportREC($n as node(), $ops as map(*))
        as node()* {
    typeswitch($n)
    case document-node() return document {$n/node() ! kref:finalizeReportREC(., $ops)}
    case element(keyrefReport) return
        element {node-name($n)} {
            $ops?multiple ! attribute multiple {.},
            $ops?single ! attribute single {.},
            $n/@* ! kref:finalizeReportREC(., $ops),
            $ops?summaries,
            $n/node() ! kref:finalizeReportREC(., $ops)
        }
    case element(keyref) | element(key) return
        let $multipleFilter := $ops?multipleFilter
        let $singleFilter := $ops?singleFilter        
        let $suppress1 :=
            if (not($multipleFilter)) then false() else
            
            $multipleFilter/unamef:matchesNameFilterObject('entities', .)
                and count($n//entity) eq 1
            or $multipleFilter/unamef:matchesNameFilterObject('pointers', .)
                and count($n//pointer) eq 1
        let $suppress2 :=
            if (not($singleFilter)) then false() else
            
            $singleFilter/unamef:matchesNameFilterObject('entities', .)
                and count($n//entity) gt 1
            or $singleFilter/unamef:matchesNameFilterObject('pointers', .)
                and count($n//pointer) gt 1
        where not($suppress1 or $suppress2)
        return
            element {node-name($n)} {
                $n/@* ! kref:finalizeReportREC(., $ops),
                $n/node() ! kref:finalizeReportREC(., $ops)
            }
        
    case element(pointers) | element(entities) return
        let $children := $n/* ! kref:finalizeReportREC(., $ops) 
        let $entityTypeHierarchyReport :=
            let $irdict := $ops?irdict
            return if (empty($irdict)) then () else
            
            if (not($n/self::entities)) then () else            
            let $typeNames := $n/entity/(@type, @btype)
            let $typeElems := $typeNames ! $irdict?(.)
            let $typeHierarchyReport := kref:getTypeHierarchyReport($typeElems)
            return
                $typeHierarchyReport
        let $annoEntities := $entityTypeHierarchyReport                
        return
            let $other := if ($n/self::pointers) then $n/../entities 
                          else $n/../pointers
            let $other := $other[1]
            return
                if ((: count($other) eq 1 and
                    and $other/@count = '1' and :)               
                    $n/@count = '1' and
                    not($annoEntities/@rootComplete eq 'false')) then $children
                else
                    element {node-name($n)} {                    
                        $n/@* ! kref:finalizeReportREC(., $ops),
                        $annoEntities,
                        $children
                    }
    case element() return 
        element {node-name($n)} {
            $n/@* ! kref:finalizeReportREC(., $ops),
            $n/node() ! kref:finalizeReportREC(., $ops)
        }
    default return $n        
};

(:~
 : Reports the hierarchical relationships between a set of types.
 :)
declare function kref:getTypeHierarchyReport($typeElems as element()*)
        as element()? {
    let $typeElems := $typeElems
    let $typeElemIds := $typeElems/generate-id(.)
    let $roots := $typeElems[not(ancestor::* intersect $typeElems)]/.
    let $areRootsSiblings := 
        if (count($roots) eq 1) then () else count($roots/..) eq 1    
    let $areRootSiblingsComplete :=
        if (not($areRootsSiblings)) then () else
            count($roots) eq $roots[1]/../* => count()
    let $rootsReport :=
        <roots>{
            for $root in $roots
            (: Only descendants which are used by an element are considered :)
            let $descendants := $root//(etype, rtype)[matches(@use, '[tER]')]
            let $descendantsIncluded := $descendants[. intersect $typeElems]
            let $descendantsMissing := $descendants except $descendantsIncluded
            return
                <root name="{$root/@name}"
                      countDescendants="{count($descendants)}">{
                    if (not($descendants)) then () else
                        attribute countDescendantsIncluded {count($descendantsIncluded)},
                    if (not($descendants)) then () else
                    <descendantEntityTypes>{
                        $descendants ! <entityType name="{@name}"/>
                    }</descendantEntityTypes>,
                    if (count($descendants) eq count($descendantsIncluded)) then ()
                    else (
                        <includedEntityTypes>{
                            $descendantsIncluded ! <entityType name="{@name}"/>
                        }</includedEntityTypes>,
                        <missingEntityTypes rootType="{$root/@name}" 
                                            count="{count($descendantsMissing)}">{
                            $descendantsMissing ! <entityType name="{@name}"/>
                        }</missingEntityTypes>
                    )
                }</root>
        }</roots>
    
    let $countRoots := $rootsReport/root => count()
    let $countTypes := $typeElems/@name => distinct-values() => count()
    let $rootsComplete :=
        if (empty($rootsReport/root[@countDescendants ne '0'])) then () else
        
        every $root in $rootsReport/root satisfies
            $root/@countDescendants eq '0' 
            or $root/(@countDescendants eq @countDescendantsIncluded)
    let $descendantsMissing := 
        $rootsReport//missingEntityTypes/entityType
    let $countDescendantsMissing :=
        $descendantsMissing => count()
    let $warning :=
        if (not($countDescendantsMissing)) then () else
        $countDescendantsMissing||
            ' MISSING ENTITY TYPE'||('S'[$countDescendantsMissing gt 1])
    let $rootInfo :=
        if (count($typeElems) eq count($roots)) then ()
        else if ($countRoots eq 1) then attribute rootType {$rootsReport/root/@name}
        else attribute rootTypes {$rootsReport/root/@name => string-join(', ')}
    return
        <hierarchyReport countTypes="{$countTypes}" 
                         countRoots="{$countRoots}">{
            $warning ! attribute WARNING {.},
            $rootsComplete ! attribute rootComplete {.},
            $areRootsSiblings ! attribute areRootsSiblings {.},            
            $areRootSiblingsComplete ! attribute areRootSiblingsComplete {.},
            $rootInfo, 
            $rootsReport//missingEntityTypes
        }</hierarchyReport>
};        

(:~
 : Creates an entity categories report.
 :)
declare function kref:entityCategoriesReport($entities as element(entity)*)
        as element() {
    let $entityCategories :=        
        for $type in $entities/(@type, @btype) => distinct-values()
        group by $suffix := replace($type, '.+_', '')[. ne $type]
        let $suffix2 := ($suffix, '-')[1]
        order by if ($suffix ne '-') then $suffix2 else 'ZZZ'
        return
            <entityCategory suffix="{$suffix2}" count="{count($type)}">{
                if ($suffix2 ne '-') then () else
                    ($type => sort()) ! <entityType name="{.}"/>
            }</entityCategory>
    return
        <entityCagories count="{count($entityCategories)}">{
            $entityCategories
        }</entityCagories>
        
};        

(:~
 : Returns the types of a particular attribute used in a set of elements.
 :)
declare function kref:getElemSetAttributeTypes($attName, 
                                               $location, 
                                               $types, 
                                               $btypes, 
                                               $options)
        as xs:string* {
    let $compDict := $options?compDict
    let $txdict := $options?txdict
    let $nsmap := $options?nsmap
    
    let $localTypeBased :=
        let $elemDecls := if (empty($btypes)) then () else (
            kref:getElemDeclsForXpath($location, $options)
            ! coto:getElemDecl(., $compDict))
            [xs:complexType, xs:simpleType]
        let $elemName := 
            $elemDecls/coto:getNormalizedComponentQName(., $nsmap) ! string()
            => distinct-values()
        where exists($elemName)
        let $localTypeDef := $txdict('element')($elemName)
        return 
            ($localTypeDef//xs:attribute[@name eq $attName][last()]/@type)[last()] 
                          => distinct-values() => sort()                                          
    return if ($localTypeBased) then $localTypeBased[string()] else
                        
    let $typeDefs := ($types, $btypes) ! $txdict('type')(.)  
    return
        ($typeDefs//xs:attribute[@name eq $attName][last()]/@type)[last()] 
                  => distinct-values() => sort()
};        
