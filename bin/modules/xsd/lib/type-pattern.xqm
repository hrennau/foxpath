(:
 : Functions determing a type pattern
 :)
module namespace typa="http://www.parsqube.de/xspy/report/type-pattern";
import module namespace uns="http://www.parsqube.de/xspy/util/namespace"
    at "util-namespace.xqm";

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

declare function typa:augmentExpandedTypeWithPattern(
                                     $typeRes as element(), 
                                     $compDict as map(*),
                                     $nsmap as element(z:nsMap),
                                     $options as map(*))
        as element() {
    let $pattern := typa:getTypePattern($typeRes, $compDict, $nsmap, $options)
    let $typeRes2 :=
        copy $typeRes_ := $typeRes
        modify replace node $typeRes_/@ki with (
            $typeRes_/@ki,
            attribute kp {$pattern}
        )
        return $typeRes_
    return $typeRes2        
};

declare function typa:getTypePattern($typeRes as element(), 
                                     $compDict as map(*),
                                     $nsmap as element(z:nsMap),
                                     $options as map(*))
        as xs:string? {
    let $ki := $typeRes/@ki return        
    switch($ki)
    case 'cc' return typa:getTypePattern_cc($typeRes, $compDict, $nsmap, $options)
    case 'cce' return typa:getTypePattern_cce($typeRes, $compDict, $nsmap, $options)    
    case 'ccr' return typa:getTypePattern_ccr($typeRes, $compDict, $nsmap, $options)    
    case 'ce' return typa:getTypePattern_ce($typeRes, $compDict, $nsmap, $options)    
    case 'cse' return typa:getTypePattern_cse($typeRes, $compDict, $nsmap, $options)    
    case 'csr' return typa:getTypePattern_csr($typeRes, $compDict, $nsmap, $options)    
    case 'sl' return typa:getTypePattern_sl($typeRes, $compDict, $nsmap, $options)    
    case 'sr' return typa:getTypePattern_sr($typeRes, $compDict, $nsmap, $options)    
    case 'su' return typa:getTypePattern_su($typeRes, $compDict, $nsmap, $options) 
    default return error(QName((), 'UNEXPECTED_DATA'), 'ki-value: '||$ki)
};

declare function typa:getTypePattern_cc($typeRes as element(), 
                                     $compDict as map(*),
                                     $nsmap as element(z:nsMap),
                                     $options as map(*))
        as xs:string {
    '?'
};    

declare function typa:getTypePattern_cce($typeRes as element(), 
                                         $compDict as map(*),
                                         $nsmap as element(z:nsMap),
                                         $options as map(*))
        as xs:string {
    '?'
};    

declare function typa:getTypePattern_ccr($typeRes as element(), 
                                         $compDict as map(*),
                                         $nsmap as element(z:nsMap),
                                         $options as map(*))
        as xs:string? {
    let $base := $typeRes/@base
    let $contentRedefinition := 
        typa:getTypePattern_contentRedefinition(
            $typeRes, $base, $compDict, $nsmap, $options)
    let $attRedefinitions := 
        typa:getTypePattern_attRedefinitions(
            $typeRes, $base, $compDict, $nsmap, $options)
    return
        string-join(($attRedefinitions, $contentRedefinition), '; ')
};    

declare function typa:getTypePattern_ce($typeRes as element(), 
                                        $compDict as map(*),
                                        $nsmap as element(z:nsMap),
                                        $options as map(*))
        as xs:string {
    'empty'
};    

declare function typa:getTypePattern_cse($typeRes as element(), 
                                         $compDict as map(*),
                                         $nsmap as element(z:nsMap),
                                         $options as map(*))
        as xs:string {
    '?'
};    

declare function typa:getTypePattern_csr($typeRes as element(), 
                                         $compDict as map(*),
                                         $nsmap as element(z:nsMap),
                                         $options as map(*))
        as xs:string? {
    let $base := $typeRes/@base
    let $attRedefinitions := 
        typa:getTypePattern_attRedefinitions(
            $typeRes, $base, $compDict, $nsmap, $options)
    return
        $attRedefinitions
};    

declare function typa:getTypePattern_sl($typeRes as element(), 
                                        $compDict as map(*),
                                        $nsmap as element(z:nsMap),
                                        $options as map(*))
        as xs:string {
    '?'
};    

