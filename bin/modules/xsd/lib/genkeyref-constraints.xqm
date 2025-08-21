(:
 : A function creating a report about generated keyref constraints.
 :)
module namespace krefco="http://www.parsqube.de/xspy/report/genkeyref-constraints";
import module namespace uns="http://www.parsqube.de/xspy/util/namespace"
    at "util-namespace.xqm";
import module namespace dict="http://www.parsqube.de/xspy/util/dictionaries"
    at "dictionaries.xqm";

import module namespace navi="http://www.parsqube.de/xspy/util/navigation"
    at "navigation.xqm";
import module namespace navi2="http://www.parsqube.de/xspy/util/navigation2"
    at "navigation2.xqm";
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

(:~
 : Creates a keyrefgen constraints report.
 :)
declare function krefco:genKeyrefConstraintsReport($genkeyref as xs:string,
                                                   $genconfig as xs:string?,
                                                   $vreport as xs:string?,
                                                   $schemas as element(xs:schema)*,
                                                   $ops as map(*)?)
        as item() {
    let $ireport := $genkeyref ! doc(.)
    let $cfg := $genconfig ! doc(.)
    let $vrep := $vreport ! doc(.)
    
    let $nsmap := uns:getTnsPrefixMap($schemas, ())  
    let $compDict := dict:getCompDict($schemas, ())
    let $itree := dict:compDict_inheritanceTree($compDict, $nsmap)
    
    let $etypeDict := $ireport//entityTypes/entityType[not(@name eq '?')]
                      /map:entry(@name, .) => map:merge()
    let $mkeyDict := (
        for $msg in $vrep//invalid/doc/message[@type eq 'missing-key']
        let $refName := $msg/@refName
        group by $refName
        return map:entry($refName, $msg)
        ) => map:merge()
    let $dkeyDict := (
        for $msg in $vrep//invalid/doc/message[@type eq 'duplicate-key']
        let $keyName := $msg/@keyName
        group by $keyName
        return map:entry($keyName, $msg)
        ) => map:merge()
        
    let $enameEtypeDict := (
        for $elemName in $ireport//entityTypes/entityType/elems/@elemName
        let $etypeName := $elemName/ancestor::entityType/@name
        group by $elemName
        let $elemNameLocal := $elemName ! replace(., '^.+:', '')
        return map:entry($elemNameLocal, $etypeName => distinct-values() => sort())
    ) => map:merge()
    let $itreeDict := (
        for $type in $itree//(type, rtype, etype)/@name
        return map:entry($type, $type/@name)
        ) => map:merge()
        
    let $entries :=
        for $elem in $ireport//pointerTypes//pointerType/elems/@elemName
        let $ename := string($elem)
        group by $ename
        order by $ename ! replace(., '.+:', '') ! lower-case(.), lower-case($ename)
        let $descriptors :=
            for $elem2 in $elem
            let $ptypeElem := $elem2/ancestor::pointerType
            let $ptype := $ptypeElem/@name
            let $etype := $ptypeElem/@entityType
            let $fields := $ptypeElem/@fields
            let $etypeL := $etype ! replace(., '.+:', '')
            let $keyrefName := $ptypeElem/@keyrefName
            let $ptypeElemNames := $ptypeElem/(xs:selector, selectors/xs:selector)/@xpath
            let $ptypeElemNamesInfo := $ptypeElemNames ! replace(., '^.//', '') => string-join(', ')
                
            let $etypeElem := $etypeDict($etype)
            let $keyName := $etypeElem/@keyName
            let $etypeElemNames := $etypeElem/(xs:selector, selectors/xs:selector)/@xpath
            let $etypeElemNamesInfo := $etypeElemNames ! replace(., '^.//', '') => string-join(', ')
            
            let $countEntityDescTypes := $etypeElem ! derivedEntityTypes/@count/xs:integer(.)
            let $skipDeepKey :=
                if (not($countEntityDescTypes gt 1)) then ()
                else $cfg//entity[@name eq $etypeL]/@skipDeepKey

            let $missingKeys := 
                krefco:missingKeysReport($ename,
                    $keyrefName, $ptypeElem, $etypeElem, $mkeyDict, $enameEtypeDict, $itreeDict)
                
            let $duplicateKeys :=
                let $msgs := $keyName ! $dkeyDict(.)
                for $msg in $msgs
                let $keyValue := $msg/@keyValue
                group by $keyValue
                order by $keyValue
                let $fnames := $msg/ancestor::doc/@uri/file:name(.) => sort()
                return
                    <duplicateKey value="{$keyValue}" files="{$fnames}"/>
            where not($ptype eq $etype) and not($etype eq '?')
            return
                <elem name="{$ename}">{
                    <ptype name="{$ptype}" keyref="{$keyrefName}" fields="{$fields}">{
                        <allElems names="{$ptypeElemNamesInfo}"/>,
                        if (empty($missingKeys)) then () else
                        <missingKeys>{$missingKeys}</missingKeys>
                    }</ptype>,
                    <etype name="{$etype}" key="{$keyName}">{
                        $countEntityDescTypes ! attribute countDescTypes {.},
                        $skipDeepKey ! attribute skipDeepKey {.},
                        <allElems names="{$etypeElemNamesInfo}"/>,                        
                        if (empty($duplicateKeys)) then () else
                        <duplicateKeys>{$duplicateKeys}</duplicateKeys>
                    }</etype>
                }</elem>
        return
            if (count($descriptors) gt 1) then <elems name="{$ename}">{$descriptors}</elems>
            else $descriptors
    let $elemGroups :=
        let $elemsMK := $entries[.//missingKeys]
        let $elemsDK := $entries[.//duplicateKeys]
        let $elemsOK := $entries except ($elemsMK, $elemsDK)        
        return (
            <elems category="missingKeys" count="{count($elemsMK)}">{
                $elemsMK
            }</elems>,
            <elems category="duplicateKeys" count="{count($elemsDK)}">{
                $elemsDK
            }</elems>,
            <elems category="OK" count="{count($elemsOK)}">{
                $elemsOK
            }</elems>
        )
    return
        <elems count="{count($entries)}" cfg="{$genconfig}">{
            $elemGroups
        }</elems>
};

declare function krefco:missingKeysReport($elemName as xs:string,
                                          $keyrefName as xs:string,
                                          $pointerType as element()?,
                                          $entityType as element()?,                                          
                                          $mkeyDict as map(*),
                                          $enameEtypeDict as map(*),
                                          $itreeDict as map(*))
        as item()* {
    let $msgs := $keyrefName ! $mkeyDict(.)
    return if (empty($msgs)) then () else
    let $elemLocalName := $elemName ! replace(., '.*:', '')
    let $entFieldPaths := tokenize($entityType/@fields)
    let $refFieldPaths := tokenize($pointerType/@fields)
    let $entAttNames := $entFieldPaths[starts-with(., '@')] ! replace(., '^@', '')
    let $refAttNames := $refFieldPaths[starts-with(., '@')] ! replace(., '^@', '')
    let $countEntAttNames := count($entAttNames)
    let $countRefAttNames := count($refAttNames)

    let $fnBuildKey := function($elem, $fieldPaths) {
        let $fieldValues :=
            for $p in $fieldPaths
            let $value := xquery:eval($p, map{'': $elem})
            return if (empty($value)) then <NOFIND/> else $value
        where empty($fieldValues[. instance of element(NOFIND)])
        return string-join($fieldValues, ',')
    }

    let $refDict := (
        for $uri in $msgs/ancestor::doc/@uri => distinct-values()
        let $doc := doc($uri)  
        let $elems := $doc//*[local-name() eq $elemLocalName]
        where $elems
        let $refValues := $elems ! $fnBuildKey(., $refFieldPaths)
        return map:entry($uri, $refValues)
    ) => map:merge()
    where exists(map:keys($refDict))
    
    let $keyDict := (
        for $uri in $msgs/ancestor::doc/@uri => distinct-values()
        let $doc := doc($uri)  
        let $elems := $doc//*[$countEntAttNames eq count(@*/name()[. = $entAttNames])]
        where $elems
        (: let $_DEBUG := trace(count($elems), '_ count entity elems: ') :)
        let $keymap := (
            for $elem in $elems
            let $key := $elem ! $fnBuildKey(., $entFieldPaths)
            where exists($key)
            return map:entry($key, local-name($elem))
            ) => map:merge()
        return map:entry($uri, $keymap)
        ) => map:merge()
    let $missingKeys :=
        for $msg in $msgs
        let $refValue := $msg/@refValue                
        let $uri := $msg/ancestor::doc/@uri
        let $refValues := $refDict($uri)
        where $refValues = $refValue
        let $matchingElems := 
            let $names := $keyDict($uri)($refValue)
            return if (exists($names)) then $names else '-'
        let $matchingElemTypes := (
            for $type in $matchingElems[. ne '-'] ! $enameEtypeDict(.)
            let $derivedTypes := $entityType/derivedEntityTypes/derivedEntityType/@name
            let $anno := if ($type = $derivedTypes) then '(derived=YES)' else '(derived=NO)'
            return $type||$anno)
            => string-join(', ')
        (: group by $refValue :)
        order by $refValue
        let $fnames := $msg/ancestor::doc/@uri/file:name(.) => sort()
        return
            <missingKey value="{$refValue}" matchingElems="{$matchingElems}">{
                if (not($matchingElemTypes)) then () else
                attribute matchingElemTypes {$matchingElemTypes},
                attribute files {$fnames}
            }</missingKey>
    return $missingKeys        
};        

