module namespace coto="http://www.parsqube.de/xspy/util/component-tools";
import module namespace dict="http://www.parsqube.de/xspy/util/dictionaries"
    at "dictionaries.xqm";
import module namespace const="http://www.parsqube.de/xspy/constants"
    at "constants.xqm";
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

(:
 :
 :    R e p o r t s
 :
 :)
 
(:~
 : Returns a document containing normalized schema components.
 :)
declare function coto:getCompsDoc($schemas as element(xs:schema)*,
                                 $kind as xs:string?,
                                 $options as map(*))
        as element() {
    let $tsummaryLabels := util:getTsummaryLabels($options?tsummary)
    let $sgsummary := $options?sgsummary
    let $sgsummaryFilter := $sgsummary ! unamef:parseNameFilter(.)
    let $withSgHeads :=
        $sgsummaryFilter and $sgsummaryFilter/unamef:matchesNameFilterObject('heads', .)
    let $anno := $options?anno
    
    let $nameFilter := $options?name
    let $typeFilter := $options?type
    let $baseFilter := $options?base
    let $sgFilter := $options?sg
    
    let $nameFilterObject := $options?name ! unamef:parseNameFilter(.)
    let $typeFilterObject := $options?type ! unamef:parseNameFilter(.)
    let $typeFilterObject := $options?type ! unamef:parseNameFilter(.)
    let $baseFilterObject := $options?base ! unamef:parseNameFilter(.)   
    
    let $sgFilterObject := $sgFilter ! unamef:parseNameFilter(.)
    let $sgFilterHeads :=
        $sgFilterObject and $sgFilterObject/unamef:matchesNameFilterObject('heads', .)
    let $sgFilterMembers :=
        $sgFilterObject and $sgFilterObject/unamef:matchesNameFilterObject('members', .)
    
    let $kindNames :=
        let $kindsAll := 
          ('type', 'stype', 'ctype', 'cstype', 'cctype', 
           'element', 'attribute', 
           'agroup', 'group')
        let $kindN := $kind ! normalize-space(.)
        let $raw :=
            if (not($kindN)) then $kindsAll
            else
                let $filter := $kindN ! unamef:parseNameFilter(.)
                return $kindsAll[unamef:matchesNameFilterObject(., $filter)]
        let $filtered := $raw[not($typeFilterObject) or . = ('attribute', 'element')]                
                             [not($sgFilter) or . = ('element')]
        return $filtered
    let $nsmap := uns:getTnsPrefixMap($schemas, ())            
    let $fnCompName := function($comp) {$comp/QName(ancestor::xs:schema/@targetNamespace, @name)}
    let $compDict := dict:getCompDict($schemas, ())
    let $fileDict := dict:getFileDict($schemas, $options)
    let $fnrMap := $fileDict ! map:merge(file/map:entry(@uri, @file/string()))

    let $sgroupHeads := 
        $compDict?element?*/@substitutionGroup/(resolve-QName(., ..) ! uns:normalizeQName(., $nsmap))
        => distinct-values()
    let $optionsGNC := map:merge((
        map:put($options, 'compDict', $compDict) !
        map:put(., 'fnrMap', $fnrMap) !
        map:put(., 'tsummary', $tsummaryLabels) ! 
        map:put(., 'sgHeads', $sgroupHeads) !
        map:put(., 'anno', $anno) 
    ))
    
    let $comps :=
        for $comp in $schemas/*[@name]
        let $lname := local-name($comp)
        where not($nameFilter) or $comp/@name/unamef:matchesNameFilterObject(., $nameFilterObject)
        where $kind = ('comp') or
            $lname eq 'complexType' and (
            $kindNames = ('type', 'ctype') or
            $kindNames = ('cstype') and $comp/xs:simpleContent or
            $kindNames = ('cctype') and not($comp/xs:simpleContent))
        or $lname eq 'simpleType' and $kindNames = ('type', 'stype')
        or $lname eq 'element' and $kindNames = ('element')
        or $lname eq 'attribute' and $kindNames = ('attribute')
        or $lname eq 'group' and $kindNames = ('group')
        or $lname eq 'attributeGroup' and $kindNames = ('agroup')

        where not($sgFilterMembers) or $comp/@substitutionGroup

        let $tns := $comp/ancestor::xs:schema/@targetNamespace
        let $qname := $comp/QName($tns, @name)
        let $qnameNorm := $qname ! uns:normalizeQName(., $nsmap)                 

        let $type := $comp/@type
        where not($typeFilter) 
              or $type/replace(., '.+:', '') 
                 ! unamef:matchesNameFilterObject(., $typeFilterObject)            

        let $base := 
            $comp/(self::xs:complexType, self::xs:simpleType, xs:complexType, xs:simpleType[1])
            /coto:getBaseAtt(.)
        where not($baseFilter) 
              or $base/replace(., '.+:', '') 
                 ! unamef:matchesNameFilterObject(., $baseFilterObject)    
                 
        let $sgroup := $comp/@substitutionGroup/uns:normalizeAttValueQName(., $nsmap)
        let $sgHead := if (not($qnameNorm = $sgroupHeads)) then () else 'yes'
        where not($sgFilterHeads) or $sgHead
        let $kind := $lname
        group by $kind
        order by $kind
        return
            element {$kind||'s'} {
                attribute count {count($comp)},
                for $comp2 in $comp
                let $comp2Norm := coto:getNormalizedComp($comp2, $nsmap, $optionsGNC) 
                let $compQName := $comp2Norm/@name ! uns:resolveNormalizedQName(., $nsmap)
                let $lname := local-name-from-QName($compQName)
                let $prefix := prefix-from-QName($compQName)
                order by $lname, $prefix
                return $comp2Norm
            }
    let $fileDictFinal := $fileDict/dict:reduceFileDict(., $comps/*/@file)            
    return
        <componentsReport xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                          xmlns:z="http://www.parsqube.de/xspy/structure">{                
            $nsmap ! uns:namespaceMapToNodes(.), 
            <meta>{
                attribute kind {$kindNames},
                $nameFilter ! attribute nameFilter {.},
                $typeFilter ! attribute typeFilter {.},
                $baseFilter ! attribute baseFilter {.},
                $sgFilter ! attribute sgFilter {.},
                attribute tsummary {$tsummaryLabels}
            }</meta>,
            <components>{$comps}</components>,
            $fileDictFinal                
        }</componentsReport>
};        