declare function typa:getTypePattern_sr($typeRes as element(), 
                                        $compDict as map(*),
                                        $nsmap as element(z:nsMap),
                                        $options as map(*))
        as xs:string {
    let $stypes := $typeRes/content/stype/xs:simpleType
    let $countEmptyStypes := $stypes[not(*/*)] => count()
    let $emptyInfo := 
        $countEmptyStypes[. gt 0] ! ('empty-restrictions('||.||')')
    let $facets := ($stypes/*/*/local-name() => 
                   distinct-values() => sort() => string-join(', '))
                   [string()]
    return ($facets, $emptyInfo) => string-join('; ')
};    

declare function typa:getTypePattern_su($typeRes as element(), 
                                        $compDict as map(*),
                                        $nsmap as element(z:nsMap),
                                        $options as map(*))
        as xs:string {
    '?'
};    

(:~
 : Returns the descriptions of attribute redefinitions.
 :
 : @param typeRes an expanded type descriptor
 : @param base the base name of the type, as a normalized QName string
 : @param compDict component dictionary
 : @param nsmap namespace map
 : @param options options controlling the execution
 : @return descriptor strings, one for each attribute redefinition
:) 
declare function typa:getTypePattern_attRedefinitions(
                                         $typeRes as element(), 
                                         $base as xs:string,
                                         $compDict as map(*),
                                         $nsmap as element(z:nsMap),
                                         $options as map(*))
        as xs:string? {
    let $attSection := $typeRes/content/attributes
    let $restriction := $attSection/restriction[@base eq $base][last()]
    let $pre := $restriction/preceding-sibling::*
    let $currentAtts := $pre/descendant-or-self::*[self::xs:attribute, self::xs:attributeGroup]
    let $attRedefinitions :=
        for $att in $restriction/*
        return
            typeswitch($att)
            case element(xs:attributeGroup) return
                let $previous := 
                    $currentAtts
                    [self::xs:attributeGroup][@ref eq $att/@ref][last()]
                return 'attGroup('||$att/@ref||')'
            case element(xs:attribute) return
                let $previous := 
                    $currentAtts
                    [self::xs:attribute][@name eq $att/@name][last()]
                let $previous :=
                    if ($previous) then $previous else
                    
                    let $attGroups :=
                        for $attGroup in $currentAtts[self::xs:attributeGroup]
                        group by $ref := $attGroup/@ref
                        let $qname := uns:resolveNormalizedQName($ref, $nsmap)
                        return $compDict?agroup($qname)
                    let $atts := $attGroups ! coto:getAttributeGroupDeepContent(., $compDict)
                    let $attMatch := $atts
                                 [uns:normalizeCompName(., $nsmap) ! string() eq $att/@name]
                                 [last()]
                                 ! coto:getNormalizedComp(., $nsmap, $options)
                    return trace($attMatch, 'Previous att version from att group: ')
                let $typeChanged := 
                    let $values := ($previous/@type, $att/@type)
                    return
                        if (count($values) eq 2) then $values[1] ne $values[2]
                        else if (count($values) eq 0) then false()
                        else
                            let $type1 := $previous/xs:simpleType
                            let $type2 := $att/xs:simpleType
                            return
                                if (empty(($type1, $type2)) or 
                                    deep-equal($type1, $type2)) then false()
                                else true()
                let $useChanged :=
                    let $values := ($previous/@use, $att/@use)
                    return
                        if (count($values) eq 0) then false()
                        else if (count($values) eq 1) then
                            if ($values eq 'optional') then false()
                            else true()
                        else $values[1] ne $ values[2]
                let $defaultChanged := 
                    let $values := ($previous/@default, $att/@default)
                    return
                        if (count($values) eq 0) then false()
                        else not($values[1] eq $values[2])
                let $fixedChanged := 
                    let $values := ($previous/@fixed, $att/@fixed)
                    return
                        if (count($values) eq 0) then false()
                        else not($values[1] eq $values[2])
                let $changes := string-join(
                    ('type'[$typeChanged], 'use'[$useChanged], 
                     'default'[$defaultChanged], 'fixed'[$fixedChanged]), ', ')                        
                return
                    '@'||$att/@name||'('||$changes||')'
            default return error()             
    return
        if (empty($attRedefinitions)) then () else
        'redef: '||($attRedefinitions => string-join(', '))
};    

(:~
 : Returns the description of type content redefinition.
 :
 : @param typeRes an expanded type descriptor
 : @param base the base name of the type, as a normalized QName string
 : @param compDict component dictionary
 : @param nsmap namespace map
 : @param options options controlling the execution
 : @return descriptor strings, one for each attribute redefinition
:) 
declare function typa:getTypePattern_contentRedefinition(
                                         $typeRes as element(), 
                                         $base as xs:string,
                                         $compDict as map(*),
                                         $nsmap as element(z:nsMap),
                                         $options as map(*))
        as xs:string? {
    let $elemSection := $typeRes/content/elements
    let $restriction := $elemSection/restriction[@base eq $base][last()]
    where $restriction
    
    let $previousRestriction := $elemSection/restriction[. << $restriction][last()]
    let $previousContent :=
        if (not($previousRestriction)) then $elemSection/*[. << $restriction]
        else ($previousRestriction, $elemSection/*[. >> $previousRestriction][. << $restriction])
    let $previousElems := $previousContent/descendant-or-self::xs:element        
    let $previousGroups := $previousContent/descendant-or-self::xs:group
    let $currentElems := $restriction//xs:element
    let $currentGroups := $restriction//xs:group

    let $currentElemNames := $currentElems/(@name, @ref)
    let $currentGroupNames := $currentGroups/@ref
    
    let $previousElemNames := $previousElems/(@name, @ref)
    let $previousGroupNames := $previousGroups/@ref

    let $elemsRetained := $currentElems[(@name, @ref) = $previousElemNames]
    let $elemsLost := $previousElemNames[not(. = $currentElemNames)]
    let $elemsAdded := $currentElemNames[not(. = $previousElemNames)]
    
    let $groupsRetained := $currentGroups[@ref = $previousGroupNames]
    let $groupsLost := $previousGroupNames[not(. = $currentGroupNames)]    
    let $groupsAdded := $currentGroups[not(@ref = $previousGroupNames)]

    (: "lost" groups must be inspected more closely - perhaps their element content appears? :)
    let $groupsLostDetails :=
        for $gname in $groupsLost
        let $gnameQ := $gname ! uns:resolveNormalizedQName(., $nsmap) 
        let $gdef := $compDict?group($gnameQ)
        let $gelems := $gdef ! coto:getDeepContentElemItems(., $compDict)
        let $gelemNamesUr := $gelems/coto:getComponentQName(.)
        let $gelemNames := $gelems/coto:getNormalizedComponentQName(., $nsmap) ! string()
        let $gelemNamesFound := $gelemNames[. = $currentElemNames]
        return
            if (empty($gelemNamesFound)) then $gname
            else
                for $gelemName in $gelemNames
                return
                    if ($gelemName = $currentElemNames) then '#groupElemRetained='||$gelemName
                    else '#groupElemRemoved='||$gelemName
     
    (: Corrected group losses, taking their element content into account :)
    let $groupsLostCorr := 
        $groupsLostDetails[not(starts-with(., '#'))]
    (: Elements lost which have been contained by a group not referenced any more :)
    let $groupElemsLost := 
        $groupsLostDetails[starts-with(., '#groupElemRemoved')] ! substring-after(., '=')
    let $groupElemsRetained := 
        $groupsLostDetails[starts-with(., '#groupElemRetained')] ! substring-after(., '=')
    
    let $elemsAddedCorr := $elemsAdded[not(. = $groupElemsRetained)]
    let $elemsLostInfo := 
        if (empty($elemsLost)) then () else
            'elem-removals('||($elemsLost => sort() => string-join(', '))||')'
    let $groupElemsLost := 
        if (empty($groupElemsLost)) then () else
            'group-elem-removals('||($groupElemsLost => sort() => string-join(', '))||')'
    let $elemsAddedInfo := 
        if (empty($elemsAddedCorr)) then () else
            'elem-added('||($elemsAddedCorr => sort() => string-join(', '))||')'
    let $groupsLostInfo :=            
        if (empty($groupsLostCorr)) then () else
            'group-removals('||($groupsLostCorr => sort() => string-join(', '))||')'
    (: This information is suppressed, assuming that the group is contained by another group :)
    let $groupsAddedInfo :=            
        if (empty($groupsAdded) or true()) then () else
            'group-added('||($groupsAdded => sort() => string-join(', '))||')'
    return
        ($elemsLostInfo, $elemsAddedInfo, $groupsLostInfo, $groupsAddedInfo) => string-join('; ')
};    
