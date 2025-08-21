module namespace unfparse="http://www.parsqube.de/xquery/util/name-filter-parser/impl";
import module namespace rgx="http://www.parsqube.de/xquery/util/regex" 
  at "../util-regex.xqm";

declare namespace z="http://www.parsqube.de/xquery/util/error";

(: 
=================================================================

   p u b l i c    f u n c t i o s
   
=================================================================
:)

(:~
 : Parses a name filter text into a structured represenation.
 :
 : A name filter is a list of positive and/or negative filters.
 : A name matches the filter if:
 : - none of the negative filters is passed
 : - there are no positive filters, or at least one of them is passed
 :
 : Name pattern syntax: 
 :    name filter = whitespace separated list of filter items
 :    filter-item = positive-item or negative-item
 :    positive-item = pattern | pattern#options
 :    pattern = a match string which is by default interpreted as 
 :       using glob syntax ('?' and '*' respectively match exactly 
 :       one or any number of unspecified characters) and by default 
 :       interpreted as case insensitive
 :    options = c | r 
 :        r - match string is a regular expression, not a glob syntax string
 :        c - match string is case sensitive 
 :    negative-item = ~pattern | ~pattern#options
 :  
 :    Example:
 :    '[A-Z]{3}#rc a\d+#r msg* *RQ#c ~*test*
 :    =>
 :    matches
 :    * must not contain the string 'test' (case insensitive)
 :    * must satisfy one of the following:
 :      - match the regex [A-Z]{3} (case sensitive) 
 :      - match the regex a\d+ (case insensitive) 
 :      - start with 'msg' (case insensitive)
 :      - end with 'RQ' (case sensitive)
 :
 : @param names the name filter text, syntax as described above
 : @return a 'nameFilter' element which is a structured representation 
 :    of the name filter
 :)
declare function unfparse:parseNameFilter($text as xs:string?)
        as element()? {
    if (not($text)) then () else 
   
    let $filter := unfparse:_parseNameFilter($text, ())
    let $errors := $filter/descendant-or-self::z:error    
    return
        if (not($errors)) then $filter else
            <z:errors source="{$text}">{$errors}</z:errors>    
};

