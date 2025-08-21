module namespace dict="http://www.parsqube.de/xspy/util/dictionaries";
import module namespace const="http://www.parsqube.de/xspy/constants"
    at "constants.xqm";
import module namespace coto="http://www.parsqube.de/xspy/util/component-tools"    
    at "component-tools.xqm";
import module namespace suto="http://www.parsqube.de/xspy/util/summary-tools"
    at "summary-tools.xqm";
import module namespace util="http://www.parsqube.de/xspy/util"
    at "util.xqm";

import module namespace uns="http://www.parsqube.de/xspy/util/namespace"
    at "util-namespace.xqm";
import module namespace unamef="http://www.parsqube.de/xquery/util/name-filter"
    at "../util/util-nameFilter.xqm";

declare namespace z="http://www.parsqube.de/xspy/structure";
declare namespace xspy="http://www.parsqube.de/xspy/structure";

(:~
 : Returns a dictionary of schema components.
 :)
declare function dict:getCompDict($schemas as element(xs:schema)*,
                                  $kinds as xs:string?)
        as map(*) {
    let $kindNames := 
        let $explicit := $kinds ! tokenize(.) ! lower-case(.)
        return
            if (exists($explicit)) then $explicit
            else ('type', 'group', 'elem', 'element', 'att', 'attribute', 'agroup', 'attributeGroup')
    let $fnCompName := function($comp) {$comp/QName(ancestor::xs:schema/@targetNamespace, @name)}            
    return
        map:merge((
            if (not($kindNames = 'type')) then () else
                map:entry('type', map:merge(
                    for $comp in $schemas/(xs:simpleType, xs:complexType)
                    group by $qname := $comp/$fnCompName(.)
                    return map:entry($qname, $comp))),        
            if (not($kindNames = 'group')) then () else
                map:entry('group', map:merge(
                    for $comp in $schemas/xs:group
                    group by $qname := $comp/$fnCompName(.)
                    return map:entry($qname, $comp))),        
            if (not($kindNames = ('elem', 'element'))) then () else
                map:entry('element', map:merge(
                    for $comp in $schemas/xs:element
                    group by $qname := $comp/$fnCompName(.)
                    return map:entry($qname, $comp))),        
            if (not($kindNames = ('att', 'attribute'))) then () else
                map:entry('attribute', map:merge(
                    for $comp in $schemas/xs:attribute
                    group by $qname := $comp/$fnCompName(.)
                    return map:entry($qname, $comp))),        
            if (not($kindNames = ('agroup', 'attributeGroup'))) then () else
                map:entry('agroup', map:merge(
                    for $comp in $schemas/xs:attributeGroup
                    group by $qname := $comp/$fnCompName(.)
                    return map:entry($qname, $comp))),        
            ()
        ))
};        

(:~
 : Writes a dictionary mapping element QNames to maps with entries
 : 'type' and 'btype' containing the type names and local base type
 : names, respectively, as normalized name strings.
 :)
declare function dict:getElemNameToTypeNamesDict($schemas as element(xs:schema)*,
                                                 $nsmap as element(z:nsMap))
        as map(xs:QName, map(xs:string, xs:string*)) {
    let $nsmap :=
        if ($nsmap) then $nsmap else uns:getTnsPrefixMap($schemas, ())
    return map:merge(
        for $elem in $schemas//xs:element
        let $elem := $elem/coto:getElemDeclSCH(., $schemas)
        let $name := $elem/@name
        let $qname := resolve-QName($name, $elem) ! uns:normalizeQName(., $nsmap)
        group by $qname
        let $types := 
            $elem/@type ! uns:normalizeAttValueQName(., $nsmap) ! string()
                => distinct-values() => sort()
        let $btypes := 
            $elem/(xs:simpleType, xs:complexType)
                /coto:getBaseAtt(.) ! uns:normalizeAttValueQName(., $nsmap) ! string()
                => distinct-values() => sort()
        return
            map:entry($qname, map{'type': $types, 'btype': $btypes})
    )
        
};

