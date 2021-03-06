module namespace f="http://www.foxpath.org/ns/fox-functions";
import module namespace i="http://www.ttools.org/xquery-functions" 
at "foxpath-processorDependent.xqm",
   "foxpath-uri-operations.xqm",
   "foxpath-util.xqm";

(:~
 : Edits a text, replacing forward slashes by back slashes.
 :
 : @param arg text to be edited
 : @return edited text
 :)
declare function f:bslash($arg as xs:string?)
        as xs:string? {
    replace($arg, '/', '\\')        
};      

(:~
 : Returns true if all items have deep-equal content. When comparing  the items,
 : only their content is considered, not their name. Thus elements with different
 : names can have deep-equal content.
 :
 : @param items the items to be checked
 : @return false if there is a pair of items which do not have deep-equal content, true otherwise
 :)
declare function f:content-deep-equal($items as item()*)
        as xs:boolean? {
    let $count := count($items)
    return if ($count le 1) then true() else
    
    every $i in 1 to $count - 1 satisfies
        let $item1 := $items[1]
        let $item2 := $items[2]
        let $atts1 := for $a in $item1/@* order by node-name($a), string($a) return $a
        let $atts2 := for $a in $item2/@* order by node-name($a), string($a) return $a
        return
            deep-equal($atts1, $atts2) and deep-equal($item1/node(), $item2/node())
};      

(:~
 : Returns the text content of a file resource.
 :
 : @param uri the file URI
 : @param encoding an encoding
 : @param options for future use
 : @return the text content
 :)
declare function f:file-content($uri as xs:string?, 
                                $encoding as xs:string?,
                                $options as map(*)?)
        as xs:string? {
    let $redirectedRetrieval := i:fox-unparsed-text_github($uri, $encoding, $options)
    return
        if ($redirectedRetrieval) then $redirectedRetrieval
        else i:fox-unparsed-text($uri, $encoding, $options)
};      

(:~
 : Returns the child URIs of a given URI, provided their name matches
 : a given name, or a regex derived from it. If $fromSubstring and 
 : $toSubstring are supplied, the URI names must match the regex 
 : obtained by replacing in $name substring $fromSubstring with 
 : $toSubstring.
 :
 : @param context the context URI
 : @param names one or several name patterns
 : @param fromSubstring used to map $name to a regex
 : @param toSubstring used to map $name to a regex
 : @return child URIs matching the name or the derived regex
 :)
declare function f:foxfunc_fox-child($context as xs:string,
                                     $names as xs:string+,
                                     $fromSubstring as xs:string?,
                                     $toSubstring as xs:string?)
        as xs:string* {
    (
    if (not($fromSubstring) or not($toSubstring)) then 
        $names ! i:childUriCollection($context, ., (), ()) ! concat($context, '/', .) 
    else 
        for $name in $names
        let $regex := replace($name, $fromSubstring, $toSubstring, 'i') !
                      concat('^', ., '$')
        return
            for $child in i:childUriCollection($context, (), (), ())
            let $cname := replace($child, '.*/', '')
            where matches($cname, $regex, 'i')
            return concat($context, '/', $child)
    ) => distinct-values()            
};

(:~
 : Returns the child elements of input nodes with a JSON name equal to
 : one of a set of input names. The JSON name is the name obtained by
 : decoding the element name as a JSON key.
 :
 : @param context the context URI
 : @param names one or several name patterns
 : @return child elements with a matching JSON name
 :)
declare function f:jchild($context as node()*,
                          $names as xs:string+)
        as item()* {
    let $flags := '' return
    
    if (every $name in $names satisfies not(matches($name, '[*?]'))) then        
        $context/*[convert:decode-key(local-name()) = $names]
    else
        let $namesRX := 
            $names 
            ! replace(., '\*', '.*') 
            ! replace(., '\?', '.') 
            ! concat('^', ., '$')
        return
            $context/*[
                let $jname := convert:decode-key(local-name())
                return some $rx in $namesRX satisfies matches($jname, $rx, $flags)
            ]                
};

(:~
 : Returns the parent URIs of a given URI, provided its name matches
 : a given name, or a regex derived from it. If $fromSubstring and 
 : $toSubstring are supplied, the parent URI name must match the regex 
 : obtained by replacing in $name substring $fromSubstring with 
 : $toSubstring.
 :
 : @param context the context URI
 : @param names one or several name patterns
 : @param fromSubstring used to map $name to a regex
 : @param toSubstring used to map $name to a regex
 : @return the parent URI, if it matches the name or the derived regex
 :)
declare function f:foxfunc_fox-parent($context as xs:string,
                                      $names as xs:string+,
                                      $fromSubstring as xs:string?,
                                      $toSubstring as xs:string?)
        as xs:string? {
    (
    for $name in $names
    let $regex :=
        if (not($fromSubstring) or not($toSubstring)) then 
            replace($name, '\*', '.*') !
            replace(., '\?', '.') !
            concat('^', ., '$')
        else
            replace($name, $fromSubstring, $toSubstring, 'i') !
            concat('^', ., '$')
    let $uri := i:parentUri($context, $regex) 
    return $uri
    ) => distinct-values()
};

(:~
 : Returns a given URI, provided its name matches a given name, or a 
 : regex derived from it. If $fromSubstring and $toSubstring are 
 : supplied, the URI name must match the regex obtained by replacing 
 : in $name substring $fromSubstring with $toSubstring.
 :
 : @param context the context URI
 : @param names one or several name patterns
 : @param fromSubstring used to map $name to a regex
 : @param toSubstring used to map $name to a regex
 : @return child URIs matching the name of the derived regex
 :)
declare function f:foxfunc_fox-self($context as xs:string,
                                    $names as xs:string+,
                                    $fromSubstring as xs:string?,
                                    $toSubstring as xs:string?)
        as xs:string? {
    (
    for $name in $names
    let $regex :=
        if (not($fromSubstring) or not($toSubstring)) then 
            replace($name, '\*', '.*') !
            replace(., '\?', '.') !
            concat('^', ., '$')
        else
            replace($name, $fromSubstring, $toSubstring, 'i') !
            concat('^', ., '$')
    let $uri := i:selfUri($context, $regex) 
    return $uri
    ) => distinct-values()
};

(:~
 : Returns the descendant URIs of a given URI, provided their name matches
 : a given name, or a regex derived from it. If $fromSubstring and 
 : $toSubstring are supplied, the URI names must match the regex 
 : obtained by replacing in $name substring $fromSubstring with 
 : $toSubstring.
 :
 : @param context the context URI
 : @param names one or several name patterns
 : @param fromSubstring used to map $name to a regex
 : @param toSubstring used to map $name to a regex
 : @return descendant URIs matching the name or the derived regex
 :)
declare function f:foxfunc_fox-descendant($context as xs:string,
                                          $names as xs:string+,
                                          $fromSubstring as xs:string?,
                                          $toSubstring as xs:string?)
        as xs:string* {
    (
    for $name in $names return
    
    if (not($fromSubstring) or not($toSubstring)) then 
        i:descendantUriCollection($context, $name, (), ()) ! concat($context, '/', .) 
    else 
        let $regex := replace($name, $fromSubstring, $toSubstring, 'i') !
                      concat('^', ., '$')        
        return
            for $child in i:descendantUriCollection($context, (), (), ())
            let $cname := replace($child, '.*/', '')
            where matches($cname, $regex, 'i')
            return concat($context, '/', $child)
    ) => distinct-values()            
};

(:~
 : Returns the descendant-or-self URIs of a given URI, provided their name 
 : matches a given name, or a regex derived from it. If $fromSubstring and 
 : $toSubstring are supplied, the URI names must match the regex obtained
 : obtained by replacing in $name substring $fromSubstring with $toSubstring.
 :
 : @param context the context URI
 : @param names one or several name patterns
 : @param fromSubstring used to map $name to a regex
 : @param toSubstring used to map $name to a regex
 : @return descendant-or-self URIs matching the name or the derived regex
 :)
