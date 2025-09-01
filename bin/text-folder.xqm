module namespace tf="http://www.parsqube.de/xquery/util/text-folder";

import module namespace op="http://www.parsqube.de/xquery/util/options"
    at "options.xqm";

import module namespace opm="http://www.parsqube.de/xquery/util/options-model"
    at "options-model.xqm";

(: ==========================================================================
 :     f o l d T e x t
 : ========================================================================== :)
(:~
 : Maps a text to a sequence of lines with a maximum length.
 : If a regex is supplied, line breaks are only inserted
 : within matching substrings, if possible. Otherwise, the
 : line breaks are inserted after the maximum number of
 : line characters, regardless of content.
 :
 : If the width is "*", the text is returned without changes,
 : unless option 'initial-prefix' is specified, in which case
 : the prefix is inserted before the string.
 :
 : Options:
 : - hanging=n - hanging indentation, n characters
 : - initial-prefix=s - the first line begins with this prefix
 : - pre-edit=o - before processing the string it is submitted
 :     to an editing operation:
 :     o = 'ns' => normalize-space
 : - leftalign => returned lines are aligned by removing initial
 :     whitespace characters
 :
 : @param t the text
 : @param width maximum line length
 : @param regex an optional regex defining "breakable"
 :   substrings
 : return a sequence of lines, representing the original text
 :) 
declare function tf:foldText($t as xs:string,
                             $width as xs:integer?,
                             $regex as xs:string?,
                             $options as map(*)?)
        as xs:string* {
    let $options := ($options, map{})[1]        
    let $t := 
        switch($options?pre-edit)
        case 'normalize-space' return normalize-space($t)
        default return $t
    let $ip := $options?initial-prefix
    return 
        if (empty($width)) then $ip||$t
        else if (string-length($t) le $width - string-length($ip)) 
             then $ip||$t else
             
    let $regex :=
        if (not($regex)) then () else switch($regex)
        case 'ws' return '\s+'
        case 'hu' return '[_\-]+'
        default return $regex
    
    let $ops := 
        map:merge(($options,
                   map:entry('width', $width),
                   if (map:contains($options, 'hanging') or
                       map:contains($options, 'initial-prefix')) 
                   then map:entry('before-first', true())
                   else ()
                ))
    return $t ! tf:foldTextREC(., $regex, $ops)
};

(:~
 : Recursive helper function of function `foldText`.
 :)
declare function tf:foldTextREC($t as xs:string,
                                $regex as xs:string?,
                                $options as map(*)?)
        as xs:string* {
    let $fnUpdOps := function($ops) {        
        if ($ops?before-first) then 
            let $o1 := map:remove($options, 'before-first')
            let $o2 :=
                if ($ops?hanging) then
                    let $h := $ops?hanging return
                        tf:repeat(' ', $h) 
                        ! map:put($o1, 'prefix', .)
                        ! map:put(., 'width', $ops?width - $h)
                else $o1
            return $o2
            else $ops}
            
    let $t :=
        (: if ($options?leftalign) then $t ! replace(., '^'||$regex, '') :)
        if ($options?leftalign) then $t ! replace(., '^\s+', '')
        else $t
    
    let $width :=
        if ($options?before-first and $options?initial-prefix) then
            $options?width - string-length($options?initial-prefix)
        else $options?width
    let $prefix := 
        if ($options?before-first and $options?initial-prefix) then
            $options?initial-prefix
        else $options?prefix            
    return
    
    if (string-length($t) le $width) then $prefix||$t else
    
    if (not($regex)) then (
        $prefix||substring($t, 1, $width),
        substring($t, $width + 1) 
        => tf:foldTextREC($regex, $fnUpdOps($options)))
    else
        let $maxlineE := substring($t, 1, $width + 1)
        let $lineRaw := $maxlineE ! 
            replace(., '^(.*)'||$regex||'.*', '$1')[. ne $maxlineE]
        let $lineRawLen := string-length($lineRaw)
        let $suffixLen := $width - $lineRawLen
        let $line := 
            if (not($lineRaw)) then substring($t, 1, $width)
            else
                let $behind := substring($maxlineE, 1 + $lineRawLen)
                let $suffix := 
                    replace($behind, '^('||$regex||').*', '$1')[. ne $behind]
                    ! substring(., 1, $suffixLen)
                return $lineRaw||$suffix
        let $remainder := substring($t, string-length($line) + 1)
        let $line := $prefix||$line
        let $optionsNext := $fnUpdOps($options)
        return ($line, $remainder => tf:foldTextREC($regex, $optionsNext))
};

declare function tf:flatten($item as item())
        as item()* {
    if ($item instance of array(*)) then array:flatten($item) else $item        
};

declare function tf:repeat($string as xs:string, $count as xs:integer)
        as xs:string {
    (for $i in 1 to $count return $string) => string-join('')        
};

(:~
 : Pads a string on the righthand side.
 :)
declare function tf:rpad($s as xs:anyAtomicType?, 
                         $width as xs:integer?, 
                         $char as xs:string?)
        as xs:string? {
    let $s := string($s)
    let $len := string-length($s) 
    return if ($len ge $width) then $s else
    
    let $char := ($char, ' ')[1]
    let $pad := concat( 
      string-join(for $i in 1 to $width - $len return $char, ''), '')
    return concat($s, $pad)
};
