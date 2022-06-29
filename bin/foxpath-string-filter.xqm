module namespace f="http://www.foxpath.org/ns/string-filter";

import module namespace ft="http://www.foxpath.org/ns/fulltext" at "foxpath-fulltext.xqm";

(:~
 : Compiles a complex string filter into a structured representation. This
 : representation will be evaluated by function f:matchesComplexStringFilter,
 : which returns true (false) if a given string matches (does not match) the
 : string filter.
 :
 : A complex string filter consists of a query and an optional control string,
 : separated by a # character. Any occurrence of a # character in the query 
 : must be doubled, thus using "##" to represent a single # character.
 :
 : The query is either a concatenated list of filter items, or a single fulltext
 : query. It is interpreted as fulltext query if and only if the control string 
 : contains the (whitespace-separated) token "fulltext", or "ftext", or "ft".
 :
 : When using filter items, the optioal control string consists of flags. The 
 : flags are provided by a string in which each single character represents a 
 : flag:
 : c - matching is case sensitive (by default case insensitive) 
 : r - filter items are interpreted as regular expressions; by default, they
 :     are interpreted as glob patterns
 : a - when mapping glob patterns to regular expressions, anchors ^ and $
 :     (indicating begin and end of the string) are added
 : A - when mapping glob patterns to regular expressions, anchors ^ and $
 :   are not added
 : , - (or ; or : or /) - the character used to separate the filter items
 :
 : If neither flag "a" nor "A" is used, anchors ^ and $ are added if
 : parameter $addAnchorsDefault is true. 
 :
 : The filter items are provided as a concatenated list, separated by whitespace
 : (default) or one of the characters ,;:/. A non-whitespace separator is
 : specified by a flag consisting of the character itself. Examples:
 : "foo#," "foo#;" "...#c:" "...#,c".
 :
 : Filter items can be inclusive and exclusive: exclusive if immediately 
 : preceded by a '~' character, inclusive otherwise. If there are inclusive 
 : filter items, a matching string must match at least one of them. A matching 
 : string  must not match any of the exclusive filter items. 
 :
 : In case of a fulltext query, the control string consists of the pseudo-
 : option "freetext" indicating that the query is a freetext query, as well
 : as optional further options. Further options have the same syntax and 
 : semantics as when used by function `contains-text`.
 : 
 : Note that a query consisting of filter items consists of possibly
 : several items, separated by whitespace or the separator indicated
 : by the flags - whereas a fulltext query is a single query, which is
 : not tokenized into subqueries.
 :
 : @param patterns a list of filter items, whitespace concatenated
 : @param addAnchorsDefault if true, translating glob patterns into
 :   regular expressions uses (does not use) anchors, unless otherwise
 :   mandated by flags (a or A) 
 : @return a map with entries 'names', 'regexes' and 'flags' 
 :)
declare function f:compileComplexStringFilter($patterns as xs:string?, $addAnchorsDefault as xs:boolean?) 
        as map(xs:string, item()*)? {
    let $itemsAndFlags := f:splitStringIntoItemsAndFlags($patterns)
    let $flags := $itemsAndFlags[1]    
    let $items := subsequence($itemsAndFlags, 2)
    
    let $isFulltext := $flags ! tokenize(.) = ('fulltext', 'ftext', 'ft')
    return
        if ($isFulltext) then  
            let $fnFulltext := ft:fnContainsText($items[1], $flags, (), ())
            return
                map{'contains-text': $fnFulltext}
        else
        
    let $ignoreCase := not(contains($flags, 'c'))
    let $patternIsRegex := contains($flags, 'r')
    let $addAnchors := 
        if (contains($flags, 'A')) then false() 
        else if (contains($flags, 'a')) then true()
        else ($addAnchorsDefault, true())[1]
    
    let $patterns := $items ! replace(., '^\s+|\s+$', '')
    return if (empty($patterns)) then () else
    
    let $patternsPlus := $patterns[not(starts-with(., '~'))]
    let $patternsMinus := $patterns[starts-with(., '~')] ! substring(., 2)
    return
        map:merge((
            map:entry('ignoreCase', $ignoreCase),
            map:entry('empty', empty(($patternsPlus, $patternsMinus))), 
            if (empty($patternsPlus)) then () else
                map:entry('include', f:compileStringFilter($patternsPlus, $ignoreCase, $patternIsRegex, $addAnchors)),
            if (empty($patternsMinus)) then () else
                map:entry('exclude', f:compileStringFilter($patternsMinus, $ignoreCase, $patternIsRegex, $addAnchors))
        ))
};

(:~
 : Translates a whitespace-separated list of "patterns" into a structured
 : representation. A pattern is a glob pattern or a regular expression.
 : The structured representation is a map.
 :
 : @param patterns a list of patterns
 : @param ignoreCase if true, regex matching ignores case
 : @param patternIsRegex if true, patterns are interpreted as regular
 :   expressions, otherwise as glob patterns
 : @param addAnchors if true, by default glob patterns are translated
 :   into regular expressions with anchors indicating the begin and
 :   end of the string; the default can be overridden by flags 'a'
 :   (add anchors) and 'A' (do not add anchors). 
 : @return a map with possible entries 'empty', 'regexes', 'flags', 
 :   'strings', 'substrings'. 
 :)
