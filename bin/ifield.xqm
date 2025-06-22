module namespace if="http://www.infofield.org/ns/xquery-functions";

import module namespace util="http://www.ttools.org/xquery-functions/util"
        at "foxpath-util.xqm";

import module namespace fuo="http://www.ttools.org/xquery-functions"
        at "foxpath.xqm",
           "foxpath-uri-operations.xqm";


declare variable $if:DOCLIB := map{
    'unparsed-text#1': fuo:fox-unparsed-text#1,
    'doc#1': fuo:fox-xml-doc#1,
    'json:doc#1': fuo:fox-json-doc#1,
    'html:doc#1': fuo:fox-html-doc#1,
    'csv:doc#2': fuo:fox-csv-doc2#2
};

(:
declare variable $if:DOCLIB := map{
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
declare function if:compileIfield($ifield as xs:string) 
        as element() {
    let $path := util:fpath($ifield)
    let $doc := try {doc($path)/*} 
                catch * {<err:error code="{$err:code}" description="{$err:description}"/>}
    return
        if ($doc/self::err:error) then $doc/error(QName((), 'IFIELD_NOFIND'), 
            'Cannot read ifield definition; code='||@code||'; description: '||@description)
        else $doc ! if:compileIfieldREC(.) ! util:prettyFoxPrint(.)
};        

(:~
 : Recursive helper function of `compileIfield`.
 :) 
declare function if:compileIfieldREC($n as node()) 
        as node()* {
    typeswitch($n)
    case document-node() return document {$n/node() ! if:compileIfieldREC(.)}
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
                $n/@* ! if:compileIfieldREC(.),
                $fileNameRegex,
                $parentNameRegex,
                $n/node() ! if:compileIfieldREC(.)
            }
               
    case element() return
        element {node-name($n)} {
            $n/@* ! if:compileIfieldREC(.),
            $n/node() ! if:compileIfieldREC(.)
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
declare function if:doc($uri as xs:string, $ifieldDoc as element()) 
        as node()? {
    let $cases := $ifieldDoc/rtypeUses/case
    return if:doc_cases($uri, $cases)
};

(:~
 : Helper function of `if:doc`, returning the document as described by
 : a sequence of <case> elements.
 :)
declare function if:doc_cases($uri as xs:string, $cases as element(case)*) 
        as node()? {
    if (not($cases)) then () else
    let $doc := head($cases) ! if:doc_case($uri, .)
    return if ($doc) then $doc else if:doc_cases($uri, tail($cases))
};

(:~
 : Helper function of `if:doc`, returning the document as described by
 : a <case> element.
 :)
declare function if:doc_case($uri as xs:string, $case as element(case)) 
        as node()? {
    let $condition := $case/condition        
    let $test := 
        if (not($condition)) then true() 
        else if:doc_checkCondition($uri, $condition)        
    return
        (: Condition satisfied :)
        if ($test) then
            let $context := ($case/iftrue, $case)[1]   
            let $iftrue := if:doc_rtypeUseOrCases($uri, $context)
            return
                if ($iftrue) then $iftrue 
                else $context/else ! if:doc_rtypeUseOrCases($uri, .)
        (: Condition not satisfied :)                
        else $case/else ! if:doc_rtypeUseOrCases($uri, .) 
};        

(:~
 : Helper function of `if:doc`, returning the document as described by
 : an ifield node containing either an <rtypeUse> element or <case>
 : elements.
 :)
declare function if:doc_rtypeUseOrCases($uri as xs:string, $context as element()) 
        as node()? {
    let $rtypeUse := $context/rtypeUse
    return
        if ($rtypeUse) then 
            if:docForRtypeName($uri, $rtypeUse, $context/ancestor::ifield)
        else
    let $cases := $context/case
    return
        if ($cases) then if:doc_cases($uri, $cases)
        else 
            let $childNames := $context/*/name() => string-join(', ')
            return
                error((), 'Unexpected structure: expected either "rtypeUse" or "case"; '||
                    'found: '||$childNames)
};

(:~
 : Helper function of `if:doc`, checking a condition defined by the ifield
 : specification.
 :)
declare function if:doc_checkCondition($uri as xs:string, $condition as element()) 
        as xs:boolean? {
    let $file := $condition/file
    let $isXml := $condition/isXml
    return (
        not($file) or if:doc_checkCondition_file($uri, $file)
        and
        not($isXml) or if:doc_checkCondition_isXml($uri, $isXml)
    )
};

(:~
 : Helper function of `if:doc`, checking a file condition defined by the ifield
 : specification.
 :)
declare function if:doc_checkCondition_file($uri as xs:string, $file as element()) 
        as xs:boolean? {
    let $nameRegex := $file/@nameRegex ! tokenize(.)
    let $parentNameRegex := $file/@parentNameRegex ! tokenize(.)
    return (
        empty($nameRegex) or (
            let $name := file:name($uri)
            return util:multiMatches($name, $nameRegex, 'i'))
        ) and (
        empty($parentNameRegex) or (
            let $parentName := file:parent($uri) ! file:name(.)
            return util:multiMatches($parentName, $parentNameRegex, 'i'))
    )
};

(:~
 : Helper function of `if:doc`, checking an is-xml condition defined by the ifield
 : specification.
 :)
declare function if:doc_checkCondition_isXml($uri as xs:string, $isXml as element()) 
        as xs:boolean? {
    doc-available($uri)
};

declare function if:docForRtypeName($uri as xs:string, 
                                    $rtypeUse as element(rtypeUse), 
                                    $ifield as element())
        as node()? {
    let $rtypeName := $rtypeUse/@rtype        
    let $rtypeDef := $ifield/rtypes/rtype[@name eq $rtypeName]         
    return
        if (not($rtypeDef)) then
            error((), 'Unknown rtype name: '||$rtypeName)
        else
    let $docFn := $rtypeDef/docFn
    return
        if ($docFn) then
            switch($docFn)
            case 'doc#1' return 
                try {$if:DOCLIB($docFn)($uri)} 
                catch * {(:trace((), 'doc() failed; uri='||$uri||'; code='||$err:code||
                                   '; description='||$err:description):)}
            case 'json:doc#1' return 
                try {$if:DOCLIB($docFn)($uri)} 
                catch * {trace((), 'json:doc() failed; uri='||$uri||'; code='||$err:code||
                                   '; description='||$err:description)}
            case 'html:doc#1' return
                try {$if:DOCLIB($docFn)($uri)} 
                catch * {trace((), 'html:doc() failed; uri='||$uri||'; code='||$err:code||
                                   '; description='||$err:description)}
                                   
            case 'csv:doc#2' return
                let $csvOptions := 
                    let $ops := $rtypeUse/options
                    return if (not($ops)) then () else
                        map:merge($ops/option/map:entry(@name, @value/string()))
                let $_DEBUG := trace($csvOptions, '_ csvOptions: ')                        
                return
                $if:DOCLIB($docFn)($uri, $csvOptions)
                (:
                    try {$if:DOCLIB($docFn)($uri, $csvOptions)} 
                    catch * {trace((), 'csv:doc() failed; uri='||$uri||'; code='||$err:code||
                                       '; description='||$err:description)}
:)                                       
            default return
                error((), 'Unknown doc function: '||$docFn)
        else
    let $parseFn := $rtypeDef/parseFn
    return
        if ($parseFn) then
        
        let $text := $if:DOCLIB(unparsed-text#1)($uri)
        return
            switch($parseFn)
            case 'parse-xml#1' return parse-xml($text)
            case 'json:parse#1' return json:parse($text)
            case 'html:parse#1' return html:parse($text)
            case 'csv:parse#2' return csv:parse($text, map{})
            default return
                error((), 'Unknown parse function: '||$parseFn)
        else        
    let $grammar := $rtypeDef/grammarUri
    return
        if ($grammar) then
            let $grammarUri := $grammar ! resolve-uri(., base-uri(.))
            let $grammarText := $grammarUri ! unparsed-text(.)            
            let $fnParse := $grammarText ! invisible-xml(.)
            return $uri ! $if:DOCLIB('unparsed-text#1')(.) ! $fnParse(.)
        else        
    
    error((), 'Alternatives to "docFn", "parseFn" and "grammarUri" not yet supported.')
};            
