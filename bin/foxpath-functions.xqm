module namespace f="http://www.ttools.org/xquery-functions";

import module namespace i="http://www.ttools.org/xquery-functions" 
at "foxpath-processorDependent.xqm",
   "foxpath-uri-operations.xqm";
   
import module namespace util="http://www.ttools.org/xquery-functions/util" 
at  "foxpath-util.xqm";
  
import module namespace foxf="http://www.foxpath.org/ns/fox-functions" 
at "foxpath-fox-functions.xqm";
    
(: 
 : ===============================================================================
 :
 :     r e s o l v e    s t a t i c    f u n c t i o n    c a l l
 :
 : ===============================================================================
 :)

declare function f:resolveStaticFunctionCall($call as element(), 
                                       $context as item()?, 
                                       $position as xs:integer?, 
                                       $last as xs:integer?,
                                       $vars as map(*)?,
                                       $options as map(*)?)
        as item()* {
    let $fname := $call/@name
    return    
        util:trace(
        
        (: ################################################################
         : p a r t  1:    e x t e n s i o n    f u n c t i o n s
         : ################################################################ :)

        (: function `annotate` 
           =================== :)
        if ($fname eq 'annotate') then
            let $value :=
                if (count($call/*) eq 1) then $context else
                    $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $anno :=
                let $index := if (count($call/*) eq 1) then 1 else 2
                return $call/*[$index]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return $value||' ('||$anno||')'            
                
        (: function `att-lnames` 
           ==================== :)
        else if ($fname eq 'att-lnames') then
            let $nodes := 
                if ($call/*) then $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context
            let $nameFilter := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $nameFilterExclude := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            return
                foxf:attNames($nodes, true(), 'lname', $nameFilter, $nameFilterExclude)

        (: function `att-names` 
           =================== :)
        else if ($fname eq 'att-names') then
            let $nodes := 
                if ($call/*) then $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context
            let $nameFilter := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $nameFilterExclude := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            return
                foxf:attNames($nodes, true(), 'name', $nameFilter, $nameFilterExclude)

        (: function `atts` 
           =============== :)
        else if ($fname eq 'atts') then
            let $flags := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:atts($context, $flags)

        (: functions `axis, ec-axis` 
           ========================= :)
        else if ($fname = ('ancestor', 'ec-ancestor', 
                           'ancestor-or-self', 'ec-ancestor-or-self',
                           'parent', 'ec-parent',
                           'self', 'ec-self',
                           'child', 'ec-child',
                           'descendant', 'ec-descendant',
                           'descendant-or-self', 'ec-descendant-or-self',
                           'sibling', 'ec-sibling',                           
                           'preceding-sibling', 'ec-preceding-sibling',
                           'following-sibling', 'ec-following-sibling',
                           'parent-sibling', 'ec-parent-sibling',                           
                           'all-descendant', 'ec-all-descendant',
                           'all-descendant-or-self', 'ec-all-descendant-or-self')) 
        then
            let $da := if (starts-with($fname, 'ec-')) then 1 else 0
            let $axis := $fname ! replace(., '^ec-', '')
            let $narg := count($call/*)
            let $args := $call/([
               *[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)[$narg gt 0],
               *[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)[$narg gt 1],
               *[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)[$narg gt 2],
               *[4]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)[$narg gt 3],
               *[5]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)[$narg gt 4]
            ])
            let $nodes := if ($da eq 0) then $context else $args(1)
            return
                foxf:nodeNavigation($nodes, $axis, $args(1 + $da), $args(2 + $da), $args(3 + $da), $args(4 + $da))

        (: function `back-slash` 
           ===================== :)
        else if ($fname eq 'back-slash' or $fname eq 'bslash') then
            let $arg := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    ($explicit, $context)[1]
            return
                foxf:bslash($arg)

        (: function `base-dir-name` 
           ========================= :)
        else if ($fname = ('base-dir-name', 'base-dname', 'bdname')) then
            let $contextItem :=
                if (empty($call/*)) then $context
                else $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:baseUriDirectory($contextItem)                

        (: function `base-file-name` 
           ========================= :)
        else if ($fname = ('base-file-name', 'base-fname', 'bfname')) then
            let $contextItem :=
                if (empty($call/*)) then $context
                else $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:baseUriFileName($contextItem)
            
        (: function `base-uri-relative` 
           ============================ :)
        else if ($fname = ('base-uri-relative', 'buri-relative', 'burirel')) then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            return foxf:baseUriRelative($context, $arg1)
            
       (: function `both-values` 
          ====================== :)
        else if ($fname = ('both-values', 'bvalues')) then
            let $leftValue := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $rightValue := $call/*[2] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:bothValues($leftValue, $rightValue)
            
        (: function `child-jnames` 
           ======================= :)
        else if ($fname eq 'child-jnames') then
            let $node := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return if (exists($explicit)) then $explicit else $context
            let $nosort := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options) ! xs:boolean(.)                
            let $namePattern := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $excludedNamePattern := $call/*[4]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)    
            return foxf:childNames($node, true(), 'jname', $namePattern, $excludedNamePattern, $nosort)            

        (: function `child-lnames` 
           ====================== :)
        else if ($fname eq 'child-lnames') then
            let $node := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return if (exists($explicit)) then $explicit else $context
            let $nosort := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options) ! xs:boolean(.)                
            let $namePattern := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $excludedNamePattern := $call/*[4]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:childNames($node, true(), 'lname', $namePattern, $excludedNamePattern, $nosort)            

        (: function `child-names` 
           ===================== :)
        else if ($fname eq 'child-names') then
            let $node := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return if (exists($explicit)) then $explicit else $context
            let $nosort := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options) ! xs:boolean(.)                
            let $namePattern := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $excludedNamePattern := $call/*[4]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)                
            return foxf:childNames($node, true(), 'name', $namePattern, $excludedNamePattern, $nosort)            

        (: function `contains-text` 
           ======================== :)
        else if ($fname eq 'contains-text') then
            let $text :=
                if (count($call/*) eq 1) then $context else
                    $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $selections :=
                let $index := if (count($call/*) eq 1) then 1 else 2
                return $call/*[$index]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:containsText($text, $selections)            
                
        (: function `content-deep-equal` 
           ============================= :)
        else if ($fname eq 'content-deep-equal') then
            let $args := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $scope := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:contentDeepEqual($args, $scope) 

        (: function `count-chars` 
           ====================== :)
        else if ($fname eq 'count-chars') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            let $s := if ($arg2) then $arg1 else $context
            let $char := ($arg2, $arg1)[1]
            return
                foxf:countChars($s, $char)

        (: function `create-dir` 
           ====================== :)
        else if ($fname eq 'create-dir') then
            let $path := 
                let $explicit := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    if ($explicit) then $explicit else $context
            return
                file:create-dir($path)

        (: function `csv-doc` 
           =================== :)
        else if ($fname = ('csv-doc', 'cdoc')) then        
            let $uri := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            let $separator := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $header := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            let $names := $call/*[4]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $quotes := $call/*[5]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            let $backslashes := $call/*[6]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                
            return
                if (empty($separator)) then i:fox-csv-doc($uri, $options)
                else if (empty($header)) then i:fox-csv-doc($uri, $separator, $options)
                else if (empty($names)) then i:fox-csv-doc($uri, $separator, $header, $options)
                else if (empty($quotes)) then i:fox-csv-doc($uri, $separator, $header, $names, $options)
                else i:fox-csv-doc($uri, $separator, $header, $names, $quotes, $backslashes, $options)
                            
        (: function `dcat` 
           =============== :)
        else if ($fname eq 'dcat') then
            let $items := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            (: remove prefix from basex URIs (should there be such URIs) :)
            let $items := $items ! replace(., '^basex://', '')            
            let $onlyDocAvailable := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $refs :=
                for $item in $items
                return
                    if ($onlyDocAvailable and not(i:fox-doc-available($item, $options))) then () 
                    else <doc href="{$item}"/>
            return
                <dcat targetFormat="xml" 
                      count="{count($items)}"
                      t="{current-dateTime()}" 
                      onlyDocAvailable="{boolean($onlyDocAvailable)}">{$refs}</dcat>
                            
        (: function `descendant-jnames` 
           ============================ :)
        else if ($fname eq 'descendant-jnames') then
            let $node := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            let $namePattern := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $excludedNamePattern := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:descendantNames($node, true(), 'jname', $namePattern, $excludedNamePattern)            

        (: function `descendant-lnames` 
           ============================ :)
        else if ($fname eq 'descendant-lnames') then
            let $node := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            let $namePattern := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $excludedNamePattern := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:descendantNames($node, true(), 'lname', $namePattern, $excludedNamePattern)            

        (: function `descendant-names` 
           =========================== :)
        else if ($fname eq 'descendant-names') then
            let $node := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            let $namePattern := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $excludedNamePattern := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:descendantNames($node, true(), 'name', $namePattern, $excludedNamePattern)            

        (: function `dir-name` 
           ==================== :)
        else if ($fname eq 'dir-name' or $fname eq 'dname') then
            let $uri := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    ($explicit, $context)[1]
            return
                replace($uri[1], '^(.*[/\\])?(.+?)[/\\][^/\\]*$', '$2')[not(. eq $uri)]
            
        (: function `distinct` 
           =================== :)
        else if ($fname eq 'distinct') then
            let $values := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                count(distinct-values($values)) eq count($values)
                            
        (: function `echo` 
           =============== :)
        else if ($fname eq 'echo') then
            let $val := trace($call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options) , 'VAL: ')        
            return
                $val

(: the following function is at risk:
    eval-xpath
:)
        (: function `eval-xpath` 
           ===================== :)
        else if ($fname = ('eval-xpath', 'xpath')) then
            let $xpath := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)  
            let $xpathContext :=
                let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($arg2, $context)
            let $xpathContextNode :=
                if ($xpathContext instance of node()) then $xpathContext
                else if (exists($xpathContext)) then i:fox-doc($xpathContext, $options)
                else ()
            return
                i:xquery($xpath, map{'':$xpathContextNode})

        (: functions `faxis, ec-faxis` 
           =========================== :)
        else if ($fname = ('fancestor', 'ec-fancestor', 
                           'fancestor-or-self', 'ec-fancestor-or-self',
                           'fparent', 'ec-fparent',
                           'fself', 'ec-fself',
                           'fchild', 'ec-fchild',
                           'fdescendant', 'ec-fdescendant',
                           'fdescendant-or-self', 'ec-fdescendant-or-self',
                           'fpreceding-sibling', 'ec-fpreceding-sibling',
                           'ffollowing-sibling', 'ec-ffollowing-sibling',
                           'fsibling', 'ec-fsibling',
                           'fparent-sibling', 'ec-fparent-sibling')) 
        then
            let $da := if (starts-with($fname, 'ec-')) then 1 else 0
            let $axis := $fname ! replace(., '^f|ec-f', '')
            let $narg := count($call/*)
            let $args := $call/([
               *[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)[$narg gt 0],
               *[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)[$narg gt 1],
               *[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)[$narg gt 2],
               *[4]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)[$narg gt 3],
               *[5]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)[$narg gt 4]
            ])
            let $uris := if ($da eq 0) then $context else $args(1)
            return
                foxf:foxNavigation($uris, $axis, $args(1 + $da), $args(2 + $da), $args(3 + $da), $args(4 + $da))
                
        (: function `file-append-text` 
           =========================== :)
        else if ($fname = ('file-append-text')) then
            let $file := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $data :=
                if (count($call/*) le 1) then $context else $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $encoding := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                if ($encoding) then file:append-text($file, $data, $encoding) else file:append-text($file, $data)
                
        (: function `file-append-text-lines` 
           ================================= :)
        else if ($fname = ('file-append-text-lines')) then
            let $file := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $data :=
                if (count($call/*) le 1) then $context else $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $encoding := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)                
            return
                if ($encoding) then file:append-text-lines($file, $data, $encoding) else file:append-text-lines($file, $data)
                
        (: function `file-basename` 
           ======================== :)
        else if ($fname = ('file-basename', 'file-bname', 'fbname')) then
            let $uri := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                replace($uri[1], '.*[/\\]', '') ! replace(., '\.[^.]+$', '')
            
        (: function `file-contains` 
           ======================= :)
        else if ($fname eq 'file-contains') then
            let $pattern :=
                if ($call/*[2]) then
                    $call/*[2]
                    /f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else if ($call/*) then
                    $call/*[1]
                    /f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else 
                    error(QName((), 'INVALID_CALL'), 
                        'Function "file-contains" requires at least one parameter.')
            let $uri :=
                if ($call/*[2]) then
                    $call/*[1]
                    /f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context
            let $text :=
                try {i:fox-unparsed-text($uri, (), $options)} catch * {()}
            return
                if (not($text)) then () else
                let $regex := replace($pattern, '\*', '.*')
                return
                    matches($text, $regex, 'si')
            
        (: function `file-content` 
           ======================= :)
        else if ($fname = ('file-content', 'fcontent')) then
            let $start := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $end := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $uri :=
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]

            let $text := f:fox-unparsed-text($uri, (), $options)
            let $start := if ($start < 0) then string-length($text) + $start else $start
            let $end := if ($end < 0) then string-length($text) + $end else $end
            let $text := if (not($start) and not($end)) then $text
                         else if (not($end)) then substring($text, $start)
                         else if (not($start)) then substring($text, 1, $end - 1)
                         else substring(substring($text, 1, $end - 1), $start)
            return
                $text
                
        (: function `file-copy` 
           ======================= :)
        else if ($fname = ('file-copy', 'fcopy')) then
            let $countArgs := count($call/*)
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $file := if (count($call/*) gt 1) then $arg1 else $context 
            let $target := if ($countArgs le 1) then $arg1 else
                $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $flags := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options) ! lower-case(.)
            return
                foxf:fileCopy($file, $target, $flags)
                
        (: function `file-date` 
           ==================== :)
        else if ($fname eq 'file-date' or $fname eq 'fdate') then
            let $uri := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    ($explicit, $context)[1]
            return
                i:fox-file-date($uri, $options)
            
        (: function `file-date-string` 
           =========================== :)
        else if ($fname eq 'file-date-string' or $fname eq 'fdates') then
            let $uri := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    ($explicit, $context)[1]
            return
                i:fox-file-date($uri, $options) ! string(.)
            
       (: function `file-exists` 
          ===================== :)
        else if ($fname eq 'file-exists') then
            let $uri := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    ($explicit, $context)[1]
            return
                i:fox-file-exists($uri, $options)
                
        (: function `file-extension` 
           ========================= :)
        else if ($fname = ('file-extension', 'file-ext', 'fext')) then
            let $uri :=
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)          
                return
                    ($explicit, $context)[1]
            let $fileName := replace($uri, '.*/', '')
            return
                if (not(contains($fileName, '.'))) then ()
                else replace($fileName, '.*(\..*)', '$1')
            
        (: function `file-info` 
           ==================== :)
        else if ($fname = ('file-info', 'finfo')) then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:fileInfo($context, $arg1, $options)

       (: function `file-lines` 
          ===================== :)
        else if ($fname = ('file-lines', 'flines')) then
            let $line1 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $line2 := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            let $pattern := $call/*[4]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            
            let $uri := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)          
                return
                    ($explicit, $context)[1]
            let $regex :=
                if (not($pattern)) then ()
                else concat('^.*', replace(replace($pattern, '\*', '.*'), '\?', '.'), '.*$')
                
            let $lines := i:fox-file-lines($uri, (), $options)
            let $lines := 
                if (not($line1) and not($line2)) then $lines else
                    let $l1 := if ($line1 lt 0) then count($lines) + 1 + $line1 else $line1
                    let $l2 := if ($line2 lt 0) then count($lines) + 1 + $line2 else $line2
                    return
                        $lines[(empty($l1) or position() ge $l1) and (not($l2) or position() le $l2)]                 
            let $lines := if (empty($regex)) then $lines else $lines[matches(., $regex, 'i')]
            return
                $lines 

        (: function `file-name` 
           ==================== :)
        else if ($fname eq 'file-name' or $fname eq 'fname') then
            let $uri := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    ($explicit, $context)[1]
            return
                replace($uri[1], '.*[/\\]', '')
            
        (: function `file-sdate` 
           ===================== :)
        else if ($fname eq 'file-sdate' or $fname eq 'fsdate') then
            let $uri := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    ($explicit, $context)[1]
            return
                f:fox-file-sdate($uri, $options)

       (: function `file-size` 
          ==================== :)
        else if ($fname = ('file-size', 'fsize')) then
            let $uri := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    ($explicit, $context)[1]
            return
                i:fox-file-size($uri, $options)

        (: function `fn-contains-text` 
           =========================== :)
        else if ($fname eq 'fn-contains-text') then
            let $selections := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $toplevelOr := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:fnContainsText($selections, $toplevelOr)            
                
        (: function `fractions` 
           ====================== :)
        else if ($fname = ('fractions', 'frac')) then
            let $values := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $compareWith := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options) 
            let $operator := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $format := $call/*[4]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $compareAs := $call/*[5]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            return
                foxf:fractions($values, $compareWith, $operator, $format, $compareAs)

        (: function `frequencies` 
           ====================== :)
        else if ($fname = ('frequencies', 'f', 'freq')) then
            let $values := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $min := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $max := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $order := $call/*[4]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            let $format := $call/*[5]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:frequencies($values, $min, $max, 'count', $order, $format)

        (: function `ft-tokenize` 
           ====================== :)
        else if ($fname = ('ft-tokenize', 'fttok')) then  
            let $narg := count($call/*)
            let $text := 
                if ($narg eq 0) then $context
                else $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $options := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:ftTokenize($text, $options)

       (: function `grep` 
          =============== :)
        else if ($fname eq 'grep') then        
            let $narg := count($call/*)
            let $da := if ($narg eq 1) then 0 else 1            
            let $args := $call/([
               *[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)[$narg gt 0],
               *[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)[$narg gt 1],
               *[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)[$narg gt 2],
               *[4]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)[$narg gt 3]
            ])
            let $uris := if ($narg eq 1) then $context else $args(1)
            return
                foxf:grep($uris, $args(1 + $da), $args(2 + $da), $args(3 + $da))
                
        (: function `hlist` 
           ================ :)
        else if ($fname = ('hlist')) then
            let $values := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $headers := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                            (: ! normalize-space(.) ! tokenize(.) :)
            let $emptyLines := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:hlist($values, $headers, $emptyLines)

        (: function `html-doc` 
           =================== :)
        else if ($fname = ('html-doc', 'hdoc')) then
            let $uri :=
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            let $doc-text := f:fox-unparsed-text($uri, (), $options)
            let $doc := $doc-text ! html:parse(.)
            return (
                $doc
            )
                            
        (: function `html-doc-available` 
           ============================= :)
        else if ($fname = ('html-doc-available', 'is-html')) then
            let $uri :=
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                exists(f:fox-unparsed-text($uri, (), $options))
                            
       (: function `indent` 
          ===================== :)
        else if ($fname = 'indent') then
            let $lines := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $indent := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $indentChar := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            
            let $indent := 
                if (empty($indent)) then 4
                else $indent[. castable as xs:integer] ! xs:integer(.)
            let $indentChar := ($indentChar ! normalize-space(.) ! substring(., 1, 1), ' ')[1]
            let $prefix := (for $i in 1 to $indent return $indentChar) => string-join('')            
            return $lines ! concat($prefix, .)

        (: function `in-scope-namespaces` 
           ============================= :)
        else if ($fname eq 'in-scope-namespaces') then
            let $elem := 
                let $explicit := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    ($explicit, $context)[1]
            return
                foxf:inScopeNamespaces($elem)

        (: function `in-scope-namespaces-descriptor` 
           ======================================== :)
        else if ($fname eq 'in-scope-namespaces-descriptor') then
            let $elem := 
                let $explicit := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    ($explicit, $context)[1]
            return
                foxf:inScopeNamespacesDescriptor($elem)

        (: function `is-dir` 
           ================= :)
        else if ($fname = ('is-dir', 'isDir')) then
            let $uri :=
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    ($explicit, $context)[1]
            return
                i:fox-is-dir($uri, $options)            
            
        (: function `is-file` 
           ================== :)
        else if ($fname = ('is-file', 'isFile')) then
            let $uri := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    ($explicit, $context)[1]
            return
                i:fox-is-file($uri, $options)
            
        (: function `is-xml` 
           ================ :)
        else if ($fname = ('is-xml', 'isXml')) then
            let $uri := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                i:fox-doc-available($uri, $options)
            
        (: function `jname-path` 
           ==================== :)
        else if ($fname = ('jname-path', 'jnpath', 'jnp')) then           
            let $nodes := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return if ($explicit) then $explicit else $context
            return
                if (empty($nodes)) then () else
                    let $numSteps := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                    return foxf:namePath($nodes, 'jname', $numSteps)

        (: function `jnode-location` 
           ========================= :)
        else if ($fname = ('jnode-location', 'jlocation')) then
            let $nodes :=
                if ($call/*) then $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context
            let $numFolders := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:nodesLocationReport($nodes, 'jname', $numFolders)

        (: function `jpath-compare` 
           ======================= :)
        else if ($fname = ('jpath-compare', 'jpathcmp')) then           
            let $docs := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $options := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:pathCompare($docs, 'jname', $options)

        (: function `jpath-content` 
           ======================== :)
        else if ($fname = ('jpath-content', 'jpcontent')) then           
            let $c := $context
            let $alsoInnerNodes := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options) 
            let $includedNames := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $excludedNames := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $excludedNodes := $call/*[4]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            return
                foxf:pathContent($c, 'jname', $alsoInnerNodes, $includedNames, $excludedNames, $excludedNodes)

        (: function `jschema-keywords` 
           ========================== :)
        else if ($fname = ('jschema-keywords', 'jskeywords')) then
            let $nodes := 
                if ($call/*) then $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context
            let $names := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)                
            let $namesExcluded := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:jschemaKeywords($nodes, $names, $namesExcluded)                            

        (: function `jsoncat` 
           ================== :)
        else if ($fname eq 'jsoncat') then
            let $items := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $onlyDocAvailable := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $refs :=
                for $item in $items
                return
                    if ($onlyDocAvailable and i:fox-json-doc-available($item, $options)) then () 
                    else <json href="{$item}"/>
            return
                <jsoncat targetFormat="json" t="{current-dateTime()}" count="{count($refs)}">{$refs}</jsoncat>
                            
        (: function `json-doc` 
           =================== :)
        else if ($fname = ('json-doc', 'jdoc')) then
            let $uri := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                i:fox-json-doc($uri, $options)
                            
        (: function `json-doc-available` 
           ============================= :)
        else if ($fname = ('json-doc-available', 'jdoc-available', 'is-json')) then
            let $uri := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                try {i:fox-json-doc-available($uri, $options)} catch * {false()}

        (: function `json-effective-value` 
           =============================== :)
        else if ($fname = ('json-effective-value', 'jsoneff', 'jeff')) then
            let $value := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    if (exists($explicit)) then $explicit 
                    else $context
            return
                $value ! foxf:jsonEffectiveValue(.)            

        (: function `json-name`, `jname` 
           ============================= :)
        else if ($fname = ('json-name', 'jname')) then
            let $arg := 
                if ($call/*) then $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context
            return foxf:jname($arg)

        (: function `json-parse` 
           ===================== :)
        else if ($fname = ('json-parse', 'jparse')) then
            let $text :=
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                json:parse($text)

       (: function `left-value-only` 
          ========================== :)
        else if ($fname = ('left-value-only', 'left-value')) then
            let $leftValue := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $rightValue := $call/*[2] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:leftValueOnly($leftValue, $rightValue)

       (: function `linefeed` 
          ================== :)
        else if ($fname eq 'linefeed') then
            if (not($call/*)) then '&#xA;'
            else
                let $count := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    string-join(for $i in 1 to $count return '&#xA;')
        
       (: function `lines` 
          ===================== :)
        else if ($fname = 'lines') then
            let $text := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $lines := tokenize($text, '&#xA;')
            return
                $lines 

        (: function `lname-path` 
           ==================== :)
        else if ($fname = ('lname-path', 'lnpath', 'lnp')) then
            let $nodes := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return if ($explicit) then $explicit else $context
            return
                if (empty($nodes)) then () else
                    let $numSteps := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                    return foxf:namePath($nodes, 'lname', $numSteps)

        (: function `lnode-location` 
           ========================= :)
        else if ($fname = ('lnode-location', 'llocation')) then
            let $nodes :=
                if ($call/*) then $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context
            let $numFolders := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:nodesLocationReport($nodes, 'lname', $numFolders)

        (: function `lpad` 
           =============== :)
        else if ($fname eq 'lpad') then
            let $string := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $width := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)          
            let $fillChar := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $fillChar := ($fillChar, ' ')[1]
            return
                foxf:lpad($string, $width, $fillChar)

        (: function `lpath-compare` 
           ======================= :)
        else if ($fname = ('lpath-compare', 'lpathcmp')) then           
            let $docs := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $options := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:pathCompare($docs, 'lname', $options)

        (: function `lpath-content` 
           ======================= :)
        else if ($fname = ('lpath-content', 'lpcontent')) then           
            let $c := $context
            let $alsoInnerNodes := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options) 
                               ! xs:boolean(.)
            let $includedNames := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $excludedNames := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $excludedNodes := $call/*[4]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            return
                foxf:pathContent($c, 'lname', $alsoInnerNodes, $includedNames, $excludedNames, $excludedNodes)

        (: function `matches-xpath` 
           ======================= :)
        else if ($fname eq 'matches-xpath') then
            let $xpath := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $xpathContext :=
                let $explicit := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            let $xpathContextNode :=
                if ($xpathContext instance of node()) then $xpathContext
                else if (exists($xpathContext)) then i:fox-doc($xpathContext, $options)
                else ()
            return
                boolean(i:xquery($xpath, map{'':$xpathContextNode})[1])
    
        (: function `median` 
           ================= :)
        else if ($fname eq 'median') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            return foxf:median($arg)
            
        (: function `name-path` 
           ==================== :)
        else if ($fname = ('name-path', 'npath', 'np')) then
            let $nodes :=
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return if (exists($explicit)) then $explicit else $context
            return
                if (empty($nodes)) then () else
                    let $numSteps := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                    return foxf:namePath($nodes, 'name', $numSteps)

        (: function `node-location` 
           ======================== :)
        else if ($fname = ('node-location', 'nlocation')) then
            let $nodes :=
                if ($call/*) then $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context
            let $numFolders := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:nodesLocationReport($nodes, 'name', $numFolders)

        (: function `non-distinct-file-names` 
           ================================== :)
        else if ($fname = ('non-distinct-file-names', 'non-distinct-fnames')) then
            let $uris := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $ignoreCase := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                               ! xs:boolean(.)            
            return foxf:nonDistinctFileNames($uris, $ignoreCase)                

        (: function `non-distinct-values` 
           ============================== :)
        else if ($fname = ('non-distinct-values', 'non-distinct')) then
            let $values := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $ignoreCase := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                               ! xs:boolean(.)
            return foxf:nonDistinctValues($values, $ignoreCase)

        (: function `oas-jschema-keywords` 
           ================================ :)
        else if ($fname = ('oas-jschema-keywords')) then
            let $nodes :=
                if (count($call/*) le 1) then $context
                else $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $names := 
                let $index := if (count($call/*) le 1) then 1 else 2
                return $call/*[$index]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $namesExcluded := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:oasJschemaKeywords($nodes, $names, $namesExcluded)            

        (: function `oas-keywords` 
           ======================= :)
        else if ($fname = ('oas-keywords')) then
            let $nodes := 
                if ($call/*) then $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context
            let $names := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)                
            let $namesExcluded := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:oasKeywords($nodes, $names, $namesExcluded)            

        (: function `oas-msg-schemas` 
           ========================== :)
        else if ($fname = ('oas-msg-schemas', 'oasmsgs')) then
            let $nodes := 
                if ($call/*) then $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context
            return foxf:oasMsgSchemas($nodes)            

        (: function `order-diff` 
           ===================== :)
        else if ($fname eq 'order-diff') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            let $arg3 := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:orderDiff($arg1, $arg2, $arg3)
                
        (: function `pads` 
           =============== :)
        else if ($fname eq 'pads') then
            let $values := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $widths := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $widths := string($widths)
            let $widthItems := tokenize(normalize-space(lower-case($widths)), ' ')            
            return
                string-join(
                    for $value at $pos in $values
                    let $value := string($value)
                    let $widthItem := trace($widthItems[$pos] , 'WIDTH_ITEM: ')
                    let $width := trace(replace($widthItem, '\D', '') ! xs:integer(.) , 'WIDTH: ')
                    return
                        if (not($width) or string-length($value) ge $width) then concat($value, ' ') 
                        else
                            let $flags := trace(replace($widthItem, '\d', '') , 'FLAGS: ')
                            let $func := trace(if (substring($flags, 1, 1) eq 'l') then foxf:lpad#3 else foxf:rpad#3 , 'FUNC: ')
                            let $side := if (substring($flags, 1, 1) eq 'l') then 'l' else 'r'                            
                            let $fill := substring($flags, 2, 1)
                            return 
                            (:
                                $func($value, $width, $fill)
                                :)
                                if ($side eq 'l') then foxf:lpad($value, $width, $fill)
                                else foxf:rpad($value, $width, $fill)
                , '')

        (: function `parent-jname` 
           ====================== :)
        else if ($fname eq 'parent-jname') then
            let $node := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                foxf:parentName($node, 'jname')            

        (: function `parent-lname` 
           ====================== :)
        else if ($fname eq 'parent-lname') then
            let $node := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                foxf:parentName($node, 'lname')            

        (: function `parent-name` 
           ====================== :)
        else if ($fname eq 'parent-name') then
            let $node := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                foxf:parentName($node, 'name')            

        (: function `path-compare` 
           ======================= :)
        else if ($fname = ('path-compare', 'pathcmp')) then           
            let $docs := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $options := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:pathCompare($docs, 'name', $options)

        (: function `path-content` 
           ======================= :)
        else if ($fname = ('path-content', 'pcontent')) then           
            let $c := $context
            let $alsoInnerNodes := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                               ! xs:boolean(.)            
            let $includedNames := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $excludedNames := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $excludedNodes := $call/*[4]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            return
                foxf:pathContent($c, 'name', $alsoInnerNodes, $includedNames, $excludedNames, $excludedNodes)

        (: function `percent` 
           ================== :)
        else if ($fname = ('percent')) then           
            let $values := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $value2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            let $fractionDigits := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            return
                foxf:percent($values, $value2, $fractionDigits)

        (: function `pfrequencies` 
           ======================= :)
        else if ($fname = ('pfrequencies', 'pfreq', 'pf')) then
            let $values := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $min := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $max := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $order := $call/*[4]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $format := $call/*[5]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:frequencies($values, $min, $max, 'percent', $order, $format)

        (: function `ps.copy` 
           ===================== :)
        else if ($fname eq 'ps.copy') then
            let $items := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $targetDir := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            let $silent := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            let $useItems :=
                for $item in $items return replace($item, '/', '\\')
            let $copies := $useItems ! concat('Copy-Item ', ., ' ', $targetDir)
            return
                string-join((
                    'Param($odir = $targetDir)',
                    $copies
                ), '&#xA;')
            
        (: function `rcat` 
           =============== :)
        else if ($fname eq 'rcat') then
            let $items := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $refs :=
                for $item in $items
                return
                    <resource href="{$item}"/>
            return
                <rcat t="{current-dateTime()}" count="{count($refs)}">{$refs}</rcat>
                           
       (: function `relevant-xsds` 
          ======================== :)
        else if ($fname = ('relevant-xsds', 'rxsds')) then
            let $arg1 := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg2 := $call/*[2] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $docs := if (exists($arg2)) then $arg1 else $context
            let $xsds := if (exists($arg2)) then $arg2 else $arg1
            return
                foxf:relevantXsds($docs, $xsds)

        (: function `rel-path` 
           =================== :)
        else if ($fname eq 'rel-path') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                if (empty($arg2)) then foxf:relPath($context, $arg1)
                else foxf:relPath($arg1, $arg2)


        (: function `remove-prefix` 
           ======================= :)
        else if ($fname eq 'remove-prefix') then
            let $name := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                foxf:removePrefix($name)            
                            
        (: function `repeat` 
           ================= :)
        else if ($fname eq 'repeat') then
            let $string := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $count := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)          
            return
                foxf:repeat($string, $count)
                
        (: function `resolve-json-allof` 
           ============================ :)
        else if ($fname = ('resolve-json-allof', 'jallof')) then
            let $allOf := 
                if ($call/*) then $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context
            return foxf:resolveJsonOneOf($allOf)            
                            
        (: function `resolve-json-anyof` 
           ============================ :)
        else if ($fname = ('resolve-json-anyof', 'janyof')) then
            let $anyOf := 
                if ($call/*) then $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context
            return foxf:resolveJsonOneOf($anyOf)            
                            
        (: function `resolve-json-oneof` 
           ============================ :)
        else if ($fname = ('resolve-json-oneof', 'joneof')) then
            let $oneOf := 
                if ($call/*) then $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context
            return foxf:resolveJsonOneOf($oneOf)            
                            
        (: function `resolve-json-ref` 
           ========================== :)
        else if ($fname = ('resolve-json-ref', 'jsonref', 'jref')) then
            let $ref := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            let $context := $context ! root() ! descendant-or-self::*[1]  
            let $mode := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                $context ! foxf:resolveJsonRef($ref, ., $mode)            

        (: function `resolve-link` 
           ======================= :)
        else if ($fname eq 'resolve-link') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            return
                foxf:resolveLink($arg1, $arg2)

        (: function `resolve-path` 
           ====================== :)
        else if ($fname eq 'resolve-path') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                (: Resolves the path and turns it into URI without trailing / :)
                file:resolve-path($arg1) ! file:path-to-uri(.) ! replace(., '/$', '')
                  
        (: function `resolve-xsdtype-ref` 
           ============================== :)
        else if ($fname = ('resolve-xsdtype-ref', 'typeref')) then
            let $ref := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            let $context := $context ! root() ! descendant-or-self::xs:schema[1]                
            return
                $context ! foxf:resolveXsdTypeRef($ref, .)            
                            
       (: function `right-value-only` 
          =========================== :)
        else if ($fname = ('right-value-only', 'right-value')) then
            let $leftValue := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $rightValue := $call/*[2] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:rightValueOnly($leftValue, $rightValue)

        (: function `row` 
           ============== :)
        else if ($fname = ('row', 'hlist-entry')) then
            let $items := $call/* ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:row($items)

        (: function `rpad` 
           =============== :)
        else if ($fname eq 'rpad') then
            let $string := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $width := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)          
            let $fillChar := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $fillChar := ($fillChar, ' ')[1]
            return
                foxf:rpad($string, $width, $fillChar)

        (: function `serialize` 
           ==================== :)
        else if ($fname eq 'serialize') then
            let $nodes := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                $nodes/serialize(.)

        (: function `shift-uri` 
           ==================== :)
        else if ($fname eq 'shift-uri') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg3 := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                if (count($call/*) gt 2) then foxf:shiftURI($arg1, $arg2, $arg3)
                else foxf:shiftURI($context, $arg1, $arg2)

        (: function `table` 
           ================ :)
        else if ($fname = ('table')) then
            let $values := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $headers := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                            (: ! normalize-space(.) ! tokenize(.) :)
            return
                foxf:table($values, $headers)

        (: function `text-to-codepoints` 
           ============================= :)
        else if ($fname eq 'text-to-codepoints') then
            let $text := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return if (exists($explicit)) then $explicit else $context
            return
                foxf:textToCodepoints($text)

        (: function `truncate` 
           =================== :)
        else if ($fname = ('truncate', 'trunc')) then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg3 := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $string := if (count($call/*) eq 1) then $context else $arg1
            let $len := if (count($call/*) eq 1) then $arg1 else $arg2               
            let $flags := $arg3
            return
                foxf:truncate($string, $len, $flags)

        (: function `unescape-json-name` 
           ============================= :)
        else if ($fname = 'unescape-json-name') then
            let $string := 
                let $explicit := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    ($explicit, $context)[1]
            return
                foxf:unescapeJsonName($string)
                
        (: function `value` 
           ================ :)
        else if ($fname eq 'value') then
            let $value :=
                $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                if (exists($value)) then $value else
                $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                
        (: function `values-distinct` 
           ========================== :)
        else if ($fname eq 'values-distinct') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            return
                count(distinct-values($arg)) eq count($arg)                
            
        (: function `win.copy` 
           ===================== :)
        else if ($fname eq 'win.copy') then
            let $items := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $targetDir := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            let $silent := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            let $useItems :=
                for $item in $items return replace($item, '/', '\\')
            let $copies :=
                if ($silent) then $useItems ! concat('copy ', ., ' ', $targetDir)
                else
                    for $item in $useItems
                    return
                        concat('echo copy ', $item, ' ', $targetDir, '&#xA;copy ', $item, ' ', $targetDir)
            return
                string-join((
                    '@echo off',
                    if ($silent) then () else
                        concat('echo copy ', count($copies), ' files ...'),
                    $copies
                ), '&#xA;')
                            
        (: function `win.delete` 
           ===================== :)
        else if ($fname eq 'win.delete') then
            let $items := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $silent := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            let $useItems :=
                for $item in $items return replace($item, '/', '\\')
            let $deletes :=
                if ($silent) then $useItems ! concat('del ', .)
                else
                    for $item in $useItems
                    return
                        concat('echo delete ', $item, '&#xA;del ', $item)
            return
                string-join((
                    '@echo off',
                    if ($silent) then () else
                        concat('echo delete ', count($deletes), ' files ...'),
                    $deletes
                ), '&#xA;')

        (: function `write-doc` 
           ==================== :)
        else if ($fname eq 'write-doc') then
            let $items := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $fname := $call/*[2] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            let $encoding := $call/*[3] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)

            let $doc := 
                let $item := $items[1]
                return
                    if ($item instance of node()) then $item
                    else if (doc-available($item)) then doc($item)
                    else ()
            let $doc := $doc ! util:prettyFoxPrint(.)   
            
            let $encoding := ($encoding, 'UTF8')[1]
            return
                file:write($fname, $doc, map{'method': 'xml', 'encoding': $encoding, 'indent': 'yes'})
                
        (: function `write-file` 
           ====================== :)
        else if ($fname eq 'write-file') then
            let $items := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $fname := $call/*[2] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            let $encoding := $call/*[3] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)

            let $text := string-join($items, '&#xA;')
            let $encoding := ($encoding, 'UTF8')[1]
            return
                file:write($fname, $text, map{'encoding': $encoding})
                
        (: function `write-files` 
           ====================== :)
        else if ($fname eq 'write-files') then
            let $files := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $folder := $call/*[2] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $encoding := $call/*[3] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:writeFiles($files, $folder, $encoding)

        (: function `write-json-docs` 
           ========================= :)
        else if ($fname eq 'write-json-docs') then
            let $files := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $folder := $call/*[2] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $encoding := $call/*[3] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:writeJsonDocs($files, $folder, $encoding)

        (: function `xelement` 
           ================== :)
        else if ($fname eq 'xelement') then
            let $name := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $contents := $call/*[position() gt 1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)

            return
                foxf:xelement($name, $contents)

        (: function `xroot-matches` 
           ======================== :)
        else if ($fname = ('xroot-matches', 'xroot')) then
            let $uri := 
                let $explicit := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    ($explicit, $context)[1]
            let $doc := i:fox-doc($uri, $options)
            return
                if (not($doc)) then false() else
            
            let $name := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)           
            let $name := normalize-space($name)
            let $lname_regex :=
                if (empty($name)) then () else
                    let $pattern := substring-before(concat($name, ' '), ' ') 
                    return f:pattern2Regex($pattern)
            let $ns_regex := 
                if (empty($name) or not(contains($name, ' '))) then () else
                    let $pattern := substring-after($name, ' ') 
                    return f:pattern2Regex($pattern)
            let $xpath :=
                let $itemSelector := concat(
                    concat('[matches(local-name(.), "', $lname_regex, '", "i")]')[$lname_regex],
                    concat('[matches(namespace-uri(.), "', $ns_regex, '", "i")]')[$ns_regex] 
                )
                return concat('/*', $itemSelector)                       
            return
                boolean(i:xquery($xpath, map{'':$doc}))

        (: function `xroot-name` 
           ==================== :)
        else if ($fname eq 'xroot-name') then
            let $uri := 
                let $explicit := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    ($explicit, $context)[1]
            return
                i:fox-doc($uri, $options)/*/local-name()                
            
        (: function `xsd-validate` 
           ===================== :)
        else if ($fname = ('xsd-validate', 'xval')) then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)  
            return foxf:xsdValidate($arg1, $arg2)
            
        (: function `xwrap` 
           ==================== :)
        else if ($fname eq 'xwrap') then
            let $val := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $name := $call/*[2] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $flags := $call/*[3] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $name2 := $call/*[4] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)

            let $name := normalize-space($name)
            let $name2 := normalize-space($name2)            
            let $qname := 
                let $lname :=
                    if (not($name)) then () 
                    else substring-before(concat($name, ' '), ' ') 
                let $ns := 
                    if (not($name) or not(contains($name, ' '))) then () 
                    else substring-after($name, ' ')
                return QName($ns, $lname)            
            let $qname2 := 
                if (not($name2)) then () else
                    let $lname2 :=
                        if (not($name2)) then () 
                        else substring-before(concat($name2, ' '), ' ') 
                    let $ns2 := 
                        if (not($name2) or not(contains($name2, ' '))) then () 
                        else substring-after($name, ' ')                
                    return QName($ns2, $lname2)
            return
                foxf:xwrap($val, $qname, $flags, $qname2, $options)

        (:
         : p a r t  1 b:    o b s o l e t e    f u n c t i o n s
         :)
         
        (: function `zzz-all-descendants` 
           ========================== :)
        else if ($fname eq 'zzz-all-descendants') then
            let $items := 
                if ($call/*) then $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context
            return foxf:allDescendants($items)

        (: function `zzz-fox-ancestor` 
           ====================== :)
        (: function `zzz-fox-ancestor-or-self` 
           =============================== :)
        else if ($fname eq 'zzz-fox-ancestor' or $fname eq 'zzz-fox-ancestor-or-self') then
            let $narg := count($call/*)
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)[$narg gt 0]
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)[$narg gt 1]
            let $arg3 := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)[$narg gt 2]
            let $arg4 := $call/*[4]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)[$narg gt 3]
            let $arg5 := $call/*[5]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)[$narg gt 4]
            let $uris :=
                if ($narg eq 0) then $context else $arg1
            let $names := $arg2
            let $namesExcluded := $arg3
            let $pselector := $arg4            
            let $ignoreCase := $arg5
            let $includeSelf := $fname eq 'fox-ancestor-or-self'
            return
                foxf:zzzFoxAncestor($uris, $names, $namesExcluded, $pselector, $ignoreCase, $includeSelf)

        (: function `zzz-fox-child` 
           ======================== :)
        else if ($fname = ('zzz-fox-child', 'zzz-fchild')) then
            let $names := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $namesExcluded := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:zzzFoxChild($context, $names, $namesExcluded)

        (: function `zzz-fox-descendant` 
           ============================= :)
        else if ($fname = ('zzz-fox-descendant', 'zzz-fdescendant')) then
            let $names := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $namesExcluded := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:zzzFoxDescendant($context, $names, $namesExcluded)

        (: function `zzz-fox-descendant-or-self` 
           ===================================== :)
        else if ($fname = ('zzz-fox-descendant-or-self', 'zzz-fdescendant-or-self')) then
            let $names := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $namesExcluded := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:zzzFoxDescendantOrSelf($context, $names, $namesExcluded)

        (: function `zzz-fox-parent` 
           ========================= :)
        else if ($fname = ('zzz-fox-parent', 'zzz-fparent')) then
            let $names := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $namesExcluded := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:zzzFoxParent($context, $names, $namesExcluded)
                
        (: function `zzz-fox-parent-sibling` 
           ================================= :)
        else if ($fname eq 'zzz-fox-parent-sibling') then
            let $names := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $namesExcluded:= $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $from := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $to := $call/*[4]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            return
                foxf:zzzFoxParentSibling($context, $names, $namesExcluded, $from, $to)

        (: function `zzz-fox-self` 
           ======================= :)
        else if ($fname = ('zzz-fox-self', 'zzz-fself')) then
            let $names := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $namesExcluded := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:zzzFoxSelf($context, $names, $namesExcluded)

        (: function `zzz-fox-sibling` 
           ========================== :)
        else if ($fname = ('zzz-fox-sibling', 'zzz-fsibling')) then
            let $names := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $namesExcluded:= $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $from := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $to := $call/*[4]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            return
                foxf:zzzFoxSibling($context, $names, $namesExcluded, $from, $to)

        (: function `zzz-jchildren` 
           ======================== :)
        else if ($fname eq 'zzz-jchildren') then
            let $nodes :=
                if ($call/*) then $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context
            let $nameFilter := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)                
            let $ignoreCase := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:zzzJchildren($context, $nameFilter, $ignoreCase)

        (: function `zzz-jnode-child` 
           ========================== :)
        else if ($fname = ('zzz-jnode-child', 'zzz-jchild')) then
            let $nodes :=
                if (count($call/*) eq 1) then $context
                else $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $names :=
                let $index :=
                    if (count($call/*) eq 1) then 1 else 2
                return $call/*[$index]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $namesExcluded := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $ignoreCase := $call/*[4]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:zzzNodeChild($nodes, 'jname', $names, $namesExcluded, $ignoreCase)

        (: function `zzz-jnode-descendant` 
           =============================== :)
        else if ($fname = ('zzz-jnode-descendant', 'zzz-jdescendant')) then
            let $nodes :=
                if (count($call/*) eq 1) then $context
                else $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $names :=
                let $index :=
                    if (count($call/*) eq 1) then 1 else 2
                return $call/*[$index]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $namesExcluded := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $ignoreCase := $call/*[4]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:zzzNodeDescendant($nodes, 'jname', $names, $namesExcluded, $ignoreCase)

        (: function `zzz-jnode-self` 
           ========================= :)
        else if ($fname = ('zzz-jnode-self', 'zzz-jself')) then
            let $nodes :=
                if (count($call/*) eq 1) then $context
                else $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $names :=
                let $index :=
                    if (count($call/*) eq 1) then 1 else 2
                return $call/*[$index]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $namesExcluded := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $ignoreCase := $call/*[4]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:zzzNodeSelf($nodes, 'jname', $names, $namesExcluded, $ignoreCase)

        (: function `zzz-has-xatt` 
           ======================= :)
        else if ($fname eq 'zzz-has-xatt' or $fname eq 'xatt') then
            let $uri := 
                let $explicit := $call/*[4]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    ($explicit, $context)[1]
            let $doc := i:fox-doc($uri, $options)
            return
                if (not($doc)) then () else
            
            let $name := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $val := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $elemName := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            
            let $name := normalize-space($name)
            let $lname :=
                if (empty($name)) then () else
                    let $pattern := substring-before(concat($name, ' '), ' ') 
                    return f:pattern2Regex($pattern)
            let $ns := 
                if (empty($name) or not(contains($name, ' '))) then () else
                    let $pattern := substring-after($name, ' ') 
                    return f:pattern2Regex($pattern)
            let $elemLname :=
                if (empty($elemName)) then () else
                    let $pattern := substring-before(concat($elemName, ' '), ' ') return
                        concat('^', replace(replace($pattern, '\*', '.*'), '\.', '\\.'), '$')
            let $elemNs := 
                if (empty($elemName) or not(contains($elemName, ' '))) then () else
                    let $pattern := substring-after($elemName, ' ') return
                        concat('^', replace(replace($pattern, '\.', '\\.'), '\*', '.*'), '$')
            let $val := $val ! f:pattern2Regex(.)

            let $xpath :=
                let $elemSelector :=
                    if (not($elemName)) then '/' else
                        concat(
                            '//*',
                            concat('[matches(local-name(.), "', $elemLname, '", "i")]')[$elemLname],
                            concat('[matches(namespace-uri(.), "', $elemNs, '", "i")]')[$elemNs]
                        ) 

                let $attSelector := concat(
                    '/@*',
                    concat('[matches(local-name(.), "', $lname, '", "i")]')[$lname],
                    concat('[matches(namespace-uri(.), "', $ns, '", "i")]')[$ns], 
                    concat('[matches(., "', $val, '", "i")]')[$val]
                )
                return
                    concat($elemSelector, $attSelector)                  
            return
                i:xquery($xpath, map{'':$doc})

        (: function `zzz-has-xelem` 
           ======================== :)
        else if ($fname eq 'zzz-has-xelem' or $fname eq 'xelem') then
            let $uri := 
                let $explicit := $call/*[4]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    ($explicit, $context)[1]
            let $doc := i:fox-doc($uri, $options)
            return
                if (not($doc)) then () else
            
            let $name := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $val := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            
            let $name := normalize-space($name)
            let $lname :=
                if (empty($name)) then () else
                    let $pattern := substring-before(concat($name, ' '), ' ') 
                    return f:pattern2Regex($pattern)
            let $ns := 
                if (empty($name) or not(contains($name, ' '))) then () else
                    let $pattern := substring-after($name, ' ') 
                    return f:pattern2Regex($pattern)
            let $val := $val ! f:pattern2Regex(.)
            let $xpath :=
                let $itemSelector := concat(
                    concat('[matches(local-name(.), "', $lname, '", "i")]')[$lname],
                    concat('[matches(namespace-uri(.), "', $ns, '", "i")]')[$ns], 
                    concat('[not(*)][matches(., "', $val, '", "i")]')[$val]
                )
                return concat('//*', $itemSelector)                       
            return
                i:xquery($xpath, map{'':$doc})

        (: function `zzz-lnode-child` 
           ========================== :)
        else if ($fname = ('zzz-lnode-child', 'lchild')) then
            let $nodes :=
                if (count($call/*) eq 1) then $context
                else $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $names :=
                let $index :=
                    if (count($call/*) eq 1) then 1 else 2
                return $call/*[$index]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $namesExcluded := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $ignoreCase := $call/*[4]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:zzzNodeChild($nodes, 'lname', $names, $namesExcluded, $ignoreCase)

        (: function `zzz-lnode-descendant` 
           =============================== :)
        else if ($fname = ('zzz-lnode-descendant', 'ldescendant')) then
            let $nodes :=
                if (count($call/*) eq 1) then $context
                else $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $names :=
                let $index :=
                    if (count($call/*) eq 1) then 1 else 2
                return $call/*[$index]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $namesExcluded := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $ignoreCase := $call/*[4]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:zzzNodeDescendant($nodes, 'lname', $names, $namesExcluded, $ignoreCase)

        (: function `zzz-node-child` 
           ========================= :)
        else if ($fname = ('zzz-node-child', 'zzz-nchild')) then
            let $nodes :=
                if (count($call/*) eq 1) then $context
                else $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $names :=
                let $index :=
                    if (count($call/*) eq 1) then 1 else 2
                return $call/*[$index]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $namesExcluded := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $ignoreCase := $call/*[4]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:zzzNodeChild($nodes, 'name', $names, $namesExcluded, $ignoreCase)

        (: ################################################################
         : p a r t  2:    s t a n d a r d    f u n c t i o n s
         : ################################################################ :)

        (: function `abs` 
           ============== :)
        else if ($fname eq 'abs') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                abs($arg)
                
        (: function `acos` 
           ============== :)
        else if ($fname eq 'acos') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                math:acos($arg)
                
        (: function `adjust-dateTime-to-timezone` 
           ====================================== :)
        else if ($fname eq 'adjust-dateTime-to-timezone') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                if (not($call/*[2])) then adjust-dateTime-to-timezone($arg1)
                else
                    let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                    return
                        adjust-dateTime-to-timezone($arg1, $arg2)
                
        (: function `avg` 
           ============== :)
        else if ($fname eq 'avg') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                avg($arg)
                
        (: function `base-uri` 
           =================== :)
        else if ($fname eq 'base-uri') then
            let $contextItem :=
                if (empty($call/*)) then $context
                else $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $argNode :=
                if ($contextItem instance of node()) then $contextItem
                else i:fox-doc($contextItem, $options)
            return
                $argNode/base-uri(.)
            
        (: function `boolean` 
           ================= :)
        (: Note - an argument with several items starting with an atomic item is treated differently
           from fn:boolean: rather than throwing an error, the first item is inspected :)
        else if ($fname eq 'boolean') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                if (count($arg) gt 1) then boolean($arg[1])
                else boolean($arg)
            
        (: function `ceiling` 
           ================== :)
        else if ($fname eq 'ceiling') then
            let $arg := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                ceiling($arg)
                
        (: function `codepoints-to-string` 
           =============================== :)
        else if ($fname = ('codepoints-to-string', 'c2s')) then
            let $arg := 
                if ($call/*) then $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context
            return codepoints-to-string($arg)
                
        (: function `concat` 
           ================= :)
        else if ($fname eq 'concat') then
            string-join(
                for $arg in $call/* return 
                    f:resolveFoxpathRC($arg, false(), $context, $position, $last, $vars, $options)
            , '')
            
        (: function `contains` 
           =================== :)
        else if ($fname eq 'contains') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)          
            return
                contains($arg1, $arg2)
            
        (: function `count` 
           ================ :)
        else if ($fname eq 'count') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            return count($arg)
            
        (: function `current-date` 
           ====================== :)
        else if ($fname eq 'current-date') then
            current-date()
                
        (: function `current-date-string` 
           ============================== :)
        else if ($fname eq 'current-date-string') then
            string(current-date())
                
        (: function `current-dateTime` 
           ========================== :)
        else if ($fname eq 'current-dateTime') then
            current-dateTime()
                
        (: function `current-dateTime-string` 
           ================================== :)
        else if ($fname eq 'current-dateTime-string') then
            string(current-dateTime())
                
        (: function `current-dir` 
           ====================== :)
        else if ($fname eq 'current-dir') then
            file:current-dir() ! file:path-to-uri(.) ! replace(., '[/\\]$', '')
                
        (: function `date` 
           =============== :)
        else if ($fname eq 'date') then
            let $arg := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                xs:date(substring(string(i:fox-file-date($arg, $options)), 1, 10))

        (: function `dateTime` 
           =================== :)
        else if ($fname eq 'dateTime') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                xs:dateTime($arg)

        (: function `day-from-date` 
           ======================== :)
        else if ($fname eq 'day-from-date') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                day-from-date($arg)
                
        (: function `day-time-duration` 
           ============================ :)
        else if ($fname eq 'dayTimeDuration') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                xs:dayTimeDuration($arg)

        (: function `dcat` 
           ============== :)
        else if ($fname eq 'dcat') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $docs := sort($arg [i:fox-doc-available(., $options)], lower-case#1) 
            return
                <docs count="{count($docs)}" t="{current-dateTime()}">{
                    $docs ! <doc uri="{.}"/>
                }</docs>

        (: function `decodeKey` 
           ==================== :)
        else if ($fname eq 'decode-key') then
            let $arg := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                convert:decode-key($arg)
                
        (: function `decode-url` 
           ===================== :)
        else if ($fname eq 'decode-url') then
            let $arg := 
                if ($call/*) then $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context
            return
                web:decode-url($arg)

        (: function `deep-equal` 
           ===================== :)
        else if ($fname eq 'deep-equal') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return deep-equal($arg2, $arg2) 

        (: function `distinct-values` 
           ========================== :)
        else if ($fname eq 'distinct-values') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            return
                distinct-values($arg)
                
        (: function `doc` 
           ============== :)
        else if ($fname eq 'doc') then
            let $uri := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                i:fox-doc($uri, $options)
                
        (: function `document-uri` 
           ======================= :)
        else if ($fname eq 'document-uri') then
            let $arg := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                if ($arg instance of node()) then $arg/root()/document-uri(.)
                else i:fox-doc($arg, $options)/document-uri(.)
                
        (: function `doc-available` 
           ======================== :)
        else if ($fname eq 'doc-available') then
            let $uri := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                i:fox-doc-available($uri, $options)
                
        (: function `empty` 
           ================ :)
        else if ($fname eq 'empty') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)         
            return
                empty($arg1)
                
        (: function `encodeKey` 
           ==================== :)
        else if ($fname eq 'encode-key') then
            let $arg := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                convert:encode-key($arg)
                
        (: function `encode-url` 
           ===================== :)
        else if ($fname eq 'encode-url') then
            let $arg := 
                if ($call/*) then $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context
            return
                web:encode-url($arg)

        (: function `exists` 
           ================ :)
        else if ($fname eq 'exists') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)         
            return
                exists($arg1)
                
        (: function `ends-with` 
           ==================== :)
        else if ($fname eq 'ends-with') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)          
            return
                ends-with($arg1, $arg2)
                
        (: function `false` 
           ================ :)
        else if ($fname eq 'false') then
            false()
            
        (: function `floor` 
           ================ :)
        else if ($fname eq 'floor') then
            let $arg := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                floor($arg)
                
        (: function `head` 
           =============== :)
        else if ($fname eq 'head') then
            let $arg := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                head($arg)
                
        (: function `in-scope-prefixes` 
           ============================ :)
        else if ($fname eq 'in-scope-prefixes') then
            let $arg := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            let $arg := if ($arg instance of xs:anyAtomicType) then i:fox-doc($arg, $options)/* else $arg                 
            return
                in-scope-prefixes($arg)
                
        (: function `last` 
           =============== :)
        else if ($fname eq 'last') then
            $last
            
        (: function `local-name` 
           ===================== :)
        else if ($fname eq 'local-name') then
            let $arg := 
                let $explicit := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                if (not(count($arg) eq 1 and $arg[1] instance of node())) then ()
                else local-name($arg)

        (: function `local-name-from-QName` 
           ================================ :)
        else if ($fname eq 'local-name-from-QName') then
            let $arg := 
                let $explicit := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                local-name-from-QName($arg)

        (: function `lower-case` 
           ===================== :)
        else if ($fname eq 'lower-case') then
            let $arg := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                lower-case($arg)

        (: function `matches` 
           ================== :)
        else if ($fname eq 'matches') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            let $arg3 := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            return
                if (exists($arg3)) then matches($arg1, $arg2, $arg3)
                else matches($arg1, $arg2)
                
        (: function `max` 
           ============== :)
        else if ($fname eq 'max') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                max($arg)
                
        (: function `min` 
           ============== :)
        else if ($fname eq 'min') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                min($arg)
                
        (: function `seconds-from-duration` 
           ================================ :)
        else if ($fname eq 'minutes-from-duration') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                minutes-from-duration($arg1)
                
        (: function `month-from-date` 
           ========================== :)
        else if ($fname eq 'month-from-date') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                month-from-date($arg)
                
        (: function `name` 
           =============== :)
        else if ($fname eq 'name') then
            let $arg := 
                let $explicit := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                if (not(count($arg) eq 1 and $arg[1] instance of node())) then ()
                else name($arg)
                
        (: function `namespace-uri` 
           ======================= :)
        else if ($fname eq 'namespace-uri') then
            let $arg := 
                let $explicit := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                if (not(count($arg) eq 1 and $arg[1] instance of node())) then ()
                else namespace-uri($arg)

        (: function `namespace-uri-from-QName` 
           =================================== :)
        else if ($fname eq 'namespace-uri-from-QName') then
            let $arg := 
                let $explicit := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                namespace-uri-from-QName($arg)

        (: function `node-name` 
           ==================== :)
        else if ($fname eq 'node-name') then
            let $arg := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                node-name($arg)
            
        (: function `normalize-space` 
           ========================= :)
        else if ($fname eq 'normalize-space') then
            let $arg := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                normalize-space($arg)
            
        (: function `not` 
           ============== :)
        else if ($fname eq 'not') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                not($arg[1])
                
        (: function `number` 
           ================= :)
        else if ($fname eq 'number') then
            let $arg := 
                let $explicit := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                $arg ! number(.)

        (: function `position` 
           =================== :)
        else if ($fname eq 'position') then
            $position
            
        (: function `QName` 
           ================ :)
        else if ($fname eq 'QName') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)           
            return
                QName($arg1, $arg2)

        (: function `replace` 
           ==================== :)
        else if ($fname eq 'replace') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            let $arg3 := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            return
                if (exists($arg3)) then replace($arg1, $arg2, $arg3)
                else replace($context, $arg1, $arg2)

        (: function `reverse` 
           ================== :)
        else if ($fname eq 'reverse') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                reverse($arg)

        (: function `resolve-QName` 
           ======================== :)
        else if ($fname eq 'resolve-QName') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                let $nameContext := if ($arg2) then $arg2 else $context
                return
                    resolve-QName($arg1, $nameContext)

        (: function `resolve-uri` 
           ====================== :)
        else if ($fname eq 'resolve-uri') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                let $baseUri := if ($arg2) then $arg2 else $context
                return
                    resolve-uri($arg1, $baseUri)

        (: function `root` 
           ===================== :)
        else if ($fname eq 'root') then
            let $arg := 
                let $arg1 := $call/*[1]
                return
                    if ($arg1) then 
                        $arg1/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                    else $context
            return
                root($arg)

        (: function `round` 
           ================ :)
        else if ($fname eq 'round') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            return
                round($arg1, $arg2)
                
        (: function `seconds-from-duration` 
           ================================ :)
        else if ($fname eq 'seconds-from-duration') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                seconds-from-duration($arg1)
                
        (: function `sort` 
           ==================== :)
        else if ($fname eq 'sort') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)          
            let $arg3 := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            let $arg4 := $call/*[4]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $sorted :=
                if (exists($arg3)) then sort($arg1, $arg2, $arg3)
                else if (exists($arg2)) then sort($arg1, $arg2)                
                else sort($arg1)
            return
                if (not($arg4 = ('d', 'descending'))) then $sorted else reverse($sorted)

        (: function `static-base-uri` 
           ========================== :)
        else if ($fname eq 'static-base-uri') then
            static-base-uri()
                
        (: function `starts-with` 
           ====================== :)
        else if ($fname eq 'starts-with') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)          
            return
                starts-with($arg1, $arg2)
                
        (: function `string` 
           ================= :)
        else if ($fname eq 'string') then
            let $arg := 
                if ($call/*[1]) then 
                    $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context                    
            return
                string($arg)
                
        (: function `string-join` 
           ====================== :)
        else if ($fname eq 'string-join') then
            let $items := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $sep := 
                let $explicit := $call/*[2] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, '')[1]
            return
                string-join($items, $sep)                
                
        (: function `string-length` 
           ======================== :)
        else if ($fname eq 'string-length') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                string-length(string($arg))
                
        (: function `string-to-codepoints` 
           =============================== :)
        else if ($fname = ('string-to-codepoints', 's2c')) then
            let $arg := 
                if ($call/*) then $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context
            return string-to-codepoints($arg)
                
        (: function `subsequence` 
           ====================== :)
        else if ($fname eq 'subsequence') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg2 := 
                let $explicit := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    if ($explicit lt 0) then 1 + count($arg1) + $explicit else $explicit
            let $arg3 := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                if (exists($arg3)) then subsequence($arg1, $arg2, $arg3)
                else if (exists($arg2)) then subsequence($arg1, $arg2)
                else $arg1
                
        (: function `substring` 
           ==================== :)
        else if ($fname eq 'substring') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            let $arg3 := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            return
                if (exists($arg3)) then substring($arg1, $arg2, $arg3)
                else substring($arg1, $arg2)
                
        (: function `substring-after` 
           =========================== :)
        else if ($fname eq 'substring-after') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            return
                substring-after($arg1, $arg2)
                
        (: function `substring-before` 
           =========================== :)
        else if ($fname eq 'substring-before') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            return
                substring-before($arg1, $arg2)
                
        (: function `sum` 
           ============== :)
        else if ($fname eq 'sum') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                sum($arg)
                
        (: function `tail` 
           =============== :)
        else if ($fname eq 'tail') then
            let $arg := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                tail($arg)
                
        (: function `time` 
           ============== :)
        else if ($fname eq 'time') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                xs:time($arg)
                
        (: function `tokenize` 
           =================== :)
        else if ($fname eq 'tokenize') then
            let $arg1 :=
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            let $arg3 := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            return
                if (not($arg2)) then tokenize($arg1) 
                else if (not($arg3)) then tokenize($arg1, $arg2)
                else tokenize($arg1, $arg2, $arg3)

        (: function `trace` 
           ================ :)
        else if ($fname eq 'trace') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)          
            return
                if (not($arg2)) then trace($arg1) 
                else trace($arg1, $arg2)

        (: function `true` 
           =============== :)
        else if ($fname eq 'true') then
            true()

        (: function `unparsed-text` 
           ======================= :)
        else if ($fname eq 'unparsed-text') then
            let $encoding :=
                $call/*[3]
                /f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $uri := 
                let $expr := $call/*[1]
                return
                    if ($expr) then
                        f:resolveFoxpathRC($expr, false(), $context, $position, $last, $vars, $options)
                    else $context
            return
                f:fox-unparsed-text($uri, $encoding, $options)
                        
        (: function `unparsed-text-lines` 
           ============================= :)
        else if ($fname eq 'unparsed-text-lines') then
            let $encoding :=
                $call/*[3]
                /f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $uri := 
                let $expr := $call/*[1]
                return
                    if ($expr) then
                        f:resolveFoxpathRC($expr, false(), $context, $position, $last, $vars, $options)
                    else $context
            return
                f:fox-unparsed-text-lines($uri, $encoding, $options)

        (: function `upper-case` 
           ===================== :)
        else if ($fname eq 'upper-case') then
            let $arg := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                upper-case($arg)

        (: function `year-from-date` 
           ========================= :)
        else if ($fname eq 'year-from-date') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                year-from-date($arg)
                
        (: function `xs:date` 
           ===================== :)
        else if ($fname eq 'xs:date') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)          
            return
                xs:date($arg1)
                
        (: function `xs:dateTime` 
           ===================== :)
        else if ($fname eq 'xs:date') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)          
            return
                xs:dateTime($arg1)
                
        (: function `xs:decimal` 
           ===================== :)
        else if ($fname eq 'xs:decimal') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)          
            return
                xs:decimal($arg1)
                
        (: function `xs:integer` 
           ===================== :)
        else if ($fname eq 'xs:integer') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)          
            return
                xs:integer($arg1)
                
        (: function `xs:string` 
           ===================== :)
        else if ($fname eq 'xs:string') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)          
            return
                xs:string($arg1)
                
        else
        error(QName((), 'NOT_YET_IMPLEMENTED'),
            concat('Unexpected function name: ', $fname))
            
        , 'function', concat('FUNCTION_CALL; FNAME=', $fname, ' : '))
        
};
