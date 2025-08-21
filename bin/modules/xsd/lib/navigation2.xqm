module namespace navi="http://www.parsqube.de/xspy/util/navigation2";
import module namespace coto="http://www.parsqube.de/xspy/util/component-tools"    
    at "component-tools.xqm";
import module namespace const="http://www.parsqube.de/xspy/constants"
    at "constants.xqm";
import module namespace dict="http://www.parsqube.de/xspy/util/dictionaries"
    at "dictionaries.xqm";
import module namespace util="http://www.parsqube.de/xspy/util"
    at "util.xqm";    
import module namespace uns="http://www.parsqube.de/xspy/util/namespace"
    at "util-namespace.xqm";
import module namespace unamef="http://www.parsqube.de/xquery/util/name-filter"
    at "../util/util-nameFilter.xqm";
import module namespace unpath="http://www.parsqube.de/xquery/util/node-path"
    at "../util/util-nodePath.xqm";

declare namespace z="http://www.parsqube.de/xspy/structure";
declare namespace xspy="http://www.parsqube.de/xspy/structure";

declare function navi:getElemPaths($item as element(xs:element)*,
                                   $length as xs:integer?,
                                   $compDict as map(*),
                                   $nsmap as element(z:nsMap),
                                   $options as map(*)?)
        as xs:string* {
    let $noprefix := $options?noprefix        
    let $pathsAll := 
        for $elem in $item
        (:
        return
            if ($elem/parent::xs:schemaXXX) then '/'||$item/coto:getNormalizedComponentQName(., $nsmap)
            else
         :)  
        let $_DEBUG := util:TRACE($elem/coto:getNormalizedComponentQName(., $nsmap) ! string(), 
            '_ get path: ')
        return 
            navi:getElemPathsREC($elem, $length, $compDict, $nsmap, $options, (), ())
    let $pathsAllDVS :=  $pathsAll => distinct-values() => sort()
    return
        if ($noprefix) then $pathsAllDVS ! replace(., '\i\c*:', '')
        else $pathsAllDVS
};

declare function navi:getElemPathsREC(
                                   $item as element(xs:element)*,
                                   $length as xs:integer?,
                                   $compDict as map(*),
                                   $nsmap as element(z:nsMap),
                                   $options as map(*)?,
                                   $stepsSoFar as xs:QName*,
                                   $visitedSoFar as element()*)                                   
        as xs:string* {
    (: let $_DEBUG := trace($item/unpath:nodePath(., ()), '_ get pathREC for elem: path= ') :)        
    let $thisStep := $item/coto:getNormalizedComponentQName(., $nsmap)
    let $steps := ($thisStep, $stepsSoFar)
    return
        if ($item intersect $visitedSoFar) then
            let $steps := (QName($const:URI_XSPY, '_CYCLE_'), $steps)
            return $steps => navi:stepsToPath($nsmap, ())
        else if (count($steps) ge $length) then
            $steps => navi:stepsToPath($nsmap, ()) 
        else 
        
    let $isGlobal := exists($item/parent::xs:schema)
    let $refs := (
        if (not($isGlobal)) then () else
        
        let $sgheads := $item/navi:getSubstitutionGroups(., $compDict, $nsmap, $options)
        let $_DEBUG := 
            let $elemName := $item/coto:getNormalizedComponentQName(., $nsmap)
            let $countSgheads := count($sgheads)
            let $sgheadNames := $sgheads/coto:getNormalizedComponentQName(., $nsmap) ! string() => string-join(', ')
            let $msg := '_ elem: '||$elemName||' - #sgheads: '||$countSgheads||
                        ('; sgnames: '||$sgheadNames)[$sgheadNames]
            return util:TRACE($msg)
                
        for $elemWSG in ($item, $sgheads)/.
        let $elemName := $elemWSG/coto:getNormalizedComponentQName(., $nsmap)
        return navi:getElementRefs($elemName, $compDict, $options))/.
        
    let $_DEBUG := 
        if (empty($refs)) then () else 
        let $countRefs := count($refs)
        let $refNames := $refs/@ref/coto:getNormalizedAttQName(., $nsmap) ! string() 
                   => sort() => string-join(', ')
        return util:TRACE('_ '||$countRefs||' refs: '||$refNames)

    return
        if ($isGlobal and empty($refs)) then    
            $steps => navi:stepsToPath($nsmap, true())
        else
        
    let $visited := ($item, $visitedSoFar)
    let $nextItems := if ($refs) then $refs else $item
    
    for $nextItem in $nextItems
    let $parentElems := navi:getParentElems($nextItem, $compDict, $nsmap, $options)
    for $parentElem in $parentElems
    return $parentElem !
        navi:getElemPathsREC(., $length, $compDict, $nsmap, $options, $steps, $visited)
};