(:
 :
 :    U t i l i t i e s
 :
 :)

(:~
 : Returns the "relu" value of a type definition, which is
 : one of the letters "r", "e", "l", "u" meaning "restriction",
 : "extension", "list", "union".
 :)
declare function coto:getTypeReluc($typeDef as element())
        as xs:string {
    let $contentElem := $typeDef/coto:getTypeContentElem(.)
    return
        if ($contentElem/self::xs:restriction) then 'r' 
        else if ($contentElem/self::xs:extension) then 'e'        
        else if ($contentElem/self::xs:complexType) then 'c'
        else if ($typeDef/xs:list) then 'l'
        else if ($typeDef/xs:union) then 'u'
        else '?'
};        

(: 
 : ***    T y p e    c o n t e n t    ***
 :)

(:~
 : Returns the element within the type definition containing the
 : content items. Content items are: model group, attributes,
 : facets.
 :
 : The element may be ...
 : - xs:restriction
 : - xs:extension
 : - xs:simpleType (root element of the type definition)
 : - xs:complexType (root element of the type definition)
 :)
declare function coto:getTypeContentElem($typeDef as element())
        as element() {
    let $ext := $typeDef/(xs:restriction, */(xs:extension, xs:restriction))
    return ($ext, $typeDef)[1]
        
}; 

(:~
 : Returns the type content as a tree of model group elements
 : (sequence, choice, all), element declarations and group 
 : references, recursively resolved.
 :)
declare function coto:getTypeItemTree($type as element(), 
                                      $compDict as map(*),
                                      $options as map(*)?)
        as element()* {
    let $contentElem := $type/coto:getTypeContentElem(.)        
    let $tree := $contentElem/coto:getModelItemTree(., $compDict, $options)
    return $tree
};

(:~
 : Returns the expanded representation of a group reference.
 :)
declare function coto:getExpandedGroupRef($groupRef as element(), 
                                          $compDict as map(*),
                                          $options as map(*)?)
        as element()* {
    let $qname := $groupRef/@ref/resolve-QName(., ..)
    let $groupDef := $compDict?group($qname)
    let $groupDefExp := $groupDef/coto:getExpandedGroup(., $compDict, $options)
    return
        element {node-name($groupRef)} {
            $groupRef/@ref,
            $groupDefExp/node()
        }
};

(:~
 : Returns the expanded representation of a group definition.
 :)
