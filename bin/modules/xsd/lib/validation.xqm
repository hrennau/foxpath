(:
 : A function returning a validation report.
 :)
module namespace val="http://www.parsqube.de/xspy/report/validation";
import module namespace ufpath="http://www.parsqube.de/xquery/util/file-path"
    at "../util/util-filePath.xqm";
import module namespace unamef="http://www.parsqube.de/xquery/util/name-filter"
    at "../util/util-nameFilter.xqm";  
import module namespace unpath="http://www.parsqube.de/xquery/util/node-path"
    at "../util/util-nodePath.xqm";
declare namespace z="http://www.parsqube.de/xspy/structure";

(:~
 : Writes a validation report.
 :)
declare function val:validationReport($xsd as xs:string, 
                                      $xml as xs:string, 
                                      $options as map(*))
        as element() {
    let $resources := val:getResources($xsd, $xml, $options)
    let $xsdpaths := $resources?xsd
    let $xmlpaths := $resources?xml
    let $_LOG := trace('Count selected documents: '||count($xmlpaths))
    let $report := val:xsdValidate($xmlpaths, $xsdpaths, ())
    let $reportAug :=
        element {node-name($report)} {
            $report/@*,
            $options?xsd ! attribute xsd {.},
            $options?xml ! attribute xml {.},
            $options?fname ! attribute fname {.},
            $options?ename ! attribute ename {.},
            $options?positions ! attribute positions {.},
            $report/node()
        }
    (:
        <validationReport>{
            <xsd>{$xsdpaths}</xsd>,
            <xmls count="{$xmlpaths => count()}">{
                $xmlpaths ! <xml>{.}</xml>
            }</xmls>
        }</validationReport>
    :)
    return $report        
};

(:~
 : Validates a set of documents against an XSD.
 :)