(:~
 : Returns a dictionary of type use by substitution groups.
 : Top-level keys:
 : 'sgHeads': for each type QName the names of substitution group head elements using this type
 : 'sgMembersTY': for each type QName the names of substitution group head elements with group members
 :   using this type as @type 
 : 'sgMembersLT': for each type QName the names of substritution group head elements with group members
 :   using this type as base type of the local type, with information about the usage appended:
 :   ...(ext) - the type is used as base type of a non-empty extension 
 :   ...(ext0) - the type is used as base type of an empty extension 
 :   ...(res) - the type is used as base type of a non-empty restriction 
 :   ...(res0) - the type is used as base type of an empty restriction 
 :)
declare function dict:getTypeUseSgDict($schemas as element(xs:schema)*)
        as map(*) {
    let $nsmap := uns:getTnsPrefixMap($schemas, ())        
    let $sgMemberElems := $schemas/xs:element[@substitutionGroup]            
    let $sgHeadQNames := $sgMemberElems/@substitutionGroup/resolve-QName(., ..)
    let $sgHeadElems := $schemas/xs:element[QName(../@targetNamespace, @name) = $sgHeadQNames]
    let $dictSgHeads :=
        map:merge(
            for $sgHeadElem in $sgHeadElems
            let $type := $sgHeadElem/@type
            where $type
            group by $qname := $type/resolve-QName(., ..)
            return map:entry($qname, $sgHeadElem/@name/QName(../../@targetNamespace, .) 
                   ! uns:normalizeQName(., $nsmap) ! string())
        )
    let $dictSgMembersTY :=
        map:merge(
            for $sgMemberElem in $sgMemberElems[@type]
            let $type := $sgMemberElem/@type
            group by $qname := $type/resolve-QName(., ..)
            let $headNames := 
                $sgMemberElem/@substitutionGroup/resolve-QName(., ..) 
                ! uns:normalizeQName(., $nsmap) ! string() 
                => distinct-values() => sort()
            return map:entry($qname, $headNames)
        )
    let $dictSgMembersLT :=
        map:merge(
            for $sgMemberElem in $sgMemberElems[not(@type)]
            let $base := $sgMemberElem/
                         (xs:complexType, xs:simpleType)/
                         (xs:restriction, */(xs:restriction, xs:extension))/
                         @base
            where $base
            group by $qname := $base/resolve-QName(., ..)
            let $derivationKind := @base/../substring(., 1, 3) => 
                distinct-values() => sort() => string-join('/')
            let $headNamesAnnotated := (
                for $elem in $sgMemberElem
                let $sgGroup := $elem/@substitutionGroup/resolve-QName(., ..) 
                                ! uns:normalizeQName(., $nsmap) ! string()
                let $annotation := 
                    let $extension := $elem/*/*/xs:extension
                    let $restriction:= $elem/(xs:restriction, */*/xs:restriction)
                    return
                        if ($extension) then
                            if ($extension/(* except xs:annotation)) then 'ext'
                            else 'ext0'
                        else if ($restriction) then
                            if ($restriction/(* except xs:annotation)) then 'res'
                            else 'res0'
                        else '???'
                return $sgGroup||'('||$annotation||')'
                ) => distinct-values() => sort()
            return map:entry($qname, $headNamesAnnotated)
        )
    return
        map{'sgHeads': $dictSgHeads,
            'sgMembersTY': $dictSgMembersTY,
            'sgMembersLT': $dictSgMembersLT
        }        
};        

(:~
 : Returns a dictionary of type use counts.
 : Top-level keys:
 : 'type': for each type QName the number of items using the type as @type
 : 'anonBaseE': for each type QName the number of anonymous type definitions using the type as extension base
 : 'anonBaseR': for each type QName the number of anonymous type definitions using the type as restriction base
 : 'itemType': for each type QName the number of type definitions using the type as item type 
 : 'memberType': for each type QName the number of type definitions using the type as member type 
 :)
declare function dict:getTypeUseCountsDict($schemas as element(xs:schema)*)
        as map(*) {
    let $nsmap := uns:getTnsPrefixMap($schemas, ())    
    let $dictTypeUseAsType :=
        map:merge(
            for $typeAtt in $schemas//(xs:element, xs:attribute)/@type
            group by $qname := $typeAtt/resolve-QName(., ..)
            return map:entry($qname, count($typeAtt)))
    let $dictTypeUseAsBaseE :=
        map:merge(
            for $typeDef in $schemas/(xs:simpleType, xs:complexType)
            let $base := $typeDef/(xs:extension, */xs:extension)/@base
            where $base
            group by $qname := $base/resolve-QName(., ..)
            return map:entry($qname, count($typeDef)))
    let $dictTypeUseAsBaseR :=
        map:merge(
            for $typeDef in $schemas/(xs:simpleType, xs:complexType)
            let $base := $typeDef/(xs:restriction, */xs:restriction)/@base
            where $base
            group by $qname := $base/resolve-QName(., ..)
            return map:entry($qname, count($typeDef)))
    let $dictTypeUseAsAnonBaseE :=
        map:merge(
            for $typeDef in $schemas//(xs:simpleType, xs:complexType)[not(@name)]
            let $base := $typeDef/(xs:extension, */xs:extension)/@base
            where $base
            group by $qname := $base/resolve-QName(., ..)
            return map:entry($qname, count($typeDef)))
    let $dictTypeUseAsAnonBaseR :=
        map:merge(
            for $typeDef in $schemas//(xs:simpleType, xs:complexType)[not(@name)]
            let $base := $typeDef/(xs:restriction, */xs:restriction)/@base
            where $base
            group by $qname := $base/resolve-QName(., ..)
            return map:entry($qname, count($typeDef)))
    let $dictTypeUseAsItemType :=
        map:merge(
            for $typeDef in $schemas//xs:simpleType
            let $itype := $typeDef/xs:list/@itemType
            where $itype
            group by $qname := $itype/resolve-QName(., ..)
            return map:entry($qname, count($typeDef)))
    let $dictTypeUseAsMemberType :=
        map:merge(
            for $mtype in 
                $schemas//xs:simpleType/xs:union/@memberTypes/
                    (for $t in tokenize(.) return resolve-QName($t, ..))
            group by $qname := $mtype
            return map:entry($qname, count($mtype)))
    return
        map{'type': $dictTypeUseAsType,
            'anonBaseE': $dictTypeUseAsAnonBaseE,
            'anonBaseR': $dictTypeUseAsAnonBaseR,
            'baseE': $dictTypeUseAsBaseE,
            'baseR': $dictTypeUseAsBaseR,
            'itemType': $dictTypeUseAsItemType,
            'memberType': $dictTypeUseAsMemberType
        }
            
};  

(: Returns a dictionary mapping type names to element declarations
 : directly using the type, either via @type or via @base of a
 : local type definition.
 :)
declare function dict:getTypeUsedByElemDict($compDict as map(*),
                                            $nsmap as element(z:nsMap))
        as map(*) {        
    let $elemsAll := 
        let $keys := map:keys($compDict?element)
        return $keys ! $compDict('element')(.)
    let $elemsGlobalType := $elemsAll[@type]
    let $elemsLocalType := $elemsAll[not(@type)]
    let $typeNames := map:keys($compDict?type)
    let $dictEntries :=
        for $typeName in $typeNames
        let $elemsType := $elemsGlobalType
            [@type/resolve-QName(., ..) eq $typeName]  
        let $elemsBase := $elemsLocalType
            [(xs:complexType, xs:simpleType)/
              coto:getTypeContentElem(.)/@base/resolve-QName(., ..) eq $typeName]
        let $elems := ($elemsType, $elemsBase)
        let $qnamesNorm := (
            for $qname in $elems/coto:getComponentQName(.) => distinct-values()
            let $qnameN := $qname ! uns:normalizeQName(., $nsmap)
            let $qnameS := string($qnameN)
            order by $qnameS
            return $qnameS ) => string-join(', ')
        return
            map:entry($typeName, map{'names': $qnamesNorm, 'elems': $elems})
    return map:merge($dictEntries)            
};

(: Returns a dictionary mapping type names to the names of elements
 : and attributes directly using the type, either via @type or via 
 : @base of a local type definition.
 :
 : @param compDict component dictionary
 : @param types the types to be described; either type definitions or QNames
 : @param nsmap namespace map
 : @return the dictionary
 :)
declare function dict:getTypeUsedByItemDict($compDict as map(*),
                                            $types as item()*,
                                            $nsmap as element(z:nsMap))
        as map(*) {        
    let $elemsAll := dict:compDict_getAllElems($compDict)
    let $attsAll := dict:compDict_getAllAtts($compDict)
    let $elemsGlobalType := $elemsAll[@type]
    let $elemsLocalType := $elemsAll[not(@type)]    
    let $attsGlobalType := $attsAll[@type]
    let $attsLocalType := $attsAll[not(@type)]
    
    let $typeNames := 
        if (empty($types)) then map:keys($compDict?type)
        else if ($types[1] instance of xs:QName) then $types
        else $types/coto:getComponentQName(.)
    let $dictEntries :=
        for $typeName in $typeNames
        let $elemsType := $elemsGlobalType
            [@type/resolve-QName(., ..) eq $typeName]  
        let $attsType := $attsGlobalType
            [@type/resolve-QName(., ..) eq $typeName]  
        let $elemsBase := $elemsLocalType
            [(xs:complexType, xs:simpleType)/
              coto:getTypeContentElem(.)/@base/resolve-QName(., ..) eq $typeName]
        let $attsBase := $attsLocalType
            [xs:simpleType/
              coto:getTypeContentElem(.)/@base/resolve-QName(., ..) eq $typeName]
        let $fnSortedQnames := function($comps) {(
            for $qname in $comps/coto:getComponentQName(.) => distinct-values()
            let $qnameS := $qname ! uns:normalizeQName(., $nsmap) ! string(.)
            order by $qnameS
            return $qnameS ) => string-join(', ')
        }        
        let $namesElemsType := $fnSortedQnames($elemsType)
        let $namesElemsBase := $fnSortedQnames($elemsBase)        
        let $namesAttsType := $fnSortedQnames($attsType)
        let $namesAttsBase := $fnSortedQnames($attsBase)        
        return 
            map:entry($typeName, map:merge((
                if (empty($elemsType)) then () else (
                  (: map:entry('elemsWithType', $elemsType), :)            
                  map:entry('namesElemsWithType', $namesElemsType)),
                if (empty($elemsBase)) then () else (
                  (: map:entry('elemsWithBase', $elemsBase), :)            
                  map:entry('namesElemsWithBase', $namesElemsBase)),
                if (empty($attsType)) then () else (
                  (: map:entry('attsWithType', $attsType), :)            
                  map:entry('namesAttsWithType', $namesAttsType)),
                if (empty($attsBase)) then () else (
                  (: map:entry('attsWithBase', $attsBase), :)            
                  map:entry('namesAttsWithBase', $namesAttsBase))
            )))
    return map:merge($dictEntries)            
};

declare function dict:getFileDict($schemas as element(xs:schema)*,
                                  $ops as map(*))
        as element(files) {
    let $files :=
        for $schema in $schemas
        group by $baseUri := $schema/base-uri(.)
        order by $baseUri
        count $fnr
        return <file file="{$fnr}" uri="{$baseUri}"/>
    let $fileDict := <files count="{count($files)}">{$files}</files>
    return $fileDict    
};  

(:~
 : Writes a dictionary mapping QNames to element declarations
 : referencing this QName (@ref).
 :)
declare function dict:getElementRefDict($compDict as map(*),
                                        $nsmap as element(z:nsMap))
        as map(*) {
    let $refElems := dict:compDict_getElemsWithRef($compDict)
    let $entries :=
        for $elem in $refElems
        let $ref := $elem/@ref/coto:getNormalizedAttQName(., $nsmap)
        group by $ref
        return map:entry($ref, $elem)
    return map:merge($entries)        
};

(:~
 : Writes a dictionary mapping qualified type names to the
 : elements using it as type or local base type.
 :)
declare function dict:getElementTypeDict($compDict as map(*),
                                         $nsmap as element(z:nsMap))
        as map(*) {
    let $allElems := dict:compDict_getAllElems($compDict)
    let $entries :=
        for $elem in $allElems
        let $typeName := 
            $elem/coto:getElemTypeOrBaseAttNormalized(., $compDict, $nsmap) 
        (: An element may have no type or base type ... :)
        where exists($typeName)
        group by $typeName
        return map:entry($typeName, $elem)
    return map:merge($entries)
};        

(:~
 : Writes a dictionary mapping QNames to group references of this 
 : name (@ref).
 :)
declare function dict:getGroupRefDict($compDict as map(*),
                                      $nsmap as element(z:nsMap))
        as map(*) {
    let $groups := dict:compDict_getGroupRefs($compDict)
    let $entries :=
        for $group in $groups
        let $ref := $group/@ref/coto:getNormalizedAttQName(., $nsmap)
        group by $ref
        return map:entry($ref, $group)
    return map:merge($entries)        
};

(:~
 : Writes a dictionary mapping QNames to all types using a group
 : with this name.
 :
 : @param compDict a component dictionary
 : @param groupRefDict a dictionary mapping group names to all @ref attributes
 : @param nsmap a namespace map
 : @return a map associating group names with type definition elements
 :)
declare function dict:getTypesUsingGroupDict(
                                      $compDict as map(*),
                                      $groupRefDict as map(*),                                      
                                      $nsmap as element(z:nsMap))
        as map(*) {
    let $groupNames := map:keys($groupRefDict)
    let $entries :=
        for $groupName in $groupNames
        let $typeDefs := dict:getTypesUsingGroup(
            $groupName, $compDict, $groupRefDict, $nsmap)
        return map:entry($groupName, $typeDefs)
    return map:merge($entries)        
};

declare %private function dict:getTypesUsingGroup(
                                         $groupName as xs:QName,
                                         $compDict as map(*),
                                         $groupRefDict as map(*),
                                         $nsmap as element(z:nsMap))
        as element()* {
    let $typeDefs :=
        for $ref in $groupRefDict($groupName)
        let $myTypes := $ref/ancestor::xs:complexType[1]
        let $usedByGroup := $ref/ancestor::xs:group[@name]/coto:getNormalizedComponentQName(., $nsmap)        
        return (
            $myTypes,
            $usedByGroup ! dict:getTypesUsingGroup(., $compDict, $groupRefDict, $nsmap)
        )
    return $typeDefs/.
};        

(:~
 : Writes a dictionary mapping type names to the names of types derived from it.
 :)
declare function dict:getInheritanceDict($inheritanceReport as element())
         as map(*) {
    map:merge(
        $inheritanceReport//typeHierarchies//(type, etype, rtype)/@name/
        map:entry(., ..))
};

declare function dict:reduceFileDict($dict as element(files), $files as xs:string*)
        as element(files) {
    let $files2 := $dict/file[@file = $files]        
    return
        element {node-name($dict)} {
            $dict/@count,
            attribute filesUsed {count($files2)},
            $files2
        }
};   

(: ==========================================================
 :     c o m p D i c t        r e t r i e v a l
 : ==========================================================
 :)

(:~
 : Returns all type definitions, global and local.
 :)
declare function dict:compDict_getAllTypes($compDict as map(*))
        as element()* {
    (
        $compDict?type?*,
        $compDict?type?*      //(xs:complexType, xs:simpleType),
        $compDict?element?*   //(xs:complexType, xs:simpleType),
        $compDict?attribute?* //xs:simpleType,        
        $compDict?group?*     //(xs:complexType, xs:simpleType),
        $compDict?agroup?*    //xs:simpleType
    )
};   

(:~
 : Returns all element declarations, global and local.
 :)
declare function dict:compDict_getAllElems($compDict as map(*))
        as element()* {
    (
        $compDict?element?*,
        $compDict?element?* //xs:element,
        $compDict?type?*    //xs:element,
        $compDict?group?*   //xs:element
    )
};   

(:~
 : Returns all attribute declarations, global and local.
 :)
declare function dict:compDict_getAllAtts($compDict as map(*))
        as element()* {
    (
        $compDict?attribute?*, 
        dict:compDict_getAllTypes($compDict)/self::xs:complexType//xs:attribute
    )
};   

(:~
 : Returns all element declarations referencing a global declaration
 : (@ref).
 :)
declare function dict:compDict_getElemsWithRef($compDict as map(*))
        as element()* {
    $compDict ! dict:compDict_getNonGlobalElems(.)[@ref]        
};        

(:~
 : Returns all element declarations with a local name matching a
 : name pattern.
 :)
declare function dict:compDict_getElemsMatchingName($namePattern as xs:string?,
                                                    $compDict as map(*))
        as element()* {
    let $nameFilter := $namePattern ! unamef:parseNameFilter(.)
    return    
        dict:compDict_getAllElems($compDict)
            [not($nameFilter) or
                (@name, @ref/replace(., '.+:', '')) ! unamef:matchesNameFilterObject(., $nameFilter)]        
};        

(:~
 : Returns all element declarations which are global.
 :)
declare function dict:compDict_getGlobalElems($compDict as map(*))
        as element()* {
    $compDict?element?*
};   

(:~
 : Returns all element declarations which are local.
 :)
declare function dict:compDict_getNonGlobalElems($compDict as map(*))
        as element()* {
    (
        $compDict?element?* //xs:element,
        $compDict?type?*    //xs:element,
        $compDict?group?*   //xs:element
    )
};   

(:~
 : Returns all group elements referencing a group definition.
 :)
declare function dict:compDict_getGroupRefs($compDict as map(*))
        as element()* {
    (
        $compDict?element?* //xs:group,
        $compDict?type?*    //xs:group,
        $compDict?group?*   //xs:group
    )
};   

(:~ 
 : Returns the type definition with a given qualified name.
 :)
declare function dict:compDict_getTypeDef($typeName as xs:QName, $compDict as map(*))
        as element()* {
    if (uns:isQNameBuiltin($typeName)) then () else        
    $compDict?type($typeName)        
};

declare function dict:compDict_getNormalizedTypeNames($compDict as map(*),
                                                      $nsmap as element(z:nsMap))
        as xs:QName* {
    $compDict?type?*/coto:getNormalizedComponentQName(., $nsmap)        
};        

(:~
 : Writes a dictionary mapping type names to its inheritance tree node. The tree
 : node can for example be used in order to determine all descendant types.
 :)
declare function dict:itree_inheritanceTreeNodeDict($itree as element())
         as map(*) {
    map:merge(
        $itree//(type, etype, rtype)/@name/
        map:entry(., ..))
};

declare function dict:compDict_inheritanceTree($compDict as map(*),
                                               $nsmap as element(z:nsMap))
        as item()* {
    let $types := $compDict?type?*
    let $baseDict := map:merge(
        for $type in $types
        let $base := $type/coto:getBaseAtt(.)
        let $baseNorm := string($base/coto:getNormalizedAttQName(., $nsmap))
        group by $baseNorm
        let $rtypes := $base/parent::xs:restriction/ancestor::*
                       [self::xs:complexType, self::xs:simpleType][1]
        let $etypes := $type except $rtypes
        let $ermap := map:merge((
            if (empty($rtypes)) then () else map:entry('restriction', 
                  $rtypes/coto:getNormalizedComponentQName(., $nsmap) ! string(.)),
            if (empty($etypes)) then () else map:entry('extension', 
                  $etypes/coto:getNormalizedComponentQName(., $nsmap) ! string(.))
        ))
        return map{$baseNorm: $ermap}
    )
    
    let $baseTypes1 := map:keys($baseDict)[string()]   
    let $baseTypes2 := $baseDict('')?extension
    let $baseTypes := ($baseTypes1, $baseTypes2)
    let $derivedTypes := $baseDict?*?*[not(. = $baseTypes2)] => distinct-values()
    let $rootTypes := $baseTypes[not(. = $derivedTypes)] => distinct-values() => sort((), string#1)
    return
        <inheritanceTree>{
            for $rootType in $rootTypes
            let $typeDef := $rootType ! uns:resolveNormalizedQName(., $nsmap) ! 
                            dict:compDict_getTypeDef(., $compDict)[1]
            let $myTree := dict:compDict_inheritanceTreeREC($rootType, $compDict, $baseDict, $nsmap)
            return <type name="{$rootType}">{$typeDef/@abstract[. eq 'true'], $myTree}</type>
        }</inheritanceTree>
};            


declare function dict:compDict_inheritanceTreeREC($name as xs:string,
                                                  $compDict as map(*),
                                                  $baseDict as map(*),
                                                  $nsmap as element(z:nsMap))
        as item()* {
    let $baseEntry := $baseDict($name)
    let $children := (
        for $child in $baseEntry?restriction 
        let $typeDef := 
            $child ! uns:resolveNormalizedQName(., $nsmap) ! 
                    dict:compDict_getTypeDef(., $compDict)[1]
        return
            <rtype name="{$child}">{
                $typeDef/@abstract[. eq 'true'],
                $child ! dict:compDict_inheritanceTreeREC(., $compDict, $baseDict, $nsmap)
            }</rtype>,
        for $child in $baseEntry?extension 
        let $typeDef := 
            $child ! uns:resolveNormalizedQName(., $nsmap) ! 
                    dict:compDict_getTypeDef(., $compDict)[1]        
        return
            <etype name="{$child}">{
                $typeDef/@abstract[. eq 'true'],
                $child ! dict:compDict_inheritanceTreeREC(., $compDict, $baseDict, $nsmap)
            }</etype>
    )
    for $child in $children
    order by $child/@name
    return $child
};        

(:~
 : Returns a dictionary returning for every element name the
 : substitution groups to which the element belongs.
 :)
declare function dict:getSgroupDict($compDict as map(*),
                                    $nsmap as element(z:nsMap))
        as item()* {
    let $sgTree := dict:compDict_sgroupTree($compDict, $nsmap)
    let $nameDict := map:merge(
        for $name in $sgTree//@name return
            map:entry($name, $name ! 
            uns:resolveNormalizedQName(., $nsmap)))
    return
        map:merge(
            for $elem in $sgTree/*//*
            let $name := $elem/@name ! $nameDict(.)
            let $groups := $elem/ancestor::*/@name ! $nameDict(.)
            return map:entry($name, $groups)
        )
};        

declare function dict:compDict_sgroupTree($compDict as map(*),
                                          $nsmap as element(z:nsMap))
        as element(sgroupTree) {
    let $elems := dict:compDict_getGlobalElems($compDict)[@substitutionGroup]
    (: Dictionary - sg-name -> member-names :)
    let $sgDict := map:merge(
        for $elem in $elems
        let $ename := $elem/coto:getNormalizedComponentQName(., $nsmap)
        let $sg := $elem/@substitutionGroup/coto:getNormalizedAttQName(., $nsmap)
        order by string($ename)
        group by $sg
        return map:entry($sg, $ename)
    )
    
    let $sgroups := map:keys($sgDict)   
    let $members := $sgDict?*
    let $roots := $sgroups[not(. = $members)]
    return
        <sgroupTree>{
            for $root in $roots
            let $myTree := dict:compDict_sgroupTreeREC($root, $sgDict)
            order by string($root)
            return <head name="{$root}">{$myTree}</head>
        }</sgroupTree>
};            

declare function dict:compDict_sgroupTreeREC($name as xs:QName,
                                             $sgDict as map(*))
        as item()* {
    let $sgEntry := $sgDict($name)
    let $children := (
        for $child in $sgEntry 
        let $childMembers := $child ! dict:compDict_sgroupTreeREC(., $sgDict)
        let $elemName := if (exists($childMembers)) then 'head' else 'memb'
        order by string($child)
        return        
            element {$elemName} {
                attribute name {$child},
                $childMembers
            }
    )
    return $children
};        

(:~
 : Returns the qualified names of types not used at att.
 :)
declare function dict:compDict_typesNotUsed($compDict as map(*))
        as xs:QName* {
    let $allElems := dict:compDict_getAllElems($compDict)
    let $allAtts := dict:compDict_getAllAtts($compDict)
    let $allTypes := dict:compDict_getAllTypes($compDict)
    let $allTypesGlobal := $compDict?type?*/coto:getComponentQName(.)

    let $elemTypeUses := $allElems/@type/resolve-QName(., ..)
    let $attTypeUses := $allAtts/@type/resolve-QName(., ..)
    let $baseUses := $allTypes/coto:getBaseAtt(.)/resolve-QName(., ..)
    let $itypeUses := $allTypes/xs:list/@itemType/resolve-QName(., ..)
    let $mtypeUses := 
        for $u in $allTypes/xs:union
        for $t in tokenize($u/@memberTypes) 
        return resolve-QName($t, $u)
    let $uses := ($elemTypeUses, $attTypeUses, $baseUses, $itypeUses, $mtypeUses) 
                  => distinct-values()
    return $allTypesGlobal[not(. = $uses)]                   
};    

(:~
 : Returns the qualified names of groups not used at att.
 :)
declare function dict:compDict_groupsNotUsed($compDict as map(*))
        as xs:QName* {
    let $allTypes := dict:compDict_getAllTypes($compDict)
    let $groupDefs := $compDict?group?*
    let $groupNames := $compDict?group?* ! coto:getComponentQName(.)
    let $groupRefs := ($allTypes, $groupDefs)//xs:group/@ref/resolve-QName(., ..)
    return $groupNames[not(. = $groupRefs)]    
                   
};    

(:~
 : Reports the relationship between between two types, one of:
 : child, descendant, parent, ancestore, same, other.
 : Returns '?' if not both types are found in the type inheritance
 : tree.
 :)
declare function dict:itree_typeRel($typeQN1 as xs:QName,
                                    $typeQN2 as xs:QName,
                                    $itree as element(),
                                    $nsmap as element(z:nsMap))
        as xs:string {
    let $type1 := $typeQN1 ! uns:normalizeQName(., $nsmap) ! xs:string(.)        
    let $type2 := $typeQN2 ! uns:normalizeQName(., $nsmap) ! xs:string(.)
    let $node1 := $itree//*[@name eq $type1]
    let $node2 := $itree//*[@name eq $type2]
    let $_DEBUG :=
        if (count($node1) gt 1) then error((), 'Multiple types for name: '||$typeQN1)
        else if (count($node2) gt 1) then error((), 'Multiple types for name: '||$typeQN2)
        else ()
    let $rel :=
        if (not($node1) or not($node2)) then '?'
        else if ($node1//* intersect $node2) then
            if ($node2/.. is $node1) then 'parent'
            else 'ancestor'
        else if ($node1/ancestor::* intersect $node2) then
            if ($node1/.. is $node2) then 'child'
            else 'descendant'
        else if ($node1 is $node2) then 'same'
        else 'other'
    return $rel        
};        


