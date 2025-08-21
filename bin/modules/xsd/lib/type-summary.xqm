(:
 : Functions creating a type inventory
 :)
module namespace tysu="http://www.parsqube.de/xspy/report/type-summary";
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
 : Creates a type inventory.
 :)
declare function tysu:typeSummaryReport($schemas as element(xs:schema)*,
                                        $ops as map(*)?)
        as element() {
    let $file := $ops?file
    let $tsummary := $ops?tsummary
    let $tsummaryLabels := util:getTsummaryLabels($ops?tsummary, ())
    
    let $scope := ($ops?scope, 'global')[1]        
    let $nameFilter := $ops?name ! unamef:parseNameFilter(.)        
    let $baseFilter := $ops?base ! unamef:parseNameFilter(.)
        
    let $nsmap := uns:getTnsPrefixMap($schemas, ())  
    let $compDict := dict:getCompDict($schemas, ())
    let $typeUseSgDict := 
        if (not($tsummaryLabels = ('sgh', 'sgm'))) then ()
        else dict:getTypeUseSgDict($schemas)
    let $typeUseCountsDict := 
        if (not($tsummaryLabels = 'use')) then ()
        else dict:getTypeUseCountsDict($schemas)        
    let $fileDict := if (not($file)) then () else dict:getFileDict($schemas, $ops)
    let $fnrMap := $fileDict ! map:merge(file/map:entry(@uri, @file/string()))
    let $typeDefs := 
        let $unfiltered :=
            if ($scope eq 'global') then $schemas/(xs:simpleType, xs:complexType)
            else if ($scope eq 'local') then $schemas//(xs:simpleType, xs:complexType)[not(@name)]
            else $schemas//(xs:simpleType, xs:complexType)
        let $filteredName :=
            if (not($nameFilter)) then $unfiltered else

            for $type in $unfiltered
            let $local := not($type/@name)
            let $item := if (not($local)) then () else
                $type/ancestor::*[self::xs:element, self::xs:attribute, self::xs:simpleType][1]
            let $name := ($item, $type)/@name[1]
            where not($nameFilter) or $name ! unamef:matchesNameFilterObject(., $nameFilter)
            return $type
        let $filteredBase :=
            if (not($baseFilter)) then $filteredName else
            
            for $type in $unfiltered
            let $contentElem := coto:getTypeContentElem($type)
            let $restriction := $contentElem[self::xs:restriction]
            let $extension := $contentElem[self::xs:extension]        
            let $base := ($restriction, $extension)/@base
            let $baseName := $base ! replace(., '.+:', '')
            where not($baseFilter) or $baseName ! unamef:matchesNameFilterObject(., $baseFilter)
            return $type
        return $filteredBase

    let $typeUsingItems := 
        if (not($tsummaryLabels = 'use')) then ()
        else dict:getTypeUsedByItemDict($compDict, $typeDefs, $nsmap)

    let $typeInfos :=
        for $type in $typeDefs
        let $local := not($type/@name)
        let $item :=
            if (not($local)) then () else
                $type/ancestor::*[self::xs:element, self::xs:attribute, self::xs:simpleType][1]
        let $name := ($item, $type)/@name[1]
        
        let $tns := $type/ancestor::xs:schema/@targetNamespace
        let $qname := QName($tns, $name)
        let $qnameNorm := $qname ! uns:normalizeQName(., $nsmap)
        let $fnr := if (empty($fnrMap)) then () else $type/base-uri(.) ! $fnrMap(.)
        let $nameAtt :=
            if (not($local)) then attribute name {$qnameNorm}
            else if ($item/self::xs:element) then attribute elementName {$qnameNorm}
            else if ($item/self::xs:attribute) then attribute attributeName {$qnameNorm}
            else if ($item/self::xs:simpleType) then attribute simpleTypeName {$qnameNorm}
            else error()

        let $typeUseMap := 
            if (not($tsummaryLabels = 'use')) then ()
            else if ($local) then () 
            else
            
            map:merge((
              map:entry('use', suto:getTypeUseSummary($qname, $typeUseCountsDict)), 
              map:entry('elemsWithType', $typeUsingItems($qname)?namesElemsWithType),
              map:entry('elemsWithBase', $typeUsingItems($qname)?namesElemsWithBase),
              map:entry('attsWithType',  $typeUsingItems($qname)?namesAttsWithType),
              map:entry('attsWithBase',  $typeUsingItems($qname)?namesAttsWithBase)
            ))
        let $sgHeads := if (not($tsummaryLabels = 'sgh')) then () else
            ($typeUseSgDict?sgHeads($qname) => string-join(', '))[string()]
        let $sgMembers := if (not($tsummaryLabels = 'sgm')) then () else
            let $memberGroupHeadNamesTY := $typeUseSgDict?sgMembersTY($qname)
            let $memberGroupHeadNamesLT := $typeUseSgDict?sgMembersLT($qname) 
            let $names := ($memberGroupHeadNamesTY, $memberGroupHeadNamesLT) => sort()            
            where exists($names)
            return string-join($names, ', ')
        let $typeSummaryAtts :=
            suto:getTypeContentSummaryAtts2($type, $compDict, $tsummaryLabels, $nsmap, ())
        order by local-name-from-QName($qnameNorm), prefix-from-QName($qnameNorm)
        return
            <type>{
                $local[.] ! attribute local {'yes'},
                $nameAtt,
                $typeSummaryAtts,
                $type/@abstract[not(. eq 'false')],
                $type/@final,
                $typeUseMap?use ! attribute use {.},
                $typeUseMap?elemsWithType ! attribute elemsWithType {.},
                $typeUseMap?elemsWithBase ! attribute elemsWithBase {.},
                $typeUseMap?attsWithType ! attribute attsWithType {.},
                $typeUseMap?attsWithBase ! attribute attsWithBase {.},
                $sgHeads ! attribute sgHeads {.},
                $sgMembers ! attribute sgMembers {.},
                $fnr ! attribute file {.}
            }</type>
    let $fileDictFinal := $fileDict/dict:reduceFileDict(., $typeInfos/@file)            
    return
        <report type="typeInventory">{
            $scope ! attribute scope {.},
            $ops?name ! attribute nameFilter {.},            
            $ops?base ! attribute baseFilter {.},
            $ops?sg ! attribute sgFilter {.},
            attribute tsummary {$tsummaryLabels},
            $nsmap,
            <types count="{count($typeInfos)}">{
                $typeInfos
            }</types>,
            $fileDictFinal
        }</report>
};
