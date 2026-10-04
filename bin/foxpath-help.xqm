module namespace he="http://www.foxpath.org/ns/help";

import module namespace app="http://www.ttools.org/xquery-functions/util"
at "foxpath-util.xqm";

import module namespace foxf="http://www.foxpath.org/ns/fox-functions" 
at "foxpath-fox-functions.xqm";

import module namespace ta="http://www.parsqube.de/xquery/util/table" 
at "table.xqm";

import module namespace op="http://www.parsqube.de/xquery/util/options"
    at "options.xqm";

declare variable $he:FUNCTIONS_DICT := '../functions/functions.xml'
    ! resolve-uri(.);
(:~
 : Filters a sequence of items against a unified string expression.
 :
 : @param items the items to be filtered
 : @param filter a unified string expression
 : @param options processing options
 : @return true or false
 :)
declare function he:help($request as xs:string,
                        $options as map(*)?)
        as item()* {
    let $dict := $he:FUNCTIONS_DICT ! doc(.)
    let $fn := ($request ! replace(., '^\s*help\s*', '') ! app:glob2regex(.),
                '*')[1] 
    let $functions := $dict//function/@name[matches(., $fn)] 
    let $countFunctions := count($functions)
    return
        if ($countFunctions eq 0) then ('No matching function found.', '')
        else if ($countFunctions gt 1) then ( 
            'Matching functions: ', '', $functions)
        else
        
    let $elem := $functions/..
    let $params := $elem//params/*
    let $options := $elem//options/*
    let $help_summary :=
        let $summary := 
            let $raw := $elem/documentation/summary
            return 
                if (empty($raw)) 
                then ' (under construction) '
                else string($raw)
        return ('SUMMARY:', $summary)
    let $help_params :=
        if (not($params)) then () else
        let $tableOptions := 'w=20.14.14.60 left-align'
        let $tuples := 
            for $param in $params
            let $name := string($param/@name)
            let $type := string($param/@type)
            let $default := ($param/@default, ' (none) ')[1] 
            let $documentation := 
                let $raw := $param/documentation/string()
                let $value := 
                    if (empty($raw)) then '(under construction)' else $raw
                return array{$value}
            return
                foxf:tuple(($name, $type, $default, $documentation))
        let $table := ta:table(
            $tuples, 'NAME, TYPE, DEFAULT, EXPLANATION', (), $tableOptions) 
        return $table
    let $help_options :=
        if (not($options)) then () else
        let $tableOptions := 'w=20.14.14.60 left-align'
        let $tuples := 
            for $option in $options
            let $name := string($option/@name)
            let $type := 
                let $ty := string($option/@type)
                let $values := $option/values/value/@string ! concat('- ', .)
                return
                    if (empty($values)) then $ty
                    else array {$ty, $values}
            let $default := ($option/@default, ' (none) ')[1] 
            let $documentation := 
                let $raw := $option/documentation ! he:editDocumentation(.)
                let $value := 
                    if (empty($raw)) then '(under construction)' else $raw
                return array{$value}
            return
                foxf:tuple(($name, $type, $default, $documentation))
        let $table := ta:table(
            $tuples, 'NAME, TYPE, DEFAULT, EXPLANATION', (), $tableOptions) 
        return $table
    let $uline := 
        (for $i in 1 to (10 + string-length($functions)) return '=')
        => string-join('')        
    return (
        '',
        'Function: '||$functions,
        $uline,
        $help_summary,
        '',
        if (not($help_params)) then () else (
          '    P A R A M S : ',
          $help_params
        ),
        if (not($help_options)) then () else (
          '',        
          '    O P T I O N S: ',
          $help_options
        )
    )
};

declare function he:editDocumentation($do as element(documentation))
    as xs:string* {
    for $child in $do/node() return
    typeswitch($child)
    case text() return string($child)
    case element(br) return '&#xA;'
    default return $child
};    