module namespace ta="http://www.parsqube.de/xquery/util/table";

import module namespace op="http://www.parsqube.de/xquery/util/options"
    at "options.xqm";

import module namespace opm="http://www.parsqube.de/xquery/util/options-model"
    at "options-model.xqm";

(: ==========================================================================
 :     t a b l e
 : ========================================================================== :)

(:~
 : Transforms a sequence of tuples into a table.
 :)
declare function ta:table($rows as item()*, 
                          $headers as xs:string*,
                          $colspecs as xs:string?,
                          $fnOptions as xs:string?)
        as item() {
    let $countCols := $rows ! array:size(.) => max()  
    let $maxLengths :=
        for $i in 1 to $countCols return
        (: ($rows!?($i) ! ta:flatten(.) ! string-length(.)) => max() :)
        ($rows!?($i) ! ta:flatten(.) ! string-length(.)) => max()        

    (: Evaluate options :)
    let $ops := ($opm:OPTION_MODELS?table !
                 op:optionsMap($fnOptions, ., 'table'), map{})[1]
                 
    (: Finalize options :)
    let $ops := ta:table_finalizeOptions($ops, $countCols)
    
    (: Column models :)
    let $cmodels := ta:table_getColModels($colspecs, $countCols, $maxLengths, $ops)
    
    (: Order models :) 
    let $omodels := ta:table_getOrderModel($ops)
    let $headersPlus :=
        if (count($headers) eq 1) then tokenize($headers, ',\s*') else $headers
        
    (: Write XML "table" :)
    let $xtable := ta:table_getXmlTable(
        $rows, $cmodels, $omodels, $headersPlus, $ops)
    return if ($ops?format eq 'xml') then $xtable else

    (: Transform XMl table in text table :)
    let $table := ta:table_xmlTableToText($xtable, $cmodels, $headersPlus, $ops)
    return $table
};

(:~ 
 : Finalizes the options.
 :)
declare function ta:table_finalizeOptions($ops as map(*), 
                                          $countCols as xs:integer)
        as map(*) {
    let $ops :=
        if (not($ops?hlist)) then $ops else 

        let $order := 
            (for $i in 1 to $countCols return string($i)) => string-join('.')
        return map:put($ops, 'order', $order)
        
    (: ... augment 'reorder', if used :)
    let $ops :=
        let $reorder := $ops?reorder
        return if (not($reorder)) then $ops else
        
        let $items := tokenize($reorder, '\.') ! xs:integer(.) 
                      => distinct-values()
        let $missingCols :=
            if (count($items) eq $countCols) then () 
            else (1 to $countCols)[not(. = $items)]
        return map:put($ops, 'reorder', ($items, $missingCols))
    return $ops    
};

(:~ 
 : Create the column models.
 :)
declare function ta:table_getColModels($colspecs as xs:string?,
                                       $countCols as xs:integer,
                                       $maxLengths as xs:integer*,
                                       $ops as map(*))                                       
        as item()* {
    (: Write preliminary models :)
    let $cspecs := $colspecs ! tokenize(., ',\s*')    
    let $cmodels :=
        let $defaultValues := map:merge((
            $ops?leftalign ! map:entry('leftalign', .),        
            $ops?hanging ! map:entry('hanging', .),
            $ops?initial-prefix ! map:entry('initial-prefix', .),
            $ops?nil ! map:entry('nil', .),            
            $ops?split ! map:entry('split', .),
            $ops?width ! map:entry('width', .)))
        for $i in 1 to $countCols 
        return map:merge((
            $opm:PARAM_MODELS?colspec ! op:optionsMap($cspecs[$i], ., 'table'),        
            $defaultValues))            
 
    (: Adapt model parameter 'width' :)
    let $cmodels :=
        for $cmodel at $cnr in $cmodels
        let $spec := $cmodel?width
        return
            if (empty($spec)) then $cmodel
            else if ($spec eq '*') then map:remove($cmodel, 'width') 
            else if ($spec castable as xs:integer) then 
                $spec ! xs:integer(.) ! map:put($cmodel, 'width', .)
            else if (matches($spec, '^\*\d+')) then
                let $num := substring($spec, 2) ! xs:integer(.)
                let $plus := ($cmodel?initial-prefix ! string-length(.), 0)[1]
                let $maxLen := $maxLengths[$cnr] + $plus
                let $useWidth := min(($maxLen, $num))
                return map:put($cmodel, 'width', $useWidth)
            else $cmodel

    (: Add parameter 'maxwidth' :)
    let $cmodels :=    
        for $cmodel at $cnr in $cmodels
        let $width := $cmodel?width
        let $maxwidth := if (exists($width)) then $width else
            let $plus := ($cmodel?initial-prefix ! string-length(.), 0)[1]
            return $maxLengths[$cnr] + $plus
        return map:put($cmodel, 'maxwidth', $maxwidth)
    return $cmodels        
};

