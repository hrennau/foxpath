module namespace f="http://www.data2type.de/ns/octopus/css-util";

import module namespace csss="http://www.data2type.de/ns/octopus/css-serializer"
at "css-serializer.xqm";

import module namespace i="http://www.ttools.org/xquery-functions" 
at "../../foxpath-uri-operations.xqm";

(:~
 : Returns a "cssdoc resource", which is a map with entries
 : '_objecttype', 'doc' and 'uri'.
 :)
declare function f:cssdocResource($resource as item()?)
        as map(*)? {
    if ($resource instance of map(*)) then $resource else
    
    let $doc := 
        if ($resource instance of node()) then $resource
        else try {i:fox-css-doc($resource, ())} catch * {()}
    return if (not($doc)) then () else
    let $uri := $resource
    return map{'_objecttype': 'cssdoc-resource', 'doc': $doc, 'uri': $uri}
};  

(:~
 : Writes a document resource to the file system.
 :)
declare function f:writeCssdocResource($path as xs:string, 
                                       $resource as map(*), 
                                       $flags as xs:string?)
        as empty-sequence() {
    let $doc := $resource?doc
    return if (not($doc)) then () else
    
    let $flagItems := $flags ! tokenize(.)
    let $serCss := $flags = 'csstext'
    return
        if ($serCss) then
            let $text := try {csss:serializeCss($doc, ())} catch * {()}
            return file:write($path, $text, ())
        else
            let $ser := map:merge(
                if (not($flagItems = 'indent')) then () 
                else map:entry('indent', 'yes'))
            return file:write($path, $doc, $ser)                
};        

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
