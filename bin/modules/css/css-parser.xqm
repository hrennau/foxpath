module namespace f="http://www.data2type.de/ns/octopus/css-parser";
import module namespace cu="http://www.data2type.de/ns/octopus/css-util"
    at "css-util.xqm";

declare variable $f:REGEX_SEP := codepoints-to-string((30000, 30000));

(:~
 : Parses a CSS document.
 :)
declare function f:parseCss($text as xs:string?,
                            $options as map(xs:string, item()*)?)
        as map(xs:string, item()*) {
    let $options := ($options, map{})[1]        
    let $text := $text ! replace(., '&#xD;', '')
    let $preCommentsEtc := f:pComments($text, $options)
    let $preComments := f:removeEtc($preCommentsEtc)
    let $etc := f:getEtc($preCommentsEtc)

    let $importsEtc := f:pImports($etc, $options)
    let $imports := f:removeEtc($importsEtc)
    let $etc2 := f:getEtc($importsEtc)

    let $rulesEtc := f:pRules($etc2, $options)
    let $rules := f:removeEtc($rulesEtc)
    let $etc3 := f:getEtc($rulesEtc)

    let $postCommentsEtc := f:pComments($etc3, $options)
    let $postComments := f:removeEtc($postCommentsEtc)
    let $etc4 := f:getEtc($postCommentsEtc)

    let $cssParsed := 
        <css>{
            $preComments,
            $imports,
            $rules,
            $postComments
        }</css>  
    return map{'parsed': $cssParsed, 'etc': $etc4}
};

(:~
 : Parses a sequence of imports.
 :)
declare function f:pImports($text as xs:string?,
                            $options as map(xs:string, item()*))
        as item()* {
    let $importsEtc := f:pImportSeq($text, $options)
    let $imports := f:removeEtc($importsEtc)
    let $etc := f:getEtc($importsEtc)
    return ($imports, $etc)
};

(:~
 : Parses a sequence of rules, at most $options?maxIterNr rules.
 :)
declare function f:pImportSeq($text as xs:string?,
                              $options as map(xs:string, item()*))
        as item()* {
    let $importEtc := f:pImport($text, $options)
    let $import := f:removeEtc($importEtc)
    let $etc := f:getEtc($importEtc)    
    return if (not($import)) then $etc else
    let $etc := $etc ! f:skipWS(.)
    return ($import, $etc ! f:pImportSeq(., $options))        
};        

(:~
 : Parses a single import.
 :)
declare function f:pImport($text as xs:string?,
                           $options as map(xs:string, item()*))
        as item()* {
    let $preCommentsEtc := f:pComments($text, $options)
    let $preComments := f:removeEtc($preCommentsEtc)
    let $etc := f:getEtc($preCommentsEtc)
    return
        if (not(starts-with($etc, '@import'))) then $text else
        
    let $etc2 := replace($etc, '^@import\s+', '')
    let $valueEtc := f:pValue($etc2, $options)
    let $value := f:removeEtc($valueEtc)
    let $etc3 := f:getEtc($valueEtc)
    return 
        if (not($value)) then ($preComments, $etc) 
        else ($preComments, <import>{$value/t => string-join('')}</import>, $etc3)
};

(:
 :    R u l e s
 :)
(:~
 : Parses a sequence of rules.
 :)
declare function f:pRules($text as xs:string?,
                          $options as map(xs:string, item()*))
        as item()* {
    let $text := $text ! f:skipWS(.)
    return if (not($text)) then $text else

    let $rulesEtc := f:pRulesPackages($text, (), $options)
    let $rules := f:removeEtc($rulesEtc)
    let $etc := f:getEtc($rulesEtc)
    return 
        if (f:onlyComments($rules)) then ($rules, $etc) 
        else (<rules>{$rules}</rules>, $etc)                
};

(:~
 : Recursive function parsing at most $packageSize rules.
 :)
