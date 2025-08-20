module namespace f="http://www.foxpath.org/ns/unified-string-expression";

import module namespace ft="http://www.foxpath.org/ns/fulltext" at "foxpath-fulltext.xqm";

(:
 :    P a r s e    u n i f i e d    e x p r e s s i o n
 :    =================================================
 :)

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
 : @param uexpr a unified string expression
 : @param default value for the decision whether to add anchors when
 :   translating glob patterns into regex; the value can be overriden
 :   by options ('A' do not add, 'a' do add)
 : @param qualifiedMatching if true, the qualified matching mode
 :   is triggered, which interprets pattern substrings preceding
 :   the first colon as namespace prefix, rather than a part
 :   of the pattern
 : @param namespaceBindings namespace bindings, required if and
 :   only if $qualifiedMatching is true
 : @return a map representation of the unified string expression 
 :)
declare function f:compileUSE(
                    $uexpr as xs:string?, 
                    $addAnchorsDefault as xs:boolean?)
        as map(xs:string, item()*)? {
    f:compileUSE($uexpr,$addAnchorsDefault, (), (), ())        
};        

declare function f:compileUSE(
                    $uexpr as xs:string?, 
                    $addAnchorsDefault as xs:boolean?,
                    $qualifiedMatching as xs:boolean?,
                    $namespaceBindings as map(*)?)
        as map(xs:string, item()*)? {
    f:compileUSE($uexpr,
        $addAnchorsDefault, $qualifiedMatching, $namespaceBindings, ())        
};        

(:~
 : Compiles a Unified String Expression into a structured representation.
 :)