declare function f:foxfunc_fox-descendant-or-self($context as xs:string,
                                                  $names as xs:string+,
                                                  $fromSubstring as xs:string?,
                                                  $toSubstring as xs:string?)
        as xs:string* {
    (
    for $name in $names
    let $descendantUris := f:foxfunc_fox-descendant($context, $name, $fromSubstring, $toSubstring)
    return (
        f:foxfunc_fox-self($context, $name, $fromSubstring, $toSubstring),
        $descendantUris
    )
    ) => distinct-values()
};

(:~
 : Returns the sibling URIs of a given URI, provided their name matches a given 
 : name, or a regex derived from it. If $fromSubstring and $toSubstring are 
 : supplied, the URI names must match the regex obtained obtained by replacing 
 : in $name substring $fromSubstring with $toSubstring.
 :
 : @param context the context URI
 : @param names one or several name patterns
 : @param fromSubstring used to map $name to a regex
 : @param toSubstring used to map $name to a regex
 : @return sibling URIs matching the name or the derived regex
 :)
declare function f:foxfunc_fox-sibling($context as xs:string,
                                       $names as xs:string+,
                                       $fromSubstring as xs:string?,
                                       $toSubstring as xs:string?)
        as xs:string* {
    (
    for $name in $names
    let $parent := i:parentUri($context, ())
    let $raw := f:foxfunc_fox-child($parent, $name, $fromSubstring, $toSubstring)
    return $raw[not(. eq $context)]
    ) => distinct-values()
};

(:~
 : Returns the sibling URIs of the parent URI of a given URI, provided their 
 ; name matches a given name, or a regex derived from it. If $fromSubstring 
 : and $toSubstring are supplied, the URI names must match the regex obtained 
 : obtained by replacing in $name substring $fromSubstring with $toSubstring.
 :
 : @param context the context URI
 : @param names one or several name patterns
 : @param fromSubstring used to map $name to a regex
 : @param toSubstring used to map $name to a regex
 : @return sibling URIs matching the name or the derived regex
 :)
declare function f:foxfunc_fox-parent-sibling($context as xs:string,
                                              $names as xs:string+,
                                              $fromSubstring as xs:string?,
                                              $toSubstring as xs:string?)
        as xs:string* {
    (        
    for $name in $names return
        i:parentUri($context, ()) 
        ! f:foxfunc_fox-sibling(., $name, $fromSubstring, $toSubstring)
    ) => distinct-values()        
};

(:~
 : Returns the ancestor URIs of a given URI, provided their name matches a given 
 : name, or a regex derived from it. If $fromSubstring and $toSubstring are 
 : supplied, the URI names must match the regex obtained obtained by replacing 
 : in $name substring $fromSubstring with $toSubstring.
 :
 : @param context the context URI
 : @param names one or several name patterns
 : @param fromSubstring used to map $name to a regex
 : @param toSubstring used to map $name to a regex
 : @return sibling URIs matching the name or the derived regex
 :)
declare function f:foxfunc_fox-ancestor($context as xs:string,                                        
                                        $names as xs:string+,
                                        $fromSubstring as xs:string?,
                                        $toSubstring as xs:string?)
        as xs:string* {
    (
    for $name in $names
    let $regex :=
        if (not($fromSubstring) or not($toSubstring)) then 
            replace($name, '\*', '.*') !
            replace(., '\?', '.') !
            concat('^', ., '$')
        else
            replace($name, $fromSubstring, $toSubstring, 'i') !
            concat('^', ., '$')
    let $uris := i:ancestorUriCollection($context, $regex, false()) 
    return $uris
    ) => distinct-values()
};

(:~
 : Returns the ancestor-or-self URIs of a given URI, provided their name matches a 
 : given name, or a regex derived from it. If $fromSubstring and $toSubstring are 
 : supplied, the URI names must match the regex obtained obtained by replacing in 
 : $name substring $fromSubstring with $toSubstring.
 :
 : @param context the context URI
 : @param names one or several name patterns
 : @param fromSubstring used to map $name to a regex
 : @param toSubstring used to map $name to a regex
 : @return sibling URIs matching the name or the derived regex
 :)
declare function f:foxfunc_fox-ancestor-or-self($context as xs:string,                                        
                                                $names as xs:string+,
                                                $fromSubstring as xs:string?,
                                                $toSubstring as xs:string?)
        as xs:string* {
    (
    for $name in $names
    let $regex :=
        if (not($fromSubstring) or not($toSubstring)) then 
            replace($name, '\*', '.*') !
            replace(., '\?', '.') !
            concat('^', ., '$')
        else
            replace($name, $fromSubstring, $toSubstring, 'i') !
            concat('^', ., '$')
    let $uris := i:ancestorUriCollection($context, $regex, true()) 
    return $uris
    ) => distinct-values()
};

(:~
 : Returns a frequency distribution.
 :
 : @param values a sequence of terms
 : @param min if specified - return only terms with a frequency >= $min
 : @param max if specified - return only terms with a frequency >= $max
 : @param kind the kind of frequency value - count, relfreq (relative frequency), 
 :   percent (percent frequency)
 : @param orderBy sort order - "a" (order by frequency ascending, 
 -   "d" (order by frequency descending); default: alphabetically
 : @param format  the output format, one of xml|json|csv|text|text*, default = text;
 :   "text* denotes "text" followed by a number (e.g. text40) specifying the width 
 :   of the term column - shorter terms are padded to this width
 : @return the frequency distribution
 :)
declare function f:foxfunc_frequencies($values as item()*, 
                                       $min as xs:integer?, 
                                       $max as xs:integer?, 
                                       $kind as xs:string?, (: count | relfreq | percent :)
                                       $orderBy as xs:string?,
                                       $format as xs:string?)
        as item() {
        
    let $width := 
        if (not($format) or $format eq 'text*') then 1 + ($values ! string(.) ! string-length(.)) => max()
        else if (matches($format, '^text\d')) then replace($format, '^text', '')[string()] ! xs:integer(.)
        else ()
    let $format := 
        if (not($format)) then 'text'
        else if (matches($format, '^text.')) then 'text'
        else $format    
 
    let $freqAttName := ($kind, 'count')[1]
    
    (: Function return the frequency representation :)
    let $fn_count2freq :=
        switch($kind)
        case 'freq' return function($c, $nvalues) {($c div $nvalues) ! round(., 1) ! string(.) ! replace(., '^[^.]+$', '$0.0')}
        case 'percent' return function($c, $nvalues) {($c div $nvalues * 100) ! round(., 1) ! string(.) ! replace(., '^[^.]+$', '$0.0')}
        default return function($c, $nvalues) {$c}

    (: Function item returning a term representation :)
    let $fn_itemText :=
        switch($format) 
        case 'text' return function($s, $c) {
            if (empty($width)) then concat($s, ' (', $c, ')')
            else 
                concat($s, ' ', 
                       string-join(for $i in 1 to $width - string-length($s) - 1 return '.', ''), 
                       ' (', $c, ')')}
        case 'json' return function($s, $c) {'"'||$s||'": '||$c}
        case 'csv' return function($s, $c) {'"'||$s||'",'||$c}
        case 'xml' return ()
        default return error(QName((), 'INVALID_ARG'), 
            concat('Unknown frequencies format, should be text|xml|json|csv; found: ', $format))

    let $nvalues := count($values)     
    let $itemsUnordered :=        
        for $value in $values
        group by $s := string($value)
        let $c := count($value)        
        let $f := $fn_count2freq($c, $nvalues)
        where (empty($min) or not($c) or $c ge $min) and (empty($max) or not($max) or $c le $max)
        return <term text="{$s}" f="{$f}"/>

    let $items :=
        switch($orderBy)
        case 'a' return 
            for $item in $itemsUnordered 
            order by $item/@f/number(.), $item/@text/lower-case(.) 
            return $item
        case 'd' return 
            for $item in $itemsUnordered 
            order by $item/@f/number(.) descending, $item/@text/lower-case(.) 
            return $item
        default return 
            for $item in $itemsUnordered 
            order by $item/@text/lower-case(.) 
            return $item
            
    return  
        switch($format)
        case 'xml' return 
            let $min := $items/@f/number(.) => min()
            let $max := $items/@f/number(.) => max()
            return
                <terms>{
                    if ($kind eq 'percent') then (
                        attribute minPercent {$min},
                        attribute maxPercent {$max}
                    ) else if ($kind eq 'freq') then (
                        attribute minFreq {$min},
                        attribute maxFreq {$max}
                    ) else (
                        attribute minCount {$min},
                        attribute maxCount {$max}
                    ),
                    $items/<item text="{@text}">{attribute {$freqAttName} {@f}}</item>
            }</terms>
        case 'json' return ('{', $items/$fn_itemText(@text, @f) ! concat('  ', .), '}') => string-join('&#xA;')
        case 'csv' return $items/$fn_itemText(@text, @f) => string-join('&#xA;')
        case 'text' return $items/$fn_itemText(@text, @f) => string-join('&#xA;')
        default return $items => string-join('&#xA;')
};      

(:~
 : Returns the JSON Schema keywords found at and under a set of nodes from a 
 : JSON Schema document.
 :
 : @param values JSON values
 : @return the resolved reference, if the value contains one, or the original value
 :)
declare function f:jschemaKeywords($values as element()*)
        as element()* {
    $values/f:jschemaKeywordsRC(.)
};

(:~
 : Recursive helper function of jschemaKeywords().
 :
 : @param n a node to process
 : @return the keyword nodes under the input node, including it
 :)
declare function f:jschemaKeywordsRC($n as node())
        as node()* {
    typeswitch($n)
    case element(default) return $n    
    case element(example) return $n
    case element(examples) return $n
    case element(enum) return $n    
    case element(json) return ($n[parent::*], $n/*/f:jschemaKeywordsRC(.))
    case element(patternProperties) return ($n, $n/*/*/f:jschemaKeywordsRC(.))    
    case element(properties) return ($n, $n/*/*/f:jschemaKeywordsRC(.))
    case element(_) return $n/*/f:jschemaKeywords(.)
    default return ($n, $n/*/f:jschemaKeywordsRC(.))
};        

