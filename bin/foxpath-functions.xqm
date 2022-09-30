module namespace f="http://www.ttools.org/xquery-functions";

import module namespace i="http://www.ttools.org/xquery-functions" 
at "foxpath-processorDependent.xqm",
   "foxpath-uri-operations.xqm";
   
import module namespace util="http://www.ttools.org/xquery-functions/util" 
at  "foxpath-util.xqm";

import module namespace ft="http://www.foxpath.org/ns/fulltext" 
at  "foxpath-fulltext.xqm";

import module namespace foxf="http://www.foxpath.org/ns/fox-functions" 
at "foxpath-fox-functions.xqm";

import module namespace urim="http://www.foxpath.org/ns/urithmetic" 
at "foxpath-urithmetic.xqm";

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

        (: function `alname` 
           ================= :)
        if ($fname = ('alname')) then  
            let $nodes := 
                if ($call/*) then $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context
            return
                foxf:alname($nodes)
                    

        (: function `aname` 
           ================ :)
        else if ($fname = ('aname')) then  
            let $nodes := 
                if ($call/*) then $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context
            return
                foxf:aname($nodes)
                    

        (: function `annotate`, ànnotate-ec` 
           ================================= :)
        else if ($fname = ('annotate', 'annotate-ec')) then
            let $da := if (ends-with($fname, '-ec')) then 1 else 0
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $value := if ($da eq 1) then $arg1 else $context
            let $anno := if ($da eq 1) then $arg2 else $arg1
            let $prefix := $call/*[2 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $postfix := $call/*[3 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:annotate($value, $anno, $prefix, $postfix)            

        (: function `atts` 
           =============== :)
        else if ($fname eq 'atts') then
            let $flags := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:atts($context, $flags)

        (: function `ancestor`, `child`, `descendant` etc. 
           =============================================== :)
        else if ($fname = ('ancestor', 'ancestor-ec',
                           'ancestor-or-self', 'ancestor-or-self-ec',
                           'parent', 'parent-ec',
                           'self', 'self-ec',
                           'child', 'child-ec',
                           'attributes', 'attributes-ec',
                           'descendant', 'descendant-ec', 
                           'descendant-or-self', 'descendant-or-self-ec',
                           'sibling', 'sibling-ec',                           
                           'preceding-sibling', 'preceding-sibling-ec',
                           'following-sibling', 'following-sibling-ec',
                           'content', 'content-ec',
                           'content-or-self', 'content-or-self-ec',
                           (: all-descendant* deprecated - use content* :)
                           'all-descendant', 'all-descendant-ec',
                           'all-descendant-or-self', 'all-descendant-or-self-ec')) 
        then
            let $da := if (ends-with($fname, '-ec')) then 1
                       else 0
            let $axis := $fname ! replace(., '-ec$', '')
            let $contextNodes := if ($da eq 0) then $context else 
                $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $namesFilter := $call/*[1 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $pselector := $call/*[2 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $controlOptions := $call/*[3 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:nodeNavigation($contextNodes, $axis, $namesFilter, $pselector, $controlOptions, $fname)

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

        (: function `child-names`, `att-names`, `content-names`, `parent-name`  
           =================================================================== :)
        else if ($fname = ('child-names', 'child-names-ec',
                           'child-lnames', 'child-lnames-ec',
                           'child-jnames', 'child-jnames-ec',
                           'descendant-names', 'descendant-names-ec',
                           'descendant-lnames', 'descendant-lnames-ec',
                           'descendant-jnames', 'descendant-jnames-ec',
                           'parent-name', 'parent-name-ec',
                           'parent-lname', 'parent-lname-ec',
                           'parent-jname', 'parent-jname-ec',
                           'ancestor-names', 'ancestor-names-ec',
                           'ancestor-lnames', 'ancestor-lnames-ec',
                           'ancestor-jnames', 'ancestor-jnames-ec',
                           'att-names', 'att-names-ec',
                           'att-lnames', 'att-lnames-ec',
                           'att-jnames', 'att-jnames-ec',
                           'content-names', 'content-names-ec',
                           'content-lnames', 'content-lnames-ec',
                           'content-jnames', 'content-jnames-ec'                           
                           )) then
            let $da := if (f:hasExplicitContext($fname)) then 1 else 0
            let $narg := count($call/*)
            let $args := $call/([
               *[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)[$narg gt 0],
               *[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)[$narg gt 1],
               *[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)[$narg gt 2]
            ])
            let $nodes := if ($da) then $args(1) else $context
            let $nameFilter := $args(1 + $da)
            let $flags := $args(2 + $da)
            let $nameKind := 
                if (contains($fname, '-name')) then 'name' 
                else if (contains($fname, '-jname')) then 'jname' 
                else 'lname'
            let $relationship := replace($fname, '^(.*?)-.*(-ec)?', '$1')                
            return foxf:relatedNames($nodes, $relationship, $nameKind, $nameFilter, $flags)            

        (: function `contains-text` 
           ======================== :)
        else if ($fname = ('contains-text', 'contains-text-ec')) then
            let $da := if (f:hasExplicitContext($fname)) then 1 else 0
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            let $text := if ($da) then $arg1 else $context
            let $query := $call/*[1 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $flags := $call/*[2 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)     
            return ft:containsText($text, $query, $flags)            
                
        (: function `content-deep-equal` 
           ============================= :)
        else if ($fname = ('content-deep-equal', 'content-deep-equal-ec')) then
            let $da := if (ends-with($fname, '-ec')) then 1 else 0    
            let $items := (
                $context[$da eq 0],
                $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options))
            let $scope := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $controlOptions := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:contentDeepEqual($items, $scope, $controlOptions)

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
        else if ($fname = ('csv-doc', 'cdoc', 'csv-doc-ec', 'cdoc-ec', 'csv-parse', 'csv-parse-ec')) then
            let $da := if (ends-with($fname, '-ec')) then 1 else 0
            let $parse := contains($fname, 'parse')
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            let $uriOrText := if ($da) then $arg1 else $context
            let $uri := if ($parse) then () else $uriOrText
            let $text := if (not($parse)) then () else $uriOrText
            let $separator := $call/*[$da + 1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $header := $call/*[$da + 2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            let $names := $call/*[$da + 3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $quotes := $call/*[$da + 4]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            let $backslashes := $call/*[$da + 5]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                if ($parse) then
                    let $funcOps := map:merge((
                        $separator ! map:entry('separator', .),
                        $header ! map:entry('header', .),
                        $names ! map:entry('format', .),
                        $quotes ! map:entry('quotes', .),
                        $backslashes ! map:entry('backslashes', .)
                    ))
                    return csv:parse($text, $funcOps)
                else if (empty($separator)) then i:fox-csv-doc($uri, $options)
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

        (: function `delete-nodes` 
           ======================= :)
        else if ($fname = ('delete-nodes', 'delete-nodes-ec')) then
            let $da := if (ends-with($fname, '-ec')) then 1 else 0        
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $doc := if ($da) then $arg1 else $context
            let $excludeExprs := if (not($da)) then $arg1 else                
                $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $fnOptions := $call/*[2 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)                
            return foxf:deleteNodes($doc, $excludeExprs, $fnOptions, $options)
                        
        (: function `depth` 
           ================ :)
        else if ($fname = ('depth', 'depth-ec')) then
            let $item := 
                if (f:hasExplicitContext($fname)) then   
                    $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context
            return foxf:depth($item)            

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
                            
        (: function `docx-doc` 
           =================== :)
        else if ($fname eq 'docx-doc') then
            let $uri := if ($call/*) then $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                        else $context
            return foxf:docxDoc($uri)
                            
        (: function `echo` 
           =============== :)
        else if ($fname eq 'echo') then
            let $val := trace($call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options) , 'VAL: ')        
            return
                $val

(: the following function is at risk:
    eval-xpath
:)
        (: function `resolve-xpath` 
           ======================== :)
        else if ($fname = ('resolve-xpath', 'xpath')) then
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

        (: function `fancestor-shifted` 
           ============================ :)
        else if ($fname = ('fancestor-shifted', 'ec-fancestor-shifted')) then
            let $da := if (starts-with($fname, 'ec-')) then 1 else 0
            let $contextUris := if ($da eq 0) then $context else
                $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $ancestor := $call/*[1 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $shiftedAncestor := $call/*[2 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $nameReplaceSubstring := $call/*[3 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $nameReplaceWith := $call/*[4 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:foxAncestorShifted($contextUris, $ancestor, $shiftedAncestor, $nameReplaceSubstring, $nameReplaceWith, $options)

        (: function `fparent-shifted` 
           ========================== :)
        else if ($fname = ('fparent-shifted', 'ec-fparent-shifted')) then
            let $da := if (starts-with($fname, 'ec-')) then 1 else 0
            let $contextUris := if ($da eq 0) then $context else
                $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $ancestor := ()
            let $shiftedAncestor := $call/*[1 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $nameReplaceSubstring := $call/*[2 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $nameReplaceWith := $call/*[3 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:foxAncestorShifted($contextUris, $ancestor, $shiftedAncestor, $nameReplaceSubstring, $nameReplaceWith, $options)


        (: functions `faxis, faxis-ec` 
           =========================== :)
        else if ($fname = ('fancestor', 'fancestor-ec', 
                           'fancestor-or-self', 'ec-fancestor-or-self',
                           'fparent', 'ec-fparent',
                           'fself', 'ec-fself',
                           'fchild', 'ec-fchild',
                           'fdescendant', 'ec-fdescendant',
                           'fdescendant-or-self', 'ec-fdescendant-or-self',
                           'fpreceding-sibling', 'ec-fpreceding-sibling',
                           'ffollowing-sibling', 'ec-ffollowing-sibling',
                           'fsibling', 'fsibling-ec',
                           'fparent-sibling', 'ec-fparent-sibling',
                           
                           'bsibling', 'bsibling-ec')) 
        then
            let $da := if (ends-with($fname, '-ec')) then 1 else 0
            let $axis := $fname ! replace(., '^.', '') ! replace(., '-ec$', '')
            let $fnOptions := if (starts-with($fname, 'b')) then 'use-base-uri' else ()
            let $uris := if ($da eq 0) then $context else 
                $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $namesFilter := $call/*[1 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $pselector := $call/*[2 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:foxNavigation($uris, $axis, $namesFilter, $pselector, $fnOptions)
                
        (: function `file-append-text` 
           =========================== :)
        else if ($fname = ('file-append-text')) then
            let $file := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $data :=
                if (count($call/*) le 1) then $context 
                else $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $encoding := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                if ($encoding) then file:append-text($file, $data, $encoding) 
                else $data ! file:append-text($file, .)
                
        (: function `file-append-text-lines` 
           ================================= :)
        else if ($fname = ('file-append-text-lines')) then
            let $file := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $data :=
                if (count($call/*) le 1) then $context 
                else $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $encoding := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)                
            return
                if ($encoding) then file:append-text-lines($file, $data, $encoding) 
                else file:append-text-lines($file, $data)
                
        (: function `file-basename` 
           ======================== :)
        else if ($fname = ('file-basename', 'file-bname', 'fbname')) then
            let $uri := 
                if ($call/*) then $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context
            return $uri ! urim:fileBaseName(.)
            
        (: function `file-contains` 
           ======================= :)
        else if ($fname eq 'file-contains') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg3 := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $pattern :=
                if ($call/*[2]) then $arg2
                else if ($call/*) then $arg1
                else 
                    error(QName((), 'INVALID_CALL'), 
                        'Function "file-contains" requires at least one parameter.')
            let $uri := if ($call/*[2]) then $arg1 else $context
            let $encoding := $arg3
            return foxf:fileContains($uri, $pattern, $encoding, $options)
            
        (: function `file-content` 
           ======================= :)
        else if ($fname = ('file-content', 'fcontent')) then
            let $uri := 
                let $raw := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($raw, $context)[1]
            let $encoding := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $start := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $length := $call/*[4]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)

            let $text := f:fox-unparsed-text($uri, $encoding, $options)
            let $start := if ($start < 0) then string-length($text) + $start + 1 else $start
            let $text := 
                if (not($start) and not($length)) then $text
                else if (not($length)) then substring($text, $start)
                else if (not($start)) then substring($text, 1, $length)
                else substring($text, $start, $length)
            return
                $text
                
        (: function `file-copy` 
           ==================== :)
        else if ($fname = ('file-copy', 'fcopy')) then
            let $countArgs := count($call/*)
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $file := if (count($call/*) gt 1) then $arg1 else $context 
            let $target := if ($countArgs le 1) then $arg1 else
                $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $flags := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options) ! lower-case(.)
            return
                foxf:fileCopy($file, $target, $flags)
                
        (: function `file-create-dir` 
           ========================== :)
        else if ($fname eq 'file-create-dir') then
            let $dirs := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return $dirs ! file:create-dir(.)
            
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
        else if ($fname = ('file-date-string', 'file-date-str')) then
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

        (: function `filter-items` 
           ======================= :)
        else if ($fname eq 'filter-items') then
            let $items:= $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $pattern := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:filterItems($items, $pattern, $options)

       (: function `filter-regex` 
          ======================= :)
        else if ($fname = ('filter-regex', 'fregex')) then
            let $items := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $regex := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $flags := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return 
                if (count($regex) le 1) then $items[matches(., $regex, string($flags))]
                else $items[some $r in $regex satisfies matches(., $r, string($flags))]

        (: function `fn-contains-text` 
           =========================== :)
        else if ($fname eq 'fn-contains-text') then
            let $selections := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $toplevelOr := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return ft:fnContainsText($selections, (), $toplevelOr, ())            
                
        (: function `map-items` 
           ==================== :)
        else if ($fname eq 'map-items') then
            let $items := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $expr := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:mapItems($items, $expr, $options)            
                
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

        else if ($fname = ('ftree', 'ftree-ec')) then  
            let $da := if (f:hasExplicitContext($fname)) then 1 else 0
            let $arg1 := 
                $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $rootFolders := if ($da eq 1) then $arg1 else $context
            let $fileProperties := 
                $call/*[1 + $da] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:ftree($rootFolders, $fileProperties, $options)
            
        else if ($fname = ('ftree-selective', 'ftree-selective-ec')) then
            let $da := if (f:hasExplicitContext($fname)) then 1 else 0
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            let $rootFolders := if ($da eq 1) then $arg1 else $context
            let $fileNames := $call/*[1 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)                
            let $folderNames := $call/*[2 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $fileProperties := 
                $call/*[3 + $da] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $functionOptions := $call/*[4 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)                
            return foxf:ftreeSelective($rootFolders, (), $fileNames, $folderNames, $fileProperties, $functionOptions, $options)
            
        else if ($fname = 'ftree-view') then
            let $uris := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $fileProperties := $call/*[2] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $functionOptions := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            return foxf:ftreeSelective((), $uris, (), (), $fileProperties, $functionOptions, $options)

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
               *[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)[$narg gt 2]
            ])
            let $uris := if ($narg eq 1) then $context else $args(1)
            return foxf:grep($uris, $args(1 + $da), $args(2 + $da))

        (: function `group-items` 
           ===================== :)
        else if ($fname = ('group-items')) then
            let $items := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $groupKeyExpr := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $groupProcExpr := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $wrapperName := $call/*[4]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $keyName := $call/*[5]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $fnOptions := $call/*[6]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:groupItems($items, $groupKeyExpr, $groupProcExpr, $wrapperName, $keyName, $fnOptions, $options)
                        

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
        else if ($fname = ('indent', 'indent-ec')) then
            let $da := if (f:hasExplicitContext($fname)) then 1 else 0
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $text := if ($da) then $arg1 else $context
            let $indentString := $call/*[1 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $fnOptions := $call/*[2 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:indent($text, $indentString, $fnOptions)
            
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

        (: function `insert-nodes` 
           ======================= :)
        else if ($fname = ('insert-nodes', 'insert-nodes-ec')) then
            let $da := if (ends-with($fname, '-ec')) then 1 else 0        
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $doc := if ($da) then $arg1 else $context
            let $insertWhereExpr :=
                if (not($da)) then $arg1 else                
                $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $insertWhatExpr :=
                $call/*[2 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $wrapExpr :=
                $call/*[3 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $fnOptions :=
                $call/*[4 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:insertNodes($doc, $insertWhereExpr, $insertWhatExpr, $wrapExpr, $fnOptions, $options)
                        
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
            let $options := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options) 
            return foxf:jparse($text, $options)

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

        (: function `lpad` 
           =============== :)
        else if ($fname eq 'lpad') then
            let $string := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $width := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)          
            let $fillChar := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $fillChar := ($fillChar, ' ')[1]
            return
                util:lpad($string, $width, $fillChar)

        (: function `map-items` 
           ==================== :)
        else if ($fname eq 'map-items') then
            let $items := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $expr := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:mapItems($items, $expr, $options)            
                
        (: function `matches-pattern` 
           ========================= :)
        else if ($fname eq 'matches-pattern') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $countArgs := count($call/*)
            let $item :=
                if (1 lt $countArgs) then $arg1 else $context 
            let $pattern := 
                if (1 lt $countArgs) then
                    $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $arg1
            return
                foxf:matchesPattern($item, $pattern)

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

        (: function `name-content` 
           ===================== :)
        else if ($fname = ('name-content', 'name-content-ec',
                           'lname-content', 'lname-content-ec',
                           'jname-content', 'jname-content-ec'))
        then
            let $da := if (f:hasExplicitContext($fname)) then 1 else 0
            let $nameKind := 
                if (contains($fname, 'lname')) then 'lname' else if (contains($fname, 'jname')) then 'jname' else 'name'
            let $contextNodes := if ($da eq 0) then $context else 
                $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $namesFilter := $call/*[1 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $options := $call/*[2 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:nameContent($contextNodes, $namesFilter, $options)

        (: function `name-diff` 
           ==================== :)
        else if ($fname = ('name-diff', 'name-diff-ec')) then
            let $da := if (f:hasExplicitContext($fname)) then 1 else 0
            let $items := (
                $context[$da eq 0],
                $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options))
            let $fnOptions := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:nameDiff($items, $fnOptions, $fname)

        (: function `name-multi-diff` 
           ========================== :)
        else if ($fname = ('name-multi-diff', 'name-multi-diff-ec')) then   
            let $da := if (f:hasExplicitContext($fname)) then 1 else 0   
            let $items := (
                $context[$da eq 0],
                $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options))
            let $options := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $options := string-join(($options, 'report-names'), ' ')
            return foxf:pathMultiDiff($items, $options, $fname)

        (: function `name-path` 
           =================== :)
        else if ($fname = ('name-path', 'name-path-ec')) then  
            let $da := if (ends-with($fname, '-ec')) then 1 else 0
            let $nodes :=
                if (not($da)) then $context 
                else $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $numSteps := $call/*[1 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)                
            let $options := $call/*[2 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                if (empty($nodes)) then () else 
                    foxf:namePath($nodes, $numSteps, $options)
                    
        (: function `node-deep-equal` 
           ========================= :)
        else if ($fname = ('node-deep-equal', 'node-deep-equal-ec')) then
            let $da := if (ends-with($fname, '-ec')) then 1 else 0    
            let $items := (
                $context[$da eq 0],
                $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options))
            return
                foxf:nodesDeepEqual($items)
                            
        (: function `node-deep-similar` 
           ============================ :)
        else if ($fname = ('node-deep-similar', 'node-deep-similar-ec')) then
            let $da := if (ends-with($fname, '-ec')) then 1 else 0    
            let $items := (
                $context[$da eq 0],
                $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options))
            let $excludeExprs := 
                for $i in 2 to count($call/*) return
                    $call/*[$i]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:nodesDeepSimilar($items, $excludeExprs, $options)
                            
        (: function `node-location` 
           ======================== :)
        else if ($fname = ('node-location', 'nlocation',
                           'lnode-location', 'lnlocation',
                           'jnode-location', 'jnlocation')) then
            let $nodes :=
                if ($call/*) then 
                    $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context
            let $flags := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $nameKind := 
                if (starts-with($fname, 'j')) then 'jname' 
                else if (starts-with($fname, 'l')) then 'lname' 
                else 'name'
            return 
                if (empty($nodes)) then () else 
                    foxf:nodesLocationReport($nodes, $nameKind, $flags)

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
                            let $func := trace(if (substring($flags, 1, 1) eq 'l') then util:lpad#3 else util:rpad#3 , 'FUNC: ')
                            let $side := if (substring($flags, 1, 1) eq 'l') then 'l' else 'r'                            
                            let $fill := substring($flags, 2, 1)
                            return 
                                if ($side eq 'l') then util:lpad($value, $width, $fill)
                                else util:rpad($value, $width, $fill)
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

        (: function `path-diff` 
           ======================= :)
        else if ($fname = (
                'path-diff', 'path-diff-ec')) then
            let $da := if (f:hasExplicitContext($fname)) then 1 else 0 
            let $items := (
                $context[$da eq 0],
                $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options))
            let $fnOptions := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:pathDiff($items, $fnOptions, $fname)

        (: function `path-multi-diff` 
           ========================== :)
        else if ($fname = ('path-multi-diff', 'path-multi-diff-ec')) then   
            let $da := if (f:hasExplicitContext($fname)) then 1 else 0   
            let $items := (
                $context[$da eq 0],
                $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options))
            let $options := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:pathMultiDiff($items, $options, $fname)

        (: function `path-content` 
           ======================= :)
        else if ($fname = ('path-content', 'path-content-ec')) then
            let $da := if (f:hasExplicitContext($fname)) then 1 else 0
            let $args := $call/*
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $nodes := if ($da eq 0) then $context else $arg1
            let $leafNameFilter := $call/*[1 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $innerNodeNameFilter := $call/*[2 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $options := $call/*[3 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:pathContent($nodes, $leafNameFilter, $innerNodeNameFilter, $options)

        (: function `percent` 
           ================== :)
        else if ($fname = ('percent')) then           
            let $values := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $value2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            let $fractionDigits := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            return
                foxf:percent($values, $value2, $fractionDigits)

        (: function `pfilter-items` 
           ========================= :)
        else if ($fname eq 'pfilter-items') then
            let $items:= $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $pattern := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:pfilterItems($items, $pattern)

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

        (: function `pretty-node` 
           ===================== :)
        else if ($fname = ('pretty-node', 'pretty-node-ec')) then
            let $da := if (f:hasExplicitContext($fname)) then 1 else 0        
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $doc := if ($da) then $arg1 else $context        
            let $options := $call/*[1 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:prettyNode($doc, $options)

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
                        
        (: function `resolve-fox` 
           ====================== :)
        else if ($fname =  ('resolve-fox', 'resolve-fox-ec')) then
            let $da := if (f:hasExplicitContext($fname)) then 1 else 0        
            let $fox := $call/*[1 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $ctxt := 
                if (not($da)) then $context else 
                  $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:resolveFoxpath($ctxt, $fox, map{})      

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
                            
        (: function `rename-nodes` 
           ========================= :)
        else if ($fname = ('rename-nodes', 'rename-nodes-ec')) then
            let $da := if (ends-with($fname, '-ec')) then 1 else 0        
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $doc := if ($da) then $arg1 else $context
            let $targetNodesExpr :=
                if (not($da)) then $arg1 else                
                $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $nameExpr :=
                $call/*[2 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $fnOptions :=
                $call/*[3 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:renameNodes($doc, $targetNodesExpr, $nameExpr, $fnOptions, $options)
                        
        (: function `repeat` 
           ================= :)
        else if ($fname eq 'repeat') then
            let $string := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $count := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)          
            return
                foxf:repeat($string, $count)
                
        (: function `replace-values` 
           ========================= :)
        else if ($fname = ('replace-values', 'replace-values-ec')) then
            let $da := if (ends-with($fname, '-ec')) then 1 else 0        
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $doc := if ($da) then $arg1 else $context
            let $replaceNodesExpr :=
                if (not($da)) then $arg1 else                
                $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $valueExpr :=
                $call/*[2 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $fnOptions :=
                $call/*[3 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:replaceValues($doc, $replaceNodesExpr, $valueExpr, $fnOptions, $options)
                        
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
                util:rpad($string, $width, $fillChar)

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

        (: function `subset-fraction` 
           ========================== :)
        else if ($fname = ('subset-fraction')) then
            let $values := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $filterExpr := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options) 
            let $format := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:subsetFraction($values, $filterExpr, $format, $options)

        (: function `table` 
           ================ :)
        else if ($fname = ('table')) then
            let $values := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $headers := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                            (: ! normalize-space(.) ! tokenize(.) :)
            let $options := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)                            
            return
                foxf:table($values, $headers, $options)

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
        else if ($fname = ('truncate', 'truncate-ec')) then
            let $da := if (f:hasExplicitContext($fname)) then 1 else 0
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $string := if ($da) then $arg1 else $context
            let $len := $call/*[1 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $flags := $call/*[2 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
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
                
        (: function `fmirrored` 
           ==================== :)
        (:
        else if ($fname = ('fmirrored', 'ec-fmirrored')) then
            let $da := if (starts-with($fname, 'ec-')) then 1 else 0
            let $contextUris := if ($da eq 0) then $context else
                $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $reflector1 := $call/*[1 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $reflector2 := $call/*[2 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            (:
            let $_DEBUG := trace($reflector1, '_R1: ')
            let $_DEBUG := trace($reflector2, '_R2: ')
             :)
            return foxf:getMirroredURI($contextUris, $reflector1, $reflector2, (), ())
        :)
        
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
        else if ($fname eq 'write-doc/old') then
            let $item := $context
            let $fname := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $options := $call/*[2] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:writeDoc($item, $fname, $options)
        (:
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
         :)        
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
           (:
        else if ($fname eq 'write-files') then
            let $files := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $folder := $call/*[2] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $encoding := $call/*[3] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:writeFiles($files, $folder, $encoding)
:)
        (: function `write-files` 
           ====================== :)
        else if ($fname eq 'write-files') then
            let $items := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $folder := $call/*[2] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $fileNameExpr := $call/*[3] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            let $encoding := $call/*[4] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $fnOptions := $call/*[5] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:writeFiles($items, $folder, $fileNameExpr, $encoding, $fnOptions, $options)
                
        (: function `write-doc` 
           ==================== :)
        else if ($fname = ('write-doc', 'write-doc-ec')) then
            let $da := if (f:hasExplicitContext($fname)) then 1 else 0
            let $arg1 := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $docs := if ($da) then $arg1 else $context        
            let $folder := $call/*[1 + $da] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $fnOptions := $call/*[2 + $da] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:writeDoc($docs, $folder, (), (), (), (), $fnOptions, $options, $fname)
                
        (: function `write-named-doc` 
           ========================== :)
        else if ($fname = ('write-named-doc', 'write-named-doc-ec')) then
            let $da := if (f:hasExplicitContext($fname)) then 1 else 0
            let $arg1 := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $docs := if ($da) then $arg1 else $context
            let $folder := $call/*[1 + $da] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $name := $call/*[2 + $da] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $fnOptions := $call/*[3 + $da] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:writeDoc($docs, $folder, $name, (), (), (), $fnOptions, $options, $fname)

        (: function `write-renamed-doc` 
           ============================ :)
        else if ($fname = ('write-renamed-doc', 'write-renamed-doc-ec')) then
            let $da := if (f:hasExplicitContext($fname)) then 1 else 0
            let $arg1 := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $docs := if ($da) then $arg1 else $context        
            let $folder := $call/*[1 + $da] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $nameFrom := $call/*[2 + $da] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $nameTo := $call/*[3 + $da] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $fnOptions := $call/*[4 + $da] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:writeDoc($docs, $folder, (), (), $nameFrom, $nameTo, $fnOptions, $options, $fname)

        (: function `write-exnamed-doc` 
           ============================ :)
        else if ($fname = ('write-exnamed-doc', 'write-exnamed-doc-ec')) then
            let $da := if (f:hasExplicitContext($fname)) then 1 else 0
            let $arg1 := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $docs := if ($da) then $arg1 else $context        
            let $folder := $call/*[1 + $da] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $nameExpr := $call/*[2 + $da] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $fnOptions := $call/*[3 + $da] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:writeDoc($docs, $folder, (), $nameExpr, (), (), $fnOptions, $options, $fname)

        (: function `write-json-docs` 
           ========================= :)
        else if ($fname eq 'write-json-docs') then
            let $files := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $folder := $call/*[2] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $encoding := $call/*[3] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:writeJsonDocs($files, $folder, $encoding)

        (: function `xatt` 
           ================== :)
        else if ($fname eq 'xatt') then
            let $contents := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $name := $call/*[2] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:xattribute($contents, $name)

        (: function `xelem` 
           ================ :)
        else if ($fname = ('xelem', 'xelem-ec')) then
            let $da := if (f:hasExplicitContext($fname)) then 1 else 0
            let $arg1 := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $items := if ($da) then $arg1 else $context 
            let $name := $call/*[1 + $da] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $options := $call/*[2 + $da] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:xelement($items, $name, $options)

        (: function `xelems` 
           ================= :)
        else if ($fname eq 'xelems') then
            let $items := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options) 
            let $name := $call/*[2] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $options := $call/*[3] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $useOptions := string-join(('repeat', $options), ' ')
            return foxf:xelement($items, $name, $useOptions)

        (: function `xitem-elems` 
           ====================== :)
        else if ($fname = ('xitem-elems', 'xitems', 'xelems')) then
            let $items := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $name := $call/*[2] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $options := $call/*[3] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                foxf:xitemElems($items, $name, $options)

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
                    return util:pattern2Regex($pattern)
            let $ns_regex := 
                if (empty($name) or not(contains($name, ' '))) then () else
                    let $pattern := substring-after($name, ' ') 
                    return util:pattern2Regex($pattern)
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
        else if ($fname = ('xsd-validate', 'xval', 'xsd-validate-ec', 'xval-ec')) then
            let $da := if (f:hasExplicitContext($fname)) then 1 else 0        
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $docs := if ($da) then $arg1 else $context
            let $xsds := if (not($da)) then $arg1 else
                         $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $fnOptions := $call/*[2 + $da]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return foxf:xsdValidate($docs, $xsds, $fnOptions)
            
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
         
        (: function `zzz-fox-ancestor` 
           ====================== :)

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
                    return util:pattern2Regex($pattern)
            let $ns := 
                if (empty($name) or not(contains($name, ' '))) then () else
                    let $pattern := substring-after($name, ' ') 
                    return util:pattern2Regex($pattern)
            let $elemLname :=
                if (empty($elemName)) then () else
                    let $pattern := substring-before(concat($elemName, ' '), ' ') return
                        concat('^', replace(replace($pattern, '\*', '.*'), '\.', '\\.'), '$')
            let $elemNs := 
                if (empty($elemName) or not(contains($elemName, ' '))) then () else
                    let $pattern := substring-after($elemName, ' ') return
                        concat('^', replace(replace($pattern, '\.', '\\.'), '\*', '.*'), '$')
            let $val := $val ! util:pattern2Regex(.)

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
                    return util:pattern2Regex($pattern)
            let $ns := 
                if (empty($name) or not(contains($name, ' '))) then () else
                    let $pattern := substring-after($name, ' ') 
                    return util:pattern2Regex($pattern)
            let $val := $val ! util:pattern2Regex(.)
            let $xpath :=
                let $itemSelector := concat(
                    concat('[matches(local-name(.), "', $lname, '", "i")]')[$lname],
                    concat('[matches(namespace-uri(.), "', $ns, '", "i")]')[$ns], 
                    concat('[not(*)][matches(., "', $val, '", "i")]')[$val]
                )
                return concat('//*', $itemSelector)                       
            return
                i:xquery($xpath, map{'':$doc})

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
            let $_DEBUG := trace($options, '___OPTIONS: ') return
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
            return deep-equal($arg1, $arg2) 

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
                
        (: function `format-number` 
           ======================== :)
        else if ($fname eq 'format-number') then
            let $number := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $picture := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)          
            let $decimalFormatName := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                if ($decimalFormatName) then format-number($number, $picture, $decimalFormatName)
                else format-number($number, $picture)
                
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
                
        (: function `index-of` 
           =================== :)
        else if ($fname eq 'index-of') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                index-of($arg1, $arg2)
                
        (: function `innermost` 
           ==================== :)
        else if ($fname eq 'innermost') then
            let $nodes := 
                if ($call/*) then $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context
            return
                innermost($nodes)
                
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

        (: function `outermost` 
           ==================== :)
        else if ($fname eq 'outermost') then
            let $nodes := 
                if ($call/*) then $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context
            return
                outermost($nodes)

        (: function `parse-html` 
           ==================== :)
        else if ($fname eq 'parse-html') then
            let $text := 
                if ($call/*) then $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context
            return
                try {html:parse($text)} catch * {<PARSE_ERROR>{$text}</PARSE_ERROR>}

        (: function `parse-xml` 
           =================== :)
        else if ($fname eq 'parse-xml') then
            let $text := 
                if ($call/*) then $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context
            return
                try {parse-xml($text)} catch * {<PARSE_ERROR>{$text}</PARSE_ERROR>}

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

(:~
 : Returns true if the function input is supplied by
 : a parameter, it is not the context item.
 :)
declare function f:hasExplicitContext($funcName as xs:string)
        as xs:boolean {
    ends-with($funcName, '-ec')        
};        