declare function f:pRulesPackages($text as xs:string,
                                  $rulesSoFar as element()*,
                                  $options as map(xs:string, item()*))
        as item()* {
    let $packageSize := 500
    let $options := 
        $options ! map:put(., 'iterNr', 1) 
                 ! map:put(., 'maxIterNr', $packageSize) 
    (:             
    let $_DEBUG := if (not($rulesSoFar)) then ()
                   else () (: trace('... '||count($rulesSoFar)||' rules parsed ... ', ()) :)
     :)
    let $rulesSeqEtc := f:pRuleSeq($text, $options)
    let $rulesSeq := f:removeEtc($rulesSeqEtc)
    let $etc := f:getEtc($rulesSeqEtc)
    let $etc := $etc ! f:skipWS(.)
    let $rulesSoFarNew := ($rulesSoFar, $rulesSeq)
    return
        (: Check if all rules have been parsed or the next package is required :)
        if (starts-with($etc, '}')) then ($rulesSoFarNew, $etc)
        else if (not($etc)) then ($rulesSoFarNew, $etc)
        else if (not($rulesSeq)) then ($rulesSoFarNew, $etc)   (: hjr, 2024-07-16 :)
        else f:pRulesPackages($etc, $rulesSoFarNew, $options)
};

(:~
 : Parses a sequence of rules, at most $options?maxIterNr rules.
 :)
declare function f:pRuleSeq($text as xs:string?,
                            $options as map(xs:string, item()*))
        as item()* {
    (: Check iterNr :)
    let $iterNr := $options?iterNr
    let $maxIterNr := $options?maxIterNr
    return if ($iterNr gt $maxIterNr) then $text else
        
    let $options := map:put($options, 'iterNr', $iterNr + 1)        
    let $ruleEtc := f:pRule($text, $options)
    let $rule := f:removeEtc($ruleEtc)
    let $etc := f:getEtc($ruleEtc)    
    return if (not($rule)) then $text else
    
    let $etc := $etc ! f:skipWS(.)
    return (
        $rule,
        if (starts-with($etc, '}')) then $etc
        else if (not(normalize-space($etc))) then $etc
        else $etc ! f:pRuleSeq(., $options)        
    )        
};        

(:~
 : Parses a single rule.
 :)
declare function f:pRule($text as xs:string?,
                         $options as map(xs:string, item()*))
        as item()* {
    let $preCommentsEtc := f:pComments($text, $options)
    let $preComments := f:removeEtc($preCommentsEtc)
    let $etc := f:getEtc($preCommentsEtc)
    
    (: let $selectorsEtc := prof:time(f:pSelector($etc, $options)) :)
    let $selectorsEtc := f:pSelector($etc, $options)
    let $selectors := f:removeEtc($selectorsEtc)
    let $etc2 := f:getEtc($selectorsEtc)
    return if (not($selectors)) then $etc else
    
    let $contentEtc :=
        if (f:isRuleDeep($selectors, $etc2)) then f:pRules($etc2, $options)
        else f:pProperties($etc2, $options)
    let $content := f:removeEtc($contentEtc)
    let $etc3 := f:getEtc($contentEtc)
    let $etc3 := $etc3 ! f:skipWS(.) 
    return if (not(starts-with($etc3, '}'))) then
       error(QName((), 'ERROR901'), '### Invalid CSS - rule content not delimited '||
           'by closing "}" ; remaining text: '||$etc3)
       else
    let $etc3 := $etc3 ! f:skipChar(., '}')
    let $rule := <rule>{$selectors, $content}</rule>
    return ($preComments, $rule, $etc3)
};

(:~
 : Parses a list of properties.
 :)
declare function f:pProperties($text as xs:string?,
                               $options as map(xs:string, item()*))
        as item()* {
    let $propertiesEtc := f:pPropertySeq($text, $options)
    let $properties := f:removeEtc($propertiesEtc)
    return if (not($properties)) then $text else
    let $etc := f:getEtc($propertiesEtc)
    return
        (<properties>{$properties}</properties>, $etc)
};

(:~
 : Parses a sequence of rules, at most $options?maxIterNr rules.
 :)
declare function f:pPropertySeq($text as xs:string?,
                                $options as map(xs:string, item()*))
        as item()* {
    let $propertyEtc := f:pProperty($text, $options)
    let $property := f:removeEtc($propertyEtc)
    let $etc := f:getEtc($propertyEtc)
    return if (not($property)) then $text else    
    let $etc := $etc ! f:skipWS(.)
    return 
        if (not($property)) then $etc 
        else (
            $property,
            if (starts-with($etc, '}')) then $etc
            else if (not(normalize-space($etc))) then $etc
            else $etc ! f:pPropertySeq(., $options)        
    )        
};        

