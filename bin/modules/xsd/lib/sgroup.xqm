module namespace sg="http://www.parsqube.de/xspy/report/sgroup";
import module namespace suto="http://www.parsqube.de/xspy/util/summary-tools"
    at "summary-tools.xqm";
import module namespace tysu="http://www.parsqube.de/xspy/report/type-summary"    
    at "../lib/type-summary.xqm";
import module namespace elsu="http://www.parsqube.de/xspy/report/element-summary"    
    at "../lib/elem-summary.xqm";    
import module namespace dict="http://www.parsqube.de/xspy/util/dictionaries"
    at "dictionaries.xqm";
import module namespace coto="http://www.parsqube.de/xspy/util/component-tools"    
    at "component-tools.xqm";
import module namespace uns="http://www.parsqube.de/xspy/util/namespace"
    at "../lib/util-namespace.xqm";
    
import module namespace ufpath="http://www.parsqube.de/xquery/util/file-path"
    at "../util/util-filePath.xqm";
import module namespace unamef="http://www.parsqube.de/xquery/util/name-filter"
    at "../util/util-nameFilter.xqm";
import module namespace util="http://www.parsqube.de/xspy/util"
    at "util.xqm";
    
declare namespace f="http://www.parsqube.de/xspy/functions";
declare namespace z="http://www.parsqube.de/xspy/structure";

declare function sg:getSgroupReport($schemas as element()*, 
                                    $ops as map(*))
        as element() {
    let $tsummaryLabels := util:getTsummaryLabels($ops?tsummary)
    let $nameFilter := $ops?name ! unamef:parseNameFilter(.)
    
    let $elemInventory := ($ops?elementInventory,  
                           elsu:elemSummaryReport($schemas, ()))[1]
    let $typeInventory := ($ops?typeInventory,  
                           tysu:typeSummaryReport($schemas, ()))[1]
    let $compDict := ($ops?compDict,
                      dict:getCompDict($schemas, ()))[1]
    let $sgHeads := $elemInventory/elems/elem[@isSgroupHead eq 'yes']
                    [not($nameFilter) or replace(@name, '.*:', '') !  
                         unamef:matchesNameFilterObject(., $nameFilter)]
    let $optionsGSD := map:merge((
        map:put($ops, 'compDict', $compDict) !
        map:put(., 'tsummary', $tsummaryLabels)
    ))
                
    let $sgInfos := 
        $sgHeads/sg:getSgroupDesc(., $elemInventory, $typeInventory, $schemas, $optionsGSD)
    let $report :=
        <report type="sgroupReport" xmlns:xs="http://www.w3.org/2001/XMLSchema">{
            attribute tsummary {$tsummaryLabels},
            sg:getExplanation($ops),        
            $typeInventory/z:nsMap,    
            <sgroups count="{count($sgInfos)}">{
                $sgInfos
            }</sgroups>
        }</report>
    let $report2 := sg:finalizeSgroupReport(
        $report, $elemInventory, $typeInventory, $compDict, $schemas)        
    return $report2        
};

declare function sg:getSgroupDesc($sgHead as element(elem),
                                  $elemInventory as element(),
                                  $typeInventory as element(),
                                  $schemas as element(xs:schema)*,
                                  $ops as map(*))
        as element() {
    let $tsummary := $ops?tsummary   
    let $name := $sgHead/@name  
    let $type := $sgHead/@type
    let $typeDesc := $typeInventory//types/type[@name eq $type]
    let $ki := $typeDesc/@ki
    let $base := $typeDesc/@base    
    let $bbase := $typeDesc/@bbase    
    let $co := $typeDesc/@co
    let $coDetails := $typeDesc[$tsummary = 'detail']/
                      (@elem, @elemChoice, @att, @group, @attGroup)
    let $members := $elemInventory/elems/elem[@sgroup eq $name]    
    return
        <head name="{$name}">{
            $sgHead/@type,
            $base[$tsummary = 'base'],
            $bbase[$tsummary = 'bbase'],
            $ki[$tsummary = 'ki'],
            $co[$tsummary = 'co'],
            $coDetails,
            $sgHead/@abstract,
            $sgHead/@fileNr[$ops?fileNr],
            
            for $member in $members
            return
                if (not($member/@isSgroupHead eq 'yes')) then
                    let $name := $member/@name
                    let $infoSource := 
                        if ($member/@type ne '#local') then $typeInventory//types/type[@name eq $member/@type]
                        else $member
                    let $base := ($infoSource/@base, $member/@base)[1]
                    let $bbase := ($infoSource/@bbase, $member/@bbase)[1]                    
                    let $ki := ($infoSource/@ki, $member/@ki)[1]
                    let $co := $infoSource/@co
                    let $coDetails := $infoSource[$tsummary = 'detail']/
                                      (@elem, @elemChoice, @att, @group, @attGroup)
                    let $atts := $member ! 
                        (@name, @type, 
                        $base[$tsummary = 'base'],
                        $bbase[$tsummary = 'bbase'],
                        $ki[$tsummary = 'ki'], 
                        $co[$tsummary = 'co'], 
                        $coDetails,
                        (@* except (@name, @type, @ki, @co, @base, @bbase, @sgroup, @fileNr, 
                                    @elem, @elemChoice, @att, @group, @attGroup)),
                        @fileNr[$ops?fileNr])
                    return                
                        $member/<memb>{$atts}</memb>
                else $member/sg:getSgroupDesc(
                    ., $elemInventory, $typeInventory, $schemas, $ops)
        }</head>
};        