(:~
 : Returns the JSON Schema keywords found in OpenAPI document.
 :
 : @param oasNodes nodes from OpenAPI documents
 : @return the keywords contained by the OpenAPI documents
 :)
declare function f:oasJschemaKeywords($oasNodes as element()*)
        as element()* {
    $oasNodes/ancestor-or-self::*[last()]/(
        definitions/*/*/f:jschemaKeywords(.),
        components/schemas/*/*/f:jschemaKeywords(.),
        f:oasMsgSchemas(.)/*/f:jschemaKeywords(.)
    )        
};

(:~
 : Returns the effective content of a JSON value: if it is an object containing
 : a reference, the reference is recursively resolved. Otherwise, the original
 : value is returned.
 :
 : This function can be used in order to integrate reference resolving into navigation.
 : Example: all payload schemas in an OpenAPI document may be collected like this:
 :
 :    $oas\paths\*\jeff()\(get, post, put, delete, options, head, patch, trace)
 :    \(
 :         (requestBody, responses\*)\jeff()\(content\schema, schema),
 :         parameters\_\jeff()[in eq 'body']\schema
 :    )
 :
 : @param value a JSON value
 : @return the resolved reference, if the value contains one, or the original value
 :)
declare function f:jsonEffectiveValue($value as element())
        as element()? {
    let $reference := $value/_0024ref return
    
    if (not($reference)) then $value else
        $reference ! f:resolveJsonRef(., .) ! f:jsonEffectiveValue(.)
};

(:~
 : Returns the schema objects describing the messages of an OpenAPI document.
 :
 : @param oas OpenAPI documents (root element or some other node)
 : @return the schema objects describing messages
 :)
declare function f:oasMsgSchemas($oas as node()*) {
    let $fn_soContent := function ($co) {$co/*/schema}
    let $fn_soParameters := function ($p) {$p/*[in eq 'body']/schema}
    let $fn_soRequestBody := function ($rb) {$rb/content/$fn_soContent(.)}
    let $fn_soResponseObject := function ($ro) {$ro/(schema, content/$fn_soContent(.))}
    let $fn_soPathItem := 
        function ($pi) {
            $pi/(get, post, put, delete, options, head, patch, trace)/(
                parameters/$fn_soParameters(.),
                requestBody/$fn_soRequestBody(.),
                responses/*/$fn_soResponseObject(.))}
    let $oas := $oas/root()/descendant-or-self::json[1]            
    return $oas/(
        paths/*/$fn_soPathItem(.),
        parameters/$fn_soParameters(.),
        responses/*/$fn_soResponseObject(.),
        components/(
            responses/*/$fn_soResponseObject(.),
            requestBodies/*/$fn_soRequestBody(.),
            pathItems/*/$fn_soPathItem(.)))    
};

(:~
 : Foxpath function `repeat#2'. Creates a string which is the concatenation of
 : a given number of instances of a given string.
 :
 : @param string the string to be repeated
 : @param count the number of repeats
 : @return the result of repeating the string
 :)
declare function f:foxfunc_repeat($string as xs:string?, $count as xs:integer?)
        as xs:string {
    string-join(for $i in 1 to $count return $string, '')
};      

(:~
 : Writes a collection of files into a folder.
 :
 : @param files the file URIs
 : @param dir the folder into which to write
 : @return 0 if no errors were observed, 1 otherwise
 :)
declare function f:foxfunc_write-files($files as item()*, 
                                       $dir as xs:string?,
                                       $encoding as xs:string?)
        as xs:integer {
    let $tocItems :=        
        for $file at $pos in $files
        let $file := 
            if ($file instance of attribute()) then string($file) else $file
        let $path :=
            if ($file instance of node()) then 
                let $raw := $file/root()/document-uri(.)
                return if ($raw) then $raw else concat('__file__', $pos)
            else $file        
        let $fname := replace($path, '^.+/', '')
        group by $fname
        return
            if (count($file) eq 1) then 
                <file name="{$fname}" path="{$path}"/>
            else
                <files originalName="{$fname}" count="{count($file)}">{
                    let $prePostfix := replace($fname, '(.+)(\.[^.]*$)', '$1~~~$2')
                    let $pre := substring-before($prePostfix, '~~~')
                    let $post := substring-after($prePostfix, '~~~')
                    for $f at $pos in $file
                    let $hereName := if ($pos eq 1) then $fname else concat($pre, '___', $pos, '___', $post)
                    return
                        <file originalName="{$fname}" name="{$hereName}" path="{$f}"/>
                }</files> 
    let $toc := <toc countFnames="{count($tocItems)}" countFiles="{count($files)}">{$tocItems}</toc>
    let $tocFname := concat($dir, '/', '___toc.write-files.xml')
    let $_ := file:write($tocFname, $toc)
    
    let $errors :=
        for $file at $pos in $files
        let $file := 
            if ($file instance of attribute()) then string($file) else $file
        let $path :=
            if ($file instance of node()) then 
                let $raw := $file/root()/document-uri(.)
                return if ($raw) then $raw else concat('__file__', $pos)
            else $file   
        let $fname := $toc//file[@path eq $path]/@name/string()
        let $fname_ := string-join(($dir, $fname), '/')        
        let $fileContent := 
            if ($file instance of node()) then serialize($file)
            else i:fox-unparsed-text($file, $encoding, ())        
        return
            try {
                trace(file:write-text($fname_, $fileContent) , concat('Write file: ', $fname_, ' '))
            } catch * {trace(1, concat('ERR:CODE: ', $err:code, ', ERR:DESCRIPTION: ', $err:description, ' - '))}
    return
        ($errors[1], 0)[1]
};

(:~
 : Writes a collection of json documents as json docs into a folder.
 :
 : @param files the file URIs
 : @param dir the folder into which to write
 : @return 0 if no errors were observed, 1 otherwise
 :)
declare function f:foxfunc_write-json-docs($files as xs:string*, 
                                           $dir as xs:string?,
                                           $encoding as xs:string?)
        as xs:integer {
    let $tocItems :=        
        for $file at $pos in $files
        let $file := 
            if ($file instance of attribute()) then string($file) else $file
        let $path :=
            if ($file instance of node()) then 
                let $raw := $file/root()/document-uri(.)
                return if ($raw) then $raw else concat('__file__', $pos)
            else $file        
        let $fnameOrig := replace($path, '^.+/', '')
        let $fname := 
            if ($file instance of node()) then $fnameOrig 
            else concat($fnameOrig, '.xml')
        group by $fnameOrig
        return
            if (count($file) eq 1) then 
                <file name="{$fname}" originalName="{$fnameOrig}" path="{$path}"/>
            else
                <files originalName="{$fnameOrig}" count="{count($file)}">{
                    let $prePostfix := replace($fnameOrig, '(.+)(\.[^.]*$)', '$1~~~$2')
                    let $pre := substring-before($prePostfix, '~~~')
                    let $post := substring-after($prePostfix, '~~~')
                    for $f at $pos in $file
                    let $name := 
                        let $raw :=
                            if ($pos eq 1) then $fnameOrig else 
                                concat($pre, '___', $pos, '___', $post)
                        return
                             if ($f instance of node()) then $raw else concat($raw, '.xml')
                    return
                        <file name="{$name}" originalName="{$fnameOrig[1]}" path="{$f}"/>
                }</files> 
    let $toc := <toc countFnames="{count($tocItems)}" countFiles="{count($files)}">{$tocItems}</toc>
    let $tocFname := concat($dir, '/', '___toc.write-json-docs.xml')
    let $_ := file:write($tocFname, $toc)
    
    let $errors :=
        for $file at $pos in $files
        let $file := 
            if ($file instance of attribute()) then string($file) else $file
        let $path :=
            if ($file instance of node()) then 
                let $raw := $file/root()/document-uri(.)
                return if ($raw) then $raw else concat('__file__', $pos)
            else $file   
        let $fname := $toc//file[@path eq $path]/@name/string()
        let $fname_ := string-join(($dir, $fname), '/')        
        let $fileContent := 
            if ($file instance of node()) then serialize($file)
            else 
                try {
                    let $fileContent := i:fox-unparsed-text($file, $encoding, ())
                    return
                        json:parse($fileContent) ! serialize(.)
                } catch * {trace((), 
                    concat('ERR:CODE: ', $err:code, ', ERR:DESCRIPTION: ', $err:description, ' - '))}
        where $fileContent                    
        return
            try {
                trace(file:write-text($fname_, $fileContent) , concat('Write file: ', $fname_, ' '))
            } catch * {trace(1, concat('ERR:CODE: ', $err:code, ', ERR:DESCRIPTION: ', $err:description, ' - '))}
    return
        ($errors[1], 0)[1]
(:        
    let $errors :=
        for $file in $files
        let $path := $file
        let $fname := replace($path, '^.+/', '')
        let $fname_ := trace(concat(string-join(($dir, $fname), '/'), '.xml') , 'PATH#: ')
        let $fileContent := f:fox-unparsed-text($file, $encoding, ())
        let $fileContentXml := json:parse($fileContent) ! serialize(.)
        return
            try {
                file:write-text($fname_, $fileContentXml)
            } catch * {1}
    return
        ($errors[1], 0)[1]
:)        
};

(:~
 : Constructs an element with content given by $content. Each pair of items in $atts
 : provides the name and value of an attribute to be added.
 :
 : @param content the element content
 : @param name the element name
 : @param atts attributes to be added
 : @return the constructed element
 :)
declare function f:xelement($content as item()*,
                            $name as xs:string,
                            $atts as item()*)
        as element() {
    element {$name} {
        for $attName at $pos in $atts[(position() + 1) mod 2 eq 0]
        let $attValue := $atts[$pos + 1]
        return
            attribute {$attName} {$attValue},
        $content            
    }
};      

(:~
 : Foxpath function `xwrap#3`. Collects the items of $items into an XML document.
 :
 : Sorting:
 : (1) if flag 's' is used: item representations are sorted by the string value of the item
 : (2) if flag 'S' is used: item representations are sorted by the string value of the item, case-insensitively
 : (3) otherwise no sorting is performed
 :
 : Before copying into the result document, every item from $items is processed as follows:
 : (A) if an item is a node:
 :   (1) if flag 'b' is set, a copy enhanced by an @xml:base attribute is created
 :   (2) if flag 'p' is set, a copy enhanced by a @fox:path attribute is created
 :   (3) if flag 'j' is set, a copy enhanced by a @fox:jpath attribute is created 
 :   (4) if flag 'a' is set, the item is not modified if it is not an attribute;
 :       if it is an attribute, it is mapped to an element which has a name 
 :       equal to the name of the parent of the attribute, and which contains a 
 :       copy of the attribute 
 :   (5) if flag 'A' is set, treatment as with flag 'a', but the constructed element
 :       has no namespace URI 
 :   (6) otherwise, the item is not modified

 : (B) if an item is atomic: 
 :   (1) if flag 'd' is set, the item is interpreted as URI and it is attempted to be
 :       parsed into a document, with an @xml:base attribute added to the root element,
 :       if flag 'b' is set, and without @xml:base otherwise; if parsing fails, a 
 :       <PARSE-ERROR> element is created with the item value as content
 :   (2) if flag 'w' is set, the item is interpreted as URI and the text found at
 :       this URI is retrieved and wrapped in an element with an @xml:base attribute
 :       element name given by parameter $name2, default _text_
 :   (3) if flag 't' is set, the item is interpreted as URI and the text found at 
 :       this URI is retrieved (not wrapped in an element)
 :   (4) if flag 'c' is set, the item is treated as a text and wrapped in an element;
 :       element name given by parameter $name2, default _text_
 :   (5) if none of the flags 'd', 'w', 't', 'c' is set: the item is not modified 
 :
 : @param items the items from which to create the content of the result document
 : @param name the name of the root element of the result document
 : @param flags flags controlling the representation of the items and possible sorting
 : @param name2 the name of inner wrapper elements, wrapping an individual item (only in case of flags c and w)
 : @param options foxpath processing options
 : @return the result document
 :)
declare function f:xwrap($items as item()*, 
                         $name as xs:QName, 
                         $flags as xs:string?, 
                         $name2 as xs:QName?, $options as map(*)?) 
        as element()? {
    (: name2 is the name of inner wrapper elements, wrapping an individual item :)
    let $name2 := if (empty($name2)) then '_text_' else $name2   
    
    let $sortRule := if (contains($flags, 's')) then 's' else if (contains($flags, 'S')) then 'S' else ()        
    let $val :=
        for $item in $items 
        order by if ($sortRule eq 's') then $item else if ($sortRule eq 'S') then lower-case($item) else ()
        return 

        (: item a node => copy item :)
        if ($item instance of node()) then
            if (matches($flags, '[bpj]') and ($item instance of element() or $item instance of document-node())) then
                let $additionalAtts := ( 
                    if (not(contains($flags, 'b'))) then () else
                        attribute xml:base {$item/base-uri(.)},
                    if (not(contains($flags, 'p'))) then () else
                        attribute path {$item/f:name-path(., 'name', ())},
                    if (not(contains($flags, 'j'))) then () else
                        attribute jpath {$item/f:name-path(., 'jname', ())}
                )
                let $additionalAttNames := $additionalAtts/node-name(.)
                let $elem := $item/descendant-or-self::*[1]
                return
                    element {node-name($elem)} {
                        $additionalAtts,
                        $elem/@*[not(node-name(.) = $additionalAttNames)], $elem/node()
                    }
            else if (contains($flags, 'a') or contains($flags, 'A')) then
                if (not($item/self::attribute())) then $item
                else 
                    let $elemName := if (contains($flags, 'A')) then $item/../local-name(.)
                                     else $item/../QName(namespace-uri(.), local-name(.))
                    return element {$elemName} {$item}
            else
                $item
                
        (: item a URI, flag 'd' => parse document at that URI :)                
        else if (contains($flags, 'd')) then
            let $doc := try {i:fox-doc($item, $options)/*} catch * {()}
            return
                if ($doc) then 
                    if (contains($flags, 'b')) then
                        let $xmlBase := if ($doc/@xml:base) then () else attribute xml:base {$item}
                        return
                            if (not($xmlBase)) then $doc else
                                element {node-name($doc)} {
                                    $doc/@*,
                                    $xmlBase,
                                    $doc/node()
                                }
                    else $doc
                else                                    
                    <PARSE-ERROR>{$item}</PARSE-ERROR>
                    
        (: item a URI, flag 'w' => read text at that URI, write it into a wrapper element :)                    
        else if (contains($flags, 'w')) then
            let $text := try {i:fox-unparsed-text($item, (), $options)} catch * {()}
            return
                if ($text) then element {$name2} {attribute xml:base {$item}, $text}
                else <READ-ERROR>{$item}</READ-ERROR>
                
        (: item a URI, flag 't' => read text at that URI, copy it into result :)                
        else if (contains($flags, 't')) then
            let $text := try {i:fox-unparsed-text($item, (), $options)} catch * {()}
            return
                if ($text) then $text
                else <READ-ERROR>{$item}</READ-ERROR>
                
        (: item a URI, flag 'c' => use item as ist :)                
        else if (contains($flags, 'c')) then
            element {$name2} {$item}
            
        else
            $item
    let $namespaces := 
        for $nn in f:extractNamespaceNodes($val)
        group by $prefix := name($nn)
        return $nn[1]
    return
        element {$name} {
            attribute countItems {count($val)},
            $namespaces,
            $val
        }
};

(:~
 : Returns for a given element all namespace bindings as strings
 : prefix=uri. The bindings are ordered by lowercase prefixes,
 : then lowercase URIs.
 :
 : @param elem the element to be observed
 : @return strings representing namespace bindings
 :)
declare function f:foxfunc_in-scope-namespaces($item as item()) 
        as xs:string+ {        
    let $elem :=
        typeswitch($item)
        case $doc as document-node() return $doc/*
        case $elem as element() return $elem
        case $node as node() return $node/..
        case $uri as xs:anyAtomicType return doc($uri)/*
        default return error()
        
    for $prefix in in-scope-prefixes($elem)
    order by $prefix
    return concat($prefix, '=', namespace-uri-for-prefix($prefix, $elem))
};    

(:~
 : Returns for a given element all namespace bindings as strings
 : prefix=uri. The bindings are ordered by lowercase prefixes,
 : then lowercase URIs.
 :
 : @param elem the element to be observed
 : @return strings representing namespace bindings
 :)
declare function f:foxfunc_in-scope-namespaces-descriptor($item as item()) 
        as xs:string+ {        
    f:foxfunc_in-scope-namespaces($item) => string-join(', ')
};    

(:~
 : Transforms a string by reversing character replacements used by 
 : the BaseX JSON representation (conversion format 'direct') for 
 : representing the names of object members.
 :
 : @param item a string
 : @return the result of character replacements reversed
 :)
declare function f:foxfunc_unescape-json-name($item as item()) as xs:string { 
    string-join(
        analyze-string($item, '_[0-9a-f]{4}')/*/(typeswitch(.)
        case element(fn:match) return substring(., 2) ! concat('"\u', ., '"') ! parse-json(.)
        default return replace(., '__', '_')), '')
};

