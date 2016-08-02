module namespace f="http://www.ttools.org/xquery-functions";
import module namespace i="http://www.ttools.org/xquery-functions" at 
    "foxpath-processorDependent.xqm",
    "foxpath-resourceTreeTypeDependent.xqm",
    "foxpath-util.xqm";
    
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
                                       $vars as map(*)?)                                       
        as item()* {
    let $fname := $call/@name
    return    
        f:trace(
        
        (: ################################################################
         : p a r t  1:    e x t e n s i o n    f u n c t i o n s
         : ################################################################ :)

        (: function `bslash` 
           ================= :)
        if ($fname eq 'back-slash' or $fname eq 'bslash') then
            let $arg := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
                return
                    ($explicit, $context)[1]
            return
                replace($arg, '/', '\\')
                
        (: function `echoString` 
           ================= :)
        else if ($fname eq 'echo-string') then
            let $arg := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
                return
                    ($explicit, $context)[1]
            return
                string($arg)
                
        (: function `eval-xpath` 
           ===================== :)
        else if ($fname = ('eval-xpath', 'xpath')) then
            let $xpath := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)  
            let $xpathContext :=
                let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
                return ($arg2, $context)
            let $xpathContextNode :=
                if ($xpathContext instance of node()) then $xpathContext
                else if (exists($xpathContext) and doc-available($xpathContext)) then doc($xpathContext)
                else ()
            return
                i:xquery($xpath, map{'':$xpathContextNode})
                
        (: function `file-contains` 
           ======================= :)
        else if ($fname eq 'file-contains') then
            let $pattern :=
                if ($call/*[2]) then
                    $call/*[2]
                    /f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
                else if ($call/*) then
                    $call/*[1]
                    /f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
                else 
                    error(QName((), 'INVALID_CALL'), 
                        'Function "file-contains" requires at least one parameter.')
            let $uri :=
                if ($call/*[2]) then
                    $call/*[1]
                    /f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
                else $context
            let $text :=
                try {unparsed-text($uri)} catch * {()}
            return
                if (not($text)) then () else
                let $regex := replace($pattern, '\*', '.*')
                return
                    matches($text, $regex, 's')
            
        (: function `file-date` 
           ==================== :)
        else if ($fname eq 'file-date' or $fname eq 'fdate') then
            let $arg := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
                return
                    ($explicit, $context)[1]
            return
                f:fileDate($arg)
            
        (: function `file-info` 
           ==================== :)
        else if ($fname eq 'file-info') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)        
            let $arg2 := 
                let $explicit := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
                return
                    ($explicit, $context)[1]                   
            return
                f:fileInfo($arg1, $arg2)

       (: function `file-lines` 
          ===================== :)
        else if ($fname = 'file-lines') then
            let $pattern := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            let $uri := 
                let $explicit := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)          
                return
                    ($explicit, $context)[1]
            let $regex :=
                if (not($pattern)) then ()
                else concat('^.*', replace(replace($pattern, '\*', '.*'), '\?', '.'), '.*$')
            let $lines := 
                try {unparsed-text-lines($uri)[empty($regex) or matches(., $regex, 'i')]}
                catch * {()}
            return
                $lines 

       (: function `grep` 
          =============== :)
        else if ($fname = ('file-lines', 'grep')) then
            let $pattern := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            let $uri := 
                let $explicit := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)          
                return
                    ($explicit, $context)[1]
            let $regex :=
                if (not($pattern)) then ()
                else concat('^.*', replace(replace($pattern, '\*', '.*'), '\?', '.'), '.*$')
            let $lines := 
                try {unparsed-text-lines($uri)[empty($regex) or matches(., $regex, 'i')]}
                catch * {()}
            return
                if (empty($lines)) then () else 
                    string-join((concat('##### ', $uri, ' #####'), $lines, '----------'), '&#xA;')

        (: function `file-name` 
           ==================== :)
        else if ($fname eq 'file-name' or $fname eq 'fname') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            let $arg := if (empty($arg)) then $context else $arg
            return
                replace($arg[1], '.*/', '')
            
       (: function `file-size` 
           =================== :)
        else if ($fname eq 'file-size' or $fname eq 'size') then
            let $arg := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
                return
                    ($explicit, $context)[1]
            return
                f:fileSize($arg)

        (: function `has-xatt` 
           =================== :)
        else if ($fname eq 'has-xatt' or $fname eq 'xatt') then
            if (not(doc-available($context))) then false() else
            
            let $name := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            let $val := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            let $elemName := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)            
            
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
            let $doc := doc($context)                    
            return
                boolean(i:xquery($xpath, map{'':$doc}))

        (: function `has-xelem` 
           ==================== :)
        else if ($fname eq 'has-xelem' or $fname eq 'xelem') then
            if (not(doc-available($context))) then false() else
            
            let $name := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            let $val := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            
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
            let $doc := doc($context)                    
            return
                boolean(i:xquery($xpath, map{'':$doc}))

        (: function `has-xroot` 
           =================== :)
        else if ($fname eq 'has-xroot') then
            if (not(doc-available($context))) then false() else
            
            let $name := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)           
            let $name := normalize-space($name)
            let $lname :=
                if (empty($name)) then () else
                    let $pattern := substring-before(concat($name, ' '), ' ') 
                    return f:pattern2Regex($pattern)
            let $ns := 
                if (empty($name) or not(contains($name, ' '))) then () else
                    let $pattern := substring-after($name, ' ') 
                    return f:pattern2Regex($pattern)
            let $xpath :=
                let $itemSelector := concat(
                    concat('[matches(local-name(.), "', $lname, '", "i")]')[$lname],
                    concat('[matches(namespace-uri(.), "', $ns, '", "i")]')[$ns] 
                )
                return concat('/*', $itemSelector)                       
            let $doc := doc($context)                    
            return
                boolean(i:xquery($xpath, map{'':$doc}))

        (: function `is-dir` 
           ================= :)
        else if ($fname eq 'is-dir' or $fname eq 'isDir') then
            let $arg := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
                return
                    ($explicit, $context)[1]
            return
                file:is-dir($arg)
            
        (: function `is-file` 
           ================== :)
        else if ($fname eq 'is-file' or $fname eq 'isFile') then
            let $arg := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
                return
                    ($explicit, $context)[1]
            return
                file:is-file($arg)
            
        (: function `isXml` 
           =============== :)
        else if ($fname eq 'is-xml' or $fname eq 'isXml') then
            let $arg := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
                return ($explicit, $context)[1]
            return
                doc-available($arg)
            
        (: function `lpad` 
           =============== :)
        else if ($fname eq 'lpad') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)          
            let $arg3 := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            let $char3 := ($arg3, ' ')[1]
            return
                f:lpad($arg1, $arg2, $arg3)
            
        (: function `matches-xpath` 
           ======================= :)
        (: *TODO* Not yet quite sure how to deal with non-node context which cannot be resolved to a document :)
        else if ($fname eq 'matches-xpath') then
            let $xpath := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)  
            let $xpathContext :=
                let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
                return ($arg2, $context)[1]
            let $xpathContextNode :=
                if ($xpathContext instance of node()) then $xpathContext
                else if (exists($xpathContext) and doc-available($xpathContext)) then doc($xpathContext)
                else ()
            return
                boolean(i:xquery($xpath, map{'':$xpathContextNode})[1])
                   
        (: function `rpad` 
           =============== :)
        else if ($fname eq 'rpad') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)          
            let $arg3 := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            let $char3 := ($arg3, ' ')[1]
            return
                f:rpad($arg1, $arg2, $arg3)

        (: function `xroot` 
           ================ :)
        else if ($fname eq 'xroot') then
            let $arg :=
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
                return
                    ($explicit, $context)[1]
            return        
                if (not(try {doc-available($arg)} catch * {()})) then () else
                    doc($arg)/*/local-name(.)
                (: try catch in order to avoid errors in case of invalid URIs :)
                
        (: ################################################################
         : p a r t  2:    s t a n d a r d    f u n c t i o n s
         : ################################################################ :)

        (: function `avg` 
           ============== :)
        else if ($fname eq 'avg') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            return
                avg($arg)
                
        (: function `concat` 
           ================= :)
        else if ($fname eq 'concat') then
            string-join(
                for $arg in $call/* return 
                    f:resolveFoxpathRC($arg, false(), $context, $position, $last, $vars)
            , '')
            
        (: function `contains` 
           =================== :)
        else if ($fname eq 'contains') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)          
            return
                contains($arg1, $arg2)
            
        (: function `count` 
           ================ :)
        else if ($fname eq 'count') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)        
            return count($arg)
            
        (: function `current-dateTime` 
           ========================== :)
        else if ($fname eq 'current-dateTime') then
            string(current-dateTime())
                
        (: function `date` 
           =============== :)
        else if ($fname eq 'date') then
            let $arg := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
                return ($explicit, $context)[1]
            return
                xs:date(substring(string(file:last-modified($arg)), 1, 10))

        (: function `dateTime` 
           =============== :)
        else if ($fname eq 'dateTime') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            return
                xs:dateTime($arg)

        (: function `day-from-date` 
           ======================== :)
        else if ($fname eq 'day-from-date') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            return
                day-from-date($arg)
                
        (: function `dcat` 
           ============== :)
        else if ($fname eq 'dcat') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            let $docs := sort($arg [doc-available(.)], lower-case#1) 
            return
                <docs count="{count($docs)}" t="{current-dateTime()}">{
                    $docs ! <doc uri="{.}"/>
                }</docs>

        (: function `distinct-values` 
           ========================== :)
        else if ($fname eq 'distinct-values') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)        
            return
                distinct-values($arg)
                
        (: function `doc` 
           ============== :)
        else if ($fname eq 'doc') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)        
            return
                doc($arg)
                
        (: function `document-uri` 
           ======================= :)
        else if ($fname eq 'document-uri') then
            let $arg := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
                return ($explicit, $context)[1] 
            return
                document-uri($arg)
                
        (: function `doc-available` 
           ======================== :)
        else if ($fname eq 'doc-available') then
            let $arg := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
                return ($explicit, $context)[1]      
            return
                doc-available($arg)
                
        (: function `empty` 
           ================ :)
        else if ($fname eq 'empty') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)         
            return
                empty($arg1)
                
        (: function `ends-with` 
           ==================== :)
        else if ($fname eq 'ends-with') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)          
            return
                ends-with($arg1, $arg2)
                
        (: function `false` 
           ================ :)
        else if ($fname eq 'false') then
            false()
            
        (: function `last` 
           =============== :)
        else if ($fname eq 'last') then
            $last
            
        (: function `local-name` 
           ===================== :)
        else if ($fname eq 'local-name') then
            let $arg := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
                return ($explicit, $context)[1]
            return
                local-name($arg)

        (: function `matches` 
           ================== :)
        else if ($fname eq 'matches') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)            
            let $arg3 := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)            
            return
                if (exists($arg3)) then matches($arg1, $arg2, $arg3)
                else matches($arg1, $arg2)
                
        (: function `max` 
           ============== :)
        else if ($fname eq 'max') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            return
                max($arg)
                
        (: function `min` 
           ============== :)
        else if ($fname eq 'min') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            return
                min($arg)
                
        (: function `month-from-date` 
           ========================== :)
        else if ($fname eq 'month-from-date') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            return
                month-from-date($arg)
                
        (: function `not` 
           ============== :)
        else if ($fname eq 'not') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            return
                not($arg[1])
                
        (: function `position` 
           =================== :)
        else if ($fname eq 'position') then
            $position
            
        (: function `replace` 
           ==================== :)
        else if ($fname eq 'replace') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)            
            let $arg3 := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)            
            return
                if (exists($arg3)) then replace($arg1, $arg2, $arg3)
                else substring($arg1, $arg2)

        (: function `root` 
           ===================== :)
        else if ($fname eq 'root') then
            let $arg := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
                return ($explicit, $context)[1]
            return
                root($arg)

        (: function `sort` 
           ==================== :)
        else if ($fname eq 'sort') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)          
            return
                if (exists($arg2)) then sort($arg1, $arg2)
                else sort($arg1)

        (: function `starts-with` 
           ====================== :)
        else if ($fname eq 'starts-with') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)          
            return
                starts-with($arg1, $arg2)
                
        (: function `string` 
           ================= :)
        else if ($fname eq 'string') then
            let $arg := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
                return
                    ($explicit, $context)[1]
            return
                string($arg)
                
        (: function `string-join` 
           ====================== :)
        else if ($fname eq 'string-join') then
            let $items := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            let $sep := 
                let $explicit := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
                return ($explicit, '')[1]
            return
                string-join($items, $sep)                
                
        (: function `string-length` 
           ======================== :)
        else if ($fname eq 'string-length') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            return
                string-length(string($arg))
                
        (: function `substring` 
           ==================== :)
        else if ($fname eq 'substring') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)            
            let $arg3 := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)            
            return
                if (exists($arg3)) then substring($arg1, $arg2, $arg3)
                else substring($arg1, $arg2)
                
        (: function `substring-after` 
           =========================== :)
        else if ($fname eq 'substring-after') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)            
            return
                substring-after($arg1, $arg2)
                
        (: function `substring-before` 
           =========================== :)
        else if ($fname eq 'substring-before') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)            
            return
                substring-before($arg1, $arg2)
                
        (: function `sum` 
           ============== :)
        else if ($fname eq 'sum') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            return
                sum($arg)
                
        (: function `tokenize` 
           =================== :)
        else if ($fname eq 'tokenize') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)            
            let $arg3 := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)            
            return
                if (not($arg2)) then tokenize($arg1) 
                else if (not($arg3)) then tokenize($arg1, $arg2)
                else tokenize($arg1, $arg2, $arg3)

        (: function `true` 
           =============== :)
        else if ($fname eq 'true') then
            true()

        (: function `year-from-date` 
           ========================= :)
        else if ($fname eq 'year-from-date') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)
            return
                year-from-date($arg)
                
        (: function `xs:integer` 
           ===================== :)
        else if ($fname eq 'xs:integer') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars)          
            return
                xs:integer($arg1)
                
        else
        error(QName((), 'NOT_YET_IMPLEMENTED'),
            concat('Unexpected function name: ', $fname))
            
        , 'function', concat('FUNCTION_CALL; FNAME=', $fname, ' : '))
        
};

(: 
 : ===============================================================================
 :
 :     f o x p a t h    e x t e n s i o n    f u n c t i o n s
 :
 : ===============================================================================
 :)
declare function f:lpad($s as xs:anyAtomicType?, $width as xs:integer, $char as xs:string?)
        as xs:string? {
    let $s := string($s)    
    let $len := string-length($s) 
    return
        if ($len ge $width) then $s else    
            let $char := ($char, ' ')[1]
            let $pad := concat(string-join(for $i in 1 to $width - $len - 1 return $char, ''), ' ')
            return
                concat($pad, $s)
};

declare function f:rpad($s as xs:anyAtomicType?, $width as xs:integer, $char as xs:string?)
        as xs:string? {
    let $s := string($s)
    let $len := string-length($s) 
    return
        if ($len ge $width) then $s else    
            let $char := ($char, ' ')[1]
            let $pad := concat(' ', string-join(for $i in 1 to $width - $len - 1 return $char, ''), '')
            return
                concat($s, $pad)
};
                
declare function f:fileDate($uri as xs:string?)
        as xs:dateTime? {
    $uri ! file:last-modified(.)
};
                
declare function f:fileName($uri as xs:string?)
        as xs:string? {
    $uri ! replace(., '.*/', '')
};
                
declare function f:fileSize($uri as xs:string?)
        as xs:integer? {
    $uri ! file:size(.)
};

declare function f:fileInfo($content as xs:string?, $uri as xs:string?)
        as xs:string? {
    let $co := ($content, 'p60. s10. d')[1]
    let $items := tokenize(normalize-space($co), ' ')
    let $line := string-join((
        for $item in $items
        let $kind := substring($item, 1, 1)
        let $format := substring($item, 2)[string()]
        let $width := $format ! replace($format, '\D', '') ! xs:integer(.)
        let $fillChar := 
            if (empty($format)) then () else (replace($format, '^\d+', '')[string()], ' ')[1]
        let $value :=
            if ($kind eq 'p') then $uri
            else if ($kind eq 'n') then f:fileName($uri)
            else if ($kind eq 's') then f:fileSize($uri)
            else if ($kind eq 'd') then f:fileDate($uri)
            else if ($kind eq 'r') then
                if (not(doc-available($uri))) then '-'
                else doc($uri)/*/local-name(.)
            else ()
        return
            if (empty($width)) then $value else 
                if ($kind eq 's') then f:lpad($value, $width, $fillChar)
                else f:rpad($value, $width, $fillChar)
        ), ' ')            
    return
        $line
};