declare function coto:getExpandedGroup($groupDef as element(), 
                                       $compDict as map(*),
                                       $options as map(*)?)
        as element()* {
    let $content := $groupDef/coto:getModelItemTreeREC(., $compDict, $options)
    return $content
};

(:~
 : Returns the tree of model group elements (sequence, choice, all), 
 : element declarations and group references, recursively resolved.
 :)
declare function coto:getModelItemTree($model as element(), 
                                       $compDict as map(*),
                                       $options as map(*)?)
        as element()* {
    $model/coto:getModelItemTreeREC(., $compDict, $options)
};

(:~
 : Returns the tree of model group elements (sequence, choice, all), 
 : element declarations and group references, recursively resolved.
 :)
declare function coto:getModelItemTreeREC($n as node(), 
                                          $compDict as map(*),
                                          $options as map(*)?)
        as node()* {
    let $nsmap := $options?nsmap return
    
    typeswitch($n)
    case element(xs:annotation) return ()
    case element(xs:sequence) | element(xs:choice) | element(xs:all) return
        let $elemName :=
            if (not($nsmap)) then node-name($n) else 
                $n/node-name(.) ! uns:normalizeQName(., $nsmap)
        return
            element {$elemName} {
                $n/@* ! coto:getModelItemTreeREC(., $compDict, $options),
                $n/node() ! coto:getModelItemTreeREC(., $compDict, $options)
            }
    case element(xs:element) return
        let $elemName :=
            if (not($nsmap)) then node-name($n) else 
                $n/node-name(.) ! uns:normalizeQName(., $nsmap)
        return
            element {$elemName} {
                $n/@* ! coto:getModelItemTreeREC(., $compDict, $options),
                $n/node() ! coto:getModelItemTreeREC(., $compDict, $options)
            }
    case element(xs:group) return
        let $groupDef := 
            if ($n/@name) then $n 
        else
            let $qname := $n/@ref/resolve-QName(., ..)        
            return $compDict?group($qname)[1]
        let $elemName :=
            if (not($nsmap)) then node-name($n) else 
                $groupDef/node-name(.) ! uns:normalizeQName(., $nsmap)
        return
            element {$elemName} {
                $n/@* ! coto:getModelItemTreeREC(., $compDict, $options), 
                $groupDef/node() ! coto:getModelItemTreeREC(., $compDict, $options)
            }
    case element() return
        let $elemName :=
            if (not($nsmap)) then node-name($n) else 
                $n/node-name(.) ! uns:normalizeQName(., $nsmap)
        return
            element {$elemName} {
                $n/@* ! coto:writeNormalizedAtt(., $nsmap),
                $n/node() ! coto:getModelItemTreeREC(., $compDict, $options)
            }
    case attribute() return $n/coto:writeNormalizedAtt(., $nsmap) 
    case text() return
        if ($n/../* and $n/not(matches(., '\S'))) then () else $n    
        
    default return $n                
};

(:
declare function coto:getModelItemTreeREC2($elem as element(), 
                                          $compDict as map(*),
                                          $options as map(*)?)
        as element()* {
    let $nsmap := $options?nsmap        
    for $child in $elem/(* except xs:annotation)
    return
        typeswitch($child)
        case element(xs:sequence) | element(xs:choice) | element(xs:all) return
            let $elemName :=
                if (not($nsmap)) then node-name($child) else 
                    $child/node-name(.) ! uns:normalizeQName(., $nsmap)
            return
                element {$elemName} {
                    coto:getModelItemTreeREC($child, $compDict, $options)
                }
        case element(xs:element) return
            let $elemName :=
                if (not($nsmap)) then node-name($child) else 
                    $child/node-name(.) ! uns:normalizeQName(., $nsmap)
            return
                element {$elemName} {
                    $child/@*/coto:writeNormalizedAtt(., $nsmap)
            }
        case element(xs:group) return
            let $qname := $child/@ref/resolve-QName(., ..)
            let $groupDef := $compDict?group($qname)
            let $elemName :=
                if (not($nsmap)) then node-name($child) else 
                    $child/node-name(.) ! uns:normalizeQName(., $nsmap)
            let $refNorm := $child/@ref/coto:writeNormalizedAtt(., $nsmap)                    
            return
                element {$elemName} {
                    attribute ref {$refNorm},
                    $groupDef ! coto:getModelItemTreeREC(., $compDict, $options)
                }
        case element(xs:any) return
            let $elemName :=
                if (not($nsmap)) then node-name($child) else 
                    $child/node-name(.) ! uns:normalizeQName(., $nsmap)
            return
                element {$elemName} {
                    $child/@* ! coto:writeNormalizedAtt(., $nsmap)
                }
        default return error((), 'Unexpected elem name: '||$child/name())                
};
:)