declare function navi:getParentElems($elem as element(xs:element),
                                     $compDict,
                                     $nsmap, 
                                     $options)
        as element(xs:element)* {
    let $_DEBUG := util:TRACE($elem/(@name, @ref), '_ get parent: ')

    let $elems0 := (        
        let $ancElem := $elem/ancestor::xs:element[1]
        return if ($ancElem) then 
            let $_DEBUG := util:TRACE($ancElem/@name, '_ containing element: ')
            return $ancElem 
        else
        
        let $typeName := $elem/ancestor::xs:complexType[@name]/
            coto:getNormalizedComponentQName(., $nsmap)
        return if (exists($typeName)) then
            let $_DEBUG := util:TRACE($typeName, '_ containing type name: ') return        
            navi:getElementsUsingType($typeName, $compDict, $nsmap, $options)[not(@ref)]
        else  
            
        let $groupName := $elem/ancestor::xs:group[@name]/
            coto:getNormalizedComponentQName(., $nsmap)
        return if (exists($groupName)) then
            let $_DEBUG := util:TRACE($groupName, '_ containing group name: ') return        
            let $typeDefs := 
                navi:getTypesUsingGroup($groupName, $compDict, $nsmap, $options)
            let $_DEBUG := for $typeDef in $typeDefs return (
                $typeDef/@name/util:TRACE(., '_ group using type: '),
                $typeDef/../@name/util:TRACE(., '_ group using local type in elem: '))
            return $typeDefs/navi:getElementsUsingTypeDef(., $compDict, $nsmap, $options)[not(@ref)]
        else 
            
        if ($elem/parent::xs:schema) then 
            let $_DEBUG := util:TRACE('_ elem ist top level element!') return
            $elem
        
        else  
            error((), 'Top-level component '||
                $elem/ancestor-or-self::*[parent::xs:schema]/name()||', name: '||$elem/@name)
    )/.
    
    let $_DEBUG := (
        let $countElem := count($elems0)
        let $names := (for $e in $elems0 return
            coto:getNormalizedComponentQName($e, $nsmap) !
            concat(xs:string(), if ($e/parent::xs:schema) then ' (G)' else ' (L)'))
            => string-join(', ')
        let $msg := ('_ count parent elems: '||$countElem||' ; names='||$names)       
        return util:TRACE($msg), ()
        (: $elems0 ! base-uri(.) ! trace(., '_ base uri: ') :)
    )        
     
    (:
    let $elems := (
        for $elem in $elems0[not(@ref)]
        return
            if ($elem/parent::xs:schema) then                
                let $sgheads := $elem/navi:getSubstitutionGroups(., $compDict, $nsmap, $options)
                let $_DEBUG := 
                    let $elemName := $elem/coto:getNormalizedComponentQName(., $nsmap)
                    let $countSgheads := count($sgheads)
                    let $sgheadNames := $sgheads/coto:getNormalizedComponentQName(., $nsmap) ! string() => string-join(', ')
                    let $msg := '_ elem: '||$elemName||' - #sgheads: '||$countSgheads||
                        ('; sgnames: '||$sgheadNames)[$sgheadNames]
                    return util:TRACE($msg)
                
                let $refs := (
                    for $elemWSG in ($elem, $sgheads)/.
                    let $elemName := $elemWSG/coto:getNormalizedComponentQName(., $nsmap)
                    return navi:getElementRefs($elemName, $compDict, $options))/.
                let $_DEBUG := 
                    if (empty($refs)) then () else 
                    let $refNames := $refs/@ref/coto:getNormalizedAttQName(., $nsmap) ! string() 
                        => sort() => string-join(', ')
                    return util:TRACE('_ refs: '||$refNames)
                return if ($refs) then $refs else $elem
            else $elem
        )/.
    
    let $_DEBUG :=
        let $count := count($elems)
        let $names := (
            for $elem in $elems
            let $suffix := '(ref)'[$elem/@ref]
            let $name := $elem/coto:getNormalizedComponentQName(., $nsmap) ! string()
            order by $name
            return $name||$suffix
            ) => string-join(', ')
        let $msg := $count||' parents found: '||$names
        return util:TRACE($msg)        
    :)
    return $elems0
};  

declare  function navi:getElementRefs($name as xs:QName,
                                      $compDict as map(*),
                                      $options as map(*)?)
        as element(xs:element)* {
    if (exists($options?elemRefDict)) then $options?elemRefDict($name) else
    let $_DEBUG := util:TRACE('Not use elem ref dict') return    
    (
        $compDict?group?*  //xs:element[@ref/resolve-QName(., ..) eq $name],
        $compDict?element?*//xs:element[@ref/resolve-QName(., ..) eq $name],
        $compDict?type?*   //xs:element[@ref/resolve-QName(., ..) eq $name]
    )
};        