(:~
 : Resolves a link to a resource. If $mediatype is specified, the
 : XML or JSON document is returned, otherwise the document text.
 :
 : @param node node containing the link
 : @param mediatype mediatype expected
 : @return the resource, either as XDM root node, or as text
 :)
declare function f:foxfunc_resolve-link($node as node(), $mediatype as xs:string?)
        as item()? {
    let $base := $node/ancestor-or-self::*[1]        
    let $uri := 
        if ($base) then resolve-uri($node, $base/base-uri(.))
        else resolve-uri($node)
    return
        if ($mediatype eq 'xml') then
            if (doc-available($uri)) then doc($uri)
            else ()
        else if (not(unparsed-text-available($uri))) then ()
        else
            let $text := unparsed-text($uri)
            return
                if ($mediatype eq 'json') then try {json:parse($text)} catch * {()}
                else $text
};        

(:~
 : Returns the attribute names of a node. If $separator is specified, the sorted
 : names are concatenated, using this separator, otherwise the names are returned
 : as a sequence. If $localNames is true, the local names are returned, otherwise 
 : the lexical names. 
 : 
 : When using $namePattern, only those child elements are considered which have
 : a local name matching the pattern.
 :
 : Example: .../foo/att-names(., ', ', false(), '*put')
 : Example: .../foo/att-names(., ', ', false(), 'input|output') 
 :
 : @param node a node (unless it is an element, the function returns the empty sequence)
 : @param separator if used, the names are concatenated, using this separator
 : @param localNames if true, the local names are returned, otherwise the lexical names 
 : @param namePattern an optional name pattern filtering the attributes to be considered 
 : @return the names as a sequence, or as a concatenated string
 :)