(:~
 : Parses the text of a path filter. A path filter consists of
 : one or several path filter items. A path filter item is a list 
 : of one or several namefilters, separated by '/' or '//'. A
 : positive path filter item is delimited by ( and ), a negative
 : path filter item is delimited by ~( and ). If the path filter
 : consists of a single, positive path filter item, the delimiting
 : ( and ) can be omitted. Examples:
 : 
 : Single path filter item:
 :    screening.xsd
 :        => last step is 'screening.xsd'
 :    screening*
 :        => last step starts with 'screening'
 :    screening//*
 :        => some 'screening' ancestor
 :    screening sar//* 
 :        => some 'screening' or 'sar' ancestor
 :    3.2.1/*
 :        => a '3.2.1' parent
 :    3.2.1/* ~deprecated*
 :        => a '3.2.1' parent, and last step must not start with 'deprecated'
 :    3.2.1/d* ~deprecated*
 :        => a '3.2.1' parent, and last step must start with 'd' but must not start with 'deprecated'
 :    ~(2007*/*/*)
 :        => no grand-parent starting with '2007'
 :    ~(2007*/gmd*/*)
 :        => no grand-parent starting with '2007' and no parent starting with 'gmd'
 :
 : Multiple path filter items:
 :    (external//*) (*nga*)
 :        => some 'external' ancestor, or last step containin 'nga'
 :    (domains//*) ~(2.1//*)
 :        => some 'domains' ancestor, but no '2.1' ancestor
 :
 : Several path filter items:
 :    (ogc//*) ~(x*) ~(2007*//*)
 :        => positive: ogc//*; negative(1): last step starting with 'x'; negative(2): an ancestor starting with '2007'
 :
 : @param text the text to be parsed
 : @return a structured representation of the path filter.
 :)
declare function unfparse:parsePathFilter($text as xs:string)
        as item()? {
    if (not($text)) then () else
    
    let $text := replace($text, '^\s+|\s+$', '')
    let $parts := 
        (: special case: if the path filter consists of a single name filter path item,
           the surrounding parentheses may be omitted; this case is recognized by:
           (a) text does not start with ( or ~(; (b) text contains '/';
           example: (a* b* / c* d*) is equivalent to: a* b* / c* d*  
        :)
        unfparse:_parseNameFilterPath($text) (: => 'nameFilterPath' :)
        (:
        if (not(matches($text, '^\s*~?\s*\('))) then        
            if (not(contains($text, '/'))) then 
                unfparse:parseNameFilter($text)      (: => 'nameFilter' :)
            else
                unfparse:_parseNameFilterPath($text) (: => 'nameFilterPath' :)
        else    
            unfparse:_parsePathFilterRC($text)
        :)
    let $errors := $parts/descendant-or-self::z:error    
    return    
        if ($errors) then
            <z:errors source="{$text}">{$errors}</z:errors>    
        else        
            <pathFilter source="{$text}">{
                if (count($parts) eq 1 and 
                    $parts/self::nameFilter and 
                    not($parts/@negative eq 'true')) then $parts else
            
                let $pos := $parts[not(@negative eq 'true')]
                let $neg := $parts[@negative eq 'true']
                return (
                    if (not($pos)) then () else <pathFilterPos>{$pos}</pathFilterPos>,
                    if (not($neg)) then () else <pathFilterNeg>{$neg}</pathFilterNeg>
                )
            }</pathFilter>
};

(:~
 : Parses the text of a name filter map into a structured represenation.
 :
 : This function variant is called without specifying the name filter
 : map type. It delegates the processing to the function variant which has 
 : an optional second parameter specifying the name filter map type.
 : Note that the name filter map type may specify a value type, as
 : for example in nameFilterMap(xs:integer).
 :
 : @param source the source text
 : @return the name filter map element
 :) 
declare function unfparse:parseNameFilterMap($source as xs:string?)
        as element()? {
    if (not($source)) then () else unfparse:parseNameFilterMap($source, ())
};    

(:~
 : Parses the text of a name filter map into a structured represenation.
 :
 : A name filter map associates values with name filters. Given a name, 
 : the function "nameFilterMapValue" returns the first value associated 
 : with a name filter which the name matches.
 :
 : @param source the source text
 : @param type the name filter map type, which may optionally specify 
 :    a value type (as in nameFilterMap(xs:integer))
 : @return the name filter map element
 :) 
declare function unfparse:parseNameFilterMap($source as xs:string?, 
                                             $type as xs:string?)
        as element()? {
    if (not($source)) then () else

    let $valueType := 
        if (not($type) or not(matches($type, '^nameFilterMap\(.*\)$'))) then ()
        else
            let $valueTypeName := replace($type, '^nameFilterMap\((.*)\)$', '$1')
            return
                if (not($valueTypeName =
                    tokenize('xs:boolean xs:int xs:integer xs:long xs:string', '\s+'))) then
                        <z:error type="TYPE_ERROR" source="{$source}" typeName="{$type}"
                           valueType="{$valueTypeName}" 
                           msg="{concat('Unknown (or not yet supported) name filter map value type: ', 
                                 $valueTypeName)}"/>
                else
                    $valueTypeName
    return
        if ($valueType instance of element(z:error)) then <z:errors>{$valueType}</z:errors> else
        
    let $items := tokenize($source, '%\s*')
    let $mapEntries :=    
        for $item in $items
        return
            if (not(contains($item, ':'))) then <entry value="{$item}"/>
            else
                let $value := replace($item, '\s+|\s*:.*', '')
                let $patterns := replace($item, '.*:\s*', '')
                let $filter := unfparse:parseNameFilter($patterns)
                let $error :=
                    if (not($valueType)) then () 
                    else if ($valueType eq 'xs:boolean' and not($value castable as xs:boolean)) then true()
                    else if ($valueType eq 'xs:int' and not($value castable as xs:int)) then true()                    
                    else if ($valueType eq 'xs:integer' and not($value castable as xs:integer)) then true()                    
                    else if ($valueType eq 'xs:long' and not($value castable as xs:long)) then true()                    
                    else if ($valueType eq 'xs:string' and not($value castable as xs:string)) then true()
                    else ()           
                return
                    if ($error) then                   
                        <z:error type="TYPE_ERROR" source="{$source}" typeName="{$type}"
                           valueType="{$valueType}" 
                           msg="{concat('Value ''', $value, ''' not castable to value type: ', 
                                 $valueType)}"/>                                 
                    else                           
                        <entry value="{$value}">{$filter}</entry>
                     

    let $defaultEntries := $mapEntries[not(*)]
    let $errors := $mapEntries/self::z:error
    return
        if ($mapEntries/self::z:error) then <z:errors>{$errors}</z:errors>
        else
            <nameFilterMap>{
                if (not($valueType)) then () else attribute valueType {$valueType},
                $mapEntries except $defaultEntries,
                $defaultEntries[1]
            }</nameFilterMap>
};


(: 
=================================================================

   p r i v a t e    f u n c t i o s
   
=================================================================
:)

(:
 :    p a r s i n g    n a m e    f i l t e r s
 :) 
(:~
 : Helper function of function 'parseNameFilter'.
 :
 :)
declare function unfparse:_parseNameFilter($text as xs:string?, $atts as attribute()*)
        as element(nameFilter)? {
    let $txt := normalize-space($text)
    let $patternList := tokenize($txt, ' ')
    let $patternsPlus := $patternList[not(starts-with(., '~'))]   
    let $patternsMinus := for $n in $patternList[starts-with(., '~')] return substring($n, 2)
    return
        <nameFilter text="{$txt}">{
            $atts,
            let $filterPos := for $p in $patternsPlus return unfparse:_parseNameFilterItem($p, ())
            let $filterNeg := for $p in $patternsMinus return unfparse:_parseNameFilterItem($p, ())
            return (
                if (not($filterPos)) then () else <filterPos>{$filterPos}</filterPos>,
                if (not($filterNeg)) then () else <filterNeg>{$filterNeg}</filterNeg>
            )                
        }</nameFilter>
};

(:~
 : Parses a name filter item and constructs a 'filter' element capturing the 
 : results. 
 :
 : @param s the item text
 : @param atts attributes to be attached to the result element
 : @return a 'filter' element which is a structured representation of the item
 :)
declare function unfparse:_parseNameFilterItem($s as xs:string, $atts as attribute()*)
        as element(filter) {
    let $isRegex := contains(substring-after($s, '#'), 'r')         
    let $options :=        
        let $raw := replace(substring-after($s, '#'), 'r', '') return
            if (contains($raw, 'c')) then replace($raw, 'c', '') else concat('i', $raw)
    let $patternRaw := replace($s, '#.*', '')
    let $regex := if ($isRegex) then $patternRaw else rgx:globToRegex($s, ())
    return
        <filter pattern="{$regex}" options="{$options}">{$atts}</filter>
};

(:
 :    p a r s i n g    p a t h    f i l t e r s
 :)
(:~
 : Parses the text of a name filter path. A name filter path
 : is either a single name filter or a sequence of name filters
 : separated by '/' or '//'. Examples:
 :    a*
 :    ~*b
 :    a* ~*b / ~c* d* 
 :    a*//b*/c* ddd 
 :
 : @param text the text to be parsed
 : @return a structured representation of the path filter item,
 :    followed by the substring which follows after the parsed
 :    text and remains to be parsed.
 :)