declare function val:xsdValidate($docs as item()*,
                                 $xsds as item()*,
                                 $options as xs:string?)
        as item()* {
    let $ops := $options ! tokenize(.)
    let $view := $ops[. = ('summary')]
    let $useFname := $ops = 'fname'    
    let $fnIdentAtt :=
        if ($useFname) then function($uri) {attribute file-name {replace($uri, '.*/', '')}}
        else function($uri) {attribute uri {$uri}}
    let $xsdNodes :=
        for $xsd in $xsds return 
            if ($xsd instance of node()) then $xsd/descendant-or-self::xs:schema[1]
            else doc($xsd)/*
    let $reports := 
        for $doc in $docs
        let $docNode :=
            if ($doc instance of node()) then $doc
            else doc($doc)/*
        let $nsuri := $docNode/namespace-uri(.)
        let $docPath := $doc[. instance of node()]/unpath:indexedNodePath(., ())
        let $lname := $docNode/local-name(.)
        let $myxsds := 
            let $raw := $xsdNodes
                [if (not($nsuri)) then not(@targetNamespace) else $nsuri eq @targetNamespace]
                [xs:element/@name = $lname]
            return
                if (exists($raw)) then $raw else $xsdNodes[1]
        let $result :=
            if (count($myxsds) gt 1) then <status>xsd_ambiguous</status>
            else if (not($myxsds)) then <status>xsd_nofind</status>
            else validate:xsd-report($doc, $myxsds/base-uri(.))/*
        let $docuri := if (not($doc instance of node())) then $doc else base-uri($doc)
        return 
            <validationReport>{
                $fnIdentAtt($docuri),
                $docPath ! attribute nodePath {.}, 
                attribute xsd {$myxsds/base-uri(.)},
                $result
            }</validationReport>
    let $messagesDistinct :=
        for $message in $reports//message
        group by $text := string($message)
        return <message count="{count($message)}">{$text}</message>
    let $reports2 :=
        if (count($reports) gt 1) then 
            let $invalid := $reports[status eq 'invalid']
            let $ambiguous := $reports[status eq 'xsd_ambiguous']            
            let $nofind := $reports[status eq 'xsd_nofind']
            let $valid := $reports except ($invalid, $ambiguous, $nofind)

            return
                <validationReports countDocs="{count($reports)}"
                                   countValid="{count($valid)}"
                                   countInvalid="{count($invalid)}"
                                   countNofind="{count($nofind)}"
                                   countAmbiguous="{count($ambiguous)}">{
                    if (not($messagesDistinct)) then () else
                    <distinctMessages count="{count($messagesDistinct)}">{
                        $messagesDistinct
                    }</distinctMessages>,
                    if (count($reports) eq 1) then $reports else (
                        <invalid count="{count($invalid)}">{
                            for $doc in $invalid 
                            let $ename := if ($doc/@nodePath) then 'node' else 'doc'
                            order by $doc/@uri, $doc/@file-name, $doc/@nodePath
                            return element {$ename} {$doc/(@uri, @file-name, @nodePath, $doc/*)}
                        }</invalid>[count($invalid) gt 0],
                        <valid count="{count($valid)}">{
                            for $doc in $valid 
                            let $ename := if ($doc/@nodePath) then 'node' else 'doc'
                            order by $doc/@uri, $doc/@file-name, $doc/@nodePath
                            return element {$ename} {$doc/(@uri, @file-name, @nodePath)}
                        }</valid>,
                        if (empty($nofind)) then () else
                        <nofind count="{count($nofind)}">{
                            for $doc in $nofind 
                            let $ename := if ($doc/@nodePath) then 'node' else 'doc'
                            order by $doc/@uri, $doc/@file-name, $doc/@nodePath
                            return element {$ename} {$doc/(@uri, @file-name, @nodePath)}
                        }</nofind>,
                        <ambiguous count="{count($ambiguous)}">{
                            for $doc in $ambiguous 
                            let $ename := if ($doc/@nodePath) then 'node' else 'doc'
                            order by $doc/@uri, $doc/@file-name, $doc/@nodePath
                            return element {$ename} {$doc/(@uri, @file-name,  @nodePath)}
                        }</ambiguous>
                    )
                }</validationReports>
        else $reports
    return
        if ($view eq 'summary') then (
            $reports2//invalid/('invalid (#'||@count||')', doc/(@uri, @file-name)/('  '||.)),
            $reports2//nofind/('nofind (#'||@count||')', doc/(@uri, @file-name)/('  '||.)),            
            $reports2//ambiguous/('ambiguous (#'||@count||')', doc/(@uri, @file-name)/('  '||.)),
            $reports2//valid/('valid (#'||@count||')')
        ) else
        let $reports3 :=    
            copy $reports2_ := $reports2
            modify delete nodes $reports2_//message/@url
            return $reports2_
        let $reports4 := val:finalizeValidationReport($reports3)
        return $reports4
 };

declare function val:finalizeValidationReport($report as element())
        as element() {
    $report ! val:finalizeValidationReportREC($report)        
};

declare function val:finalizeValidationReportREC($n as node())
        as node()* {
    typeswitch($n)
    case document-node() return document {$n/node() ! val:finalizeValidationReportREC(.)}
    case element(message) return
        let $text := $n/string()
        let $atts := (
            (: Case: duplicate key :)
            if (not(matches($text,
                'cvc-identity-constraint.4.2.2: Doppelter Schlüsselwert', 'i'))) then () else
                (: let $_DEBUG := trace($text, '_ duplicate key message: ') :)                
                let $keyValue := replace($text, '.*?\[(.*?)\].*', '$1')[. ne $text]
                return
                    if (not($keyValue)) then () else
                    let $keyName := replace($text, '.*?"(.*?)".*', '$1')
                    return (
                        attribute type {'duplicate-key'},
                        attribute keyName {$keyName},
                        attribute keyValue {$keyValue}
                    ),
            (: Case: key not found :)                    
            if (not(matches($text,
                'cvc-identity-constraint.4.3: Schlüssel .*nicht gefunden', 'i'))) then () else
                (: let $_DEBUG := trace($text, '_ missing key message: ') :)
                let $refName := replace($text, '.*Schlüssel\s*"(.*?)".*', '$1', 'i')[. ne $text]            
                let $refValue := replace($text, '.*Wert\s*"(.*?)".*', '$1', 'i')[. ne $text]
                    return (
                        attribute type {'missing-key'},
                        attribute refName {$refName},
                        attribute refValue {$refValue}
                    ),
            (: Case: key incomplete :)                    
            if (not(matches($text,
                'cvc-identity-constraint.4.2.1.b: Nicht genügend Werte', 'i'))) then () else
                
                let $keyName := replace($text, '.*?key name="(.*?)".*', '$1', 'i')
                return (
                    attribute type {'incomplete-key'},
                    attribute keyName {$keyName}
                ),
            (: Case: key empty :)                
            if (not(matches($text,
                'cvc-identity-constraint.4.2.1.a: Element.*keinen Wert für den Schlüssel "', 'i'))) then () else
                let $keyName := replace($text, '.*Wert für den Schlüssel "(.*?)".*', '$1', 'i')
                return (
                    attribute type {'empty-key'},
                    attribute keyName {$keyName}                
                )
            )
        return
            if ($atts) then $n/element {node-name(.)} {@*, $atts}
            else $n/element {node-name(.)} {@*, text()}

    case element() return 
        element {node-name($n)} {
            $n/@* ! val:finalizeValidationReportREC(.),
            $n/node() ! val:finalizeValidationReportREC(.)
        }
    default return $n
};

declare function val:resolvePositions($positions as xs:string?, $maxpos as xs:integer)
        as xs:integer* {
    let $positionsNorm := $positions ! replace(., '\s*-\s*', '-')
    let $items := $positionsNorm ! tokenize(.)
    let $numbers :=
        for $item in $items return
            if (contains($item, '-')) then
                let $num1 := (substring-before($item, '-')[string()], '1')[1] ! xs:integer(.)
                let $num2 := (substring-after($item, '-')[string()], string($maxpos))[1] ! xs:integer(.)
                return $num1 to $num2
            else $item ! xs:integer(.)
    return $numbers => distinct-values() => sort()
};

declare function val:getResources($xsd as xs:string,
                                  $xml as xs:string,
                                  $options as map(*))
        as map(*) {
    let $xsdR := $xsd ! ufpath:resolvePath(.)        
    let $xmlR := $xml ! ufpath:resolvePath(.)
    
    let $xsdpaths := (
        if ($xsdR ! file:is-file(.)) then $xsdR
        else if ($xsdR ! file:is-dir(.)) then
            file:descendants($xsdR)[ends-with(file:name(.), '.xsd')]
        else
            error(QName((), 'FILE_NOT_FOUND'), 'XSD resource not found: '||$xsd)
        ) ! ufpath:normalizePath(.)
    let $_CHECK :=
        if (exists($xsdpaths)) then () else
            error(QName((), 'FILE_NOT_FOUND'), 'No XSD resources found in folder: '||$xsdR)
    
    let $xmlpaths := (
        if ($xmlR ! file:is-file(.)) then $xmlR
        else if ($xmlR ! file:is-dir(.)) then
           file:descendants($xmlR)[ends-with(file:name(.), '.xml')]
        else
            error(QName((), 'FILE_NOT_FOUND'), 'XML resource not found: '||$xmlR)
        ) ! ufpath:normalizePath(.)
    let $_CHECK :=
        if (exists($xmlpaths)) then () else
            error(QName((), 'FILE_NOT_FOUND'), 'No XML resources found in folder: '||$xmlR)
        
    let $xmlpathsFiltered1 :=
        if (not($options?dname)) then $xmlpaths
        else
            let $dnameFilter := $options?dname ! unamef:parseNameFilter(.)
            return 
                for $path in $xmlpaths
                let $relpath := $path ! ufpath:relativePath(., $xmlR)                
                let $steps := ($relpath ! tokenize(., '/'))[position() lt last()] 
                where some $step in $steps satisfies 
                    unamef:matchesNameFilterObject($step, $dnameFilter)
                return $path
    let $xmlpathsFiltered2 :=
        if (not($options?fname)) then $xmlpathsFiltered1
        else
            let $fnameFilter := $options?fname ! unamef:parseNameFilter(.)
            return $xmlpaths[file:name(.) ! unamef:matchesNameFilterObject(., $fnameFilter)]
    let $xmlpathsFiltered3 :=
        if (not($options?ename)) then $xmlpathsFiltered2
        else
            let $enameFilter := $options?ename ! unamef:parseNameFilter(.)
            return 
                for $path in $xmlpathsFiltered1
                let $doc := doc($path)
                where $doc//*[local-name(.) ! unamef:matchesNameFilterObject(., $enameFilter)]
                return $path
    let $xmlpathsFiltered4 :=
        if (not($options?positions)) then $xmlpathsFiltered3
        else
            let $positions := $options?positions ! val:resolvePositions(., count($xmlpathsFiltered1))
            return $xmlpathsFiltered3[position() = $positions]
    let $xmlpathsFiltered := $xmlpathsFiltered4
    
    let $_CHECK :=
        if (exists($xmlpathsFiltered)) then () else
            error(QName((), 'NO_FILTER_MATCHES'), 'No XML resources matching filters')
    
    let $resources :=
        map{'xsd': $xsdpaths,
            'xml': $xmlpathsFiltered
        }
    return $resources
};        