declare function f:foxfunc_att-names($node as node(), 
                                     $concat as xs:boolean?, 
                                     $nameKind as xs:string?,   (: name | lname | jname :)
                                     $namePattern as xs:string?,
                                     $excludedNamePattern as xs:string?)
        as xs:string* {
    let $nameRegex := $namePattern ! replace(., '\*', '.*') ! replace(., '\?', '.') 
                      ! concat('^', ., '$')        
    let $excludedNameRegex := $excludedNamePattern ! replace(., '\*', '.*') ! replace(., '\?', '.') 
                      ! concat('^', ., '$')        
    let $items := $node/@*
       [not($nameRegex) or matches(local-name(.), $nameRegex, 'i')]
       [not($excludedNameRegex) or not(matches(local-name(.), $excludedNameRegex, 'i'))]
    let $separator := ', '[$concat]
    let $names := 
        if ($nameKind eq 'lname') then 
            ($items/local-name(.)) => distinct-values() => sort()
        else if ($nameKind eq 'jname') then 
            ($items/f:foxfunc_unescape-json-name(local-name(.))) => distinct-values() => sort()
        else ($items/name(.)) => distinct-values() => sort()
    return
        if (exists($separator)) then string-join($names, $separator)
        else $names
};        

(:~
 : Returns the child element names of a node. If $concat is true, the sorted names are 
 : concatenated, using ', ' as separator. Otherwise the names are returned
 : as a sequence. Dependent on $nameKind, the local names (lname), the JSON
 : names (jname) or the lexical names (name) are returned. Names are sorted.
 :
 : When using $namePattern, only those child elements are considered which have
 : a local name matching the pattern.
 :
 : Example: .../foo/child-names(., ', ', false(), '*put')
 : Example: .../foo/child-names(., ', ', false(), 'input|output') 
 :
 : @param nodes nodes (only elements contribute to the result)
 : @param concat if true, the names are concatenated
 : @param nameKind one of "name", "lname" or "jname" 
 : @param namePatterns optional name patterns selecting child names to be considered
 : @param excludedNamePattern optional name patterns selecting child elements to be ignored
 : @return the names as a sequence, or as a concatenated string
 :)