(:~
 : Returns the <xs:element> and <xs:group> elements contained by
 : a type definition.
 :)
declare function coto:getTypeContentItems($type as element())
        as element()* {
    let $contentElem := $type/coto:getTypeContentElem(.)        
    return $contentElem/coto:getModelContentItems(.)
};

(:~
 : Returns the <xs:element> and <xs:group> elements contained by
 : a model group. A model group is a parent of <xs:sequence>,
 : <xs:choice>, <xs:all> or <xs:group>.
 :)
declare function coto:getModelContentItems($contentElem as element())
        as element()* {
    for $child in $contentElem/(* except xs:annotation)
    return
        if ($child/self::xs:sequence, $child/self::xs:choice, $child/self::xs:all) then
            $child/coto:getModelContentItems(.)
        else $child
};

(:~
 : Returns the element declarations representing the child elements
 : of a complex type definition.
 :)
declare function coto:getTypeChildElems($typeDef as element(),
                                        $compDict as map(*))
        as element()* {
    let $typeDefsAll := $typeDef   (: NOT_YET_IMPLEMENTED :)
                                   (: Get the sequence of ancestor type definitions :)
    let $lastRestriction := $typeDefsAll[xs:complexContent/xs:restriction][last()]
    let $typeDefs :=
        if (not($lastRestriction)) then $typeDefsAll else
        let $pos := 
            for $i in 1 to count($typeDefsAll) 
            where $typeDefsAll[$i] is $lastRestriction 
            return $i
        return $typeDefsAll[position() ge $pos]
        
    for $typeDef in $typeDefs
    let $contentElem := coto:getTypeContentElem($typeDef)
    let $elems := coto:getDeepContentElemItems($contentElem, $compDict)
    return $elems
};

(:~
 : Returns the <xs:attribute> elements contained by a type directly
 : or indirectly via recursively resolved attribute group references. 
 : 
 : Note: cyclic references are recognized.
 :)
declare function coto:getDeepContentAtts($contentElem as element(),
                                         $compDict as map(*))
        as element()* {
    $contentElem/xs:attribute,        
    $contentElem/xs:attributeGroup/coto:getAttributeGroupDeepContent(., $compDict)
};

(:~
 : Returns the built-in base type of a type.
 :)
declare function coto:getBuiltinBaseQName($typeDef as element(), 
                                         $compDict as map(*))
        as xs:QName? {
    let $baseQName := $typeDef/coto:getBaseAtt(.)/resolve-QName(., ..)
    where exists($baseQName)
    let $ns := namespace-uri-from-QName($baseQName)
    return
        if ($ns eq $const:URI_XSD) then 
            QName($const:URI_XSD, 'xs:'||local-name-from-QName($baseQName))
        else 
            $compDict?type($baseQName) ! coto:getBuiltinBaseQName(., $compDict)
};       

(:~
 : Returns the <xs:element> elements contained by a model group directly
 : or indirectly via recursively resolved group references. 
 : 
 : Note: cyclic references are recognized.
 :)
declare function coto:getDeepContentElemItems($contentElem as element(),
                                              $compDict as map(*))
        as element()* {
    $contentElem/coto:getDeepContentElemItemsREC(., (), $compDict)
};

(:~
 : Recursive helper function of `coto:getDeepContentElemItems`.
 :)
declare function coto:getDeepContentElemItemsREC($contentElem as element(),
                                                $groupQNamesSofar as xs:QName*,
                                                $compDict as map(*))
        as element()* {
    for $child in $contentElem/(* except xs:annotation) return
    typeswitch($child)
        case element(xs:sequence) | element(xs:choice) | element(xs:all) return
            $child/coto:getDeepContentElemItemsREC(., $groupQNamesSofar, $compDict)
        case element(xs:group) return
            let $ref := $child/@ref/resolve-QName(., ..)
            return if ($ref = $groupQNamesSofar) then () else
            let $groupDef := $compDict?group($ref)
            return $groupDef/coto:getDeepContentElemItemsREC(
                ., ($groupQNamesSofar, $ref), $compDict)
        case element(xs:attribute) | element(xs:attributeGroup) return ()                
        default return $child
};