(:~
 : Returns element declarations using a type definition.
 :)
declare function navi:getElementsUsingTypeDef(
                                           $typeDef as element(),
                                           $compDict as map(*),
                                           $nsmap as element(z:nsMap),
                                           $options as map(*)?)
        as element()* {
    let $typeName := $typeDef[@name]/coto:getNormalizedComponentQName(., $nsmap)        
    return
        if (exists($typeName)) then 
            navi:getElementsUsingType($typeName, $compDict, $nsmap, $options)
        else $typeDef/parent::xs:element
};

(:~
 : Returns element declarations using a type with a given name.
 :)
declare function navi:getElementsUsingType($name as xs:QName,
                                           $compDict as map(*),
                                           $nsmap as element(z:nsMap),
                                           $options as map(*)?)
        as element()* {
    let $inheritanceTree :=
        if (exists($options?inheritanceTree)) then $options?inheritanceTree
        else dict:compDict_inheritanceTree($compDict, $nsmap)
    let $name := $name ! uns:normalizeQName(., $nsmap)        
    let $derivedTypeNames := 
        let $nameS := string($name)
        return 
            $inheritanceTree//*[@name eq $nameS]//*/@name !
            uns:resolveNormalizedQName(., $nsmap)
    
    let $_DEBUG := if (local-name-from-QName($name) = (
                          'DeadRun_VersionStructure', 
                          'Assignment_VersionStructure_')) then (
                       util:TRACE(string($name), '_ type name: '),
                       util:TRACE($derivedTypeNames, '_ derived type names: '))
                   else ()
    return
    if (exists($options?elemTypeDict)) then (
        let $elemTypeDict := $options?elemTypeDict
        for $typeName in ($name, $derivedTypeNames)
        return
            $elemTypeDict($typeName)
        )/.
    else
    let $_DEBUG := util:TRACE('Not use elem type dict') return        
    (
        $compDict?element?*/descendant-or-self::xs:element,
        $compDict?type?*   /descendant::xs:element,
        $compDict?group?*  /descendant::xs:element
    )
    [coto:getElemTypeOrBaseAttNormalized(., $compDict, $nsmap) = ($name, $derivedTypeNames)]
};  

(:~
 : Returns type definitions using a group with a given name.
 :)
declare function navi:getTypesUsingGroup($name as xs:QName,
                                         $compDict as map(*),
                                         $nsmap as element(z:nsMap),
                                         $options as map(*)?)
        as element()* {
    let $typesUsingGroupDict :=
        let $fromOptions := $options?typesUsingGroupDict
        return
            if (exists($fromOptions)) then $fromOptions
            else 
                let $groupRefDict := dict:getGroupRefDict($compDict, $nsmap)
                return dict:getTypesUsingGroupDict($compDict, $groupRefDict, $nsmap)
    return $typesUsingGroupDict($name)
};

declare function navi:stepsToPath($steps as xs:QName+, 
                                  $nsmap as element(z:nsMap),
                                  $isAbsolute as xs:boolean?)
        as xs:string {
    '/'[$isAbsolute]||(        
    $steps ! uns:normalizeQName(., $nsmap) ! string() 
    => string-join('/'))        
};  

(:~
 : Returns the substitution group head elements which may be
 : replaced by the given element.
 :)
declare function navi:getSubstitutionGroups($elem as element(), 
                                            $compDict as map(*),
                                            $nsmap as element(z:nsMap),
                                            $options as map(*))
        as element(xs:element)* {
    if (not($elem/self::xs:element/parent::xs:schema)) then () else
    
    if (exists($options?sgroupDict)) then 
        let $sgroups := $elem/coto:getNormalizedComponentQName(., $nsmap) ! $options?sgroupDict(.)
        for $sgroup in $sgroups return $compDict('element')($sgroup)                             
    else        
        
    let $sgroupHead := $elem/coto:getElemDecl(., $compDict)/@substitutionGroup/resolve-QName(., ..)
    let $sgroupHeadElem := $sgroupHead ! $compDict('element')(.)
    (:
    let $_DEBUG := 
        if (empty($sgroupHead)) then () else (
        trace('### Elem: '||coto:getNormalizedComponentQName($elem, $nsmap)||
              ' - sgroup: '||$sgroupHead||' - '||count($sgroupHeadElem)))
     :)             
    return (
        $sgroupHeadElem,
        $sgroupHeadElem[@substitutionGroup] ! 
        navi:getSubstitutionGroups(., $compDict, $nsmap, $options)
    )
};