declare function f:child-names($nodes as node()*, 
                               $concat as xs:boolean?, 
                               $nameKind as xs:string?,   (: name | lname | jname :)
                               $namePatterns as xs:string?,
                               $excludedNamePatterns as xs:string?)
        as xs:string* {
    let $nameRegexes := $namePatterns 
                      ! tokenize(.)
                      ! replace(., '\*', '.*') ! replace(., '\?', '.') 
                      ! concat('^', ., '$')        
    let $excludedNameRegexes := 
                      $excludedNamePatterns
                      ! tokenize(.)
                      ! replace(., '\*', '.*') ! replace(., '\?', '.') 
                      ! concat('^', ., '$')
    let $separator := ', '[$concat]

    for $node in $nodes
    let $items := $node/*
       [empty($nameRegexes) or (some $nameRegex in $nameRegexes satisfies 
         matches(local-name(.), $nameRegex, 'i'))]
       [empty($excludedNameRegexes) or not(
         some $excludedNameRegex in $excludedNameRegexes satisfies 
            matches(local-name(.), $excludedNameRegex, 'i'))]
    let $names := 
        if ($nameKind eq 'lname') then 
            ($items/local-name(.)) => distinct-values() => sort()
        else if ($nameKind eq 'jname') then 
            ($items/f:foxfunc_unescape-json-name(local-name(.))) => distinct-values() => sort()
        else ($items/name(.)) => distinct-values() => sort()
    let $path :=        
        if (exists($separator)) then string-join($names, $separator)
        else $names
    order by $path        
    return
        $path
};        

(:~
 : Returns the descendant element names of a node. If $separator is specified, the sorted
 : names are concatenated, using this separator, otherwise the names are returned
 : as a sequence. If $localNames is true, the local names are returned, otherwise the 
 : lexical names. 
 :
 : When using $namePattern, only those descendant elements are considered which have
 : a local name matching the pattern.
 :
 : Example: .../foo/descendant-names(., ', ', false(), '*put')
 : Example: .../foo/descendant-names(., ', ', false(), 'input|output') 
 :
 : @param node a node (unless it is an element, the function returns the empty sequence)
 : @param separator if used, the names are concatenated, using this separator
 : @param localNames if true, the local names are returned, otherwise the lexical names 
 : @param namePattern an optional name pattern filtering the descendant elements to be considered
 : @return the names as a sequence, or as a concatenated string
 :)
declare function f:foxfunc_descendant-names(
                                       $node as node(), 
                                       $concat as xs:boolean?, 
                                       $nameKind as xs:string?,   (: name | lname | jname :)
                                       $namePattern as xs:string?,
                                       $excludedNamePattern as xs:string?)
        as xs:string* {
    let $nameRegex := $namePattern ! replace(., '\*', '.*') ! replace(., '\?', '.') 
                      ! concat('^', ., '$')        
    let $excludedNameRegex := $excludedNamePattern ! replace(., '\*', '.*') ! replace(., '\?', '.') 
                      ! concat('^', ., '$')        
    let $items := $node//*
       [not($nameRegex) or matches(local-name(.), $nameRegex, 'i')]
       [not($excludedNameRegex) or not(matches(local-name(.), $excludedNameRegex, 'i'))]
    let $separator := ', '[$concat]
    let $names := 
        if ($nameKind eq 'lname') then 
            ($items/local-name(.)) => distinct-values() => sort()
        else if ($nameKind eq 'jname') then 
            ($items/f:foxfunc_unescape-json-name(local-name(.))) => distinct-values() => sort()
        else ($items/name(.)) => distinct-values() => sort()
    return
        if (exists($separator)) then string-join($names, $separator)
        else $names
};        

(:~
 : Returns the parent name of a node. If $localNames is true, the local name is returned, 
 : otherwise the lexical names. 
 :
 : @param node a node
 : @param localName if true, the local name is returned, otherwise the lexical name
 : @return the parent name
 :)
declare function f:fileCopy($fileUri as xs:string,
                            $targetUri as xs:string,
                            $options as map(xs:string, item()*)?)
        as empty-sequence() {
    let $fileUriDomain := i:uriDomain($fileUri, ())
    return
        if (not($fileUriDomain eq 'FILE_SYSTEM')) then 
            error(QName((), 'INVALID_CALL'),
                concat('Function file-copy() expects a source file from the ',
                  'file system; file URI: ', $fileUri))
            else

    let $targetUriDomain := i:uriDomain($targetUri, ())
    return
        if (not($targetUriDomain eq 'FILE_SYSTEM')) then 
            error(QName((), 'INVALID_CALL'),
                concat('Function file-copy() expects a target folder in the ',
                  'file system; target dir URI: ', $targetUri))
            else
            
    if (i:fox-file-exists($targetUri, ())) then
        if (i:fox-is-file($targetUri, ()) and not($options?overwrite)) then
             error(QName((), 'INVALID_CALL'), concat('Target file exists; use option "overwrite" ',
                 'if you want to overwrite existing files; file URI: ', $targetUri))
        else file:copy($fileUri, $targetUri)
    else
        let $targetParentUri := trace(file:parent($targetUri) , '___TARGET_PARENT_URI: ')
        let $_CRETE := 
            if (i:fox-file-exists($targetParentUri, ())) then ()
            else if (not($options?create)) then
                error(QName((), 'INVALID_CALL'), concat('Target directory does not ',
                    'exists; use option "create" if you want automatic creation of ',
                    'a non-existent target dir; target dir URI: ', $targetParentUri))
            else file:create-dir($targetParentUri)
        return
            file:copy($fileUri, $targetUri)
                
(:                
                if (not(i:fox-file-exists(file:parent($targetUri))) then file:copy($
    let $targetFileExists :=
        $targetResourceExists and (
            i:fox-is-file($targetUri, ()) or
            i:fox-file-exists($targetUri||'/'||file:name($fileUri), ()))
    let $_CHECK := (
        if (not($targetFileExists) or $options?overwrite) then () 
        else
            error(QName((), 'INVALID_CALL'), concat('Target file exists; use option "overwrite" ',
                'if you want to overwrite existing files; file URI: ', $targetUri))
        ,                
        
    if (i:fox-file-exists($targetUri, ())) then
        let $_CHECK :=
            if (i:fox-is-dir($targetDirUri)) then
                let $targetFileUri := $targetUri || '/' || file:name($fileUri)
                return
                    if (i:fox-file-exists($targetFileUri, .)) then
                if ($options?overwrite) then ()
                else
                    error(QName((), 'INVALID_CALL'), concat('Target file exists; use option "overwrite" ',
                        'if you want to overwrite existing files; file URI: ', $targetUri))
                        
        return
            file:copy($fileUri, $targetUri)
                
    else            
    let $_CREATE_DIR :=
        let $targetDirExists := i:fox-file-exists($targetDirUri, ())    
        return
            if ($targetDirExists) then ()
            else if ($options?create) then file:create-dir($targetDirUri)
            else
                error(QName((), 'INVALID_CALL'), concat('Target directory does not ',
                    'exists; use option "create" if you want automatic creation of ',
                    'a non-existent target dir; target dir URI: ', $targetDirUri))
    let $_CHECK_OVERWRITE :=
        if ($options?overwrite) then ()
        else if (not(i:fox-file-exists($targetDirUri || '/' || file:name($fileUri), ()))) then ()
        else
            error(QName((), 'INVALID_CALL'), concat('Target file exists; use option "overwrite" ',
                'if you want to overwrite existing files; file URI: ', $fileUri))
    return
        file:copy($fileUri, $targetDirUri)
:)        
};        

(:~
 : Returns the parent name of a node. If $localNames is true, the local name is returned, 
 : otherwise the lexical names. 
 :
 : @param node a node
 : @param localName if true, the local name is returned, otherwise the lexical name
 : @return the parent name
 :)
declare function f:foxfunc_parent-name($node as node(),
                                       $nameKind as xs:string?)   (: name | lname | jname :)
        as xs:string* {
    let $item := $node/..
    let $name := if ($nameKind eq 'lname') then $item/local-name(.)
                 else if ($nameKind eq 'jname') then $item/f:foxfunc_unescape-json-name(local-name(.))
                 else $item/name(.)
    return
        $name
};        

(:~
 : Returns those atomic items which are in the left value, but not in the right one. 
 :
 : @param leftValue a value
 : @param rightValue another value 
 : @return the items in the left value, but not the right one
 :)
declare function f:leftValueOnly($leftValue as item()*,
                                 $rightValue as item()*)
    as item()* {
    $leftValue[not(. = $rightValue)]
};

(:~
 : Returns the paths leading from a context node to all descendants. This may be
 : regarded as a representation of the node's content, hence the function name.
 :
 : @param context a node
 : @param nameKind the kind of name used as path steps: 
 :   jname - JSON names; lname - local names; name - lexical names
 : @param includedNames name patterns of nodes which must be present in the path 
 : @param excludedNames name patterns of nodes excluded from the content 
 : @param excludedNodes nodes excluded from the content 
 : @return the parent name
 :)
declare function f:path-content($context as node()*, 
                                $nameKind as xs:string?,
                                $includedNames as xs:string?,
                                $excludedNames as xs:string?,
                                $excludedNodes as node()*)
        as xs:string* {
        
    let $descendants := 
        if ($nameKind eq 'jname') then $context/descendant::*
        else $context/descendant::*/(., @*)
        
    let $includedNamesRegex :=
        $includedNames ! tokenize(.)
        ! replace(., '\*', '.*')
        ! replace(., '\?', '.')
        ! concat('^', ., '$')

    let $excludedNamesRegex :=
        $excludedNames ! tokenize(.)
        ! replace(., '\*', '.*')
        ! replace(., '\?', '.')
        ! concat('^', ., '$')

    let $includedNodes :=
        if (empty($includedNamesRegex)) then ()
        else if ($nameKind eq 'jname') then
            $descendants[name() ! convert:decode-key(.) ! (some $r in $includedNamesRegex satisfies matches(., $r, 'i'))]
        else
            $descendants[local-name(.) ! (some $r in $includedNamesRegex satisfies matches(., $r, 'i'))]
    
    let $excludedNodes := (
        $excludedNodes,
        
        if (empty($excludedNamesRegex)) then ()
        else if ($nameKind eq 'jname') then
            $descendants[name() ! convert:decode-key(.) ! (some $r in $excludedNamesRegex satisfies matches(., $r, 'i'))]
        else
            $descendants[local-name(.) ! (some $r in $excludedNamesRegex satisfies matches(., $r, 'i'))]
    )
    let $descendants2 :=
        if (empty($includedNamesRegex)) then $descendants
        else $descendants[ancestor-or-self::* intersect $includedNodes]
        
    let $descendants3 := 
        if (empty($excludedNodes)) then $descendants2
        else $descendants2[not(ancestor-or-self::* intersect $excludedNodes)]
    
    for $d in $descendants3 return
    let $ancos := $d/ancestor-or-self::node()[. >> $context]
    let $steps :=        
        if ($nameKind eq 'lname') then 
            $ancos/concat(self::attribute()/'@', local-name(.))
        else if ($nameKind eq 'jname') then 
            $ancos/concat(self::attribute()/'@', 
                let $raw := f:foxfunc_unescape-json-name(local-name(.))
                return if (not(contains($raw, '/'))) then $raw else concat('"', $raw, '"')
            )
        else $ancos/concat(self::attribute()/'@', name(.))
    return string-join($steps, '/')
};        