declare function f:compileUSE(
                    $uexpr as xs:string?, 
                    $addAnchorsDefault as xs:boolean?,
                    $qualifiedMatching as xs:boolean?,
                    $namespaceBindings as map(*)?,
                    $options as xs:string?) 
        as map(xs:string, item()*)? {
    let $ifmap := f:splitStringIntoItemsAndFlags($uexpr)
    let $flags := $ifmap?flags  
    let $items := $ifmap?items
    
    let $isFulltext := $flags ! tokenize(.) = ('fulltext', 'ftext', 'ft')
    return
        if ($isFulltext) then  
            let $fnFulltext := ft:fnContainsText($items[1], $flags, (), $options)
            return map{'contains-text': $fnFulltext}
        else
        
    let $qualifiedMatching := $qualifiedMatching or contains($flags, 'q')
    let $ignoreCase := not(contains($flags, 'c'))
    let $patternIsRegex := contains($flags, 'r')
    let $addAnchors := 
        if (contains($flags, 'A')) then false() 
        else if (contains($flags, 'a')) then true()
        else ($addAnchorsDefault, true())[1]
    
    (: Trim patterns :)
    let $patterns := $items ! replace(., '^\s+|\s+$', '')
    return if (empty($patterns)) then () else
    
    let $patternsPlus := $patterns[not(starts-with(., '~'))]
    let $patternsMinus := $patterns[starts-with(., '~')] ! substring(., 2)
    let $useNamespaceBindings := $namespaceBindings[$qualifiedMatching]
    return 
        map:merge((
            map:entry('empty', empty(($patternsPlus, $patternsMinus))), 
            if (empty($patternsPlus)) then () else
                map:entry('include', f:compileGlorexPatternSet(
                    $patternsPlus, $ignoreCase, $patternIsRegex, $addAnchors, $useNamespaceBindings)),
            if (empty($patternsMinus)) then () else
                map:entry('exclude', f:compileGlorexPatternSet(
                    $patternsMinus, $ignoreCase, $patternIsRegex, $addAnchors, $useNamespaceBindings))
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
declare function f:compileGlorexPatternSet(
                                       $patterns as xs:string*, 
                                       $ignoreCase as xs:boolean?,
                                       $patternIsRegex as xs:boolean?,
                                       $addAnchors as xs:boolean?,
                                       $namespaceBindings as map(*)?)
        as map(xs:string, item()*)? {
    if (exists($namespaceBindings)) then 
        f:compileGlorexPatternSetQualified(
            $patterns, $ignoreCase, $patternIsRegex, $addAnchors, $namespaceBindings)
    else
    let $patterns := $patterns ! normalize-space(.)[string()]
    return if (empty($patterns)) then () else
    
    (: Pattern kind: literal (do not contain wildcard, @ or \) :)
    let $literals := 
        if ($patternIsRegex) then () else $patterns[not(matches(., '[@*?\\]'))]
    let $useLiterals := 
        if (not($ignoreCase)) then $literals else $literals ! lower-case(.)
    (: Pattern kind: regular expression :)
    let $regexes := 
        for $pattern in $patterns[not(. = $literals)]
        let $regexAndFlags := 
            f:patternToRegexAndFlags($pattern, $ignoreCase, $patternIsRegex, $addAnchors)
        return map{'expr': $regexAndFlags[1], 'flags': $regexAndFlags[2]}
        
    let $flags := if ($ignoreCase) then 'i' else ''   
    let $flags := 'ys'||$flags    (: 20250414, hjr :)
    let $map := 
        map{'regexes': $regexes, 
            'empty': empty(($literals, $regexes)), 
            'flags': $flags,
            'cmpIgnoreCase': $ignoreCase}
    return
        if (exists($literals)) then
            let $key := if ($addAnchors) then 'strings' else 'substrings'
            return map:put($map, $key, $useLiterals)
        else $map            
};

(:~
 : Maps a pattern string to a regex string and a flags string.
 :)
declare function f:patternToRegexAndFlags(
                    $pattern as xs:string, 
                    $ignoreCase as xs:boolean?, 
                    $patternIsRegex as xs:boolean?, 
                    $addAnchors as xs:boolean?)
        as xs:string+ {
    let $patternAndLocalflags :=
        if (not(contains($pattern, '@'))) then $pattern
        else            
            let $flagsString := f:splitStringAtDoubleEscapableChar($pattern, '@')
            let $localFlags := $flagsString[2]
            let $usePattern := subsequence($flagsString, 1)
            return ($usePattern, $localFlags)
    let $usePattern := $patternAndLocalflags[1]
    let $lflags := $patternAndLocalflags[2]
    let $regexAndFlags :=
        if (not($lflags)) then
            let $regexExpr := 
                if ($patternIsRegex) then $usePattern 
                else $usePattern ! f:globToRegex(., 'A'[not($addAnchors)])
            let $useFlags := 'i'[$ignoreCase] 
            let $useFlags := 's'||$useFlags    (: 20250414, hjr :)
            return ($regexExpr, $useFlags) 
        else  
            let $useAddAnchors := 
                if ($lflags ! matches(., 'a', 'i')) then 
                    if (contains($lflags, 'A')) then false() else true()
                else $addAnchors 
            let $useIgnoreCase :=
                if ($lflags ! matches(., 'c', 'i')) then
                    if (contains($lflags, 'c')) then false() else true()
                else $ignoreCase 
            let $usePatternIsRegex :=
                if ($lflags ! matches(., 'r', 'i')) then
                    if (contains($lflags, 'r')) then true() else false()
                else $patternIsRegex
            let $useFlags := 'i'[$useIgnoreCase]
            let $useFlags := 's'||$useFlags    (: 20250414, hjr :)
            let $regexExpr := 
                if ($usePatternIsRegex) then $usePattern 
                else $usePattern ! f:globToRegex(., 'A'[not($useAddAnchors)])
            return ($regexExpr, $useFlags)    
    return $regexAndFlags            
};


(:~
 : Translates a whitespace-separated list of "patterns" into a structured
 : representation. A pattern is a glob pattern or a regular expression.
 : The structured representation is a map.
 :
 : This variant splits the patterns into prefix and local name. The prefix
 : is mapped to a namespace URI, and only the local name is evaluated as
 : a pattern.
 :
 : @param patterns a list of patterns
 : @param ignoreCase if true, regex matching ignores case
 : @param patternIsRegex if true, patterns are interpreted as regular
 :   expressions, otherwise as glob patterns
 : @param addAnchors if true, by default glob patterns are translated
 :   into regular expressions with anchors indicating the begin and
 :   end of the string; the default can be overridden by flags 'a'
 :   (add anchors) and 'A' (do not add anchors). 
 : @param namespaceBindings a mapping of prefixes to namespace URIs
 : @return a map with possible entries 'empty', 'regexes', 'flags', 
 :   'strings', 'substrings'. 
 :)
declare function f:compileGlorexPatternSetQualified(
                                       $patterns as xs:string*, 
                                       $ignoreCase as xs:boolean?,
                                       $patternIsRegex as xs:boolean?,
                                       $addAnchors as xs:boolean?,
                                       $namespaceBindings as map(*))
        as map(xs:string, item()*)? {
    (: let $_DEBUG := trace($namespaceBindings, '_NAMESPACE_BINDINGS: ') :)        
    let $patterns := $patterns ! normalize-space(.)[string()]
    return if (empty($patterns)) then () else
    
    let $fn_nsuri_lname := function($pattern) {
        let $withPrefix := contains($pattern, ':')
        let $prefix := 
            if ($pattern eq '*') then '*' 
            else if (not($withPrefix)) then () 
            else replace($pattern, ':.*', '')
        let $lname := if (not($withPrefix)) then $pattern else replace($pattern, '^.+:', '')
        let $string := if (not($ignoreCase)) then $lname else $lname ! lower-case(.)
        let $namespace := 
            if ($prefix ne '*') then $namespaceBindings($prefix)
            else if ($prefix eq '*') then '*'
            else ()
        let $_CHECK := if (not($prefix) or $namespace) then () else 
            error(QName((), 'INVALID_ARG'), concat('No namespace binding for prefix: ', $prefix))
        return ($string, $namespace)
    }
    let $literals := 
        if ($patternIsRegex) then () else        
        let $raw := $patterns[replace(., '^.+:', '')[not(contains(., '*')) and not(contains(., '?'))]]
        for $item in $raw
        let $nsuri_lname := $fn_nsuri_lname($item)
        return map{'string': $nsuri_lname[1], 'namespace': $nsuri_lname[2]}
    let $regexes := 
        if ($patternIsRegex) then 
            for $pattern in $patterns
            let $nsuri_lname := $fn_nsuri_lname($pattern)
            return map{'string': $nsuri_lname[1], 'namespace': $nsuri_lname[2]}            
        else
            for $pattern in $patterns
            let $nsuri_lname := $fn_nsuri_lname($pattern)
            let $nsuri := $nsuri_lname[2]
            let $regexAndFlags := 
                f:patternToRegexAndFlags($nsuri_lname[1], $ignoreCase, $patternIsRegex, $addAnchors)  
            return map{'expr': $regexAndFlags[1], 
                       'flags': $regexAndFlags[2], 
                       'namespace': $nsuri_lname[2]}
    let $flags := if ($ignoreCase) then 'i' else ''     
    let $map := 
        map{'regexes': $regexes, 
            'empty': empty(($literals, $regexes)), 
            'flags': $flags,
            'cmpIgnoreCase': $ignoreCase}
    return
        if (exists($literals)) then
            let $key := if ($addAnchors) then 'strings' else 'substrings'
            return map:put($map, $key, $literals)
        else $map            
};

(:
 :    M a t c h    u n i f i e d    e x p r e s s i o n
 :    =================================================
 :)

(:~
 : Matches a string against a complex string filter. The filter has
 : been constructed by function f:compileComplexStringFilter.
 :
 : @param string the string to match
 : @param filter the compiled complex string filter
 : @return true of false, if the string matches, does not match, the filter
 :) 
declare function f:matchesUSE(
                   $items as item()+,                                               
                   $filter as map(xs:string, item()?)?)
        as xs:boolean {
    if (count($items) gt 1) then f:matchesUSEQualified($items[1], $items[2], $filter)
    else
    
    let $fnContainsText := $filter?contains-text
    return
        if (exists($fnContainsText)) then $fnContainsText($items) else
        
    if (empty($filter)) then true() else        
    let $include := $filter?include
    let $exclude := $filter?exclude
    return
        (empty($include) or f:matchesGlorexPatternSet($items, $include)) and
        (empty($exclude) or not(f:matchesGlorexPatternSet($items, $exclude)))        
};

(:~
 : Matches a string against a complex string filter. The filter has
 : been constructed by function f:compileComplexStringFilter.
 :
 : @param string the string to match
 : @param filter the compiled complex string filter
 : @return true of false, if the string matches, does not match, the filter
 :) 
declare function f:matchesUSEQualified(
                   $string as xs:string,
                   $namespace as xs:string,
                   $filter as map(xs:string, item()?)?)
        as xs:boolean {
    let $fnContainsText := $filter?contains-text
    return
        if (exists($fnContainsText)) then $fnContainsText($string) else
        
    if (empty($filter)) then true() else        
    let $include := $filter?include
    let $exclude := $filter?exclude
    return
        (empty($include) or f:matchesGlorexPatternSet($string, $namespace, $include)) and
        (empty($exclude) or not(f:matchesGlorexPatternSet($string, $namespace, $exclude)))        
};

(:~
 : Matches a string against a string filter. The filter has been constructed by
 : function f:compileStringFilter.
 :
 : @param string the string to match
 : @param stringFilter a compiled string filter 
 : @return true if the string filter is matched, false otherwise
 :)
declare function f:matchesGlorexPatternSet(
                                       $string as xs:string, 
                                       $stringFilter as map(xs:string, item()*)?)
        as xs:boolean {
    let $stringCMP := if ($stringFilter?cmpIgnoreCase) then lower-case($string) else $string
    return
        $stringFilter?empty 
        or $stringFilter?strings = $stringCMP
        or (some $sstr in $stringFilter?substrings satisfies contains($stringCMP, $sstr))
        or (some $r in $stringFilter?regexes satisfies matches($string, $r?expr, $r?flags))
};

(:~
 : Matches a string associated with a namespace URI against a string filter.
 :
 : @param string the string to match
 : @param namespace the namespace associated with the string
 : @param stringFilter a compiled string filter 
 : @return true if the string filter is matched, false otherwise
 :)
declare function f:matchesGlorexPatternSet(
                                       $string as xs:string,
                                       $namespace as xs:string,
                                       $stringFilter as map(xs:string, item()*)?)
        as xs:boolean {
    let $stringCMP := if ($stringFilter?cmpIgnoreCase) then lower-case($string) else $string 
    return
        $stringFilter?empty
        or exists($stringFilter?strings) and (
            some $s in $stringFilter?strings satisfies $s?string eq $stringCMP and $s('namespace') = ($namespace, '*'))
        or exists($stringFilter?substrings) and (
            some $s in $stringFilter?substrings satisfies contains($stringCMP, $s?string) and $s('namespace') = ($namespace, '*'))
        or exists($stringFilter?regexes) and (
            some $r in $stringFilter?regexes satisfies matches($string, $r?expr, $r?flags) and $r('namespace') = ($namespace, '*'))
};

(:
 :    U t i l i t y    f u n c t i o n s
 :    ==================================
 :)

(:~
 : Splits a string into items and flags. The optional flags are separated
 : from the items by a # character. Doubled # characters are interpreted as
 : literal characters which do not separate items and flags.
 :
 : If flags are used and contain one of the tokens 'fulltext', 'ftext', 'ft',
 : the item text is interpreted as a single item. Otherwise, the item text
 : is tokenized into items separated by whitespace (default) or one of the
 : characters ,;:/ . A non-whitespace separator is assumed if contained by
 : the flag string.
 :
 : Example: "foo bar zoo"
 : => flags="", three items="foo", "bar", "zoo"
 :
 : Example: "foo##bar#c"
 : => flags="c", one item="foo#bar"
 :
 : Example: "foo bar, zoo #,c"
 : => flags=",c", two items="foo bar", "zoo"
 :
 : Example: "foo bar; zoo #c;"
 : => flags="c;", two items="foo bar", "zoo"
 :
 : Example: "foo:bar, zoo #:"
 : => flags=":", two items="foo", "bar, zoo"
 :
 : @param string the string to be split
 : @return a map with entries 'items' and 'flags'.
 :)
declare function f:splitStringIntoItemsAndFlags($string as xs:string) 
        as map(*) {
    let $concatAndFlags := f:splitStringAtDoubleEscapableChar($string, '#')        
    let $concat := $concatAndFlags[1]
    let $flags := $concatAndFlags[2]
    return
        if (tokenize($flags) = ('fulltext', 'ftext', 'ft')) then 
            map{'flags': $flags, 'items': $concat}
        else
        
    let $sep := 
        if (not(matches($flags, '[,;:/]'))) then () else
            replace($flags, '^.*([,;:/]).*', '$1') ! substring(., 1, 1)
    return map{
        'flags': $flags,
        'items':
            if ($sep) then tokenize($concat, '\s*'||$sep||'\s*') 
            else tokenize($concat)}
};

(:~
 : Returns the substrings preceding and following the first occurrence of a
 : character ($char) which is not escaped by repeating it. (In other words:
 : the first occurrence of $char which is either not repeated or repeated an 
 : uneven number of times.) If the string does not contain the character or 
 : any occurrence is repeated an even number of times), the original string 
 : and a zero-length string are returned.
 : 
 : The first substring returned is edited by replacing any doubled occurrence 
 : of the character with a single occurrence. (Note that the second
 : substring is not edited.)
 :
 : @param string the string to be analyzed
 : @param char the character separating the substrings
 : @return sequence of two strings: the string preceding and 
 :   the string following the character
 :)
declare function f:splitStringAtDoubleEscapableChar(
                    $string as xs:string, 
                    $char as xs:string)
        as xs:string+ {
    if (not(contains($string, $char))) then ($string, '')
    else if (not(contains($string, $char||$char))) then (
            substring-before($string, $char), substring-after($string, $char))
    else        
        let $patternBefore := '^('||$char||$char||'|[^'||$char||'])+'
        return 
            let $before := replace($string, '('||$patternBefore||').*', '$1')
            let $after := substring($string, string-length($before) + 2)
            return ($before ! replace(., $char||$char, $char), $after)
};        

(:~
 : Maps a glob pattern to a regular expression.
 :
 : @param glob a glob pattern
 : @param flags flags controlling the evaluation;
 
 : @return the equivalent regular expession
 :)
declare function f:globToRegex($glob as xs:string, $flags as xs:string?)
        as xs:string {
    let $addAnchors := not(contains($flags, 'A')) return
    
    $glob        
    ! replace(., '\\s', ' ')
    ! replace(., '[.+|\\(){}\[\]\^$]', '\\$0')        
    ! replace(., '\*', '.*')
    ! replace(., '\?', '.')
    ! (if ($addAnchors) then concat('^', ., '$') else .)
};
