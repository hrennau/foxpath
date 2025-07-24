module namespace is="http://www.foxpath.org/ns/ispace";

import module namespace util="http://www.ttools.org/xquery-functions/util"
        at "foxpath-util.xqm";

import module namespace fuo="http://www.ttools.org/xquery-functions"
        at "foxpath.xqm",
           "foxpath-uri-operations.xqm";


declare variable $is:DOCLIB := map{
    'unparsed-text#1': fuo:fox-unparsed-text#1,
    'doc#1': fuo:fox-xml-doc#1,
    'json:doc#1': fuo:fox-json-doc#1,
    'html:doc#1': fuo:fox-html-doc#1,
    'csv:doc#2': fuo:fox-csv-doc2#2,
    'docx:doc#1': fuo:docx-doc#1
};

(:
declare variable $is:DOCLIB := map{
    'unparsed-text#1': unparsed-text#1,
    'doc#1': doc#1,
    'json:doc#1': json:doc#1,
    'html:doc#1': html:doc#1,
    'csv:doc#2': csv:doc#2
};
:)

(:
 :    c o m p i l e I f i e l d
 :    =========================
 :)
 
(:~
 : Compiles an infofield definition. Attributes containing glob expressions
 : are accompanied by attributes containing the corresponding regular 
 : expressions.
 :) 