declare function f:compileStringFilter($patterns as xs:string*, 
                                       $ignoreCase as xs:boolean?,
                                       $patternIsRegex as xs:boolean?,
                                       $addAnchors as xs:boolean?)
        as map(xs:string, item()*)? {
    let $patterns := $patterns ! normalize-space(.)[string()]
    return if (empty($patterns)) then () else
    
    let $literals := 
        if ($patternIsRegex) then () else        
        let $raw := $patterns[not(contains(., '*')) and not(contains(., '?'))]
        return if (not($ignoreCase)) then $raw else $raw ! lower-case(.)
    let $regexes := 
        if ($patternIsRegex) then $patterns else
        $patterns[contains(., '*') or contains(., '?')]
        ! replace(., '[.+|\\(){}\[\]\^$]', '\\$0')        
        ! replace(., '\*', '.*')
        ! replace(., '\?', '.')
        ! (if ($addAnchors) then concat('^', ., '$') else .)
    let $flags := if ($ignoreCase) then 'i' else ''     
    let $map := 
        map{'regexes': $regexes, 
            'empty': empty(($literals, $regexes)), 
            'flags': $flags,
            'ignoreCase': $ignoreCase}
    return
        if (exists($literals)) then
            let $key := if ($addAnchors) then 'strings' else 'substrings'
            return map:put($map, $key, $literals)
        else $map            
};

(:~
 : Matches a string against a complex string filter. The filter has
 : been constructed by function f:compileComplexStringFilter.
 :
 : @param string the string to match
 : @param filter the compiled complex string filter
 : @return true of false, if the string matches, does not match, the filter
 :) 
declare function f:matchesComplexStringFilter(
                   $string as xs:string,                                               
                   $filter as map(xs:string, item()?)?)
        as xs:boolean {
    let $fnContainsText := $filter?contains-text
    return
        if (exists($fnContainsText)) then $fnContainsText($string) else
        
    if (empty($filter)) then true() else        
    let $ignoreCase := $filter?ignoreCase
    let $include := $filter?include
    let $exclude := $filter?exclude
    return
        (empty($include) or f:matchesStringFilter($string, $include, $ignoreCase)) and
        (empty($exclude) or not(f:matchesStringFilter($string, $exclude, $ignoreCase)))        
};

(:~
 : Matches a string against a string filter. The filter has been constructed by
 : function f:compileStringFilter.
 :
 : @param string the string to match
 : @param stringFilter a compiled string filter 
 : @return true if the string filter is matched, false otherwise
 :)
declare function f:matchesStringFilter($string as xs:string, 
                                       $stringFilter as map(xs:string, item()*)?,
                                       $ignoreCase as xs:boolean?)
        as xs:boolean {
    let $flags := if ($ignoreCase) then 'i' else ''
    let $string := if ($stringFilter?ignoreCase) then lower-case($string) else $string 
    return
        $stringFilter?empty
        or exists($stringFilter?strings) and $string = $stringFilter?strings
        or exists($stringFilter?substrings) and (some $sstr in $stringFilter?substrings satisfies contains($string, $sstr))
        or exists($stringFilter?regexes) and (some $r in $stringFilter?regexes satisfies matches($string, $r, $flags))
};

(:~
 : Splits a string into items and flags. The optional flags are separated
 : from the items by a # character. Doubled # characters are interpreted as
 : literal characters which do not separate items and flags.
 :
 : If flags are used and contain one of the tokens 'fulltext', 'ftext', 'ft',
 : the item text is interpreted as a single item. Otherwise, the item text
 : is tokenized into items separated by whitespace (default) or one of the
 : characters ,;:/. A non-whitespace separator is assumed if contained by
 : the flag string.
 :
 : @param string the string to be split
 : @return a sequence of items; the first one representing the flags, which
 :   may be a zero-length strings; all following items representing the
 :   items extracted from the string
 :)
declare function f:splitStringIntoItemsAndFlags($string as xs:string) 
        as xs:string+ {
    let $concatAndFlags := f:splitStringAtDoubleEscapableChar($string, '#')        
    let $concat := $concatAndFlags[1]
    let $flags := $concatAndFlags[2]
    return
        if (tokenize($flags) = ('fulltext', 'ftext', 'ft')) then ($flags, $concat)
        else
        
    let $sep := 
        if (not(matches($flags, '[,;:/]'))) then () else
            replace($flags, '^.*([,;:/]).*', '$1') ! substring(., 1, 1)
    return (
        $flags,
        if ($sep) then tokenize($concat, '\s*'||$sep||'\s*') else tokenize($concat))
};

(:~
 : Returns the substrings preceding and following the first occurrence
 : of a character ($char) which is not escaped by repeating it.
 : If the string does not contain the character in single form
 : (or repeated an uneven number of times), the original string and a 
 : zero-length string are returned.
 : 
 : The substring returned is edited by replacing any doubled occurrence 
 : of the character with a single occurrence.
 :
 : @param string the string to be analyzed
 : @param char the character delimiting the substring
 : @return the strings preceding and following the character
 :)
declare function f:splitStringAtDoubleEscapableChar(
                    $string as xs:string, 
                    $char as xs:string)
        as xs:string+ {
    if (not(contains($string, $char))) then ($string, '')
    else if (not(contains($string, $char||$char))) then (
            substring-before($string, $char), substring-after($string, $char))
    else (        
        let $patternBefore := '^('||$char||$char||'|[^'||$char||'])+'
        return 
            let $before := replace($string, '('||$patternBefore||').*', '$1')
            return ($before, substring($string, string-length($before) + 2))
    ) ! replace(., $char||$char, $char)
};        
