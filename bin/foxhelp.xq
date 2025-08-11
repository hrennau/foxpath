declare namespace foxh="http://www.foxpath.org/ns/fox-help";

import module namespace foxf="http://www.foxpath.org/ns/fox-functions" 
at "foxpath-fox-functions.xqm";

import module namespace use="http://www.foxpath.org/ns/unified-string-expression" 
at  "foxpath-unified-string-expression.xqm";

declare variable $op external;
declare variable $filter external := ();
declare variable $functionsUri := '../functions/functions.xml'
    ! resolve-uri(.);
    
declare variable $fdict := $functionsUri ! doc(.);

declare function foxh:help($op as xs:string, 
                           $filter as xs:string?,
                           $fdict as node())
        as item()* {
    let $filterC := $filter ! use:compileUSE(., true())
    return
    
    switch($op)
    case 'efunctions' return
        let $descriptors :=
            for $f in $fdict//function
            let $name := $f/@name/string()
            let $ec := if ($f/@withEc) then '-ec' else ' - '
            return (
                <function name="{$f/@name}" group="{$f/@group}" ec="{$ec}">{
                  $f/documentation/summary/normalize-space()}</function>,
                for $alias in $f/@alias/tokenize(.) return
                    <function name="{$alias}" group="{$f/@group}" ec="{$ec}">{
                      '(Alias of: '||$f/@name||')'}</function>
            )
        let $filtered :=
            for $d in $descriptors
            where empty($filterC) or $filterC ! use:matchesUSE($d/@name,.)            
            order by $d/@name
            return $d
        let $tuples :=
            for $d in $filtered
            return foxf:tuple(($d/@name, $d/@ec, $d/@group, $d/string()))
        let $countAll := count($descriptors[not(starts-with(., '(Alias'))])            
        let $count := count($filtered[not(starts-with(., '(Alias'))])
        return (
            '# Functions: '||$count||'/'||$countAll,
            '',
            foxf:table($tuples, 'Name, -ec, Group, Summary', ()))
    default return error()
};        

foxh:help($op, $filter, $fdict)