(:~
 : Returns the parent name of a node. If $localNames is true, the local name is returned, 
 : otherwise the lexical names. 
 :
 : @param node a node
 : @param localName if true, the local name is returned, otherwise the lexical name
 : @return the parent name
 :)
declare function f:name-path($nodes as node()*, 
                             $nameKind as xs:string?,   (: name | lname | jname :) 
                             $numSteps as xs:integer?)
        as xs:string* {
    for $node in $nodes return
    
    (: _TO_DO_ Remove hack when BaseX Bug is removed; return to: let $nodes := $node/ancestor-or-self::node() :)        
    let $ancos := 
        let $all := $node/ancestor-or-self::node()
        let $dnode := $all[. instance of document-node()]
        return ($dnode, $all except $dnode)
    let $steps := 
        
        if ($nameKind eq 'lname') then 
            $ancos/concat(self::attribute()/'@', local-name(.))
        else if ($nameKind eq 'jname') then 
            $ancos/concat(self::attribute()/'@', 
                let $raw := f:foxfunc_unescape-json-name(local-name(.))
                return if (not(contains($raw, '/'))) then $raw else concat('"', $raw, '"')
            )
        else 
            $ancos/concat(self::attribute()/'@', name(.))
    let $steps := if (empty($numSteps)) then $steps else subsequence($steps, count($steps) + 1 - $numSteps)
    return string-join($steps, '/')
};        

(:~
 : Returns the local name of a lexical QName.
 :
 : @param name a lexical QName
 : @return the name with the prefix removed
 :)
declare function f:foxfunc_remove-prefix($name as xs:string?)
        as xs:string? {
    $name ! replace(., '^.+:', '')
};        

(:~
 : Returns those atomic items which are in the right value, but not in the left one. 
 :
 : @param leftValue a value
 : @param rightValue another value 
 : @return the items in the right value, but not the left one
 :)
declare function f:rightValueOnly($leftValue as item()*,
                                  $rightValue as item()*)
    as item()* {
    $rightValue[not(. = $leftValue)]
};

(:~
 : Truncates a string if longer than a maximum length, appending '...'.
 :
 : @param name a lexical QName
 : @return the name with the prefix removed
 :)
declare function f:foxfunc_truncate($string as xs:string?, $len as xs:integer, $flag as xs:string?)
        as xs:string? {
    $string ! substring($string, 1, $len) || ' ...'[string-length($string) gt $len]
};        

declare function f:hlistEntry($items as item()*)
        as xs:string {
    let $sep := codepoints-to-string(30000)
    return
        string-join($items, $sep)
};

(:~
 : Transforms a sequence of value into an indented list. Each value is a concatenated 
 : list of items from subsequent levels of hierarchy. Example:
 :
 : foo#bar
 : foo#bar2#bar3
 : foo#zoo#zoo2
 : boo#len
 : zoo
 : =>
 : foo
 : . bar2
 : . . bar3
 : . zoo
 . . . zoo2
 . boo
 . . len
 . zoo
 :)
declare function f:hlist($values as xs:string*, 
                         $emptyLines as xs:string?)
        as xs:string {
    let $sep := codepoints-to-string(30000) (:  ($sep, '#')[1] :)        
    let $values := $values[string(.)] => sort()    
    let $emptyLineFns :=
        if (not($emptyLines)) then ()
        else
            map:merge(
                for $i in 1 to string-length($emptyLines)
                let $lineCount := substring($emptyLines, $i, 1) ! xs:integer(.)
                where $lineCount
                return
                    map:entry($i - 1, function() {for $j in 1 to $lineCount return ''})
            )                    
            
    return
        f:hlistRC(0, $values, $sep, $emptyLineFns) => string-join('&#xA;')        
};

declare function f:hlistRC($level as xs:integer, 
                           $values as xs:string*, 
                           $sep as xs:string,
                           $emptyLineFns as map(*)?)
        as xs:string* {
    let $prefix := (for $i in 1 to $level return '.  ') => string-join('')
    return
        if (not(some $value in $values satisfies contains($value, $sep))) then 
            for $value in $values
            group by $v := $value
            let $suffix := count($value)[. ne 1] ! concat(' (', ., ')')
            let $parts := tokenize($v, '~~~')
            return 
                if (count($parts) eq 1) then $prefix || $v || $suffix
                else
                    for $part in $parts
                    return $prefix || $part
        else
            for $value in $values
            (: group by $groupValue := (substring-before($value, $sep)[string()], $value)[1] :)
            group by $groupValue := replace($value, '(^.*?)' || $sep || '.*', '$1', 's')
            let $contentValue := $value ! substring-after(., $sep)[string()]           
            order by $groupValue
            let $parts := tokenize($groupValue, '~~~')
            return (
                if (count($parts) eq 1) then concat($prefix, $groupValue)
                else for $part in $parts return ($prefix || $part),
                f:hlistRC($level + 1, $contentValue, $sep, $emptyLineFns),
                $emptyLineFns ! map:get(., $level) ! .()
                (:''[$level eq 0] :)
            )
};


