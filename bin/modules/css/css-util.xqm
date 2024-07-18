module namespace f="http://www.data2type.de/ns/octopus/css-util";

(:~
 : Returns the property name, given a parsed property element.
 :)
declare function f:propertyName($property as element(property))
        as xs:string {
    ($property/name/t => string-join('')) ! replace(., '^\s+|\s+$', '')        
};

(:~
 : Returns the property value, given a parsed property element.
 :)
declare function f:propertyValue($property as element(property))
        as xs:string {
    ($property/value/t => string-join('')) ! replace(., '^\s+|\s+$', '')        
};

(:~
 : Returns the rule selector, given a parsed rule element.
 :)
declare function f:ruleSelector($rule as element(rule))
        as xs:string {
    ($rule/selectors/t => string-join('')) ! replace(., '^\s+|\s+$', '')
    ! replace(., '\s*,\s*', ', ')
    ! normalize-space(.)
};

(:~
 : Returns the individual rule selectors, given a parsed rule element.
 :)
declare function f:ruleSelectors($rule as element(rule))
        as xs:string* {
    let $selectors := f:ruleSelector($rule)
    return tokenize($selectors, ',\s*')
};

(:~
 : Edits a sequence of <t> and <comment> elements: leading whitespace is 
 : removed from the first <t> element, and trailing whitespace is removed 
 : from the last <t> element.
 :)
declare function f:trimSequenceT($seq as element()*)
        as element()* {
    if (count($seq) eq 1) then
        if (matches($seq, '^\s|\s$')) then <t>{f:trim($seq)}</t> else $seq
    else        
        let $positions := $seq/local-name(.) => index-of('t')        
        let $p1 := $positions[1]
        let $p2 := $positions[last()]
        let $_DEBUG := trace($p1||'/'||$p2, 'p1/p2: ')
        return
            if ($p1 eq $p2) then
                if (matches($seq[$p1], '^\s|\s$')) then (
                    subsequence($seq, 1, $p1 - 1),
                    <t>{f:trim($seq[$p1])}</t>,
                    subsequence($seq, $p1 + 1)
                ) else $seq
            else
                for $item at $p in $seq
                return
                    if ($p eq $p1) then
                        if (matches($item, '^\s')) then 
                            <t>{replace($item, '^\s+', '')}</t>
                        else $item
                    else if ($p eq $p2) then
                        if (matches($item, '\s$')) then 
                            <t>{replace($item, '\s+$', '')}</t>
                        else $item
                    else $item                    
};

(:
 : === S t r i n g    p r o c e s s i n g ===
 :)

declare function f:trim($s as xs:string) {
    replace($s, '^\s+|\s+$', '')
};