(:~
 : Create the order model.
 : Note: if option "reorder" is specified, the order spec
 : refers to the reordered columns, as the XML table contains
 : reordered columns.
 :)
declare function ta:table_getOrderModel($ops as map(*))
        as item()* {
    let $reorder := $ops?reorder
    let $colMapping :=
        if (empty($reorder)) then ()
        else for $i in 1 to count($reorder) return index-of($reorder, $i)
        
    let $ospecs :=
        let $parts := $ops?order ! tokenize(., '\.')
        for $part in $parts
        let $col := 
            let $prelim := replace($part, '^(\d+).*', '$1') ! xs:integer(.)
            return 
              if (empty($colMapping)) then $prelim else $colMapping[$prelim]
        let $spec := replace($part, '^\d+(.*)', '$1')[. ne $part]
        return
            map{'col': $col, 'spec': $spec}
    let $omodels :=
        for $ospec in $ospecs 
        let $col := $ospec?col
        let $spec := $ospec?spec[normalize-space(.)]
        let $fn :=
            if (ends-with($spec, 'n')) then
                function($row) {
                    try {$row/*[$col]/normalize-space(.)[1] 
                         ! number(.)} catch * {()}}
            else if (ends-with($spec, 'c')) then
                function($row) {
                     $row/*[$col]/normalize-space(.) ! lower-case(.) 
                     => string-join(',')}
            else function($row) {
                     $row/*[$col]/normalize-space(.) 
                     => string-join(',')}
        let $direction :=
            if (empty($spec) or $spec = ('n', 'c')) then 'a' 
            else substring($spec, 1, 1)
        return map{'fn': $fn, 'direction': $direction}
    return $omodels        
};

(:~
 : Write the XML table.
 :)
declare function ta:table_getXmlTable($rows as array(*)*,
                                      $colModels as map(*)*,
                                      $orderModels as map(*)*,
                                      $headersPlus as xs:string*,
                                      $ops as map(*))
        as element() {
    let $countCols := count($colModels)     
    let $reorder := $ops?reorder
    let $colseq := if (exists($reorder)) then $reorder else 1 to $countCols

    let $xtable :=    
        let $tableName := ($headersPlus[starts-with(., 'table=')] 
                          ! replace(., '^table=', ''), 'table')[1]
        let $rowName := ($headersPlus[starts-with(., 'row=')] 
                          ! replace(., '^row=', ''), 'row')[1]        
        let $colnames :=
            if (exists($headersPlus)) then $headersPlus
            else (1 to $countCols) ! ('col'||.)
        let $rows :=
            for $row in $rows return element {$rowName}{
                let $size := array:size($row) 
                for $c in $colseq 
                let $colModel := $colModels[$c]
                let $width := $colModel?width
                let $items := 
                    if ($c gt $size) then () else $row($c) ! ta:flatten(.)
                let $items := 
                    if (empty($items) or count($items) eq 1 and $items = '') 
                    then $colModel?nil 
                    else $items
                let $nitems := count($items)
                let $elemName := $colnames[$c] ! replace(., '\s', '_')
                let $elemName := ($elemName, 'Column')[1]
                return
                    element {$elemName} {
                        for $item at $inr in $items ! normalize-space(.)
                        let $regex := ($colModel?split, $ops?split, '\s+')[1]
                        let $itemContent := $item ! 
                            ta:foldText(., $width, $regex, $colModel) ! <line>{.}</line>
                        let $itemContent2 :=
                            for $line in $itemContent
                            return tokenize($line, '&#xA;') ! <line>{.}</line>
                        return
                            <item>{$itemContent2}</item>
                    }}
        let $rows :=
            if (empty($orderModels)) then $rows 
            else ta:table_sort($rows, $orderModels)
        return
            element {$tableName} {$rows}
    return $xtable          
};

(:~
 : Transforms the XML table into a text representation.
 :)
declare function ta:table_xmlTableToText($xtable as element(),
                                         (: $colMWidths as xs:integer+, :)
                                         $cmodels as map(*)+,
                                         $headers as xs:string*,
                                         $ops as map(*))
        as xs:string {
    let $countCols := count($cmodels)
    let $colseq := 
        let $reorder := $ops?reorder
        return if (exists($reorder)) then $reorder else 1 to $countCols
    let $cmodelsReo := for $i in 1 to $countCols return $cmodels[$colseq[$i]]
    let $maxwidths := for $i in 1 to $countCols return $cmodelsReo[$i]?maxwidth
    let $widths := for $i in 1 to $countCols return $cmodelsReo[$i]?width
    
    let $frameline := '|'||
        string-join($maxwidths ! ta:repeat('-', . + 2), '|')||'|'
    
    let $fnWriteLine := function($ncols, $cols, $cwidths) {
        '| '||string-join(for $i in 1 to $ncols return 
                  ta:rpad($cols[$i], $cwidths[$i], ' '), ' | ')||' |'
    }
    let $fnFramelineHlist := function($row, $cwidths) {
        let $nextRow := $row/following-sibling::*[1]
        let $firstColChange := (
            for $i in 1 to $countCols
            where not($row/*[$i] eq $nextRow/*[$i])
            return $i)[1]
        return
          '|'||string-join(for $i in 1 to $countCols
              let $char :=
                  if ($i eq $countCols or $i ge $firstColChange) then '-'
                  else ' '
              return ta:repeat($char, $cwidths[$i] + 2)||'|', '')
    }    
    let $fnWriteLineHlist := function($ncols, $cols, $cwidths, $row) {
        let $prevRow := $row/preceding-sibling::*[1]
        let $firstColChange := (
            for $i in 1 to $countCols
            where not($row/*[$i] eq $prevRow/*[$i])
            return $i)[1]
        return
          '| '||string-join(
          for $i in 1 to $countCols
          let $value := 
              if ($i eq $countCols or $i ge $firstColChange) then $cols[$i]
              else ' '
          return
            ta:rpad($value, $cwidths[$i], ' '), ' | ')||' |'
    }
    let $headLines :=
        let $headersXml :=
            for $pos in $colseq
            let $header := $headers[$pos]
            let $width := $maxwidths[$pos]
            let $lines := $header ! ta:foldText(., $width, '\s+', ()) 
                                  ! <line>{.}</line>
            return 
                <header>{$lines}</header>
        return if (not($headersXml)) then () else
        
        let $nlines := $headersXml/count(line) => max()
        for $lnr in 1 to $nlines
        let $values := $headersXml/string(line[$lnr])
        return 
            $fnWriteLine($countCols, $values, $maxwidths)
        
    let $rowLines :=
        let $nrows := count($xtable/row)
        for $row at $rnr in $xtable/row return (
        let $nlines := $row/*/count(descendant::line) => max()
        
        for $lnr in 1 to $nlines
        let $values := $row/*/string(descendant::line[$lnr])
        return
            if ($ops?hlist) then
                $fnWriteLineHlist($countCols, $values, $maxwidths, $row)
            else 
                $fnWriteLine($countCols, $values, $maxwidths)
        ,
        if ($ops?hlist) then
            $fnFramelineHlist($row, $maxwidths)[$rnr ne $nrows]
        else
            $frameline[$rnr ne $nrows]
        )
        
    let $tableWidth := 4 + sum($maxwidths) + ($countCols - 1) * 3
    let $frameLine := '#'||ta:repeat('-', $tableWidth - 2)||'#'
    return 
        string-join((    
            if (empty($headLines)) then () else        
            ($frameLine, $headLines),
            $frameLine,
            $rowLines,
            $frameLine
        ), '&#xA;')
};        

(:
(:~
 : Adapt the column value 'width'. Rules:
 : - value missing: no change
 : - value a number: no change
 : - value '*': remove value
 : - value '*number': replace with the minimum of number and maximum col width
 :)
declare function ta:table_adaptColWidths($cmodels as map(*)*, 
                                         $maxLengths as xs:integer*)
        as map(*)* {
    for $cmodel at $cnr in $cmodels
    let $spec := $cmodel?width
    return
        if (empty($spec)) then $cmodel
        else if ($spec eq '*') then map:remove($cmodel, 'width') 
        else if ($spec castable as xs:integer) then 
            $spec ! xs:integer(.) ! map:put($cmodel, 'width', .)
        else if (matches($spec, '^\*\d+')) then
            let $num := substring($spec, 2) ! xs:integer(.)
            let $plus := ($cmodel?initial-prefix ! string-length(.), 0)[1]
            let $maxLen := $maxLengths[$cnr] + $plus
            let $useWidth := min(($maxLen, $num))
            return map:put($cmodel, 'width', $useWidth)
        else $cmodel
};        
:)

(:~
 : Helper function of function `table`. Recursive processes all
 : sort models.
 :)
declare function ta:table_sort($rows as element()*, $omodels as map(*)*)
        as element()* {
    let $omodel := head($omodels)
    let $remainder := tail($omodels)
    let $fn := $omodel?fn
    let $direction := $omodel?direction
    let $sorted := 
        let $prelim := $rows => sort((), $fn)
        return
            if ($direction eq 'd') then reverse($prelim)
            else $prelim
    return if (empty($remainder)) then $sorted else
        
    for $row in $sorted
    group by $key := $fn($row) => string-join(',')
    return
        if (count($row) eq 1) then $row
        else $row => ta:table_sort($remainder)
}; 

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
declare function ta:foldText($t as xs:string,
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
    return $t ! ta:foldTextREC(., $regex, $ops)
};

(:~
 : Recursive helper function of function `foldText`.
 :)
declare function ta:foldTextREC($t as xs:string,
                                $regex as xs:string?,
                                $options as map(*)?)
        as xs:string* {
    let $fnUpdOps := function($ops) {        
        if ($ops?before-first) then 
            let $o1 := map:remove($options, 'before-first')
            let $o2 :=
                if ($ops?hanging) then
                    let $h := $ops?hanging return
                        ta:repeat(' ', $h) 
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
        => ta:foldTextREC($regex, $fnUpdOps($options)))
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
        return ($line, $remainder => ta:foldTextREC($regex, $optionsNext))
};

declare function ta:flatten($item as item())
        as item()* {
    if ($item instance of array(*)) then array:flatten($item) else $item        
};

declare function ta:repeat($string as xs:string, $count as xs:integer)
        as xs:string {
    (for $i in 1 to $count return $string) => string-join('')        
};

(:~
 : Pads a string on the righthand side.
 :)
declare function ta:rpad($s as xs:anyAtomicType?, 
                         $width as xs:integer?, 
                         $char as xs:string?)
        as xs:string? {
    let $s := string($s)
    let $len := string-length($s) 
    return if ($len ge $width) then $s else
    
    let $char := ($char, ' ')[1]
    let $pad := concat(' ', 
      string-join(for $i in 1 to $width - $len - 1 return $char, ''), '')
    return concat($s, $pad)
};




