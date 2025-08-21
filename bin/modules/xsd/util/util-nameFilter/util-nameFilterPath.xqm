(:~
nameFilterPath.xqm - utility functions for path filtering
:)

(: ============================================================================== :)

module namespace upathf="http://www.parsqube.de/xquery/util/name-filter-path/impl";
import module namespace unamef="http://www.parsqube.de/xquery/util/name-filter/impl"
    at "util-nameFilter.xqm";
import module namespace unfparse="http://www.parsqube.de/xquery/util/name-filter-parser/impl"
    at "util-nameFilterParser.xqm";
(: 
=================================================================

   p u b l i c    f u n c t i o s
   
=================================================================
:)

(:~
 : Checks whether a path matches a path filter.
 :
 : @param path the path to be checked
 : @param filter a path filter string
 : @return true if the path matches the filter, or the filter is empty, 
 :   false otherwise
 :)
declare function upathf:matchesPathFilter(
                        $path as xs:string?, 
                        $filter as xs:string?)
        as xs:boolean {
    unfparse:parsePathFilter($filter)
    ! upathf:matchesPathFilterObject($path, .)
};        


(:~
 : Checks whether a path matches a path filter.
 :
 : @param path the path to be checked
 : @param pathFilter the path filter against which to check
 : @return true if the path matches the filter, or the filter is empty, 
 :   false otherwise
 :)
declare function upathf:matchesPathFilterObject(
                    $path as xs:string?,
                    $pathFilter as element(pathFilter)?)
        as xs:boolean? {
    if (not($path)) then () else
    
    let $pos := $pathFilter/pathFilterPos/nameFilterPath
    let $neg := $pathFilter/pathFilterNeg/nameFilterPath
    
    let $posResult := if (not($pos)) then true() else
        some $f in $pos satisfies upathf:_matchesNameFilterPath($path, $f)            
    return
        if (not($posResult)) then false() 
        else if (not($neg)) then true() 
        else 
            some $f in $neg satisfies upathf:_matchesNameFilterPath($path, $f)
};

(: 
=================================================================

   p r i v a t e    f u n c t i o s
   
=================================================================
:)

(:~
 : Informs whether a given path matches a name filter path. Note that a
 : path filter is composed of one or more name filter paths, used as
 : positive or negative filters.
 :) 
declare %private function upathf:_matchesNameFilterPath(
                          $path as xs:string, 
                          $filterPath as element(nameFilterPath))
        as xs:boolean {
    let $root := $filterPath/@root
    return
        if ($root and not(matches($path, '^'||$root, 'i'))) then false() 
        else
        
    let $path2 := 
        if (not($root)) then $path else 
            substring($path, 1 + string-length($root))
    let $steps := $filterPath/nameFilter
    return upathf:matchesFilterPathREC($path2, $steps)
};        

(:~
 : Recursive helper function of 'matchesFilterPath'.
 :
 : @param context paths to be matched against the 
 :   remaining filter steps
 : @param step remaining filter steps
 : @return true if matches, otherwise false or empty sequence
 :)
declare function upathf:matchesFilterPathREC(
                        $context as xs:string+,
                        $steps as element(nameFilter)+)
        as xs:boolean? {
    let $head := $steps => head()
    let $tail := $steps => tail()
    (:
    let $_DEBUG := trace($context, '_CONTEXT: ')
    let $_DEBUG := trace($head, '_HEAD: ')
    :)
    return
        if (empty($tail)) then 
            let $relevantSteps :=
                if ($head/@sep eq '//') then 
                    $context ! replace(., '.*/', '') (: final path steps :)
                else 
                    $context[not(contains(., '/'))] (: single step paths :)
            return
                exists($relevantSteps
                    [unamef:matchesNameFilterObject(., $head)])
        else if ($head/@sep eq '//') then
            exists(
                $context
                ! upathf:getSubPathsAfterMatchingSteps(., $head)
                [upathf:matchesFilterPathREC(., $tail)])
        else
            exists(
                $context ! upathf:step1Etc(.)[?etc]
                [unamef:matchesNameFilterObject(?step1, $head)]
                ! upathf:matchesFilterPathREC(?etc, $tail)[.])
};

(:~
 : Splits a path into first step and the remaining path following it.
 :
 : @param path a path string
 : @return a map with entries 'step1' and 'etc'.
 :)
declare %private function upathf:step1Etc($path as xs:string)
        as map(xs:string, xs:string?) {
    let $step1 := replace($path, '^(.*?)/.*', '$1')        
    let $etc :=
        if ($step1 eq $path) then () else 
            substring($path, 1 + string-length($step1))
            ! replace(., '^\s*/\s*', '')
    return map{'step1': $step1, 'etc': $etc}
};        

(:~
 : Returns all trailing parts of a path which follow a step
 : matching a filter.
 :
 : @param path a path
 : @param a filter
 : @return trailing parts of the path which follow a matching step
 :)
declare %private function upathf:getSubPathsAfterMatchingSteps(
                                 $path as xs:string, 
                                 $filter as element())
        as xs:string* {
    let $steps := $path ! tokenize(., '\s*/\s*')
    let $countSteps := count($steps)
    return
        for $step at $pos in $steps[position() lt last()]
        where unamef:matchesNameFilterObject($step, $filter)
        return subsequence($steps, $pos + 1) => string-join('/')
};