declare function sg:finalizeSgroupReport($report as element(),
                                         $elemInventory as element(),
                                         $typeInventory as element(),
                                         $compDict as map(*),
                                         $schemas as element(xs:schema)*)
        as element() {
    $report ! sg:finalizeSgroupReportREC(
        ., $elemInventory, $typeInventory, $compDict, $schemas)        
};        

declare function sg:finalizeSgroupReportREC($n as node(),
                                            $elemInventory as element(),
                                            $typeInventory as element(),
                                            $compDict as map(*),
                                            $schemas as element(xs:schema)*)
        as node()* {
    typeswitch($n)
    case document-node() return 
        document {$n ! node() 
            ! sg:finalizeSgroupReportREC(
                ., $elemInventory, $typeInventory, $compDict, $schemas)}
    case element() return 
        element {node-name($n)} {
            $n/@* ! sg:finalizeSgroupReportREC(
                ., $elemInventory, $typeInventory, $compDict, $schemas),
            $n/node() ! sg:finalizeSgroupReportREC(
                ., $elemInventory, $typeInventory, $compDict, $schemas)
        }
    case attribute(base) | attribute(localBase) | attribute(type) return
        let $value := 
            if ($n eq $n/../parent::head/@type) then '#head.type'
            else if ($n eq $n/../parent::head/@base) then '#head.base'
            else $n
        return attribute {node-name($n)} {$value}
    default return $n            
};        

declare function sg:getExplanation($ops as map(*))
        as element(explanation) {
    <explanation>{
        <elem name="report" explain="Root element of the report"/>,
        <elem name="sgroups" explain="Container element, containing the substitution groups ('head' elements)"/>,        
        <elem name="head" explain="Represents an element used as a substitution group head"/>,        
        <elem name="memb" explain="Represents an element belonging to a substitution group"/>,        
        <elem name="z:ns" explain="A normalized namespace binding"/>,
        <elem name="z:nsMap" explain="Contains the normalized namespace bindings used in this report"/>,        
        <att name="@abstract" explain="The type definition is abstract"/>,
        <att name="@att" explain="Name of the only 'xs:attribute' declared by this type"/>,
        <att name="@attGroup" explain="Name of the only 'xs:attributeGroup' declared by this type"/>,        
        <att name="@base" explain="Base type">
          <details>
        Values:
          #local:     local type definition contained by the element declaration
          #head.type: the same type as the type of the head element of the containing substitution group
          ...:        type name, using a normalized namespace prefix
          </details>
        </att>,
        <att name="@co" explain="Summarizes the contents of the type">
          <details>
        Value items are separated by ~:
          (1) Complex content items
            att(i)        - i attribute declarations
            att(i,j,k)    - i attribute declarations, j attribute group declarations, k resolved attribute declarations
            
            grp-seq(i)    - a group element with a sequence child element containing i element declarations            
            grp-seq(i,j,k)- a group element with a sequence child element containing i element declarations, j group references, k resolved element declarations
            grp-cho(i)    - a group element with a choice child element containing i element declarations            
            grp-cho(i,j,k)- a group element with a choice child element containing i element declarations, j group references, k resolved element declarations
            grp-all(i)    - a group element with an all child element containing i element declarations
            grp-all(i,j,k)- a group element with an all child element containing i element declarations, j group references, k resolved element declarations
            
            seq(i)        - a sequence element containing i element declarations            
            seq(i,j,k)    - a sequence element containing i element declarations, j group references, k resolved element declarations            
            cho(i)        - a choice element containing i element declarations            
            cho(i,j,k)    - a choice element containing i element declarations, j group references, k resolved element declarations            
            all(i)        - an all element containing i element declarations            
            all(i,j,k)    - an all element containing i element declarations, j group references, k resolved element declarations
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
          c:  complex, not derived
          cc: complex, complex content
          cs: complex, simple content
          sr: simple, restricted
          sl: simple, list
          su: simple: union
          </details>                                                                      
        </att>,                                   
        <att name="@name" explain="The name of an element, using a normalized prefix (see z:nsMap)"/>,                                   
        <att name="@prefix" explain="Prefix used in normalized QNames"/>,
        <att name="@re" explain="If restriction, extension, or something else">
          <details>
        Values:
          c: complex type, not derived by extension or restriction
          e: extension
          r: restriction
          l: list definition
          u: union definition
          </details>
        </att>,        
        <att name="@type" explain="The type name">
          <details>
        Values:
          #local:     local type definition contained by the element declaration
          #head.type: the same type as the type of the head element of the containing substitution group
          ...:        type name, using a normalized namespace prefix
          </details>
        </att>,
        <att name="@uri" explain="A namespace URI associated with @prefix"/>        
    }</explanation>        
};


                                    