declare function is:compileIspace($ispace as xs:string) 
        as element() {
    let $path := util:fpath($ispace)
    let $doc := try {doc($path)/*} 
                catch * {<err:error code="{$err:code}" description="{$err:description}"/>}
    let $ops := map{}
    return
        if ($doc/self::err:error) then $doc/error(QName((), 'ISPACE_NOFIND'), 
            'Cannot read ispace definition; code='||@code||'; description: '||@description)
        else $doc ! is:compileIspaceREC(., $ops) ! util:prettyFoxPrint(.)
};        

(:~
 : Recursive helper function of `compileIspace`.
 :) 
declare function is:compileIspaceREC($n as node(),
                                     $options as map(xs:string, item()*)) 
        as node()* {
    typeswitch($n)
    case document-node() return document {$n/node() ! is:compileIspaceREC(., $options)}
    case element(grammars) return
        let $contextDir := ($n/(@dir, @baseURI, @xml:base)[1]/
                            replace(., '[^/]$', '$0/') 
                            ! resolve-uri(., $n/base-uri(.)),
                            $n/base-uri(.))[1]
        let $optionsUpd := map:put($options, 'grammarContextDir', $contextDir)
        return
            element {node-name($n)} {
                attribute dir {$contextDir},
                $n/(@* except @dir) ! is:compileIspaceREC(., $optionsUpd),
                $n/node() ! is:compileIspaceREC(., $optionsUpd)
            } 
    case element(grammar) return
        let $contextDir := $options?grammarContextDir
        let $uri := $n/@uri ! resolve-uri(., $contextDir)
        return
            element {node-name($n)} {
                $n/(@* except @uri) ! is:compileIspaceREC(., $options),
                $uri ! attribute uri {.},
                $n/node() ! is:compileIspaceREC(., $options)
            }
    case $file as element(file) return
        let $fnRegexAtt := function($att) {
            let $attName := local-name($att)||'Regex'
            return attribute {$attName} {
                $att ! tokenize(.) ! util:glob2regex(.) => string-join(' ')
            }
        }
        let $fileNameRegex := $file/@name ! $fnRegexAtt(.)
        let $parentNameRegex := $file/@parentName ! $fnRegexAtt(.)
        return
            element {node-name($n)} {
                $n/@* ! is:compileIspaceREC(., $options),
                $fileNameRegex,
                $parentNameRegex,
                $n/node() ! is:compileIspaceREC(., $options)
            }
               
    case element() return
        element {node-name($n)} {
            $n/@* ! is:compileIspaceREC(., $options),
            $n/node() ! is:compileIspaceREC(., $options)
        }
    
    default return $n        
};

(:
 :    d o c
 :    =====
 :)

(:~
 : Maps a document URI to a root node.
 :) 
declare function is:doc($uri as xs:string, 
                        $ispaceDoc as element())
        as node()? {
    is:doc($uri, $ispaceDoc, map{})
};

(:~
 : Maps a document URI to a root node.
 :) 
declare function is:doc($uri as xs:string, 
                        $ispaceDoc as element(),
                        $options as map(xs:string, item()*))
        as node()? {
    let $cases := $ispaceDoc/rtypeUses/case
    return is:doc_cases($uri, $cases, $options)
};

(:~
 : Helper function of `is:doc`, returning the document as described by
 : a sequence of <case> and or <rtypeUse> elements.
 :)
declare function is:doc_cases($uri as xs:string, 
                              $cases as element()*,
                              $options as map(xs:string, item()*)) 
        as node()? {
    if (not($cases)) then () else
    let $doc := head($cases) ! is:doc_case($uri, ., $options)
    return if ($doc) then $doc else is:doc_cases($uri, tail($cases), $options)
};

(:~
 : Helper function of `is:doc`, returning the document as described by
 : a <case> or <rtypeUse> element.
 :)
declare function is:doc_case($uri as xs:string, 
                             $case as element(),
                             $options as map(xs:string, item()*))
        as node()? {
    if ($case/self::rtypeUse) then
        is:docForRtypeName($uri, $case, $case/ancestor::ispace, $options)    
    else
    
    let $condition := $case/condition    
    let $test := 
        if (not($condition)) then true() 
        else is:doc_checkCondition($uri, $condition, $options)
    return
        (: Condition satisfied :)
        if ($test) then
            if ($case/iftrue) then 
                is:doc_cases($uri, $case/iftrue/*, $options)
            else if ($case/condition) then
                is:doc_cases($uri, $case/condition/following-sibling::*, $options)
            else is:doc_cases($uri, $case/*, $options)
        else 
            $case/else/is:doc_cases($uri, *, $options)
};        

declare function is:docForRtypeName($uri as xs:string, 
                                    $rtypeUse as element(rtypeUse), 
                                    $ispace as element(),
                                    $options as map(xs:string, item()*))
        as node()? {
    let $rtypeName := $rtypeUse/@rtype        
    let $rtypeDef := $ispace/rtypes/rtype[@name eq $rtypeName]
    return
        if (not($rtypeDef)) then
            error((), 'Unknown rtype name: '||$rtypeName)
        else
    let $docFn := $rtypeDef/docFn
    return
        if ($docFn) then
            switch($docFn)
            case 'doc#1' return 
                try {$is:DOCLIB($docFn)($uri)} 
                catch * {(: trace((), 'doc() failed; uri='||$uri||'; code='||$err:code||
                                   '; description='||$err:description) :)}
            case 'json:doc#1' return 
                try {$is:DOCLIB($docFn)($uri)} 
                catch * {trace((), 'json:doc() failed; uri='||$uri||'; code='||$err:code||
                                   '; description='||$err:description)}
            case 'docx:doc#1' return 
                try {$is:DOCLIB($docFn)($uri)} 
                catch * {trace((), 'docx:doc() failed; uri='||$uri||'; code='||$err:code||
                                   '; description='||$err:description)}
            case 'html:doc#1' return
                try {$is:DOCLIB($docFn)($uri)} 
                catch * {trace((), 'html:doc() failed; uri='||$uri||'; code='||$err:code||
                                   '; description='||$err:description)}
                                   
            case 'csv:doc#2' return
                let $csvOptions := 
                    let $ops := $rtypeUse/options
                    return if (not($ops)) then () else
                        map:merge($ops/option/map:entry(@name, @value/string()))
                return
                $is:DOCLIB($docFn)($uri, $csvOptions)
                (:
                    try {$is:DOCLIB($docFn)($uri, $csvOptions)} 
                    catch * {trace((), 'csv:doc() failed; uri='||$uri||'; code='||$err:code||
                                       '; description='||$err:description)}
:)                                       
            default return
                error((), 'Unknown doc function: '||$docFn)
        else
    let $parseFn := $rtypeDef/parseFn
    return
        if ($parseFn) then
        
        let $text := $is:DOCLIB(unparsed-text#1)($uri)
        return
            switch($parseFn)
            case 'parse-xml#1' return parse-xml($text)
            case 'json:parse#1' return json:parse($text)
            case 'html:parse#1' return html:parse($text)
            case 'csv:parse#2' return csv:parse($text, map{})
            default return
                error((), 'Unknown parse function: '||$parseFn)
        else        
    let $grammar := $rtypeDef/grammar
    return
        if ($grammar) then
            let $grammarUri := 
                $rtypeDef/ancestor::ispace/grammars/grammar[@name eq $grammar/@ref]/@uri
            let $grammarText := $grammarUri ! unparsed-text(.)            
            let $fnParse := $grammarText ! invisible-xml(.)
            return $uri ! $is:DOCLIB('unparsed-text#1')(.) ! $fnParse(.)
        else        
    
    error((), 'Alternatives to "docFn", "parseFn" and "grammarUri" not yet supported.')
};            

(:~
 : Helper function of `is:doc`, checking a condition defined by the ispace
 : specification.
 :)
declare function is:doc_checkCondition($uri as xs:string, 
                                       $condition as element(),
                                       $options as map(xs:string, item()*))                                       
        as xs:boolean? {
    let $file := $condition/file
    let $isXml := $condition/isXml
    return
        (not($file) or is:doc_checkCondition_file($uri, $file, $options))
        and
        (not($isXml) or is:doc_checkCondition_isXml($uri, $isXml, $options))
};

(:~
 : Helper function of `is:doc`, checking a file condition defined by the ispace
 : specification.
 :)
declare function is:doc_checkCondition_file($uri as xs:string, 
                                            $file as element(),
                                            $options as map(xs:string, item()*))
        as xs:boolean? {
    let $nameRegex := $file/@nameRegex ! tokenize(.)
    let $parentNameRegex := $file/@parentNameRegex ! tokenize(.)
    return (
        empty($nameRegex) or (
            let $name := $uri ! replace(., '.*/', '')
            return util:multiMatches($name, $nameRegex, 'i'))
        ) and (
        empty($parentNameRegex) or (
            let $parentName := file:parent($uri) ! file:name(.)
            return util:multiMatches($parentName, $parentNameRegex, 'i'))
    )
};

(:~
 : Helper function of `is:doc`, checking an is-xml condition defined by the ispace
 : specification.
 :)
declare function is:doc_checkCondition_isXml($uri as xs:string, 
                                             $isXml as element(),
                                             $options as map(xs:string, item()*))                                             
        as xs:boolean? {
    doc-available($uri)
};

