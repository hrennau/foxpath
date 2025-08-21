(:~
nameFilter.xqm - utility functions for name filtering
:)

(: ============================================================================== :)

module namespace unamef="http://www.parsqube.de/xquery/util/name-filter/impl";
import module namespace unfparse="http://www.parsqube.de/xquery/util/name-filter-parser/impl"
    at "util-nameFilterParser.xqm";

(: 
=================================================================

   p u b l i c    f u n c t i o s
   
=================================================================
:)

(:~
 : Reports whether a name matches a name filter.
 :
 : @params name the name to be checked
 : @param filter a name filter string
 : @return true if the name matches the filter, or the filter is empty, 
 :   false otherwise
 :)
declare function unamef:matchesNameFilter(
                        $name as xs:string?, 
                        $filter as xs:string?)
        as xs:boolean {
    let $filterP := unfparse:parseNameFilter($filter)
    return unamef:matchesNameFilterObject($name, $filterP)
};        

(:~
 : Reports whether a name matches at least one of a set of name filters.
 :
 : @params name the name to be checked
 : @param filters a set of name filters
 : @return true if the name matches at least one of the name filters, 
 :   or no filters are supplied, false otherwise
 :)
declare function unamef:matchesNameFilters(
                        $name as xs:string?, 
                        $filters as xs:string*)
        as xs:boolean {
    let $filtersP := $filters ! unfparse:parseNameFilter(.)
    return unamef:matchesNameFilterObjects($name, $filtersP)
};        

(:~
 : Reports whether a name matches a name filter. The name filter
 : was previously obtained by passing a whitespace separated list
 : of name patterns to function 'writeNameFilter'.
 :
 : @params name the name to be checked
 : @param filter the filter against which to check
 : @return true if the name matches the filter, or the filter is empty, false otherwise
 :)
declare function unamef:matchesNameFilterObject(
                        $name as xs:string?, 
                        $filter as element(nameFilter)?)
      as xs:boolean? {
    if (empty($name)) then () else      
    if (empty($filter)) then true() else

      (empty($filter/filterPos/filter) or 
          (some $f in $filter/filterPos/filter satisfies 
              matches($name, string($f/@pattern), string($f/@options)))) 
       and
      (every $f in $filter/filterNeg/filter satisfies 
          not(matches($name, string($f/@pattern), string($f/@options)))) 
};

(:~
 : Reports whether a name matches at least one of a series of name filters.
 :
 : @params name the name to be checked
 : @param filters the filters against which to check 
 : @return true if the name matches at least one filter or there is not filter, false otherwise
 :)
declare function unamef:matchesNameFilterObjects(
                        $name as xs:string?, 
                        $filters as element(nameFilter)*)
      as xs:boolean? {
    if (empty($name)) then () else      
    if (empty($filters)) then true() else
    some $filter in $filters satisfies unamef:matchesNameFilterObject($name, $filter) 
};

(:~
 : Checks if a sequence of names contains at least one name
 : matching a name filter. More precisely, returns true if 
 : there is at least one name which is not removed by the filter.
 :
 : Note. This implies that the function returns false
 : if the sequence of names is empty, and the function
 : returns true if there are names but there is no
 : name filter.
 :
 : @params names the names to be checked
 : @return true if there is at least one name not removed
 :    by the filter
 :)
declare function unamef:someNameMatchesNameFilterObject(
                        $names as xs:string*, 
                        $filter as element(nameFilter)?)
      as xs:boolean {
   if (empty($names)) then false()
   else if (empty($filter)) then true() else
      some $name in $names satisfies unamef:matchesNameFilterObject($name, $filter)
};

(:~
 : Filters a sequence of names by a name filter. The name filter
 : was previously obtained by passing a whitespace separated list
 : of name patterns to function 'writeNameFilter'.
 :
 : @params names the names to be filtered
 : @return the filtered names
 :)
declare function unamef:filterNames(
                        $names as xs:string*, 
                        $filter as element(nameFilter)?)
        as xs:string* {
   if (empty($filter)) then $names else
   $names
      [empty($filter/filterPos/filter) or 
        (some $f in $filter/filterPos/filter satisfies 
            matches(., string($f/@pattern), string($f/@options)))]
      [every $f in $filter/filterNeg/filter satisfies 
        not(matches(., string($f/@pattern), string($f/@options)))] 
};

(:~
 : Retrieves the value associated with a name according to
 : a name filter map. The name filter map can optionally specify 
 : a value type. If a value type is specified, the value returned
 : by this function is typed correspondingly.
 :
 : @DO_IT: Currently only these types are supported:
 :    xs:boolean xs:int xs:integer xs:long xs:string 
 :
 : @param name the name with which the value is associated
 : @param nameFilterMap a name filter map which associates values
 :    with name patterns
 : @param defaultValue an optional default value
 : @return the value associated with the name
 :)
declare function unamef:nameFilterMapValue(
                                      $name as xs:string, 
                                      $nameFilterMap as element(nameFilterMap)?, 
                                      $defaultValue as xs:anyAtomicType?)
        as xs:anyAtomicType? {
    if (not($nameFilterMap)) then $defaultValue else
    
    let $value := $nameFilterMap/entry[nameFilter][unamef:matchesNameFilter($name, nameFilter)][1]/@value         
    let $value :=
        if (exists($value)) then $value else
            let $value := $nameFilterMap/entry[not(*)][1]/@value
            return
                if (exists($value)) then $value else $defaultValue
    return
        if (not($value)) then () else
            let $valueType := $nameFilterMap/@valueType/string()
            return
                if (not($valueType)) then $value else
                    if ($valueType eq 'xs:boolean') then xs:boolean($value)
                    else if ($valueType eq 'xs:int') then xs:int($value)                    
                    else if ($valueType eq 'xs:integer') then xs:integer($value)                    
                    else if ($valueType eq 'xs:long') then xs:long($value)                    
                    else if ($valueType eq 'xs:string') then xs:string($value)                    
                    else $value
};