(:~
 : Parses a single property.
 :)
declare function f:pProperty($text as xs:string?,
                             $options as map(xs:string, item()*))
        as item()* {
    let $preCommentsEtc := f:pComments($text, $options)
    let $preComments := f:removeEtc($preCommentsEtc)
    let $etc := f:getEtc($preCommentsEtc)
    let $etc := $etc ! f:skipWS(.)
    return if (starts-with($etc, '}')) then ($preComments, $etc) else

    (: let $nameEtc := prof:time(f:pName($etc, $options)) :)
    let $nameEtc := f:pName($etc, $options)
    let $name := f:removeEtc($nameEtc)
    let $etc2 := f:getEtc($nameEtc)   
    return if (not($name)) then ($preComments, $etc) else
    
    (: let $valueEtc := prof:time(f:pValue($etc2, $options)) :)
    let $valueEtc := f:pValue($etc2, $options)
    let $value := f:removeEtc($valueEtc)
    return if (not($value)) then ($preComments, $etc) else
    
    let $etc3 := f:getEtc($valueEtc)
    let $etc3 := $etc3 ! f:skipWS(.)
    
    let $property := <property>{$name, $value}</property>
    return ($preComments, $property, $etc3)
};

(:
 :    p a r s e S e l e c t o r
 :    -------------------------
 :) 
(:~
 : Parses a CSS selector. Returns a <selectors> element
 : followed by the remaining unparsed text. If no
 : selector could be parsed, the text string is returned,
 : regardless if it starts with comments.
 :) 
declare function f:pSelector($text as xs:string,
                             $options as map(xs:string, item()*)?)
        as item()* {
    let $TEST_PSELECTOR:= 1 
    return if ($TEST_PSELECTOR eq 0) then f:pSelector0($text, $options) else
    
    let $sb := substring-before($text, '{')[string()]
    return
        if ($sb and not(matches($sb, '["'']|/\*'))) then (
            <selectors><t>{f:trimWS($sb)}</t></selectors>,
            substring($text, string-length($sb) + 2)
        ) else
        
    let $len := 300
    let $text0 := substring($text, 1, $len)
    let $selectorEtc := f:pSelector0($text0, $options)
    let $selector := f:removeEtc($selectorEtc)
    (: $unclosed is true if a quoted string or comment was accepted, 
       perhaps because string splitting hid the counter part :)
    let $unclosed1 := $selector/t[contains(., '/*')]
    let $unclosed2 :=    
        $selector/t[contains(., '"') or contains(., "'")]
        [f:containsUnmatchedQuotes(.)]
    let $_DUMMY := $unclosed2 ! trace(., 'Quote unmatched, must use complete text ')        
    return
        if ($selector and not($unclosed1 or $unclosed2)) then
            let $etc := f:getEtc($selectorEtc)
            let $etc2 := $etc||substring($text, $len + 1)
            return ($selector, $etc2)
        else
            f:pSelector0($text, $options)            
};

(:~
 : Parses a CSS selector. Returns a <selectors> element,
 : followed by the remaining unparsed text.
 :)
declare function f:pSelector0($text as xs:string,
                              $options as map(xs:string, item()*)?)
        as item()* {
    let $itemsEtc := f:pSelectorREC($text ! f:skipWS(.), (), $options)
    return if (f:nomatch($itemsEtc)) then $text else

    let $items := f:removeEtc($itemsEtc)
    return if (f:onlyComments($items)) then $text else
    
    let $etc := f:getEtc($itemsEtc)
    return (<selectors>{$items}</selectors>, $etc)
};

(:~
 : Retursive helper function of `pSelector`.
 :)
