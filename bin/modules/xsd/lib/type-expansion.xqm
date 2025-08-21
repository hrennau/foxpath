(:
 : Functions creating a type inventory
 :)
module namespace tyex="http://www.parsqube.de/xspy/report/type-expansion";
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

(: 
 : ***    R e p o r t s    ***
 :) 

(:~
 : Creates a type expansion report.
 :)
declare function tyex:typeExpansionReport($schemas as element(xs:schema)*,
                                          $ops as map(*)?)
        as element() {
    let $filenr := $ops?filenr
    let $tsummary := $ops?tsummary
    let $tsummaryLabels := util:getTsummaryLabels($ops?tsummary)
    
    let $scope := ($ops?scope, 'global')[1]        
    let $nameFilter := $ops?name ! unamef:parseNameFilter(.)        
    let $baseFilter := $ops?base ! unamef:parseNameFilter(.)
    let $kiFilter := $ops?ki ! unamef:parseNameFilter(.)
    let $sgFilter := $ops?sg ! unamef:parseNameFilter(.)
    let $sgFilterHeads :=
        $sgFilter and $sgFilter/unamef:matchesNameFilterObject('heads', .)
    let $sgFilterMembers :=
        $sgFilter and $sgFilter/unamef:matchesNameFilterObject('members', .)
        
    let $nsmap := uns:getTnsPrefixMap($schemas, ())  
    let $compDict := dict:getCompDict($schemas, ())
    let $typeUseCountsDict := dict:getTypeUseCountsDict($schemas)   
    let $typeUseSgDict := dict:getTypeUseSgDict($schemas)
    let $fileDict := dict:getFileDict($schemas, $ops)
    let $fnrMap := map:merge($fileDict/file/map:entry(@uri, @fileNr/string()))
    let $typeDefs := 
        if ($scope eq 'global') then $schemas/(xs:simpleType, xs:complexType)
        else if ($scope eq 'local') then $schemas//(xs:simpleType, xs:complexType)[not(@name)]
        else $schemas//(xs:simpleType, xs:complexType)
        
    let $options2 := map:merge((
        map:put($ops, 'compDict', $compDict) !
        map:put(., 'nsmap', $nsmap)
    ))
        
    let $typeInfos :=
        for $type in $typeDefs
        let $local := not($type/@name)
        let $item := if (not($local)) then () else 
            $type/ancestor::*
            [self::xs:element, self::xs:attribute, self::xs:simpleType][1]
        let $name := ($item, $type)/@name[1]
        where not($nameFilter) or $name ! unamef:matchesNameFilterObject(., $nameFilter)

        let $base := $type/coto:getBaseAtt(.)
        let $baseName := $base ! replace(., '.+:', '')
        where not($baseFilter) or $baseName ! unamef:matchesNameFilterObject(., $baseFilter)

        let $tns := $type/ancestor::xs:schema/@targetNamespace
        let $qname := QName($tns, $name)
        let $qnameNorm := $qname ! uns:normalizeQName(., $nsmap)
        let $fnr := $type/base-uri(.) ! $fnrMap(.)
        let $nameAtt :=
            if (not($local)) then attribute name {$qnameNorm}
            else if ($item/self::xs:element) then attribute elementName {$qnameNorm}
            else if ($item/self::xs:attribute) then attribute attributeName {$qnameNorm}
            else if ($item/self::xs:simpleType) then attribute simpleTypeName {$qnameNorm}
            else error()

        let $typeUse := suto:getTypeUseSummary($qname, $typeUseCountsDict)        
        let $sgHeads := 
            ($typeUseSgDict?sgHeads($qname) => string-join(', '))[string()]
        where not($sgFilterHeads) or $sgHeads            
        let $sgMembers :=
            let $memberGroupHeadNamesTY := $typeUseSgDict?sgMembersTY($qname)
            let $memberGroupHeadNamesLT := $typeUseSgDict?sgMembersLT($qname) 
            let $names := ($memberGroupHeadNamesTY, $memberGroupHeadNamesLT) => sort()            
            where exists($names)
            return string-join($names, ', ')
        where not($sgFilterMembers) or $sgMembers            
        let $file := $type/base-uri(.)
        let $typeSummaryAtts :=
            suto:getTypeContentSummaryAtts2($type, $compDict, $tsummaryLabels, $nsmap, ())
        let $ki := $typeSummaryAtts/self::attribute(ki)
        where not($kiFilter) or $ki ! unamef:matchesNameFilterObject(., $kiFilter)
        order by local-name-from-QName($qnameNorm), prefix-from-QName($qnameNorm)
        let $expanded := tyex:getTypeChain($type, $nsmap, $options2)
        let $type :=
            <type>{
                $local[.] ! attribute local {'yes'},
                $nameAtt,
                $typeSummaryAtts,
                $type/@abstract[not(. eq 'false')],
                $type/@final,
                if ($local) then () else attribute use {$typeUse},
                $sgHeads[$tsummaryLabels = 'sg'] ! attribute sgHeads {.},
                $sgMembers[$tsummaryLabels = 'sg'] ! attribute sgMembers {.},
                if (not($filenr)) then () else attribute fileNr {$fnr},
                $expanded/*
            }</type>
        let $type2 := 
            typa:augmentExpandedTypeWithPattern(
                $type, $compDict, $nsmap, $options2)
        return $type2
    return
        <report type="typeExpansion"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:z="http://www.parsqube.de/xspy/structure">{
            uns:namespaceMapToNodes($nsmap),                
            $scope ! attribute scope {.},
            $ops?name ! attribute nameFilter {.},            
            $ops?base ! attribute baseFilter {.},
            $ops?sg ! attribute sgFilter {.},
            $ops?ki ! attribute kiFilter {.},
            attribute tsummary {$tsummaryLabels},
            $nsmap,
            <types count="{count($typeInfos)}">{
                $typeInfos
            }</types>,
            if (not($filenr)) then () else $fileDict
        }</report>
};

(: 
 : ***    T y p e    c h a i n    ***
 :) 

declare function tyex:getTypeChain($type as element(),
                                   $nsmap as element(z:nsMap),
                                   $options as map(*))
        as element() {
    let $options := map:put($options, 'skipLocalType', true())        
    let $verbosity := $options?verbosity
    let $compDict := $options?compDict
    
    let $chain := tyex:getTypeChainREC($type, $nsmap, $options) 
    let $stypeContents :=
        if (not($chain/xs:simpleType)) then () else
        let $stypes := 
            for $step in $chain return
            typeswitch($step)
            case element(union) return
                let $typedef := $step/*[1]
                let $memberTypes := $step/* => tail()
                return
                    $typedef/element {node-name(.)} {
                        @*, 
                        node(),
                        $memberTypes
                    }
            case element(list) return
                let $typedef := $step/*[1]
                let $itemType := $step/* => tail()
                return
                    $typedef/element {node-name(.)} {
                        @*, 
                        node(),
                        $itemType
                    }
            case element(extension) | element(restriction) return
                if ($step/xs:simpleType) then $step/xs:simpleType
                (: Attributes are reported in section <attributes> :)
                else if ($step/xs:complexType/xs:simpleContent) then ()
                (: Complex content should not appear in the chain, although it does :)
                else if ($step/xs:complexType/xs:complexContent) then ()
                else $step/*
            default return ()                    
        return
            <stype>{$stypes}</stype>
    let $atts := 
        for $step in $chain/*/coto:getTypeContentElem(.)
        let $atts := $step/(xs:attribute, xs:attributeGroup)
        where $atts
        let $attsExp :=
            for $att in $atts return
            typeswitch($att)
            case element(xs:attribute) return $att
            case element(xs:attributeGroup) return
                element {node-name($att)} {
                    $att/@*,
                    let $qname := $att/@ref/uns:resolveNormalizedQName(., $nsmap)
                    let $agroupDef := $compDict?agroup($qname)
                    return $agroupDef ! coto:getAttributeGroupDeepContent(., $compDict)
                                      ! coto:getNormalizedComp(., $nsmap, $options)
                }
            default return error()
        return
            if ($step/self::xs:restriction) then
                <restriction>{$step/@base, $attsExp}</restriction>
            else $attsExp
    let $contentAtts :=
        if (not($atts)) then () else
            <attributes>{$atts}</attributes>
            
    (: Model group of restriction is wrapped in <restriction base="..."> :)
    let $modelGroups :=
        for $mgroup in $chain/*/coto:getTypeContentElem(.)/
            (xs:sequence, xs:choice, xs:all, xs:group)
        let $restrictionBase := $mgroup/parent::xs:restriction/@base            
        return
            if ($restrictionBase) then                
                <restriction base="{$restrictionBase}">{
                    uns:namespaceMapToNodes($nsmap),
                    $mgroup}</restriction>
            else $mgroup
     
    let $modelGroups2 :=
        if ($options?skipGroupExpansion) then $modelGroups
        else
            let $groups := $modelGroups/coto:getExpandedGroup(., $compDict, $options)
            return $groups
            (: ! coto:getNormalizedComp(., $nsmap, $options) :)
    let $contentModelGroups :=
        if (empty($modelGroups2)) then () else
            let $seq := <xs:sequence>{$modelGroups2}</xs:sequence>
            let $seq2 := tyex:simplifyNestedModelGroups($seq)
            return <elements>{$seq2}</elements>
    let $content :=
        <content>{
            $contentAtts,
            $stypeContents,
            $contentModelGroups
        }</content>
    return 
        <type>{
            $content,
            if (not($verbosity)) then () else
                <layers>{$chain}</layers>
        }</type>
};        

declare function tyex:getTypeChainREC($type as element(),
                                      $nsmap as element(z:nsMap),
                                      $options as map(*))
        as element()* {
    let $compDict := $options?compDict        
    let $typeNorm := $type ! coto:getNormalizedComp(., $nsmap, $options)        
    let $base :=
        $type/(xs:restriction, 
              (xs:simpleContent, xs:complexContent)
              /(xs:restriction, xs:extension))
              /@base        
    let $list := $type/xs:list/(@itemType, (* except xs:annotation))
    let $union := $type/xs:union/(@memberTypes, (* except xs:annotation)) 
    let $fnResolve := function($qname, $elemName) {    
        if ($qname ! uns:isQNameBuiltin(.)) then 
            $qname ! uns:normalizeQName(., $nsmap) 
                   ! element {$elemName} {attribute name {.}}
        else
            let $typeDef := $compDict?type($qname)
            let $resolved := $typeDef ! tyex:getTypeChainREC(., $nsmap, $options)
            return 
                element {$elemName} {$resolved}
    }
    
    let $resolved :=
        if ($base) then
            let $qname := resolve-QName($base, $base/..)        
            let $ancestors :=
                if (uns:isQNameBuiltin($qname)) then ()
                else
                    $compDict?type($qname) ! 
                    tyex:getTypeChainREC(., $nsmap, $options)
            return (
                $ancestors,
                element {$base/parent::*/local-name(.)} {$typeNorm}
            )
        else if ($list) then 
            <list>{
                $typeNorm,
                if ($list/self::attribute()) then
                    let $qname := resolve-QName($list, $list/..)
                    (: return $fnResolve($qname, 'itemType') :) (: hjr, 20250820 :)
                    let $resolved := $fnResolve($qname, 'itemType')
                    return
                        if (not($resolved/*)) then $resolved
                        else <itemType>{$resolved/*/*}</itemType> 
                else $list ! tyex:getTypeChainREC(., $nsmap, $compDict)
            }</list>                
        else if ($union) then 
            <union>{
                $typeNorm,
                let $mtypes1 := $union/self::attribute()/tokenize(.)
                for $mtype1 in $mtypes1
                let $qname := resolve-QName($mtype1, $union/..)
                (: return $fnResolve($qname, 'memberType') :) (: hjr, 20250820 :)
                let $resolved := $fnResolve($qname, 'memberType')
                return
                    if (not($resolved/*)) then $resolved
                    else <memberType>{$resolved/*/*}</memberType>
                ,
                for $mtype2 in $union/self::xs:element
                let $resolved := $mtype2 ! tyex:getTypeChainREC(., $nsmap, $compDict)
                return <memberType>{$resolved}</memberType>
            }</union>
        else <type>{$typeNorm}</type>
    return $resolved        
}; 

(: 
 : ***    N e s t e d    m o d e l    g r o u p s    ***
 :) 

(:~
 : Simplifies nested model groups.
 : Actions:
 : - a sequence without attributes with a sequence parent is
 :   unwrapped
 :)
declare function tyex:simplifyNestedModelGroups($elem as element())
        as node()* {
    $elem ! tyex:simplifyNestedModelGroupsREC(.)        
};

(:~
 : Recursive helper function of `simplifyNestedModelGroups`.
 :)
declare function tyex:simplifyNestedModelGroupsREC($n as node())
        as node()* {
    typeswitch($n)
    case element(xs:sequence) return
        let $atts := $n/@* ! tyex:simplifyNestedModelGroupsREC(.)
        let $children := $n/node() ! tyex:simplifyNestedModelGroupsREC(.)
        return
            if (empty($atts)) then $children
            else 
                element {node-name($n)} {
                    $atts,
                    $children
                }
    case element() return
        $n/element {node-name(.)} {
            @* ! tyex:simplifyNestedModelGroupsREC(.),
            node() ! tyex:simplifyNestedModelGroupsREC(.)
        }
    default return $n        
};

