module namespace tpher="http://www.parsqube.de/xspy/report/type-inheritance";
import module namespace const="http://www.parsqube.de/xspy/constants"
    at "constants.xqm";
import module namespace suto="http://www.parsqube.de/xspy/util/summary-tools"
    at "summary-tools.xqm";
import module namespace tysu="http://www.parsqube.de/xspy/report/type-summary"    
    at "../lib/type-summary.xqm";
import module namespace uns="http://www.parsqube.de/xspy/util/namespace"
    at "../lib/util-namespace.xqm";
    
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
declare namespace f="http://www.parsqube.de/xspy/functions";
declare namespace z="http://www.parsqube.de/xspy/structure";

(:~
 : Returns a type inheritance report.
 :
 : Options:
 : - base: name pattern selecting base types - consider only types with these ultimate base types
 : - tsummary: labels identifying info attributes
 :)
declare function tpher:getInheritanceReport($schemas as element(xs:schema)*,
                                            $ops as map(*))
        as element() {
    (: Get type summary report :)
    let $opsTSR := map{'tsummary': 'base'}
    let $typeInventory := tysu:typeSummaryReport($schemas, $opsTSR)

    let $tsummaryLabels := util:getTsummaryLabels($ops?tsummary, ())[not(. = 'base')]  
    let $_DEBUG := trace($tsummaryLabels, 'tsummaryLabels: ')
    let $baseFilter := $ops?base ! unamef:parseNameFilter(.)    
    let $nsmap := $typeInventory/z:nsMap
    let $compDict := dict:getCompDict($schemas, ())        
        
    let $baseTypesElems :=
        let $baseTypeNames := $typeInventory/types/type/@base/uns:resolveNormalizedQName(., $nsmap)    
        for $type in $typeInventory/types/type
        [not(@base) or namespace-uri-from-QName(@base/uns:resolveNormalizedQName(., $nsmap))
                       eq $const:URI_XSD]
        let $qname := $type/@name/uns:resolveNormalizedQName(., $nsmap)
        let $lname := local-name-from-QName($qname)        
        where $qname = $baseTypeNames
          
        where not($baseFilter) or $lname ! unamef:matchesNameFilterObject(., $baseFilter)             
        return $type  
        
    let $opsINH := map:merge((
        $ops ! map:put(., 'tsummary', $tsummaryLabels)
    ))
        
    let $_LOG := trace('Write '||count($baseTypesElems)||' type hierarchies ...')
    let $hierarchies :=
        for $baseTypeElem in $baseTypesElems
        let $qname := $baseTypeElem/@name/uns:resolveNormalizedQName(., $nsmap)
        order by local-name-from-QName($qname), namespace-uri-from-QName($qname)
        return
            $baseTypeElem/tpher:getInheritanceReportREC(., (), $compDict, $schemas, $opsINH)
            
    let $hierarchiesAug :=
        if (not($tsummaryLabels = 'use')) then $hierarchies else
        let $typeNames :=
            $hierarchies/descendant-or-self::*/@name/uns:resolveNormalizedQName(., $nsmap)
        let $_LOG := trace('Write type use dictionaries ...')
        let $typeUseCountsDict := dict:getTypeUseCountsDict($schemas)            
        let $typeUsingItemsDict := dict:getTypeUsedByItemDict($compDict, $typeNames, $nsmap)
        let $_LOG := trace('Add type atts ...')        
        let $aug := $hierarchies => 
            tpher:addTypeUseAtts($typeUseCountsDict, $typeUsingItemsDict, $nsmap)
        return $aug
        
    let $report :=
        <report type="inheritanceReport" xmlns:xs="http://www.w3.org/2001/XMLSchema">{
            attribute tsummary {$tsummaryLabels},
            $ops?base ! attribute base {.},
            tpher:getExplanation($ops),        
            $typeInventory/z:nsMap,
            <typeHierarchies count="{count($hierarchies)}">{
                $hierarchiesAug
            }</typeHierarchies>
        }</report>
    return
        if ($ops?typedef) then
            let $options := map:put($ops, 'nsmap', $nsmap)
            return $report ! tpher:getInheritanceRepTypeDefs(., $schemas, $options)
        else $report
};