declare function f:pSelectorREC($text as xs:string, 
                                $lead as xs:string?,
                                $options as map(xs:string, item()*)?)                             
        as item()* {
    let $parts :=
        replace($text,
        '^(.*?) ( (/\* .*? \*/) | ((".*?")|(''.*?'')) |  (\{) ) (.*)',
        '$1'||$f:REGEX_SEP||'$3'||$f:REGEX_SEP||
        '$4'||$f:REGEX_SEP||'$7'||$f:REGEX_SEP||
        '$8', 'sx')[. ne $text]
        ! tokenize(., $f:REGEX_SEP) 
    (:let $_DEBUG := trace($parts => string-join(' ### '), '___PARTS: '):)        
    return if (empty($parts)) then <nomatch/> else 
    let $t := ($lead||$parts[1]) return
    
    (: closing character found :)
    if ($parts[4]) then 
        (f:trimWS($t)[string()] ! <t>{.}</t>, $parts[5])
    
    (: comment :)
    else if ($parts[2]) then
        let $comment := substring($parts[2], 3, string-length($parts[2]) - 4)
        return (
            f:trimWS($t)[string()] ! <t>{.}</t>, <comment>{$comment}</comment>,
            $parts[5] ! f:pSelectorREC(., (), $options))
            
    (: quoted string :)
    else if ($parts[3]) then
        let $leadNew := $t||$parts[3]
        return $parts[5] ! f:pSelectorREC(., $leadNew, $options)
        
    else error((), 'Text: '||$text)
};

(:
 :    p a r s e N a m e
 :    -----------------
 :)
 
declare function f:pName($text as xs:string,
                         $options as map(xs:string, item()*)?)
        as item()* {
    let $TEST_PNAME:= 1 
    return if ($TEST_PNAME eq 0) then f:pName0($text, $options) else
    
    let $sb := substring-before($text, ':')[string()]
    return
        if ($sb and not(matches($sb, '["'']|/\*'))) then (
            <name><t>{f:trimWS($sb)}</t></name>,
            substring($text, string-length($sb) + 2)
        ) else
        
    let $len := 300
    let $text0 := substring($text, 1, $len)
    let $nameEtc := f:pName0($text0, $options)
    let $name := f:removeEtc($nameEtc)
    (: $unclosed is true if a quoted string or comment was accepted, 
       perhaps because string splitting hid the counter part :)
    let $unclosed1 := $name/t[contains(., '/*')]
    let $unclosed2 :=    
        $name/t[contains(., '"') or contains(., "'")]
        [f:containsUnmatchedQuotes(.)]
    (: let $_DUMMY := $unclosed2 ! trace(., '_UNMATCHED: ') :)        
    return
        if ($name and not($unclosed1 or $unclosed2)) then
            let $etc := f:getEtc($nameEtc)
            let $etc2 := $etc||substring($text, $len + 1)
            return ($name, $etc2)
        else
            f:pName0($text, $options)            
};

(:~
 : Parses a CSS property name. Returns a <name> element,
 : followed by the remaining unparsed text.
 :)
declare function f:pName0($text as xs:string,
                          $options as map(xs:string, item()*)?)
        as item()* {
    let $itemsEtc := f:pNameREC($text ! f:skipWS(.), (), $options)
    return if (f:nomatch($itemsEtc)) then $text else

    let $items := f:removeEtc($itemsEtc)
    return if (f:onlyComments($items)) then $text else
    
    let $etc := f:getEtc($itemsEtc)
    return (<name>{$items}</name>, $etc)
};

(:~
 : Retursive helper function of `pName`.
 :)
declare function f:pNameREC($text as xs:string, 
                            $lead as xs:string?,
                            $options as map(xs:string, item()*)?)                             
        as item()* {
    let $parts :=
        replace($text,
        '^(.*?) ( (/\* .*? \*/) | ((".*?")|(''.*?'')) |  (:) ) (.*)',
        '$1'||$f:REGEX_SEP||'$3'||$f:REGEX_SEP||
        '$4'||$f:REGEX_SEP||'$7'||$f:REGEX_SEP||
        '$8', 'sx')[. ne $text]
        ! tokenize(., $f:REGEX_SEP) 
    return if (empty($parts)) then <nomatch/> else 
    (: let $_DEBUG := trace($parts => string-join(' ### '), '___PARTS: ') :)
    let $t := ($lead||$parts[1]) return
    
    (: closing character found :)
    if ($parts[4]) then 
        (f:trimWS($t)[string()] ! <t>{.}</t>, $parts[5])
    
    (: comment :)
    else if ($parts[2]) then
        let $comment := substring($parts[2], 3, string-length($parts[2]) - 4)
        return (
            f:trimWS($t)[string()] ! <t>{.}</t>, <comment>{$comment}</comment>,
            $parts[5] ! f:pNameREC(., (), $options))
            
    (: quoted string :)
    else if ($parts[3]) then
        let $leadNew := $t||$parts[3]
        return $parts[5] ! f:pNameREC(., $leadNew, $options)
        
    else error((), 'Text: '||$text)
};
(:
 :    p a r s e V a l u e
 :    -------------------
 :)
 
