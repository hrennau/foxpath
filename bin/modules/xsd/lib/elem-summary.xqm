(:
 : Functions creating an element inventory
 :)
module namespace elsu="http://www.parsqube.de/xspy/report/element-summary";
import module namespace uns="http://www.parsqube.de/xspy/util/namespace"
    at "util-namespace.xqm";

import module namespace dict="http://www.parsqube.de/xspy/util/dictionaries"
    at "dictionaries.xqm";
import module namespace suto="http://www.parsqube.de/xspy/util/summary-tools"
    at "summary-tools.xqm";
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
 : Creates an element inventory.
 :)
declare function elsu:elemSummaryReport($schemas as element(xs:schema)*,
                                       $ops as map(*)?)
        as element() {
    let $file := $ops?file
    let $tsummaryLabels := util:getTsummaryLabels($ops?tsummary)
    let $scope := ($ops?scope, 'global')[1]
    let $nameFilter := $ops?name ! unamef:parseNameFilter(.)
    let $typeFilter := $ops?type ! replace(., '#', '\\#') ! unamef:parseNameFilter(.)    
    let $baseFilter := $ops?base ! unamef:parseNameFilter(.)
    let $sgFilter := $ops?sg ! unamef:parseNameFilter(.)
    let $sgFilterHeads :=
        $sgFilter and $sgFilter/unamef:matchesNameFilterObject('heads', .)
    let $sgFilterMembers :=
        $sgFilter and $sgFilter/unamef:matchesNameFilterObject('members', .)
    
    let $nsmap := uns:getTnsPrefixMap($schemas, ())  
    let $compDict := dict:getCompDict($schemas, ())
    let $elemRefDict := dict:getElementRefDict($compDict, $nsmap)
    
    let $fileDict := if (not($file)) then () else dict:getFileDict($schemas, $ops)
    let $fnrMap := $fileDict ! map:merge(file/map:entry(@uri, @file/string()))
    let $elems := 
        if ($scope eq 'global') then $schemas/xs:element
        else if ($scope eq 'local') then $schemas/*//xs:element[not(@ref)]
        else $schemas//(xs:element)[not(@ref)]
    let $sgroupHeads := 
        $elems/@substitutionGroup/(resolve-QName(., ..) ! uns:normalizeQName(., $nsmap))
        => distinct-values()
    let $elemInfos :=
        for $elem in $elems
        where not($sgFilterMembers) or $elem/@substitutionGroup
        
        let $isGlobal := exists($elem/parent::xs:schema)
        let $isGlobalAtt := 
            if (not($scope eq 'all')) then () 
            else (if ($isGlobal) then true() else false()) ! attribute global {.}
        let $fnr := $elem/base-uri(.) ! $fnrMap(.)
        let $name := $elem/@name
        let $tns := $elem/ancestor::xs:schema/@targetNamespace
        let $qname := QName($tns, $name)
        let $qnameNorm := $qname ! uns:normalizeQName(., $nsmap)
        where not($nameFilter) or 
            $name ! unamef:matchesNameFilterObject(., $nameFilter)
        
        let $typeName := 
            ($elem/@type/uns:normalizeAttValueQName(., $nsmap), 
             $elem/(xs:simpleType, xs:complexType)/'#local',
             '#none')[1]
        let $typeLname := string($typeName) ! replace(., '.*:', '')
        where not($typeFilter) or            
            $typeLname ! unamef:matchesNameFilterObject(., $typeFilter)
            
        let $typeDef := $elem/(xs:simpleType, xs:complexType) 
        let $typeBase :=
            $typeDef/coto:getBaseAtt(.)/uns:normalizeAttValueQName(., $nsmap)
        let $baseLname := local-name-from-QName($typeBase)
        where not($baseFilter) or            
            $baseLname ! unamef:matchesNameFilterObject(., $baseFilter)
        
        let $refElems := if (not($isGlobal)) then () else $elemRefDict($qname)
        let $refElemsCount := if (not($isGlobal)) then () else count($refElems)
        
        let $sgroup := $elem/@substitutionGroup/uns:normalizeAttValueQName(., $nsmap)
        let $sgHead := if (not($qnameNorm = $sgroupHeads)) then () else 'yes'
        where not($sgFilterHeads) or $sgHead
        
        let $occ := $elem[not($isGlobal)]/suto:getOcc($elem) ! attribute occ {.}
        let $typeSummaryAtts := $typeDef ! 
            suto:getTypeContentSummaryAtts2(., $compDict, $tsummaryLabels, $nsmap, ())
        order by local-name-from-QName($qnameNorm), prefix-from-QName($qnameNorm)
        return
            <elem name="{$qnameNorm}">{
                $isGlobalAtt,
                $typeName ! attribute type {.},
                $typeSummaryAtts,
                $occ,
                $refElemsCount ! attribute countRefs {.},
                $sgroup ! attribute sgroup {.},
                $sgHead[$tsummaryLabels = 'sg'] ! attribute isSgroupHead {.},
                if (not($file)) then () else attribute file {$fnr}
            }</elem>
    let $fileDictFinal := $fileDict/dict:reduceFileDict(., $elemInfos/@file)        
    return
        <report type="elementInventory">{
            $scope ! attribute scope {.},
            $ops?name ! attribute nameFilter {.},        
            $ops?base ! attribute baseFilter {.},
            $ops?type ! attribute typeFilter {.},
            attribute tsummary {$tsummaryLabels},            
            $nsmap,
            <elems count="{count($elemInfos)}">{
                $elemInfos
            }</elems>,
            $fileDictFinal
        }</report>
};
