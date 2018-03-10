import module namespace f="http://www.ttools.org/xquery-functions" at "foxpath.xqm", "foxpath-util.xqm";
declare namespace soap="http://schemas.xmlsoap.org/soap/envelope/";

declare variable $doc external := ();
declare variable $xsd external := ();
declare variable $ename external := ();
declare variable $xpath external := ();
declare variable $parse as xs:boolean? external := ();
declare variable $mode as xs:string? external := ();   (: val, xsdelems :)
declare variable $f:URI_SOAP := "http://schemas.xmlsoap.org/soap/envelope/";

declare function f:xval($doc as xs:string, $xsd as xs:string, $mode as xs:string?)
        as item()* {
    let $DUMMY := f:trace($mode, 'xval', concat('doc=', $doc, ' ; xsd=', $xsd, ' ; MODE: '))
    let $require := tokenize(
        if ($mode = ('ls', 'parse', 'docs')) then 'docs'
        else if ($mode = ('xsds', 'tns', 'tnames', 'xsdcat')) then 'xsds'
        else if ($mode = ('val')) then 'docs xsds'     
        else if ($mode = ('ls2', 'parse2')) then ''
        else
            error(QName((), 'INVALID_ARG'), 
                concat('Invalid mode; supported: val, parse, parse2, ls, ls2, docs, xsds, tns, tnames; found: ', 
                    $mode))
        , ' ')    
    let $xsd :=
        if ($require = 'xsds' and $doc and not($xsd)) then
            $doc
        else
            $xsd
    return    
        if ($require = 'docs' and not($doc)) then
            f:createFoxpathErrors('INVALID_ARG',
                concat('Using mode ''', $mode, ''', ',
                'parameter ''doc'' is required, but missing.'))       
        else if ($require = 'xsds' and not($xsd)) then
            f:createFoxpathErrors('INVALID_ARG',
                concat('Using mode ''', $mode, ''', ',
                'parameter ''xsd'' is required, but missing.'))       
        else
        
    (: === mode 'ls' ========================================= :)        
    if ($mode eq 'ls') then
        f:resolveFoxpath($doc, (), (), map:entry('IS_CONTEXT_URI', true()), (), ())
    
    (: === mode 'ls2 ========================================= :)        
    else if ($mode eq 'ls2') then
        f:getResolveReport($doc, $xsd)
    
    (: === mode 'cat' ======================================== :)        
    else if ($mode eq 'xsdcat') then
        let $xsdUris := f:resolveFoxpath($xsd, (), (), map:entry('IS_CONTEXT_URI', true()), ())
        return
            f:cat($xsdUris)
    
    (: === mode 'parse' ====================================== :)        
    else if ($mode eq 'parse') then
        f:parseFoxpath($doc)
    
    (: === mode 'parse2' ===================================== :)        
    else if ($mode eq 'parse2') then
        f:getParseReport($doc, $xsd)
    else
    
    (: resolve foxpaths to URI sequences :)
    let $docUris := 
        if (not($require = 'docs')) then ()
        else 
            f:resolveFoxpath($doc, (), (), '*.xml', map:entry('IS_CONTEXT_URI', true()), ())
    let $xsdUris := 
        if (not($require = 'xsds')) then () 
        else 
            f:resolveFoxpath($xsd, (), (), '*.xsd', map:entry('IS_CONTEXT_URI', true()), ())
    return 
        if ($docUris instance of element(errors)) then $docUris 
        else if ($xsdUris instance of element(errors)) then $xsdUris else
     
    let $DUMMY := trace($mode, 'MODE: ') return        
    (: === mode 'docs' ======================================= :)        
    if ($mode eq 'docs') then (
        f:getDocsReport($mode, $doc, $docUris )    
    )
    (: === mode 'xsds' ======================================= :)        
    else if ($mode eq 'xsds') then (
        let $uris := f:resolveFoxpath($xsd, (), (), '*.xsd', map:entry('IS_CONTEXT_URI', true()), ())
        return f:getXsdsReport($mode, $xsd, $uris)    
    )
    
    (: === mode 'tns' ======================================== :)
    else if ($mode eq 'tns') then (
        let $xsdUris := f:resolveFoxpath($xsd, (), (), '*.xsd', map:entry('IS_CONTEXT_URI', true()), ())
        return f:getTnsReport($mode, $xsd, $xsdUris)
    (: ======================================================= :)
    
    (: === mode 'tnames' ===================================== :)
    ) else if ($mode eq 'tnames') then (
        let $xsdUris := f:resolveFoxpath($xsd, (), (), '*.xsd', map:entry('IS_CONTEXT_URI', true()), ())
        return f:getTnamesReport($mode, $xsdUris)
    (: ======================================================= :)        
    
    ) else

    let $docUris := f:resolveFoxpath($doc, (), (), '*.xml', map:entry('IS_CONTEXT_URI', true()), ())
    let $xsdUris := f:resolveFoxpath($xsd, (), (), '*.xsd', map:entry('IS_CONTEXT_URI', true()), ())
    (: let $DUMMY := trace((), concat('count(docs)=', count($docUris), ' , count(xsds)=', count($xsdUris))) :)
    return
        if (empty($docUris)) then concat('No documents found for doc path: ', $doc)
        else if (empty($xsdUris)) then concat('No schemas found for xsd path: ', $xsd)
        else
    
    let $xsds :=
        for $xsdUri in $xsdUris
        return
            try{doc($xsdUri)} catch * {<error type="malformedXsd" xsdUri="{$xsdUri}"/>}
    let $xsdErrors := $xsds/self::error
    let $xsds := $xsds except $xsdErrors

    let $elemNamePattern :=
        if (not($ename)) then () else 
            concat('^', replace($ename, '\*', '.*'), '$')       
    let $results :=
        for $docUri in $docUris
        let $doc := try{doc($docUri)} catch * {<doc name="{$docUri}" state="malformed"/>}
        return
            if ($doc/@state eq 'malformed') then $doc else

        let $docRootElem := $doc/*
        let $docRootElemName := $docRootElem/local-name(.)

        let $parseImplicit := $docRootElemName = ('LogEntries')
        let $allNamespaceDocRoots := $docRootElemName = ('LogEntries')
        
        (: select element to be validated :)
        let $doc := if ($parse or $parseImplicit) then f:parseEmbedded($doc)
                    else $doc
        let $elems := 
            if ($docRootElemName eq 'jmeterTestPlan') then f:getJmxMsgs($doc/*)
            else if ($elemNamePattern) then $doc//*[matches(local-name(.), $elemNamePattern, 'i')]
            else if ($xpath) then xquery:eval($xpath, map{'':$doc})
            else if ($allNamespaceDocRoots) then
                $doc//*[namespace-uri(.) ne $f:URI_SOAP]
                       [parent::*[not(namespace-uri(.) ne $f:URI_SOAP)]]
            else $doc/*
        for $elem in $elems
        let $elemName := $elem/local-name(.)
        let $elemNamespace := $elem/namespace-uri(.)[string()]
        group by $elemIdent := concat($elemName, '@', $elemNamespace)
        let $elemName1 := $elemName[1]
        let $elemNamespace1 := $elemNamespace[1]
        for $elemNode at $nr in $elem
        let $elemInfo := 
            if ($elemNode is $doc/* and false()) then () else (    (: *TODO* check why if :)
                attribute elem {
                    if (empty($elemNamespace1)) then $elemName1
                    else concat($elemName1, ' {', $elemNamespace1, '}')
                },
                attribute elemNr {$nr}
            )
        (: select validating xsd :)
        let $xsdUri :=
            let $xsd := $xsds/*
                [xs:element[@name eq $elemName[1]]]
                [empty($elemNamespace) and not(@targetNamespace) or 
                 $elemNamespace[1] eq @targetNamespace]
                [1]
            let $xsd := $xsd[1]
            return
                $xsd/root()/document-uri(.)
        let $result := 
            if (exists($xsdUri)) then 
                let $report := validate:xsd-info($elemNode, $xsdUri)
                let $report :=
                    if (empty($report)) then $report
                    else if ($docRootElem/local-name(.) = 'jmeterTestPlan') then
                        let $falseErrorLocations :=
                            $report[matches(., '\$\{.*\}')] ! replace(., '^(\d+:\d+:).*', '$1')
                        return $report[not(some $loc in $falseErrorLocations satisfies starts-with(., $loc))]
                        (: $report[not(matches(., '\$\{.*\}'))] :)
                    else $report       
                let $state := if (exists($report)) then 'invalid' else 'valid'
                return
                    <doc name="{$docUri}" state="{$state}">{
                        $elemInfo,
                        for $msg in $report return <msg>{$msg}</msg>
                    }</doc>
            else
                <doc name="{$docUri}" state="noXsd">{$elemInfo}</doc>  
        return
            $result
    let $malformed := $results[@state eq 'malformed']        
    let $invalid := $results[@state eq 'invalid']
    let $valid := $results[@state eq 'valid']
    let $noXsd := $results[@state eq 'noXsd']
   
    let $msgSummary :=
        let $allInvalidMsgs := sort(distinct-values($invalid/msg/replace(., '^\d+:\d+:.*?:\s*', '')))
        return
            if (empty($allInvalidMsgs)) then () 
            else
                <msgSummary count="{count($allInvalidMsgs)}">{
                    $allInvalidMsgs ! <msg>{.}</msg>
                }</msgSummary>   
    
    return
        <validationResults time="{current-dateTime()}">{
            if (empty($malformed)) then () else
            <malformed count="{count($malformed)}">{
                $malformed
            }</malformed>,
        
            if (empty($noXsd)) then () else
                f:reportNoXsd($noXsd),
        
            <invalid count="{count($invalid)}">{
                if (not($invalid)) then () else (
                    $msgSummary,                
                    <docs>{$invalid}</docs>
                )
            }</invalid>,
            
            f:reportValid($valid)
        }</validationResults>
};

(:~
 : Reports the elements for which no XSD could be found
 :)
declare function f:reportNoXsd($docs as element()*)
        as element() {
    if (not($docs)) then () else
    
    let $elems :=        
        for $doc in $docs
        group by $elem := $doc/@elem
(:        
        let $lname := replace($elem, '\s.*', '')
        let $ns := replace($elem, '^.*\s', '')[. ne $elem]
:)        
        let $count := count($doc)
        order by lower-case($elem)        
        return
            (: <elem name="{$lname}" namespace="{$ns}" count="{$count}"/> :)
            <elem name="{$elem}" count="{$count}"/>
     return
        <noXsdFound countElemNames="{count($elems)}">{$elems}</noXsdFound>            
};

(:~
 : Reports the elements found to be valid.
 :)
declare function f:reportValid($docs as element()*)
        as element() {
    let $vdocs := $docs[not(@elem)]        
    let $velems :=        
        for $doc in $docs[@elem]
        group by $elem := $doc/@elem
        let $count := count($doc)    
        order by lower-case($elem)
        return
            <elem name="{$elem}" count="{$count}"/>
     return
        <valid>{
            if (not($docs[@elem])) then 
                attribute count {count($vdocs)}
            else (
                attribute countElemNames {count($velems)},
                $velems
            ),
            $vdocs 
        }</valid>            
};

declare function f:parseEmbedded($n as node())
        as node() {
    typeswitch($n)
    case document-node() return
        document {for $c in $n/node() return f:parseEmbedded($c)}
    case element() return
        element {node-name($n)} {
            for $a in $n/@* return f:parseEmbedded($a),
            for $c in $n/node() return f:parseEmbedded($c)
        }
    case text() return
        if (matches($n, '^\s*<.*>\s*$', 's')) then
            try {
                parse-xml($n)
            } catch * {
                $n
            }
        else $n
    default return $n
};        

(:+
 : Extracts XML msgs from JMeter testplans.
 :)
declare function f:getJmxMsgs($jmxs as element(jmeterTestPlan)*)
        as element()* {
    let $msgTextElems := $jmxs/(
        .//SoapSampler/stringProp[@name eq 'HTTPSamper.xml_data'],
        .//HTTPSamplerProxy//elementProp[@elementType eq 'HTTPArgument']/stringProp[@name eq 'Argument.value']
    )
    let $msgs :=
        for $e in $msgTextElems
        let $msg := try {parse-xml($e)/*} catch * {()}
        let $msg := $msg/(.//soap:Body/*, .)[1]
        return $msg
    return $msgs
};

(:~
 : Reports the parsing of 'doc' and 'xsd' parameters.
 :)
declare function f:getParseReport($foxpathDoc as xs:string, $foxpathXsd as xs:string)
        as element() {
    let $foxpathDocElems := if (not($foxpathDoc)) then () else f:parseFoxpath($foxpathDoc)        
    let $foxpathXsdElems := if (not($foxpathXsd)) then () else f:parseFoxpath($foxpathXsd)
    return
        <parseReport>{
            if (not($foxpathDoc)) then () else
            <parseDoc>{
                $foxpathDocElems
            }</parseDoc>,
            if (not($foxpathXsd)) then () else
            <parseXsd>{
                $foxpathXsdElems
            }</parseXsd>
        }</parseReport>
};

(:~
 : Reports the resolving of 'doc' and 'xsd' parameters to URIs.
 :)
declare function f:getResolveReport($foxpathDoc as xs:string, $foxpathXsd as xs:string)
        as element() {
    let $foxpathDocURIs := if (not($foxpathDoc)) then () else 
        f:resolveFoxpath($foxpathDoc, (), (), '*.xml', map:entry('IS_CONTEXT_URI', true()))        
    let $foxpathXsdURIs := if (not($foxpathXsd)) then () else 
        f:resolveFoxpath($foxpathXsd, (), (), '*.xsd', map:entry('IS_CONTEXT_URI', true()))
    return
        <resolveReport>{
            if (not($foxpathDoc)) then () else
            <docs count="{count($foxpathDocURIs)}">{
                $foxpathDocURIs ! <doc path="{.}"/>
            }</docs>,
            if (not($foxpathXsd)) then () else
            <xsds count="{count($foxpathXsdURIs)}">{
                $foxpathXsdURIs ! <xsd path="{.}"/>
            }</xsds>
        }</resolveReport>
};

declare function f:getDocsReport($mode as xs:string, $foxpath as xs:string, $uris as xs:string*)
        as element() {
    <docs count="{count($uris)}" foxpath="{$foxpath}">{
        for $uri in $uris
        order by $uri
        return <doc uri="{$uri}"/>
    }</docs>
};

declare function f:cat($uris as xs:string*)
        as element() {
    <docs count="{count($uris)}">{
        for $uri in $uris
        order by lower-case($uri)
        return
            <doc href="{$uri}"/>
    }</docs>
};

declare function f:getXsdsReport($mode as xs:string, $foxpath as xs:string, $uris as xs:string*)
        as element() {
    <xsds count="{count($uris)}" foxpath="{$foxpath}">{
        for $uri in $uris
        order by $uri
        return <xsd uri="{$uri}"/>
    }</xsds>
};

declare function f:getTnsReport($mode as xs:string, $foxpath as xs:string, $xsdUris as xs:string*)
        as element() {
    let $xsds := $xsdUris ! doc(.)/*
    let $tns :=
        for $xsd in $xsds
        group by $tns := $xsd/@targetNamespace
        let $elems := $xsd/xs:element
        return
            <tns uri="{$tns}" countElems="{count($elems)}" foxpath="{$foxpath}">{
                for $elem in $elems
                let $xsd := $elem/root()/document-uri(.)
                let $xsdName := replace($xsd, '.*/', '')
                order by $elem/@name/lower-case(.)
                return
                    <elem name="{$elem/@name}" xsd="{$xsdName}"/>
            }</tns>
    let $countElems := count($tns/elem)
    return
        <tnss count="{count($tns)}" countElems="{$countElems}">{$tns}</tnss>
};

declare function f:getTnamesReport($mode as xs:string, $xsdUris as xs:string*)
        as element() {
    let $xsds := $xsdUris ! doc(.)/*
    let $tnames :=
        for $elem in $xsds/xs:element
        group by $name := $elem/@name
        let $descriptors := $elem ! concat(../@targetNamespace, '#', root()/document-uri(.))
        let $tnsFiles := sort(distinct-values($descriptors))
        return
            <tname name="{$name}" countElems="{count($elem)}">{
                for $tnsFile in $tnsFiles
                let $tns := substring-before($tnsFile, '#')
                let $file := substring-after($tnsFile, '#')
                return
                     <elem tns="{$tns}" file="{$file}"/>
            }</tname>
    return
        <tnames count="{count($tnames)}">{$tnames}</tnames>
};


(:
let $s := 'x[name(wild.\].\\\])]/y'
let $s := 'x[name(wild\\\])]/y'
let $s := 'x[P\\\]#]/y'
let $s := '/projects/wild*[name/wild.\].\\\])vv\\]/log[xml(events)]'
let $s := '/a//b/c'
:)
let $d := "/a[cr(>2016-01-01)]/b/c[xml(a,b) || json &amp;&amp; date(2016-02-16) || not(json(x))]"
let $d := "/projects/wildfly//log[xml(*log*,*middleware*) || xpath(//c[d]) || jxpath(//c/_item/e)]"
let $d := "/a/b[date=2016-02-13 &amp;&amp; xml(FooRQ, *middleware*) || jxpath(/c/d)]//c"
let $d := "/projects/ncats/*"
let $doc := ($doc, $d)[1]

let $x := "/projects/xsd/xsd-ffs/*.xsd"
let $xsd := ($xsd, $x)[1]
let $debug := 0
return
    if ($debug eq 1) then f:parseFoxpath($xsd)
    else if ($debug eq 2) then f:resolveFoxpath($xsd, (), (), '*.xsd', map:entry('IS_CONTEXT_URI', true()))    
    else if ($debug eq 3) then f:parseFoxpath($doc)
    else if ($debug eq 4) then f:resolveFoxpath($doc, (), (), '*.xml', map:entry('IS_CONTEXT_URI', true()))    
    else f:xval($doc, $xsd, $mode)
