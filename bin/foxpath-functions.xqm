module namespace f="http://www.ttools.org/xquery-functions";
import module namespace i="http://www.ttools.org/xquery-functions" at 
    "foxpath-processorDependent.xqm",
    "foxpath-fox-functions.xqm",
    "foxpath-uri-operations.xqm",
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
                                       $vars as map(*)?,
                                       $options as map(*)?)
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
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    ($explicit, $context)[1]
            return
                f:foxfunc_bslash($arg)

        (: function `dcat` 
           =============== :)
        else if ($fname eq 'dcat') then
            let $items := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $onlyDocAvailable := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $refs :=
                for $item in $items
                return
                    if ($onlyDocAvailable and not(i:fox-doc-available($item, $options))) then () 
                    else <doc href="{$item}"/>
            return
                <dcat targetFormat="xml" 
                      t="{current-dateTime()}" 
                      onlyDocAvailable="{boolean($onlyDocAvailable)}">{$refs}</dcat>
                            
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
                try {i:fox-unparsed-text($uri, $options)} catch * {()}
            return
                if (not($text)) then () else
                let $regex := replace($pattern, '\*', '.*')
                return
                    matches($text, $regex, 'si')
            
        (: function `file-content` 
           ======================= :)
        else if ($fname eq 'file-content') then
            let $pattern :=
                if ($call/*[2]) then
                    $call/*[2]
                    /f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else if ($call/*) then
                    $call/*[1]
                    /f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else () 
            let $uri :=
                if ($call/*[2]) then
                    $call/*[1]
                    /f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                else $context
            return
                if (not($pattern)) then f:fox-unparsed-text($uri, $options)
                else
                    let $regex := replace($pattern, '\*', '.*')
                    return
                        f:fox-unparsed-text-lines($uri, $options)[matches(., $regex, 'i')]
            
        (: function `file-date` 
           ==================== :)
        else if ($fname eq 'file-date' or $fname eq 'fdate') then
            let $uri := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    ($explicit, $context)[1]
            return
                i:fox-file-date($uri, $options)
            
        (: function `file-sdate` 
           ===================== :)
        else if ($fname eq 'file-sdate' or $fname eq 'fsdate') then
            let $uri := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    ($explicit, $context)[1]
            return
                f:fox-file-sdate($uri, $options)
            
        (: function `file-ext` 
           ================== :)
        else if ($fname eq 'file-ext') then
            let $uri := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)          
                return
                    ($explicit, $context)[1]
            let $fileName := replace($uri, '.*/', '')
            let $ext := replace($fileName, '.*(\..*)', '$1')
            return
                $ext
            
        (: function `file-info` 
           ==================== :)
        else if ($fname eq 'file-info') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $arg2 := 
                let $explicit := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    ($explicit, $context)[1]                   
            return
                f:fileInfo($arg1, $arg2, $options)

       (: function `file-lines` 
          ===================== :)
        else if ($fname = 'file-lines') then
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
                
            let $lines := i:fox-file-lines($uri, $options)
            let $lines := 
                if (not($line1) and not($line2)) then $lines else
                    $lines[(empty($line1) or position() ge $line1) and (not($line2) or position() le $line2)]                 
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
                replace($uri[1], '.*/', '')
            
       (: function `file-size` 
           =================== :)
        else if ($fname eq 'file-size' or $fname eq 'size') then
            let $uri := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    ($explicit, $context)[1]
            return
                i:fox-file-size($uri, $options)

       (: function `grep` 
          =============== :)
        else if ($fname eq 'grep') then
            let $pattern := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $uri := 
                let $explicit := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)          
                return
                    ($explicit, $context)[1]
            let $regex :=
                if (not($pattern)) then ()
                else concat('^.*', replace(replace($pattern, '\*', '.*'), '\?', '.'), '.*$')
            let $lines := i:fox-unparsed-text-lines($uri, $options)
            let $lines := $lines[empty($regex) or matches(., $regex, 'i')]
            return
                if (empty($lines)) then () else 
                    string-join((concat('##### ', $uri, ' #####'), $lines, '----------'), '&#xA;')

        (: function `is-dir` 
           ================= :)
        else if ($fname eq 'is-dir' or $fname eq 'isDir') then
            let $uri :=
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    ($explicit, $context)[1]
            return
                i:fox-is-dir($uri, $options)
            
        (: function `is-file` 
           ================== :)
        else if ($fname eq 'is-file' or $fname eq 'isFile') then
            let $uri := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    ($explicit, $context)[1]
            return
                i:fox-is-file($uri, $options)
            
        (: function `is-xml` 
           ================ :)
        else if ($fname eq 'is-xml' or $fname eq 'isXml') then
            let $uri := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                i:fox-doc-available($uri, $options)
            
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
        else if ($fname eq 'json-doc') then
            let $uri := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                i:fox-json-doc($uri, $options)
                            
        (: function `json-doc-available` 
           ============================= :)
        else if ($fname eq 'json-doc-available') then
            let $uri := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                try {i:fox-json-doc($uri, $options)/true()} catch * {false()}
                            
       (: function `linefeed` 
          ================== :)
        else if ($fname eq 'linefeed') then
            if (not($call/*)) then '&#xA;'
            else
                let $count := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    string-join(for $i in 1 to $count return '&#xA;')
        
        (: function `lpad` 
           =============== :)
        else if ($fname eq 'lpad') then
            let $string := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $width := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)          
            let $fillChar := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $fillChar := ($fillChar, ' ')[1]
            return
                f:lpad($string, $width, $fillChar)
            
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
                            
        (: function `rpad` 
           =============== :)
        else if ($fname eq 'rpad') then
            let $string := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $width := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)          
            let $fillChar := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $fillChar := ($fillChar, ' ')[1]
            return
                f:rpad($string, $width, $fillChar)

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
                            
        (: function `xatt` 
           =============== :)
        else if ($fname eq 'has-xatt' or $fname eq 'xatt') then
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

        (: function `xelem` 
           ================ :)
        else if ($fname eq 'has-xelem' or $fname eq 'xelem') then
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
                
        (: function `xwrap` 
           ==================== :)
        else if ($fname eq 'xwrap') then
            let $val := $call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)        
            let $name := $call/*[2] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $flags := $call/*[3] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)

            let $name := normalize-space($name)
            let $lname :=
                if (empty($name)) then () 
                else substring-before(concat($name, ' '), ' ') 
            let $ns := 
                if (empty($name) or not(contains($name, ' '))) then () 
                else substring-after($name, ' ') 
            let $qname := QName($ns, $lname)

            return
                f:foxfunc_xwrap($val, $qname, $flags, $options)

(: the following two functions are at risk:
    eval-xpath
    matches-xpath    
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
                   
        (: function `echo` 
           ==================== :)
        else if ($fname eq 'echo') then
            let $val := trace($call/*[1] ! f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options) , 'VAL: ')        
            return
                $val

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
            
        (: function `current-dateTime` 
           ========================== :)
        else if ($fname eq 'current-dateTime') then
            string(current-dateTime())
                
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
            let $redirectedRetrieval := f:redirectedRetrieval($uri, $options)
            return
                if ($redirectedRetrieval) then 
                    let $doc := try {parse-xml($redirectedRetrieval)} catch * {()}
                    return exists($doc)
                else i:fox-doc-available($uri, $options)
                
        (: function `empty` 
           ================ :)
        else if ($fname eq 'empty') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)         
            return
                empty($arg1)
                
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
                
        (: function `month-from-date` 
           ========================== :)
        else if ($fname eq 'month-from-date') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                month-from-date($arg)
                
        (: function `node-name` 
           ==================== :)
        else if ($fname eq 'node-name') then
            let $arg := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                node-name($arg)
            
        (: function `not` 
           ============== :)
        else if ($fname eq 'not') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                not($arg[1])
                
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
                else substring($arg1, $arg2)

        (: function `reverse` 
           ================== :)
        else if ($fname eq 'reverse') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                reverse($arg)

        (: function `root` 
           ===================== :)
        else if ($fname eq 'root') then
            let $arg := 
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, $context)[1]
            return
                root($arg)

        (: function `sort` 
           ==================== :)
        else if ($fname eq 'sort') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $arg2 := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)          
            let $arg3 := $call/*[3]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)            
            return
                if (exists($arg3)) then sort($arg1, $arg2, $arg3)
                else if (exists($arg2)) then sort($arg1, $arg2)                
                else sort($arg1)

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
                let $explicit := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return
                    ($explicit, $context)[1]
            return
                string($arg)
                
        (: function `string-join` 
           ====================== :)
        else if ($fname eq 'string-join') then
            let $items := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            let $sep := 
                let $explicit := $call/*[2]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
                return ($explicit, '')[1]
            return
                string-join($items, $sep)                
                
        (: function `string-length` 
           ======================== :)
        else if ($fname eq 'string-length') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                string-length(string($arg))
                
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
                
        (: function `tokenize` 
           =================== :)
        else if ($fname eq 'tokenize') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
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

        (: function `year-from-date` 
           ========================= :)
        else if ($fname eq 'year-from-date') then
            let $arg := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)
            return
                year-from-date($arg)
                
        (: function `xs:integer` 
           ===================== :)
        else if ($fname eq 'xs:integer') then
            let $arg1 := $call/*[1]/f:resolveFoxpathRC(., false(), $context, $position, $last, $vars, $options)          
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

(:
declare function f:fileDate($uri as xs:string?)
        as xs:dateTime? {
    $uri ! i:fileLastModified(.)
};
:)

declare function f:fileName($uri as xs:string?)
        as xs:string? {
    $uri ! replace(., '.*/', '')
};

(:~
 : Returns a string describing a resource identified by a URI.
 :)
declare function f:fileInfo($content as xs:string?, $uri as xs:string?, $options as map(*)?)
        as xs:string? {
    let $co := ($content, 'p60. s-10_ d')[1]
    let $items := tokenize(normalize-space($co), ' ')
    let $line := string-join((
        for $item in $items
        let $kind := substring($item, 1, 1)
        let $format := substring($item, 2)[string()]
        let $padWidth := $format ! replace($format, '\D', '') ! xs:integer(.)
        let $padSide := if (starts-with($format, '-')) then 'l' else 'r'
        let $fillChar := 
            if (empty($format)) then () else (replace($format, '^-?\d+', '')[string()], ' ')[1]
        let $isDir := i:fox-is-dir($uri, $options)            
        let $value :=
            if ($kind eq 'p') then $uri
            else if ($kind eq 'n') then f:fileName($uri)
            else if ($kind eq 's') then 
                if (i:fox-is-dir($uri, $options)) then '/' else i:fox-file-size($uri, $options)
            else if ($kind eq 'd') then i:fox-file-date($uri, $options)
            else if ($kind eq 'r') then
                let $doc := i:fox-doc($uri, $options)
                return
                    if (not($doc)) then '-' 
                    else $doc/*/local-name(.)
            else if ($kind eq 't') then
                let $doc := i:fox-doc($uri, $options)
                return
                    if (not($doc)) then '-'
                    else $doc/*/concat(local-name(.), ' / ', 
                        string-join(sort(distinct-values(*/local-name()), lower-case#1), ' '))
            else if ($kind eq 'e') then
                let $doc := i:fox-doc($uri, $options)
                return
                    if (not($doc)) then '-'
                    else $doc/*/concat(local-name(.), ' / ', 
                        string-join(sort(distinct-values(.//*/local-name()), lower-case#1), ' '))
            else if ($kind eq 'a') then
                let $doc := i:fox-doc($uri, $options)
                return
                    if (not($doc)) then '-'
                    else $doc/string-join(sort(distinct-values(
                        .//@*/local-name()), lower-case#1), ' ')
            else ()
        return            
            if (empty($padWidth)) then $value
            else if ($kind eq 's' and $isDir) then f:rpad('/', $padWidth, ' ')            
            else if ($padSide eq 'l') then f:lpad($value, $padWidth, $fillChar)
                else f:rpad($value, $padWidth, $fillChar)
        ), ' ')            
    return
        $line
};

(:
declare function f:fileSdate($uri as xs:string?)
        as xs:string? {
    $uri ! i:fileLastModified(.) ! string()
};
:)                