(:~
 : Returns the type definitions for given item declarations.
 :)
declare function coto:getItemTypeDefs($items as element()*, 
                                      $compDict as map(*))
        as element()* {
    let $items := (
        $items[@name],
        for $ref in $items[@ref]/coto:getComponentQName(.)
        return $compDict('element')($ref)[@name]
    )
    let $typeNames := $items/@type/resolve-QName(., ..)
    let $globalTypeDefs := $typeNames ! $compDict?type(.)
    let $localTypeDefs := $items/(xs:complexType, xs:simpleType)
    let $typeDefs := ($globalTypeDefs, $localTypeDefs)
    return $typeDefs
};   

declare function coto:getElemDeclsForElemName($elemName as xs:QName,
                                              $typeDef as element(),
                                              $nsmap as element(z:nsMap),
                                              $compDict as map(*),
                                              $options as map(*))
        as element()* {
    let $elems := coto:getTypeChildElems($typeDef, $compDict)
    return $elems[coto:getComponentQName(.) eq $elemName]
};     


(: 
 : ***    G r o u p   p r o c e s s i n g    ***
 :)
 
(: 
 : ***    A t t r i b u t e    g r o u p   p r o c e s s i n g    ***
 :)
 
 (:~
 : Returns the attribute declarations directly or indirectly contained by an 
 : attribute group.
 :)
declare function coto:getAttributeGroupDeepContent(
                                      $agroup as element(xs:attributeGroup),
                                      $compDict as map(*))
        as element()* {
    $agroup/coto:getAttributeGroupDeepContentREC(., (), $compDict)
};

(:~
 : Recursive helper function of `coto:getDeepContentAtts`.
 :)
declare function coto:getAttributeGroupDeepContentREC(
                                      $agroup as element(xs:attributeGroup),
                                      $groupQNamesSofar as xs:QName*,
                                      $compDict as map(*))
        as element()* {
    let $agroupDef :=
        if ($agroup/@name) then $agroup else

        let $ref := $agroup/@ref/resolve-QName(., ..)
        return 
            if ($ref = $groupQNamesSofar) then () 
            else $compDict?agroup($ref)
    where $agroupDef
    let $refResolved := $agroup/@ref/resolve-QName(., ..)
    let $groupQNamesSofarNew := ($groupQNamesSofar, $refResolved)   
    
    for $child in $agroupDef/(* except xs:annotation) return
    typeswitch($child)
        case element(xs:attribute) return $child
        case element(xs:attributeGroup) return
            coto:getAttributeGroupDeepContentREC(
                $child, $groupQNamesSofarNew, $compDict)
        default return ()
};        

(: 
 : ***    R e t r i e v a l    ***
 :) 

(:~
 : Returns the element declarations contained in the
 : component dict. Dependent of $global, only the
 : global element declarations or all element
 : declarations are returned.
 :
 : @param compDict component dictionary
 : @param global if true, only global elements are returned
 : @return element declarations
 :)
