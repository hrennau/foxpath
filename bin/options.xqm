module namespace op="http://www.parsqube.de/xquery/util/options";

(:~
 : Returns the options encoded by an $options parameter
 : as a map.
 :) 
declare function op:optionsMap($options as item()?, 
                               $model as map(*),
                               $functionName as xs:string)
        as map(*) {
    let $omap := $model?options
    let $vmap := $model?optionValues
    let $onames := map:keys($omap)
    let $vnames := map:keys($vmap)
    let $names := ($onames, $vnames) 
    return if (empty($names)) then map{} else
    
    let $namesWD := 
        for $name in $onames
        let $desc := $omap($name) ?default
        where exists($desc)
        return $name
    return 
        if (empty($namesWD) and (
            $options instance of map(*) or empty($options))) then 
                ($options, map{})[1]
        else
        
    let $mapPrelim :=
        if ($options instance of map(*)) then $options 
        else if (empty($options)) then map{}
        else
        
        let $o := $options ! replace(., '\s*=\s*', '=')        
        let $items := $o ! tokenize(.)
        let $entries :=
            for $item in $items
            let $item :=
                if (not(matches($item, '^\i\c*?\d+$'))) then $item else
                    let $name := 
                        replace($item, '^(\i\c*?)\d+$', '$1')
                        ! op:optionsMap_getSelName(., $names)
                    let $itemName := $item !  op:optionsMap_getSelName(., $names)
                    return 
                        if (not($name) or $itemName) then $item
                        else replace($item, '^(\i\c*?)(\d+)$', '$1=$2')
            let $nameU := $item ! replace(., '=.*', '')
            let $name := op:optionsMap_getSelName($nameU, $names)
            return 
                if (count($name) gt 1) then
                    error(QName((), 'AMBIGUOUS_OPTION'), concat(
                    'Function "', $functionName, '" - abbreviated option ("'||$nameU||'")'||  
                    '; ambiguous; matches: ', ($name => sort() => string-join(', '), '.')))
                else if (count($name) eq 0) then                
                    error(QName((), 'UNKNOWN_OPTION'), concat(
                        'Function "', $functionName, '" - invalid option ("'||$nameU||'")'||  
                        '; valid options: ', ($names => sort() => string-join(', '), '.')))
                    else

            let $omodel := $omap($name)
            let $otype := $omodel?type
            let $ovalues := $omodel?values
            let $opattern := $omodel?pattern
            let $opatternExplanation := $omodel?patternExplanation
            
            let $value := 
                if (not(contains($item, '='))) then () 
                else $item ! replace(., '.*?=', '') ! replace(., '\\s', ' ')
            return 
                if (empty($value)) then
                    if (exists($omodel)) then
                        error(QName((), 'INVALID_OPTION'), 'Option "'||$name||
                            '" must have a value ('||$name||'=...)') 
                    else map:entry($name, true())
                else
                    (: Constraints: type, values :)
                    let $valueE :=
                        if (empty($ovalues) or $value = $ovalues) then $value 
                        else
                            let $selected := op:optionsMap_getSelName($value, $ovalues)
                            return
                                if (count($selected) eq 1) then $selected
                                else if (count($selected) gt 1) then
                                    error(QName((), 'AMBIGUOUS_OPTION_VALUE'), 
                                        'Ambiguous value "'||$value||'" for option "'||
                                        $name||'"; matches: '||
                                        (($selected => sort()) ! xs:string(.) => string-join(', ')))
                                else
                                    error(QName((), 'INVALID_OPTION_VALUE'), 
                                        'Invalid value "'||$value||'" for option "'||
                                        $name||'"; must be one of: '||
                                        (($ovalues => sort()) ! xs:string(.) => string-join(', ')))
                    let $valueET :=
                        if (not($otype)) then $valueE else
                        try {
                            switch($otype)
                            case 'integer' return xs:integer($valueE)
                            case 'decimal' return xs:decimal($valueE)
                            case 'text' return $valueE ! replace(., '\\s', ' ')
                            case 'string' return $valueE ! replace(., '\\s', ' ')
                            default return error(QName((), 'INVALID_MODEL'), 
                                'Invalid model, unknown type: '||$otype)
                        } catch * {
                            error(QName((), 'INVALID_OPTION'),
                                'Invalid value "'||$value||'" for option "'||
                                $name||'"; cannot cast to type "'||$otype||'".')
                        }
                    let $valueETP :=
                        if ($opattern) then
                            let $matches := matches($valueET, $opattern)
                            return
                                if (not($matches)) then
                                    error(QName((), 'INVALID_OPTION'),
                                        'Invalid value "'||$value||'" '||
                                        'for option "'||$name||'". '||
                                        (if (not($opatternExplanation)) then 
                                        'It must match the regular expression "'
                                        ||$opattern||'".'
                                        else ($opatternExplanation ! (' '||.))))
                                else $valueET
                         else $valueET
                    return
                        map:entry($name, $valueETP)
        return map:merge($entries)
    
    (: Finalize map :)
    let $usedNames := map:keys($mapPrelim)
    let $usedNamesV := $usedNames[. = $vnames]
    let $usedNamesO := $usedNames[not(. = $usedNamesV)]
    let $usedNames2 := (
        $usedNamesO,
        $usedNamesV ! $vmap(.)) => distinct-values()
    let $namesMissing := $onames[not(. = $usedNames2)][. = $namesWD]
    (:
    let $_DEBUG := trace($usedNamesV, '_ used names V: ')
    let $_DEBUG := trace($namesWD, '_ names WD: ')
    let $_DEBUG := trace($namesMissing, '_ names missing: ')
    :)
    (: add entries #1: options which have been supplied as values :)
    let $addEntries1 := $usedNamesV ! map:entry($vmap(.), .)
    (: let $_DEBUG := trace($addEntries1, '_ addEntries1: ') :)
    (: add entries #2: options missing, having a default value :)    
    let $addEntries2 := $namesMissing ! map:entry(., $omap(.)('default'))
    (: let $_DEBUG := trace($addEntries2, '_ addEntries2: ') :)
    
    (: Finalize map :)
    let $addEntries := ($addEntries1, $addEntries2)
    let $mapFinal :=
        if (empty($addEntries) and empty($usedNamesV)) then $mapPrelim
        else map:merge((
            $usedNamesO ! map:entry(., $mapPrelim(.)),
            $addEntries
        ))
    return $mapFinal
};        

declare function op:optionsMap_getSelName($name, $names) {
    if ($name = $names) then $name
    else $names[starts-with(., $name)]
};

