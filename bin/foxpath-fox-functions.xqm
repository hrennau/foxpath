module namespace f="http://www.ttools.org/xquery-functions";
import module namespace i="http://www.ttools.org/xquery-functions" at 
    "foxpath-processorDependent.xqm",
    "foxpath-uri-operations.xqm",
    "foxpath-util.xqm";

(:~
 : Foxpath function `bslash#1'. Edits a text, replacing forward slashes by 
 : back slashes.
 :
 : @param arg text to be edited
 : @return edited text
 :)
declare function f:foxfunc_bslash($arg as xs:string?)
        as xs:string? {
    replace($arg, '/', '\\')        
};      

(:~
 : Foxpath function `file-content#1'. Edits a text, replacing forward slashes by 
 : back slashes.
 :
 : @param arg text to be edited
 : @return edited text
 :)
declare function f:foxfunc_file-content($uri as xs:string?, 
                                        $encoding as xs:string?,
                                        $options as map(*)?)
        as xs:string? {
    let $redirectedRetrieval := f:fox-unparsed-text_github($uri, $encoding, $options)
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
        $names ! f:childUriCollection($context, ., (), ()) ! concat($context, '/', .) 
    else 
        for $name in $names
        let $regex := replace($name, $fromSubstring, $toSubstring, 'i') !
                      concat('^', ., '$')
        return
            for $child in f:childUriCollection($context, (), (), ())
            let $cname := replace($child, '.*/', '')
            where matches($cname, $regex, 'i')
            return concat($context, '/', $child)
    ) => distinct-values()            
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
    let $uri := f:parentUri($context, $regex) 
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
    let $uri := f:selfUri($context, $regex) 
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
        f:descendantUriCollection($context, $name, (), ()) ! concat($context, '/', .) 
    else 
        let $regex := replace($name, $fromSubstring, $toSubstring, 'i') !
                      concat('^', ., '$')        
        return
            for $child in f:descendantUriCollection($context, (), (), ())
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
    let $parent := f:parentUri($context, ())
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
        f:parentUri($context, ()) 
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
    let $uris := f:ancestorUriCollection($context, $regex, false()) 
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
    let $uris := f:ancestorUriCollection($context, $regex, true()) 
    return $uris
    ) => distinct-values()
};

(:~
 : Returns a frequency distribution.
 :
 : @param values a sequence of terms
 : @param min if specified - return only terms with a frequency >= $min
 : @param max if specified - return only terms with a frequency >= $max
 : @format format the output format, one of text|xml|json|csv, default = text
 : @format width if format = text - the width of the term column
 : @return the frequency distribution
 :)
