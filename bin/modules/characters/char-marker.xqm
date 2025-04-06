module namespace f="http://www.foxpath.org/ns/fox-functions/char-marker";
import module namespace i="http://www.ttools.org/xquery-functions" 
at "../../foxpath-uri-operations.xqm";

import module namespace uth="http://www.foxpath.org/ns/urithmetic" 
at  "../../foxpath-urithmetic.xqm";
 

(:~
 : Optionally replaces characters and marks them by inserting
 : unicode codepoint information immediately before it.
 :
 : @param item the document to be analyzed
 : @param mark the characters to be marked
 : @param replace the replacements to be performed
 : @param flags for future use
 : @param cfgPath for future use
 : @return the edited documents, with replacements performed and marks added
 :)
declare function f:replaceAndMarkChars(
                               $item as item(), 
                               $replace as xs:string?,
                               $mark as xs:string?,                               
                               $flags as xs:string?,                               
                               $cfgPath as xs:string?)

        as item() {
    let $isDocResource := uth:instanceOfDocResource($item)        
    let $cfg := $cfgPath ! doc(.)
    let $markC :=
        if ($mark) then $mark else $cfg//mark => string-join(' ')
    let $replaceC := 
        if ($replace) then $replace
        else $cfg//replaces/replace/concat(@from, '=', @to)
             => string-join(' ')
       
    let $doc := uth:itemToNode($item)
    let $edited :=
        if (not($replaceC)) then $doc else
            let $repls := $replaceC => f:editReplacements()
            return f:performReplacements($doc, $repls)
    let $mcodes := $markC ! tokenize(.) ! f:char2codepoint(.)
    let $markedTable := map:merge(
        for $mcode in $mcodes
        let $from := codepoints-to-string($mcode)
        let $fromRegex := $from ! replace(., '[.+|\\(){}\[\]\^$]', '\\$0')
        let $to := '#['||string($mcode)||']'||$from
        return map:entry($from, map{'from': $fromRegex, 'to': $to}))
    let $marked := $edited ! f:mark(., $mcodes, $markedTable)
    let $result :=
        if ($isDocResource) then uth:updateDocResourceContent($item, $marked)
        else $marked 
    return $result      
};

declare function f:char2codepoint($s as xs:string) as xs:integer {
    if (starts-with($s, '#')) then substring($s, 2) ! xs:integer(.)
    else string-to-codepoints($s)[1]
};

declare function f:editReplacements($replacements as xs:string?)
        as element(replacements)? {
    let $pairs := $replacements ! replace(., '\s*=\*s', '=') ! tokenize(.)        
    return if (empty($pairs)) then () else
    
    let $fnString2char := function($s) {
        if (not(starts-with($s, '#'))) then $s 
        else f:char2codepoint($s) ! codepoints-to-string(.)}
    return
        <replacements>{
            for $pair in $pairs
            let $from := $pair ! replace(., '=.*', '') ! $fnString2char(.)
            let $to := $pair ! replace(., '.*=(.*)', '$1') ! $fnString2char(.)
            return <replacement from="{$from}" to="{$to}"/>
        }</replacements>   
};        
            
declare function f:performReplacements($doc as node(), $replacements as element(replacements)?)
        as node() {
    if (empty($replacements)) then $doc else
    
    let $fnFL := function($string, $rep) {
        $string ! replace(., $rep/@from, $rep/@to)}
    return
        copy $doc_ := $doc
        modify
            for $tnode in $doc_//text()
            let $reps := $replacements/replacement[contains($tnode, @from)]
            where exists($reps)
            let $edited := fold-left($reps, $tnode, $fnFL)
            return replace value of node $tnode with $edited 
        return $doc_
};        

declare function f:mark($doc as node(), $mcodes as xs:integer*, $mtable as map(*))
        as node() {
    let $fnFL := function($accum, $code) {
        let $codeS := codepoints-to-string($code)
        let $fromTo := $accum?mtable($codeS)
        let $string2 := $accum?string ! replace(., $fromTo?from, $fromTo?to)
        return map:put($accum, 'string', $string2)
    }
    return
    copy $doc_ := $doc
    modify
        for $tnode in $doc_//text()
        let $codes := $tnode ! string-to-codepoints(.)[. = $mcodes]
        where exists($codes)
        let $accum := map{'string': string($tnode), 'mtable': $mtable}
        let $accum2 := fold-left($codes => distinct-values(), $accum, $fnFL)
        let $marked := $accum2?string
        return replace value of node $tnode with $marked 
    return $doc_
};        