declare %private function unfparse:_parseNameFilterPath($text as xs:string)
        as item()* {
    unfparse:_parseNameFilterPath($text, ())        
};

(:~
 : Parses a name filter path, which is either a single name filter
 : (e.g. "a* ~*b") or a name filter path (e.g. a* ~*b / c*). The 
 : parsed item is either a 'nameFilterPath' element or a 'nameFilter' 
 : element, dependent on whether the name filter path contains slashes.
 : Note that a path filter item is a name filter path.
 :
 : @param text the text to be parsed
 : @param atts attributes to be attached to the 'nameFilterPath' or
 :    'nameFilter' element constructed
 : @return the parsed name filter path, followed by the substring which follows 
 :    after the parsed text and remains to be parsed.
 :)
declare %private function unfparse:_parseNameFilterPath(
                                   $text as xs:string, 
                                   $atts as attribute()*)
        as item()* {  
    let $pathText :=        
        if (not(starts-with($text, '('))) then
            (: Remove surrounding whitespace :)
            replace($text, '^\s+|\s+$', '') 
        else
            (: Remove parentheses :)
            replace($text, '^(\((.*?[^\\])?(\\\\)*\)).*', '$1') 
    let $next :=
        if (not(starts-with($text, '('))) then () else            
            substring($text, 1 + string-length($pathText))
            [normalize-space(.)]   
    return
        if (matches($next, '^\S') and not(starts-with($next, '('))) then 
            <z:error source="{$text}" 
               msg="{concat('Name filter path in parentheses must be ',
                   'followed by whitespace or string end; found: ', $text)}"/> 
        else if (starts-with($pathText, '(') and not(ends-with($pathText, ')'))) 
        then 
            <z:error source="{$text}" 
               msg="{concat('Name filter path preceded by ( but not followed ',
                   'by ); text: ', $text)}"/>
        else
            let $pathTextC := replace($pathText, '^\(|\)$', '')
            let $parsed :=
                if (not(contains($pathTextC, '/'))) then 
                    unfparse:_parseNameFilter($pathTextC, $atts) 
                else  
                    let $doubleSlash := starts-with($pathTextC, '//')
                    let $root := 
                        if ($doubleSlash) then () else 
                            $pathTextC  
                            ! replace(., '^(([a-z]:)?/).*', '$1', 'i')
                              [matches(., '^([a-z]:)?/$', 'i')]
                    let $remainder :=
                        if ($doubleSlash) then $pathTextC
                        else if ($root) then 
                            substring($pathTextC, string-length($root))
                        else '//'||$pathTextC
                    return
                        <nameFilterPath source="{$pathTextC}">{
                            $root ! attribute root {.},
                            $atts,
                            $remainder ! unfparse:_parseNameFilterPathRC(.)
                        }</nameFilterPath>
        return ($parsed, $next)
};