(:~
 :
 : ===    J S O N   r e l a t e d ===
 :
 :)

(:~
 : Resolves a JSON reference to a JSON object. The reference is
 : a JSON Pointer (https://tools.ietf.org/html/rfc6901).
 :
 : @param reference the reference string
 : @param doc a node from the document used as congtext
 : @return the referenced schema object, or the empty string if no such object is found
 :)
declare function f:resolveJsonRef($reference as xs:string?, 
                                  $doc as element())
        as element()? {
    if (not($reference)) then () else
    
    let $doc := $doc/ancestor-or-self::*[last()]
    let $withFragment := contains($reference, '#')
    let $resource := 
        if ($withFragment) then substring-before($reference, '#') else $reference
    let $path := 
        if ($withFragment) then replace($reference, '.*?#/', '') else ()
    let $context :=
        if (not($resource)) then $doc else
            try {
                resolve-uri($resource, $doc/base-uri(.)) 
                ! json:doc(.)/*
            } catch * {
                trace((), '___WARNING - CANNOT RESOLVE REFERENCE: ' || $reference
                || ' ; CONTEXT: ' || $doc/base-uri(.)),
                
                (: Second try - replace '-' with '/' in base URI;
                   motivation: maybe this document has been downloaded to a file
                   with a name obtained by replacing in an internet address
                   / with - :)
                let $baseUri2 := $doc/base-uri(.) ! replace(., '-', '/')
                return
                    try {
                        let $baseUri2 := $doc/base-uri(.) ! replace(., '-', '/')
                        let $dirPart := replace($baseUri2, '/[^/]+$', '')
                        let $uri := resolve-uri($resource, $baseUri2)
                        let $uriAdjusted := replace($uri, $dirPart||'/', $dirPart||'-')
                        return json:doc($uriAdjusted)/*
                    } catch * {
                        trace((), '___WARNING - SECOND ATTEMPT ALSO FAILED; BASE-URI 2: ' || $baseUri2)
                    }                     
            }
    where $context            
    return   
        if (not($path)) then $context else
            let $steps := tokenize($path, '\s*/\s*')
            let $target := f:resolveJsonRefRC($steps, $context)
            return 
                if ($target/_0024ref) then 
                    $target/_0024ref/f:resolveJsonRef(., $doc)
                else $target
};

(:~
 : Recursive helper function of 'resolveJsonRef'.
 :
 : @param steps the steps of the path (JSON Pointer steps)
 : @param context the context in which to resolve the path
 : @return the targets addressed by the path
 :)
declare function f:resolveJsonRefRC($steps as xs:string+, 
                                    $context as element()*)
        as element()* {
    let $head := head($steps)
    let $tail := tail($steps)
    let $refToken := $head 
                     ! web:decode-url(.)
                     ! replace(., '~1', '/') 
                     ! replace(., '~0', '~')
    let $elem :=
        if ($context/@type eq 'array') then
            if (matches($refToken, '^\d+$')) then $context/_[1 + xs:integer($refToken)]
            else () (: Invalid JSON Pointer syntax :)
        else 
            let $elemName := $refToken ! convert:encode-key(.)
            return $context/*[name() eq $elemName]
    return
        if (not($elem)) then ()
        else if (empty($tail)) then $elem
        else f:resolveJsonRefRC($tail, $elem)
};

(:~
 : Resolves an XSD type reference to the referenced type definition.
 :)
declare function f:resolveXsdTypeRef($reference as attribute(type), 
                                     $schema as element(xs:schema)?)
        as element()? {
    if (not($reference)) then () else
    
    let $schema := ($schema, $reference/ancestor::xs:schema[1])[1]
    let $refQname := $reference/resolve-QName(., ..)
    let $refNs := string(namespace-uri-from-QName($refQname))
    let $refName := local-name-from-QName($refQname)
    let $result := f:resolveXsdTypeRefRC($refNs, $refName, $schema, (), (), ())
    return $result[self::xs:simpleType, xs:complexType][1]
};

declare function f:resolveXsdTypeRefRC($refNs as xs:string,
                                       $refName as xs:string,
                                       $schema as element(xs:schema),
                                       $schemasSameLevel as element(xs:schema)*,
                                       $chameleonNs as xs:string?,
                                       $visited as element(xs:schema)*)
        as element()? {
    if ($visited intersect $schema) then $visited else
    
    let $tns := ($schema/@targetNamespace, $chameleonNs, '')[1]
    let $typeDefHere :=
        if ($refNs ne $tns) then () else
            $schema/(xs:simpleType, xs:complexType)[@name eq $refName]            
    return
        if ($typeDefHere) then $typeDefHere else

            let $visitedNew := ($visited, $schema)
            let $resultSSL := 
                if (not($schemasSameLevel)) then () else
                    f:resolveXsdTypeRefRC($refNs, $refName, 
                        head($schemasSameLevel), tail($schemasSameLevel), $chameleonNs, $visitedNew)
            let $typeDefSSL := $resultSSL[self::xs:simpleType, self::xs:complexType]
            return
                if ($typeDefSSL) then $typeDefSSL
                else                
                    let $visitedNew := ($visitedNew, $resultSSL)
                    let $schemaLocationsNextLevel :=
                        if ($tns eq $refNs) then $schema/xs:include/@schemaLocation
                        else $schema/xs:import[@namespace eq $tns]/@schemaLocation
                    let $schemasNextLevel := 
                        $schemaLocationsNextLevel/resolve-uri(., ..)
                        ! (try {doc(.)} catch * {()})
                        [not(. intersect $visited)]
                    let $resultSNL := 
                        if (not($schemasNextLevel)) then () else
                            f:resolveXsdTypeRefRC($refNs, $refName, 
                                head($schemasNextLevel), tail($schemasNextLevel), $tns, $visitedNew)
                    return $resultSNL                                
};        

(:~
 : Resolves a JSON Schema allOf group.
 :
 : @param reference the reference string
 : @param oad the OpenAPI documents considered
 : @return the referenced schema object, or the empty string if no such object is found
 :)
declare function f:resolveJsonAllOf($allOf as element(), 
                                    $doc as element(json)+)
        as element()* {
    for $subschema in $allOf/_        
    return
        if ($subschema[_0024ref]) then 
            let $effective := f:resolveJsonRef($subschema/_0024ref, $doc)
            return
                if ($effective/allOf) then $effective/allOf/f:resolveJsonAllOf(., $doc)
                else $effective
        else if ($subschema/_allOf) then $subschema/allOf/f:resolveJsonAllOf(., $doc)
        else $subschema
};

(:~
 :
 : ===    U t i l i t i e s ===
 :
 :)

(:~
 : Returns namespace nodes which apply to all elements in the
 : input sequence of elements.
 :
 : @param elems a sequence of elements
 : @return a sequence of namespace nodes
 :)
declare function f:extractNamespaceNodes($elems as element()*)
        as namespace-node()* {
    let $nspairs := (
        for $elem in $elems
        let $prefixes := in-scope-prefixes($elem)
        let $nspair := $prefixes ! concat(., '#', namespace-uri-for-prefix(., $elem))
        return $nspair 
    ) => distinct-values()
    
    for $nspair in $nspairs
    group by $nsuri := substring-after($nspair, '#')
    where 1 eq ($nspair => distinct-values() => count())
    return
        let $prefix := $nspair[1] ! substring-before(., '#')
        return
            if ($prefix eq '' and 
                (some $elem in $elems satisfies not('' = in-scope-prefixes($elem)))) 
            then () else namespace {$prefix} {$nsuri}
               
};