declare function f:pValue($text as xs:string,
                          $options as map(xs:string, item()*)?)
        as item()* {
    let $TEST_PVALUE := 1 
    return if ($TEST_PVALUE eq 0) then f:pValue0($text, $options) else
    
    let $sb := 
        let $raw := substring-before($text, ';')[string()]
        return
            if (not(contains($raw, '}'))) then $raw
            else substring-before($raw, '}')
    return
        if ($sb and not(matches($sb, '["'']|/\*'))) then (
            <value><t>{f:trimWS($sb)}</t></value>,
            substring($text, string-length($sb) + 2)
        ) else
        
    let $len := 300
    let $text0 := substring($text, 1, $len)
    let $valueEtc := f:pValue0($text0, $options)
    let $value := f:removeEtc($valueEtc)
    (: $unclosed is true if a quoted string or comment was accepted, 
       perhaps because string splitting hid the counter part :)
    let $unclosed1 := $value/t[contains(., '/*')]
    let $unclosed2 :=    
        $value/t[contains(., '"') or contains(., "'")]
        [f:containsUnmatchedQuotes(.)]
    (: let $_DUMMY := $unclosed2 ! trace(., '_UNMATCHED: ') :)        
    return
        if ($value and not($unclosed1 or $unclosed2)) then
            let $etc := f:getEtc($valueEtc)
            let $etc2 := $etc||substring($text, $len + 1)
            return ($value, $etc2)
        else
            f:pValue0($text, $options)            
};

(:~
 : Parses a CSS property value. Returns a <value> element,
 : followed by the remaining unparsed text.
 :)
declare function f:pValue0($text as xs:string,
                          $options as map(xs:string, item()*)?)
        as item()* {
    let $itemsEtc := f:pValueREC($text ! f:skipWS(.), (), $options)
    return if (f:nomatch($itemsEtc)) then $text else
    let $items := f:removeEtc($itemsEtc)
    return if (f:onlyComments($items)) then $text else
    
    let $etc := f:getEtc($itemsEtc)
    return (<value>{$items}</value>, $etc)
};

(:~
 : Retursive helper function of `pValue`.
 :)
declare function f:pValueREC($text as xs:string, 
                             $lead as xs:string?,
                             $options as map(xs:string, item()*)?)                             
        as item()* {
    let $parts :=
        replace($text,
        '^(.*?) ( (/\* .*? \*/) | ((".*?")|(''.*?'')) |  ([;}]) ) (.*)',
        '$1'||$f:REGEX_SEP||'$3'||$f:REGEX_SEP||
        '$4'||$f:REGEX_SEP||'$7'||$f:REGEX_SEP||
        '$8', 'sx')[. ne $text]
        ! tokenize(., $f:REGEX_SEP) 
(:        
    let $parts :=
        replace($text,
        '^(.*?) ( (/\* .*? \*/) | ((["'']) .*? \5) |  ([;}]) ) (.*)',
        '$1'||$f:REGEX_SEP||'$3'||$f:REGEX_SEP||
        '$4'||$f:REGEX_SEP||'$6'||$f:REGEX_SEP||
        '$7', 'sx')[. ne $text]
        ! tokenize(., $f:REGEX_SEP)
:)        
    return if (empty($parts)) then <nomatch/> else 
    (: let $_DEBUG := trace($parts => string-join(' ### '), '___PARTS: ') :)
    let $t := ($lead||$parts[1]) return
    
    (: closing character found :)
    if ($parts[4]) then 
        let $prefix := '}'[. eq $parts[4]]
        return
            (f:trimWS($t)[string()] ! <t>{.}</t>, $prefix||$parts[5])
    
    (: comment :)
    else if ($parts[2]) then
        let $comment := substring($parts[2], 3, string-length($parts[2]) - 4)
        return (
            f:trimWS($t)[string()] ! <t>{.}</t>, <comment>{$comment}</comment>,
            $parts[5] ! f:pValueREC(., (), $options))
            
    (: quoted string :)
    else if ($parts[3]) then
        let $leadNew := $t||$parts[3]
        return $parts[5] ! f:pValueREC(., $leadNew, $options)
        
    else error((), 'Text: '||$text)
};