declare function coto:elems($compDict as map(*), 
    $global as xs:boolean?)
        as element()* {
    let $elemsGlobal := $compDict?element?*        
    return
        if ($global) then $elemsGlobal else (
            $elemsGlobal,
            $compDict?*?*//xs:element)
};

(:~
 : Returns the element declarations contained in the
 : component dict. Dependent of $global, only the
 : global element declarations or all element
 : declarations are returned.
 :
 : @param compDict component dictionary
 : @param global if true, only global elements are returned
 : @return element declarations
 :)
declare function coto:elemsForName($name as xs:QName,
                                   $compDict as map(*),                                   
                                   $global as xs:boolean?)
        as element()* {            
    coto:elems($compDict, $global)
        [coto:getComponentQName(.) eq $name]
};

(:~
 : Returns a type definition.
 :)
declare function coto:getTypeDef($qname as xs:QName, 
                                 $schemas as element(xs:schema)*)
        as element()? {
    let $tns := namespace-uri-from-QName($qname)
    let $lname := local-name-from-QName($qname)
    let $schemasSel := $schemas[string(@targetNamespace) eq $tns]
    return $schemasSel/(xs:simpleType, xs:complexType)[@name eq $lname][1]
};

(:~
 : Returns the @base attribute of a type definition.
 :)
declare function coto:getBaseAtt($typeDef as element())
        as attribute(base)? {
    $typeDef/coto:getTypeContentElem(.)/@base
};       

(:~
 : Returns the qualified name of the base type of a type definition.
 :)
declare function coto:getBaseQName($typeDef as element())
        as xs:QName? {
    $typeDef/coto:getTypeContentElem(.)/@base/resolve-QName(., ..)
};       

(:~
 : Returns the normalized qualified name of the base type of a type definition.
 :)
declare function coto:getBaseQNameNormalized($typeDef as element(), 
                                             $nsmap as element(z:nsMap))
        as xs:QName? {
    $typeDef ! coto:getBaseQName(.) ! uns:normalizeQName(., $nsmap)
};       

(:~
 : Returns the @type attribute or the @base attribute of the 
 : local type definition of an element. The @type attribute
 : or the local type definition may be contained by the element 
 : declaration itself, or by the element declaration referenced 
 : from the given element declaration via @ref.
 :)
declare function coto:getElemTypeOrBaseAtt($elemDecl as element(),
                                           $compDict as map(*))
        as attribute()? {
    let $elemDeclEff := coto:getElemDecl($elemDecl, $compDict) 
    let $localType := $elemDeclEff/(xs:simpleType, xs:complexType)
    return
        if ($localType) then $localType/coto:getBaseAtt(.)
        else $elemDeclEff/@type
};       

(:~
 : Returns the @type attribute or the @base attribute of the 
 : local type definition of an element. The @type attribute
 : or the local type definition may be contained by the element 
 : declaration itself, or by the element declaration referenced 
 : from the given element declaration via @ref.
 :)
declare function coto:getElemTypeOrBaseAttNormalized(
                                           $elemDecl as element(),
                                           $compDict as map(*),
                                           $nsmap as element(z:nsMap))
        as xs:QName? {
    coto:getElemTypeOrBaseAtt($elemDecl, $compDict)
    ! coto:getNormalizedAttQName(., $nsmap)
};       


(:~
 : Returns the @base attribute of the local type definition
 : of an element. The local type definition may be contained
 : by the element declaration itself, or by the element
 : declaration referenced from the given element declaration
 : via @ref.
 :)
declare function coto:getElemBaseAtt($elemDecl as element(),
                                     $compDict as map(*))
        as attribute(base)? {
    let $elemDeclEff := coto:getElemDecl($elemDecl, $compDict)        
    return
        $elemDeclEff/(xs:simpleType, xs:complexType)/coto:getBaseAtt(.)
};       

(:~
 : Returns the @type attribute of an element declaration or
 : the element declaration which it references.
 :)
declare function coto:getTypeAtt($typeDef as element(),
                                 $compDict as map(*))
        as attribute(type)? {
    $typeDef/coto:getElemDecl(., $compDict)/@type
};       

(:~
 : Returns the element declaration referenced by an element
 : declaration, if it has a @ref attribute, or the element
 : declaration itself, otherwise.
 :)
declare function coto:getElemDecl($elemDecl as element(),
                                  $compDict as map(*))
        as element(xs:element) {
    if ($elemDecl/@ref) then
        let $qname := $elemDecl/@ref/resolve-QName(., ..)
        let $lname := local-name-from-QName($qname)
        let $namespace := namespace-uri-from-QName($qname)
        let $elemDeclEff :=
            $compDict?element?*[@name eq $lname]
                [if (not($namespace)) then not(../@targetNamespace)
                 else $namespace eq ../@targetNamespace]
            [1]
        return $elemDeclEff
    else $elemDecl
};       

(:~
 : Returns the element declaration referenced by an element
 : declaration, if it has a @ref attribute, or the element
 : declaration itself, otherwise.
 :)
declare function coto:getElemDeclSCH($elemDecl as element(),
                                     $schemas as element(xs:schema)*)
        as element(xs:element) {
    if ($elemDecl/@ref) then
        let $qname := $elemDecl/@ref/resolve-QName(., ..)
        let $lname := local-name-from-QName($qname)
        let $namespace := namespace-uri-from-QName($qname)
        let $elemDeclEff := (
            $schemas[if (not($namespace)) then not(@targetNamespace)
                     else $namespace eq @targetNamespace]/
            xs:element[@name eq $lname]
            )[1]
        return $elemDeclEff
    else $elemDecl
};       

(: 
 : ***    N a m e s    ***
 :)

(:~
 : Returns the QName of a schema component. Both attributes,
 : @name and @ref are evaluated.
 :) 
declare function coto:getComponentQName($comp as element())
        as xs:QName? {
    let $name := $comp/(@name, @ref)
    return $name/QName(string(ancestor::xs:schema/@targetNamespace), .)         
};

(:~
 : Returns the normalized QName of a schema component.
 :) 
declare function coto:getNormalizedComponentQName($comp as element(), 
                                                  $nsmap as element(z:nsMap))
        as xs:QName {
    if ($comp/self::xs:any) then QName('http://www.w3.org/2001/XMLSchema', 'any') else        
    if ($comp/self::xs:anyAttribute) then QName('http://www.w3.org/2001/XMLSchema', 'anyAttribute')
    else if ($comp/self::_cycle_) then QName($const:URI_XSPY, 'z:_cycle_')
    else if (not($comp/(@name, @ref))) then (trace($comp, '_INVALID_CALL_NO_NAME_OR_REF: '), error())
    else $comp/coto:getComponentQName(.) ! uns:normalizeQName(., $nsmap)         
};

(:~
 : Returns the normalized QName contained by an attribute (e.g. @base).
 :) 
declare function coto:getNormalizedAttQName($att as attribute(), 
                                            $nsmap as element(z:nsMap))
        as xs:QName {
    $att/resolve-QName(., ..) ! uns:normalizeQName(., $nsmap)         
};

(:~ 
 : Returns a "component path" identifying the location of a schema
 : component within the schema.
 :
 : @param comp a component element
 : @param nsmap a map of namespace bindings
 : @return the path
 :) 
declare function coto:componentPath($comp as element(), 
                                    $nsmap as element(z:nsMap))
        as xs:string {
    if ($comp/parent::xs:schema) then
        local-name($comp)||'('||($comp/uns:normalizeCompName(., $nsmap))||')'
    else
        let $ancestors := $comp/ancestor-or-self::*[local-name(.) = 
            ('simpleType', 'complexType', 'element', 'attribute', 'group', 'keyref', 'key')]
        return (
            $ancestors/(local-name(.)||'('||(
                if (@name) then uns:normalizeCompName(., $nsmap)
                else @ref ! uns:normalizeAttValueQName(., $nsmap)
            )||')')) => string-join('/')
};

declare function coto:componentContext($comp as element(), 
                                       $nsmap as element(z:nsMap))
        as xs:string {
    if ($comp/parent::xs:schema) then 'schema'
    else
        let $ancestors := $comp/ancestor::*[local-name(.) = 
            ('simpleType', 'complexType', 'element', 'attribute', 'group', 'keyref', 'key')]
        return (
            $ancestors/(local-name(.)||'('||(
                if (@name) then uns:normalizeCompName(., $nsmap)
                else @ref ! uns:normalizeAttValueQName(., $nsmap)
            )||')')) => string-join('/')
};        

(: 
 : ***    N o r m a l i z e d    c o m p     ***
 :)

(:~
 : Maps a schema component to a normalized representation.
 : Features:
 : - @name - value is mapped to a lexcical QName with a normalized prefix
 : - @type, @ref, @base, @list - value is mapped to a lexcical QName with a normalized prefix
 :)
declare function coto:getNormalizedComp($comp as element(),
                                       $nsmap as element(z:nsMap),
                                       $options as map(*))
        as element() {
    let $normalized := coto:getNormalizedCompREC($comp, $nsmap, $options)        
    return
        $normalized/element {node-name(.)} {
            uns:namespaceMapToNodes($nsmap),
            @*, node()            
        }
};

(:~
 : Recursive helper functionof `getNormalizedComp`.
 :)
declare function coto:getNormalizedCompREC($n as node(),
                                          $nsmap as element(z:nsMap),
                                          $options as map(*))
        as node()* {
    typeswitch($n)
    case document-node() return $n/node() ! 
        coto:getNormalizedCompREC(., $nsmap, $options)
    case element(xs:annotation) return
        if (not($options?anno)) then () else
            let $qname := node-name($n) ! uns:normalizeQName(., $nsmap)
            return
                element {$qname} {
                    $n/@* ! coto:getNormalizedCompREC(., $nsmap, $options),
                    $n/node() ! coto:getNormalizedCompREC(., $nsmap, $options)
                }        
    case element() return
        let $tsummary := $options?tsummary
        let $additionalAtts := (
            (: if option 'skipLocalType': @z:type, @z:baseType :)
            if (not($options?skipLocalType)) then () 
            else (
                let $ltype := 
                    $n/(self::xs:element, self::xs:attribute)
                      /(xs:simpleType, xs:complexType)
                return if (not($ltype)) then () else (
                    attribute z:type {'#local'},
                    $ltype/coto:getBaseAtt(.) 
                    ! uns:normalizeAttValueQName(., $nsmap)
                    ! attribute z:baseType {.}
                    )
            ),
            let $compDict := $options?compDict
            return if (empty($compDict)) then 
                error((), 'INVALID_ARG', 'mode "tsummary" requires compDict')
                else
            if ($n/self::element(xs:complexType) or $n/self::element(xs:simpleType)
                or $n/self::xs:element/(xs:complexType, xs:simpleType) 
                or $n/self::xs:attribute/xs:simpleType)
            then
                let $typeDef := 
                    ($n/self::xs:simpleType,
                     $n/self::xs:complexType,
                     $n/xs:simpleType,
                     $n/xs:complexType)[1]
                return
                    suto:getTypeContentSummaryAtts2($typeDef, 
                        $compDict, $tsummary, $nsmap, map{'anamePrefix': 'z'})
            (: element: @z:isSgHead :)                        
            else if ($n/self::element(xs:element)) then (
                if (not($tsummary = 'sg')) then () else
                let $isSgHead := $n/coto:getComponentQName(.) = $options?sgHeads
                return $isSgHead[.] ! attribute z:isSgHead {'yes'}
            ) else (),
            (: file :)
            let $file := 
                if (empty($options?fnrMap) or not($n/parent::xs:schema)) then () 
                else $n/base-uri(.) ! $options?fnrMap(.)
            return $file ! attribute file {.}
        )
        let $qname := node-name($n) ! uns:normalizeQName(., $nsmap)
        return
            element {$qname} {
                $n/@* ! coto:getNormalizedCompREC(., $nsmap, $options),
                $additionalAtts,
                
                if ($options?skipLocalType and 
                    $n/(self::xs:attribute, self::xs:element))
                then ()
                else $n/node() ! coto:getNormalizedCompREC(., $nsmap, $options)
            }
    case attribute() return $n/coto:writeNormalizedAtt(., $nsmap)
    case text() return
        if (not(matches($n, '\S')) and $n/../*) then () 
        else $n
    default return $n
};

(:~
 : Writes a normalized attribute. If no namespace map is,
 : supplied, the attribute is simply copied.
 :)
declare function coto:writeNormalizedAtt($srcAtt as attribute(), 
                                         $nsmap as element(z:nsMap)?)
        as attribute() {
    if (not($nsmap)) then $srcAtt else
    typeswitch($srcAtt)
    case attribute(type) | attribute(ref) | attribute(base) | attribute(refer) |
         attribute(list) | attribute(itemType) | attribute(substitutionGroup) return
        let $qname := $srcAtt ! resolve-QName(., ..) ! uns:normalizeQName(., $nsmap)
        return attribute {node-name($srcAtt)} {$qname}
    case attribute(xpath) return
        let $as := $srcAtt/analyze-string(., '(\i\c*?:)?\i\c*', 's')
        let $value :=
            string-join(
                for $child in $as/* return typeswitch($child)
                case element(fn:match) return
                    $child ! resolve-QName(., $srcAtt/..) ! uns:normalizeQName(., $nsmap)
                default return $child
            , '')
        return attribute {node-name($srcAtt)} {$value}            
    case attribute(memberTypes) return 
        let $mtypes := $srcAtt ! tokenize(.) ! resolve-QName(., $srcAtt/..) ! uns:normalizeQName(., $nsmap)
        return attribute {node-name($srcAtt)} {$mtypes}
    case attribute(name) return
        if (contains($srcAtt, ':')) then $srcAtt
        else if ($srcAtt/parent::xs:attribute and not(
            $srcAtt/ancestor::*[@attributeFormDefault][1]/@attributeFormDefault 
                eq 'qualified'))
            then $srcAtt
        else
        
        let $tns := $srcAtt/ancestor::xs:schema/@targetNamespace
        let $qname := QName($tns, $srcAtt) ! uns:normalizeQName(., $nsmap) 
        return attribute name {$qname}
    default return $srcAtt    
};        