declare function f:foxfunc_frequencies($values as item()*, 
                                       $min as xs:integer?, 
                                       $max as xs:integer?, 
                                       $format as xs:string?,
                                       $width as xs:integer?)
        as item() {
        
    let $format := ($format, 'text')[1]
 
    (: Function item returning a text representation :)
    let $textrep :=
        if ($format ne 'text') then ()
        else if (empty($width)) then function ($s, $c, $w) {concat($s, ' (', $c, ')')}
        else function ($s, $c, $w) {concat($s, string-join(for $i in 1 to $w - string-length($s) return '.', ''), ' (', $c, ')')}
        
    (: Function item returning a term representation :)
    let $item :=
        switch($format) 
        case 'text' return function($s, $c) {$textrep[1]($s, $c, $width[1])} 
        case 'xml' return function($s, $c) {<term text="{$s}" count="{$c}"/>}
        case 'json' return function($s, $c) {'"'||$s||'": '||$c}
        case 'csv' return function($s, $c) {'"'||$s||'",'||$c}
        default return error(QName((), 'INVALID_ARG'), concat('Unknown frequencies format, should be text|xml|json|csv; found: ', $format))
        
    (: Item frequencies :)        
    let $items :=
        for $value in $values
        group by $s := string($value)
        let $c := count($value)
        where (empty($min) or $c ge $min) and (empty($max) or $c le $max)
        order by lower-case($s)
        return $item($s, $c)
        
    (: The report :)
    return
        switch($format)
        case 'xml' return <terms minCount="{min($items/@count)}" maxCount="{min($items/@count)}">{$items}</terms>
        case 'json' return ('{', $items ! concat('  ', .), '}') => string-join('&#xA;')
        default return $items => string-join('&#xA;')
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
            else f:fox-unparsed-text($file, $encoding, ())        
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
                    let $fileContent := f:fox-unparsed-text($file, $encoding, ())
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
 :   (2) if flag 'a' is set, the item is not modified if it is not an attribute;
 :       if it is an attribute, it is mapped to an element which has a name 
 :       equal to the name of the parent of the attribute, and which contains a 
 :       copy of the attribute 
 :   (2) if flag 'A' is set, treatment as with flag 'a', but the constructed element
 :       has no namespace URI 
 :   (3) otherwise, the item is not modified

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
declare function f:foxfunc_xwrap($items as item()*, 
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
            if (contains($flags, 'b') and ($item instance of element() or $item instance of document-node())) then
                let $baseUri := base-uri($item)
                let $elem := $item/descendant-or-self::*[1]
                return
                    let $xmlBase := if ($elem/@xml:base) then () else attribute xml:base {$baseUri}
                    return
                        element {node-name($elem)} {
                            $elem/@*, $xmlBase, $elem/node()
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
    return
        element {$name} {attribute countItems {count($val)}, $val}
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
                                     $localNames as xs:boolean?,
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
    let $names := if ($localNames) then $items/local-name(.) => sort()
                  else $items/name(.) => sort()
    let $names := distinct-values($names)        
    return
        if (exists($separator)) then string-join($names, $separator)
        else $names
};        

(:~
 : Returns the child element names of a node. If $separator is specified, the sorted
 : names are concatenated, using this separator, otherwise the names are returned
 : as a sequence. If $localNames is true, the local names are returned, otherwise the 
 : lexical names. 
 :
 : When using $namePattern, only those child elements are considered which have
 : a local name matching the pattern.
 :
 : Example: .../foo/child-names(., ', ', false(), '*put')
 : Example: .../foo/child-names(., ', ', false(), 'input|output') 
 :
 : @param node a node (unless it is an element, the function returns the empty sequence)
 : @param separator if used, the names are concatenated, using this separator
 : @param localNames if true, the local names are returned, otherwise the lexical names 
 : @param namePattern an optional name pattern filtering the child elements to be considered
 : @return the names as a sequence, or as a concatenated string
 :)
declare function f:foxfunc_child-names($node as node(), 
                                       $concat as xs:boolean?, 
                                       $localNames as xs:boolean?,
                                       $namePattern as xs:string?,
                                       $excludedNamePattern as xs:string?)
        as xs:string* {
    let $nameRegex := $namePattern ! replace(., '\*', '.*') ! replace(., '\?', '.') 
                      ! concat('^', ., '$')        
    let $excludedNameRegex := $excludedNamePattern ! replace(., '\*', '.*') ! replace(., '\?', '.') 
                      ! concat('^', ., '$')        
    let $items := $node/*
       [not($nameRegex) or matches(local-name(.), $nameRegex, 'i')]
       [not($excludedNameRegex) or not(matches(local-name(.), $excludedNameRegex, 'i'))]
    let $separator := ', '[$concat]
    let $names := if ($localNames) then $items/local-name(.) => sort()
                  else $items/name(.) => sort()
    let $names := distinct-values($names)        
    return
        if (exists($separator)) then string-join($names, $separator)
        else $names
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
                                       $localNames as xs:boolean?,
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
    let $names := if ($localNames) then $items/local-name(.) => sort()
                  else $items/name(.) => sort()
    let $names := distinct-values($names)        
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
declare function f:foxfunc_parent-name($node as node(), $localName as xs:boolean?)
        as xs:string* {
    let $item := $node/..
    let $name := if ($localName) then $item/local-name(.)
                 else $item/name(.)
    return
        $name
};        

(:~
 : Returns the parent name of a node. If $localNames is true, the local name is returned, 
 : otherwise the lexical names. 
 :
 : @param node a node
 : @param localName if true, the local name is returned, otherwise the lexical name
 : @return the parent name
 :)
declare function f:foxfunc_name-path($node as node(), 
                                     $localNames as xs:boolean?, 
                                     $numSteps as xs:integer?)
        as xs:string* {
    let $steps := 
        if ($localNames) then 
            $node/ancestor-or-self::node()/concat(self::attribute()/'@', local-name(.))
        else 
            $node/ancestor-or-self::node()/concat(self::attribute()/'@', name(.))
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