declare function tpher:getInheritanceReportREC($type as element(type), 
                                               $re as xs:string?,
                                               $compDict as map(*),
                                               $schemas as element(xs:schema)*,
                                               $ops as map(*))
        as element() {
    let $tsummary := $ops?tsummary
    
    let $typeInventory := $type/ancestor::*[last()]        
    let $nsmap as element(z:nsMap) := $typeInventory/z:nsMap
    let $typeDef := $type/@name/uns:resolveNormalizedQName(., $nsmap) ! $compDict?type(.)
    let $qname := $type/@name/uns:resolveNormalizedQName(., $nsmap)
    let $derivedTypes := $typeInventory/types/type
        [@base/uns:resolveNormalizedQName(., $nsmap) = $qname]
    let $typeSummaryAtts :=
        suto:getTypeContentSummaryAtts2($typeDef, $compDict, $tsummary, $nsmap, ())
    let $base := $type/@base/uns:resolveNormalizedQName(., $nsmap)
    let $basePrim := $base[namespace-uri-from-QName(.) eq $uns:URI_XSD]
    let $content :=
        for $derivedType in $derivedTypes
        let $re := $derivedType/@ki/substring(., string-length(.), 1)
        return
            tpher:getInheritanceReportREC($derivedType, $re, $compDict, $schemas, $ops)
    let $elemName := $re||'type'   
    let $attNameER := 'co'
    return
        $type/element {$elemName} {
            attribute name {$qname},
            @abstract,            
            $basePrim ! attribute base {.},
            $typeSummaryAtts,
            @sgHeads[$tsummary = 'sg'],
            @sgMembers[$tsummary = 'sg'],
            @use[$tsummary = 'use'],            
            $content
        }
}; 

declare function tpher:getInheritanceRepTypeDefs($inheritanceReport as element(),
                                                 $schemas as element(xs:schema)*, 
                                                 $ops as map(*))
        as element() {
    let $nsmap := $inheritanceReport/z:nsMap        
    let $options := map:put($ops, 'nsmap', $nsmap) 
    return tpher:getInheritanceRepTypeDefsREC($inheritanceReport, $schemas, $options)            
};        

(:~
 : Adds to the report normalized type definitions.
 :)
declare function tpher:getInheritanceRepTypeDefsREC(
                                             $n as node(),
                                             $schemas as element(xs:schema)*, 
                                             $ops as map(*))
        as node()? {
    typeswitch($n)
    case document-node() return
        document {$n/node() ! tpher:getInheritanceRepTypeDefsREC(., $schemas, $ops)}
    case element() return
        let $typedef :=
            if (local-name($n) = ('type', 'etype', 'rtype')) then
                let $qname := uns:resolveNormalizedQName($n/@name, $ops?nsmap)
                return 
                    coto:getTypeDef($qname, $schemas) ! 
                    util:schemaCompNormalized(., $ops?nsmap)
            else ()
        return
        element {node-name($n)} {
            in-scope-prefixes($n) ! namespace {.} {namespace-uri-for-prefix(., $n)},
            $n/@* ! tpher:getInheritanceRepTypeDefsREC(., $schemas, $ops),
            $typedef,
            $n/node() ! tpher:getInheritanceRepTypeDefsREC(., $schemas, $ops)
        }
    default return $n        
};        

(:~
 : Adds to a preliminary hierarchy tree attributes describing
 : the use of the type by elements, attributes and other types.
 :)
declare function tpher:addTypeUseAtts($types as element()*,
                                      $typeUseCountsDict as map(*),
                                      $typeUsingItemsDict as map(*),
                                      $nsmap as element())  
        as element()* {
    let $ops := map{'typeUseCountsDict': $typeUseCountsDict,
                    'typeUsingItemsDict': $typeUsingItemsDict,
                    'nsmap': $nsmap}        
    for $type in $types return tpher:addTypeUseAttsREC($type, $ops)
};

(:~
 : Recursive helper function of `addTypeUseAtts`.
 :)
declare function tpher:addTypeUseAttsREC($n as node(),
                                         $ops as map(*))
        as node()* {                                         
    typeswitch($n)                                       
    case document-node() return 
        document {$n/node() ! tpher:addTypeUseAttsREC($n, $ops)}
    case element() return
        element {node-name($n)} {
            $n/@* ! tpher:addTypeUseAttsREC(., $ops),
            $n/@name/uns:resolveNormalizedQName(., $ops?nsmap) !
              suto:getTypeUseAtts(
                ., $ops?typeUseCountsDict, $ops?typeUsingItemsDict),
            $n/node() ! tpher:addTypeUseAttsREC(., $ops)
        }
    default return $n
};

