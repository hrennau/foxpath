(:
 : Functions creating a type inventory
 :)
module namespace iss="http://www.parsqube.de/xspy/report/issues";
import module namespace uns="http://www.parsqube.de/xspy/util/namespace"
    at "util-namespace.xqm";
import module namespace dict="http://www.parsqube.de/xspy/util/dictionaries"
    at "dictionaries.xqm";
import module namespace coto="http://www.parsqube.de/xspy/util/component-tools"    
    at "component-tools.xqm";
import module namespace util="http://www.parsqube.de/xspy/util"    
    at "../lib/util.xqm";
import module namespace ufpath="http://www.parsqube.de/xquery/util/file-path"
    at "../util/util-filePath.xqm";
import module namespace unamef="http://www.parsqube.de/xquery/util/name-filter"
    at "../util/util-nameFilter.xqm";
declare namespace z="http://www.parsqube.de/xspy/structure";

(:~
 : Creates an issues report.
 :)
declare function iss:reportIssues($schemas as element(xs:schema)*,  
                                  $issueType as xs:string,
                                  $ops as map(*)?)
        as element() {
    switch($issueType)
    case 'types-not-used' return iss:reportIssuesTypesNotUsed($schemas, $ops) 
    case 'groups-not-used' return iss:reportIssuesGroupsNotUsed($schemas, $ops)
    default return error()
};

(:~
 : Creates an issues report, type "types not used".
 :)
declare function iss:reportIssuesTypesNotUsed(
                                  $schemas as element(xs:schema)*,  
                                  $ops as map(*)?)
        as element() {
    let $compDict := dict:getCompDict($schemas, ())
    let $nsmap := uns:getTnsPrefixMap($schemas, ())
    
    let $typesNotUsed := dict:compDict_typesNotUsed($compDict)
    let $typesNotUsedInfo :=
        for $type in $typesNotUsed
        let $typeN := $type ! uns:normalizeQName(., $nsmap)
        order by string($typeN) ! lower-case(.)
        return <type name="{$typeN}"/>
    let $report :=
        <typesNotUsed count="{count($typesNotUsed)}">{
            $typesNotUsedInfo
        }</typesNotUsed>
    return $report
};

(:~
 : Creates an issues report, type "types not used".
 :)
declare function iss:reportIssuesGroupsNotUsed(
                                  $schemas as element(xs:schema)*,  
                                  $ops as map(*)?)
        as element() {
    let $compDict := dict:getCompDict($schemas, ())
    let $nsmap := uns:getTnsPrefixMap($schemas, ())
    
    let $groupsNotUsed := dict:compDict_groupsNotUsed($compDict)
    let $groupsNotUsedInfo :=
        for $group in $groupsNotUsed
        let $qname := $group ! uns:normalizeQName(., $nsmap)
        order by string($qname) ! lower-case(.)
        return <group name="{$qname}"/>
    let $report :=
        <groupsNotUsed count="{count($groupsNotUsed)}">{
            $groupsNotUsedInfo
        }</groupsNotUsed>
    return $report
};