(:
 :    C o m m e n t s
 :)
(:~
 : Parses comments.
 :)
declare function f:pComments($text as xs:string?,
                             $options as map(xs:string, item()*))
        as item()* {
    let $text2 := $text ! f:skipWS(.)        
    return
        if (not(starts-with($text2, '/*'))
            or not(contains($text2, '*/'))) then $text 
        else
            let $tComment := replace($text2, '^(/\* .*? \*/) .*', '$1', 'sx')
            let $len := string-length($tComment)
            let $etc := substring($text2,  1 + $len) ! f:skipWS(.)
            let $comment := substring($tComment, 3, $len - 4)
            return (
                <comment>{$comment}</comment>,
                f:pComments($etc, $options)
            )                
};

(:   
 :    U t i l i t i e s
 :)
(:~
 : Removes leading whitespace from the start of a text.
 :)
declare function f:skipWS($text as xs:string?)
        as xs:string {
    replace($text, '^\s+', '')
};

(:~
 : Removes from the start of a text a given character, follwed
 : by optional whitespace.
 :)
declare function f:skipChar($text as xs:string?, $char as xs:string)
        as xs:string {
    if (not(starts-with($text, $char))) then $text else
        substring($text, 2) ! replace(., '^\s+', '')
};

(:~
 : Removes leading whitespace and trailing whitespace.
 :)
declare function f:trimWS($text as xs:string?)
        as xs:string {
    replace($text, '^\s+|\s+$', '')
};

declare function f:onlyComments($nodes as node()*)
        as item()* {
    every $node in $nodes satisfies $node instance of element(comment)        
};

declare function f:nomatch($items as item()*)
        as item()* {
    $items[last()] instance of element(nomatch)        
};

declare function f:getEtc($items as item()*)
        as item()* {
    $items[last()][. instance of xs:anyAtomicType]        
};

declare function f:removeEtc($items as item()*)
        as item()* {
    if ($items[count($items)] instance of node()) then $items        
    else subsequence($items, 1, count($items) - 1)        
};

(:~
 : Returns true if a string contains unmatched single or
 : double quotes.
 :)
declare function f:containsUnmatchedQuotes($s as xs:string)
        as xs:boolean {
    let $result1 :=
        if (not(contains($s, '"'))) then false() else
        let $count := string-length(replace($s, '[^"]', ''))
        return (0 ne ($count mod 2))
    let $result2 :=
        if (not(contains($s, "'"))) then false() else
        let $count := string-length(replace($s, "[^']", ""))
        return (0 ne ($count mod 2))
    return $result1 or $result2
};

(:~
 : Inspects the text after the selector and returns
 : true/false, if the rule is flat/deep.
 :)
declare function f:isRuleDeep($selector as xs:string, 
                              $text as xs:string?)
        as xs:boolean? {
    if (matches($selector, '^@media\s')) then true()        
    else if (not(starts-with($selector, '@'))) then false()
    else if (not(contains($text, ':'))) then true() 
    else if (not(contains($text, '{'))) then false()
    else  
        (: let $_DEBUG := trace((), ' ... expensive deep rule check ... ') :)
        let $nameEtc := f:pName($text, ())        
        let $name := f:removeEtc($nameEtc)
        let $t1 := $name/t => string-join('')
        return
            if (not(contains($t1, '{'))) then false() 
            else        
                (: let $selectorEtc := prof:time(f:pSelector($text, ())) :)        
                let $selectorEtc := f:pSelector($text, ())
                let $selector := f:removeEtc($selectorEtc)
                let $t2 := $selector/t => string-join('')
                return
                    string-length($t2) lt string-length($t1)
};


 