declare function tpher:getExplanation($ops as map(*))
        as element(explanation) {
    <explanation>{
        <elem name="report" explain="Root element of the report"/>,
        <elem name="typeHierarchies" explain="Container element, containing the type hierarchies ('type' elements)"/>,        
        <elem name="type" explain="Represents a type which is not derived and serves as a base type"/>,        
        <elem name="etype" explain="Represents a type which is derived by extension from the parent element's type"/>,
        <elem name="rtype" explain="Represents a type which is derived by restriction from the parent element's type"/>,
        <elem name="z:ns" explain="A normalized namespace binding"/>,
        <elem name="z:nsMap" explain="Contains the normalized namespace bindings used in this report"/>,        
        <att name="@abstract" explain="The type definition is abstract"/>,
        <att name="@att" explain="Name of the only 'xs:attribute' declared by this type"/>,
        <att name="@attGroup" explain="Name of the only 'xs:attributeGroup' declared by this type"/>,        
        <att name="@bbase" explain="Built-in base type"/>,
        <att name="@co" explain="Summarizes the contents of the type">
          <details>
        Value items are separated by ~:
          (1) Complex content items
            att(i)        - i attribute declarations
            att(i,j,k)    - i attribute declarations, j attribute group declarations, k resolved attribute declarations
            
            seq(i)        - a sequence element containing i element declarations            
            seq(i,j,k)    - a sequence element containing i element declarations, j group references, k resolved element declarations            
            cho(i)        - a choice element containing i element declarations            
            cho(i,j,k)    - a choice element containing i element declarations, j group references, k resolved element declarations            
            all(i)        - an all element containing i element declarations            
            all(i,j,k)    - an all element containing i element declarations, j group references, k resolved element declarations
            
            grp-seq(i)    - a group element with a sequence child element containing i element declarations            
            grp-seq(i,j,k)- a group element with a sequence child element containing i element declarations, j group references, k resolved element declarations
            grp-cho(i)    - a group element with a choice child element containing i element declarations            
            grp-cho(i,j,k)- a group element with a choice child element containing i element declarations, j group references, k resolved element declarations
            grp-all(i)    - a group element with an all child element containing i element declarations
            grp-all(i,j,k)- a group element with an all child element containing i element declarations, j group references, k resolved element declarations
            
          (2) Simple content items             
            Items of restriction
              enumeration   - xs:enumeration
              pattern       - xs:pattern
              minLength     - xs:minLength
              maxLength     - xs:maxLength
              minInclusive  - xs:minInclusive
              maxInclusive  - xs:minInclusive
            list          - a list definition (xs:list)
            union         - a union definition (xs:union)
          </details>         
        </att>,          
        <att name="@elem" explain="Name of the only 'xs:element' declared by this type"/>,
        <att name="@elemChoice" explain="Names of the two elements between which the type defines a choice"/>,        
        <att name="@group" explain="Name of the only 'xs:group' referenced by this type"/>,
        <att name="@ki" explain="The kind of type">
          <details>
        Values:
          cc:  complex, not derived
          ce:  complex, empty          
          cce: complex, complex content, extension
          ccr: complex, complex content, restriction
          cse: complex, simple content, extension
          csr: complex, simple content, restriction
          sr: simple, restricted
          sl: simple, list
          su: simple: union
          </details>                                                                      
        </att>,                                   
        <att name="@name" explain="The name of a type, using a normalized prefix (see z:nsMap)"/>,                                   
        <att name="@prefix" explain="Prefix used in normalized QNames"/>,
        <att name="@sgHeads" 
             explain="The names of substitution groups with a head element using this type"/>,
        <att name="@sgMembers" explain="The names of substitution groups with a member using this type">
          <details>
        Value items are separated by ~:
          a name followed by (res) means that the type is used as restriction base
            of a local type definition
          a name followed by (ext) means that the type is used as extension base
            of a local type definition, and the extension is not empty
          a name followed by (ext0) means that the type is used as extension base
            of a local type definition, and the extension is empty
          </details>
        </att>,
        <att name="@uri" explain="A namespace URI associated with @prefix"/>,        
        <att name="@use" explain="How the type is used">
          <details>
        Value items are separated by ~:
          t#: number of @type attributes (e.g. t1, t3)
          r#: number of restriction base attributes of a global type (e.g. r1, r4)
          e#: number of extension base attributes of a global type (e.g. e1, e2)
          R#: number of restriction base attributes of a local type (e.g. r1, r4)
          E#: number of extension base attributes of a local type (e.g. e1, e2)
          l#: number of item type attributes of a list type (e.g. l1, l2)
          u#: number of member type attributes of a union type (e.g. u1, u2)            
        Example: t4~e1 - four @type attributes referencing this type; one local type extending this type.
        The special value --- means THE TYPE IS NOT USED AT ALL
          </details>
        </att>
    }</explanation>        
};

