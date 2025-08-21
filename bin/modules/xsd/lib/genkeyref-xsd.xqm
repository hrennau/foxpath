(:
 : Functions creating a keyref report
 :)
module namespace xkref="http://www.parsqube.de/xspy/report/genkeyref-xsd";
import module namespace uns="http://www.parsqube.de/xspy/util/namespace"
    at "util-namespace.xqm";

import module namespace navi="http://www.parsqube.de/xspy/util/navigation"
    at "navigation.xqm";
import module namespace navi2="http://www.parsqube.de/xspy/util/navigation2"
    at "navigation2.xqm";
import module namespace dict="http://www.parsqube.de/xspy/util/dictionaries"
    at "dictionaries.xqm";
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
declare namespace xsd="http://www.w3.org/2001/XMLSchema";

(:~
 : Creates a type resolution report.
 :)
declare function xkref:genKeyrefXsd($schemas as element(xs:schema)*,
                                    $ops as map(*)?)
        as element() {
    let $keyrefgen := $ops?keyrefgen
    let $keyrefgenDoc := doc($keyrefgen)/*
    let $config := $ops?config
    let $schemaLocationBridge := '../../../../NeTEx-CEN/xsd'
    let $configDoc := $config[string()] ! doc(.)/*
    
    let $options := $ops !
                    map:put(., 'configDoc', $configDoc)
    
    let $xsdPath := $const:REL_PATH_NETEX||'/'||$const:PATH_PUBLICATION_DELIVERY
    let $xsdDoc := doc($xsdPath)
    let $xsdElem := $xsdDoc//xs:element[@name eq 'PublicationDelivery']
    let $keyrefConstraints := xkref:keyrefKeyConstraints($keyrefgenDoc, $options)
    let $scaffold :=
        $xsdDoc/xs:schema/element {node-name(.)} {
            uns:copyNamespaces(.),
            @*,
            (xs:include | xs:import)/xkref:editIncludeImport(., $schemaLocationBridge),
            <xsd:include schemaLocation="{$const:FNAME_PUBLICATION_DELIVERY_GENERATED}"/>,
            $xsdElem/element {node-name(.)} {
                uns:copyNamespaces(.),
                @*,
                $keyrefConstraints
            }
        }
    return $scaffold
};

declare function xkref:keyrefKeyConstraints($keyrefgen as element(),
                                            $options as map(*))
        as node()* {
    let $limitCount := $options?limitCount[. gt 0]        
    let $onlyKeys := $options?onlyKeys[. gt 0]
    let $configDoc := $options?configDoc
    let $entityTypes := $keyrefgen//entityTypes/entityType
    
    let $skipKeys := $configDoc//entities/entity[@skipKey eq 'yes']/@name
    let $skipDeepKeys := $configDoc//entities/entity[@skipDeepKey eq 'yes']/@name
    let $entityNamesWithMissingKeys := 
        xkref:getEntityTypesWithManyMissingFields($entityTypes, $configDoc)
    
    let $_DEBUG := trace('_ limitCount='||$limitCount||' ; onlyKeys='||$onlyKeys)
    let $_DEBUG := trace($skipKeys => string-join(', '), '_ skip keys: ')
    let $_DEBUG := trace($skipDeepKeys => string-join(', '), '_ skip deep keys: ')
    let $_DEBUG := trace($entityNamesWithMissingKeys, '_ entity with misssingkeys: ')
    
    (: entity types :)
    for $entityType in $entityTypes
        [not($limitCount) or position() le $limitCount]
    let $entityName := $entityType/@name        
    let $entityTypeName := $entityName/replace(., '.+:', '')
    let $entityConfig := $configDoc//entities/entity[@name = $entityTypeName]    
    where not($entityTypeName = $skipKeys)

    let $pointerTypes := $keyrefgen//pointerTypes/pointerType[@entityType eq $entityName]
    let $skipEntity :=
        if ($pointerTypes) then false()
        else if ($entityName = $entityNamesWithMissingKeys) then true()
        else false()
    let $_DEBUG :=
        if (not($skipEntity)) then ()
        else trace($entityTypeName, '_ skip key because of missing key values for type: ')
    where not($skipEntity)           
            
    let $entityXPath := xkref:getEntityXpath($entityType, $configDoc)    
    where $entityXPath
    
    let $entityLabel := $entityName ! replace(., '_.*', '') ! replace(., '.+:', '')
    let $keyName := $entityType/@keyName    (: xkref:entityTypeNameToKeyName($entityName) :)    
    let $entityFields :=
        let $excludedKeyFields := $entityConfig/@excludeKeyFields ! tokenize(.)  
        let $_DEBUG := if (empty($excludedKeyFields)) then () else
            trace(string-join($excludedKeyFields, ', '), 
                '_ # excluded key fields for entity type='||$entityName||': ')
        for $field in $entityType/@fields/tokenize(.)[not(. = $excludedKeyFields)] return
            <xsd:field xpath="{$field}"/>

    (: key element :)
    let $keyElem := 
		<xsd:key name="{$keyName}">{
			<xsd:selector>{
			    attribute xpath {$entityXPath}
			}</xsd:selector>,
			$entityFields
		}</xsd:key>

    (: deep key element :)    
    let $deepKeyElem :=
        let $derivedEntityTypes := 
            $entityType/derivedEntityTypes/derivedEntityType/@name/replace(., '^.+:', '')
        let $derivedEntityTypesSkip := $derivedEntityTypes[. = $skipKeys]
            => sort()
        return
        
        if (not($entityType/derivedEntityTypes)) then () 
        else if ($entityTypeName = $skipDeepKeys) then 
            comment {' Generation of deep key suppressed, key: '||$keyName||' '}
        else if (exists($derivedEntityTypesSkip) and $const:SUPPRESS_DEEP_KEY_IF_DERIVED_SKIPPED_EXISTS) then
            comment {' Generation of deep key suppressed as it contains '||
                'skipped keys ('||$derivedEntityTypesSkip => string-join(', ')||'), key: '||$keyName||' '}
        else
            let $derivedEntityTypeNames := 
                $entityType/derivedEntityTypes/derivedEntityType/@name
            let $_DEBUG :=
                if (not($derivedEntityTypeNames = $entityNamesWithMissingKeys)) then () 
                else trace($entityName, 
                    '_ skip deep key because of missing key values for derived type: ')
            where not($derivedEntityTypeNames = $entityNamesWithMissingKeys)
            
            let $derivedEntityTypeElems := ($entityType,
                $keyrefgen//entityTypes/entityType[@name = $derivedEntityTypeNames])
            let $entityXPathDeep := xkref:getEntityXpath($derivedEntityTypeElems, $configDoc)
            where $entityXPathDeep
            let $keyNameDeep := $keyName||'_Deep'
            return 
		        <xsd:key name="{$keyNameDeep}">{
		            if (empty($derivedEntityTypesSkip)) then () else
		            comment {'Deep key excludes skipped types: '||($derivedEntityTypesSkip => string-join(', '))},
			        <xsd:selector>{
			            attribute xpath {$entityXPathDeep}
			        }</xsd:selector>,
			        $entityFields
		        }</xsd:key>
                
    (: pointer types :)
    let $keyrefConstraints := if ($onlyKeys) then () else
        for $pointerType in $pointerTypes
        let $keyrefExprs :=
            for $expr in $pointerType//*:selector/@xpath
            let $edited := $expr ! replace(., '/b:', '/netex:') ! replace(., '/d:', '/siri:')
            return $edited
        let $keyrefXPath := $keyrefExprs => string-join(' | ')        
        where $keyrefXPath
        
        let $keyrefName := $pointerType/@keyrefName (: xkref:pointerTypeNameToKeyrefName($keyref/@name, $entityName) :)
        let $pointerFields :=
            let $excludedKeyFields := $entityConfig/@excludeKeyFields ! tokenize(.)        
            for $field in $pointerType/@fields/tokenize(.)[not(. = $excludedKeyFields)] return
                <xsd:field xpath="{$field}"/>  
        let $refer := ($deepKeyElem/@name, $keyElem/@name)[1]                
        return
            <xsd:keyref name="{$keyrefName}" refer="{$refer}">{
    			<xsd:selector>{
	    		    attribute xpath {$keyrefXPath}
		    	}</xsd:selector>, 
		    	$pointerFields
            }</xsd:keyref>
        
    return (
        comment {'=== Entity "'||$entityLabel||'" ==='},
        $keyrefConstraints,
        $keyElem,
        $deepKeyElem
    )
};  

declare function xkref:entityTypeNameToKeyName($name as xs:string)
        as xs:string {
    let $existingKeys := ('TypeOfValue_Key')        
    let $keyName := 
        if (ends-with($name, '_VersionStructure')) then replace($name, '_VersionStructure', '_Key')
        else if (ends-with($name, '_VersionFrameStructure')) then replace($name, '_VersionFrameStructure', '_VfsKey')        
        else if (ends-with($name, '_VersionedChildStructure')) then replace($name, '_VersionedChildStructure', '_VcsKey')
        else if (ends-with($name, '_ValueStructure')) then replace($name, '_ValueStructure', '_VasKey')
        else if (ends-with($name, '_ViewStructure')) then replace($name, '_ViewStructure', '_VisKey')
        else if (contains($name, '_')) then replace($name, '_[^_]+$', '_Key')
        else $name||'_Key'
    let $keyName := $keyName ! replace(., '.+:', '')        
    let $keyName := if ($keyName = $existingKeys) then $keyName||'2' else $keyName   
    
    let $_DEBUG := if (not(contains($keyName, 'TypeOfValueXXX'))) then () 
                   else trace($keyName, '_ keyName: ')
    return $keyName
};        

declare function xkref:pointerTypeNameToKeyrefName($pointerName as xs:string, $entityName as xs:string)
        as xs:string {
    let $keyrefName := 
        if (ends-with($pointerName, 'RefStructure')) then replace($pointerName, 'RefStructure', '_Ref')
        else $pointerName||'_Ref'
    let $keyrefName := $keyrefName ! replace(., '.+:', '')        
    return $keyrefName
};        

declare function xkref:getEntityXpath($entityTypes as element()+,
                                      $keyrefConfig as element()?)
        as xs:string? {
    let $entityExprs :=
        for $entityType in $entityTypes
        let $entityName := $entityType/@name
        let $entityTypeName := $entityName ! replace(., '.+:', '')   
        let $entityConfig := $keyrefConfig//entities/entity[@name = $entityTypeName]
        where not($entityConfig/@skipKey eq 'yes')    (: 20250604, hjr - added where clause :)
        
        let $excludedKeySelectorElems := $entityConfig/@excludeKeySelectorElems ! tokenize(.)
        let $_DEBUG := if (empty($excludedKeySelectorElems)) then () 
                       else trace($excludedKeySelectorElems, '_ X excluded key selector elems: ')
        let $includedKeySelectorElems := $entityConfig/@includeKeySelectorElems ! tokenize(.)
        let $_DEBUG := if (empty($includedKeySelectorElems)) then () 
                       else trace($includedKeySelectorElems, '_ Y included key selector elems: ')
        
        for $expr in $entityType//*:selector/@xpath
        let $fields := $expr ! tokenize(., '/+')[string()] ! replace(., '.+:', '')
        where (empty($includedKeySelectorElems) or $fields = $includedKeySelectorElems)
        where not($fields = $excludedKeySelectorElems)
        let $edited := $expr ! replace(., '/b:', '/netex:') ! replace(., '/d:', '/siri:')
        order by $edited
        return $edited
    let $entityXPath := $entityExprs => string-join(' | ')
    return $entityXPath[.]
}; 

declare function xkref:editIncludeImport($includeImport as element(), $bridgePath as xs:string)
        as element() {
    element {node-name($includeImport)} {
        for $att in $includeImport/@* return
            if ($att/self::attribute(schemaLocation)) then
                attribute {node-name($att)} {string-join(($bridgePath, $att), '/')}
            else $att,
        $includeImport/node()
   }
};

declare function xkref:getEntityTypesWithManyMissingFields(
                                                    $entityTypes as element()*,
                                                    $config as element()?)
        as xs:string* {
    let $maxCountMF := $config//global/casesMissingFields/@maxCount/xs:integer(.) (: MAX_COUNT_MISSING_FIELDS := 10 :)
    return if (empty($maxCountMF)) then () else
    
    let $entityNames :=
        for $entityType in $entityTypes
        let $selectors := $entityType//xs:selector
        let $missingFieldCounts := 
            $selectors/@counts[matches(., '#missingFields=.*/')]
        let $maxMissing :=
            for $countInfo in $missingFieldCounts ! replace(., '.*#missingFields=(.)', '$1')
            let $counts := tokenize($countInfo, '/') ! xs:integer(.)
            return max($counts)
        let $maxMaxMissing := max($maxMissing)
        where ($maxMaxMissing ge $maxCountMF)
        return $entityType/@name
    return $entityNames => sort()
};        