(:~
 : Recursive helper function of 'parseNameFilterpath'.
 :)
declare %private function unfparse:_parseNameFilterPathRC(
                                    $text as xs:string)
      as element()* {
    let $s := replace($text, '^\s+', '')
    let $sep := replace($s, '^(/+).*', '$1')
    let $sepAtt := $sep ! attribute sep {.}
    let $afterSep := replace($s, '^/+\s*', '')
    return
        if (not(contains($afterSep, '/'))) then 
            unfparse:_parseNameFilter($afterSep, $sepAtt)
        else
            let $step := substring-before($afterSep, '/')
            let $next := substring($afterSep, 1 + string-length($step))
            return (
                unfparse:_parseNameFilter($step, $sepAtt),
                unfparse:_parseNameFilterPathRC($next)
            )
};

(:~
 : Recursive helper function of '_parsePathFilter'. Parses
 : the next path filter item and returns the parsed item
 : and the remainder of the text not yet parsed. The
 : parsed item is either a 'nameFilterPath' element or
 : a 'nameFilter' element, dependent on whether the
 : path filter item contains slashes.
 :
 : @param text the text which remains to be parsed.
 : @return a structured representation of the next
 :    path filter item, followed by the text which
 :    follows the parsed text and remains to be parsed.
 :)
declare %private function unfparse:_parsePathFilterRC($text as xs:string)
        as item()* {
    let $head := replace($text, '^\s+', '')
    return
        if (not($head)) then ()
        else if (starts-with ($head, '(') or starts-with($head, '~(')) then
            let $neg :=
                if (starts-with($head, '~')) then true() else ()
            let $negFlag := if (not($neg)) then () else attribute negative {'true'}
            let $head := if ($neg) then substring($head, 2) else $head
            let $pathEtc := unfparse:_parseNameFilterPath($head, $negFlag)
            return
                if ($pathEtc[. instance of element(z:error)]) then $pathEtc else (
                    $pathEtc[1],
                    if (not($pathEtc[2])) then () else
                        unfparse:_parsePathFilterRC($pathEtc[2])
                )
        else
            unfparse:_parsePathFilterRC(concat('(', $head, ')'))
};
