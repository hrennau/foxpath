module namespace f="http://www.data2type.de/ns/octopus/css-reporter";
import module namespace cp="http://www.data2type.de/ns/octopus/css-parser"
    at "css-parser.xqm";
import module namespace ap="http://www.data2type.de/ns/octopus/ofx-anno-parser"
    at "ofx-anno-parser.xqm";
import module namespace au="http://www.data2type.de/ns/octopus/ofx-anno-util"
    at "ofx-anno-util.xqm";
import module namespace cu="http://www.data2type.de/ns/octopus/css-util"
    at "css-util.xqm";
import module namespace util="http://www.data2type.de/ns/octopus/ofx-util"
    at "ofx-util.xqm";
import module namespace nf="http://www.data2type.de/ns/octopus/util-name-filter"
  at "util-nameFilter.xqm";

(:~
 : Reports a CSS document. The document is provided either as file path
 : or as document text. Optionally, an aligned document is also provided,
 : in order to report whether values have changed. 
 :
 : Options:
 : * view - report view, one of 'anno', 'css', tree'
 : * contextUri - the URI is returned as a relative URI against the context 
 :     URI
 : * alignedContextUri - the URI is returned as a relative URI against the 
 :     context URI 
 :)
declare function f:reportCssAnno(
                             $uri as xs:string,
                             $uriAligned as xs:string?,
                             $contextUri as xs:string,
                             $alignedContextUri as xs:string?,
                             $stylingDoc as element()?,                             
                             $options as map(xs:string, item()*))
        as item()* {
    let $view := $options?view  
    let $text := unparsed-text($uri)
    let $textAligned := unparsed-text($uriAligned)    
    let $relUri := $uri ! util:getRelPath(., $contextUri, true())    
    let $relUriAligned := $uriAligned ! util:getRelPath(., $alignedContextUri, true())    
    let $parseOptions := map{} 
    
    let $cssx := 
        let $treeEtc := prof:time(cp:parseCss($text, $options), '  Parse Oct.custom: ')
        return $treeEtc?parsed
    return if ($view eq 'tree') then $cssx else
    let $cssx2 := $textAligned ! (
        let $treeEtc := prof:time(cp:parseCss(., $options), '  Parse Oct.zero:   ')
        return $treeEtc?parsed)
        
    let $options := 
        map:merge(($options, 
        map{
            'addinfo': map{'property': f:reportCssAnno_propertyDetails#2},
            'stylingDoc': $stylingDoc,
            'alignedDoc': $cssx2,
            'alignedRulePropertyMap': f:rulePropertyMap($cssx2),
            'ruleNodeIdPositionMap': f:ruleNodeIdPositionMap($cssx),
            'uri': $relUri,
            'uriAligned': $relUriAligned,
            'contextUri': $contextUri,
            'alignedContextUri': $alignedContextUri}))
            
    let $report1 := prof:time(f:repCss($cssx, $options), '  Create report:    ')
    let $report2 := f:finalizeReportCssAnno($report1, $options)
    return $report2
};

(:~
 : Generates additional details about <property> elements,
 : related to annotations.
 :)
declare function f:reportCssAnno_propertyDetails(
                                 $p as element(property),
                                 $options as map(xs:string, item()*))                                 
        as node()* {
    let $annoElem :=        
        let $comment := $p/preceding-sibling::*[1]
                          /self::comment[contains(., '@ofx:')]
        let $parsedEtc := $comment ! ap:parseAnnotation(., 1, (), 'css')
        let $parsed := $parsedEtc?parsed
        return $parsed
    let $ignoreMe := if (empty($annoElem)) then false() else
        let $planNameFilter := $options?planNameFilter
        let $tagsFilter := $options?tagsFilter
        let $annoSources := $options?annoSources
        let $annoTypes := $options?annoTypes        
        let $matchesProperty := 
            au:annotationMatchesFilter(
                $annoElem, $planNameFilter, $tagsFilter, $annoSources, $annoTypes)
        return not($matchesProperty)
    return if ($ignoreMe) then <DELETE/> else
    
    let $details := $options?details  
    let $alignedRulePropertyMap := $options?alignedRulePropertyMap   
    let $ruleNodeIdPositionMap := $options?ruleNodeIdPositionMap
    let $fnRuleSelPath := 
        function($p) {$p/ancestor-or-self::rule/cu:ruleSelector(.) => string-join('/')}
    let $pName := $p/cu:propertyName(.)
    let $pValue := $p/cu:propertyValue(.)
    let $containingRule := $p/ancestor::rule[1]
    let $containingRulePos := ($ruleNodeIdPositionMap(generate-id($containingRule)), 1)[1]
    let $ruleSelPath := $containingRule/$fnRuleSelPath(.)
    let $ruleSel := $ruleSelPath[last()]
    let $alignedRules := $alignedRulePropertyMap($ruleSelPath)
    let $alignedRule := $alignedRules[$containingRulePos]
    (:
    let $_DUMMY := if ($containingRulePos eq 1) then () else
        (
         trace($alignedRule, '_ALIGNED_RULE: '),
         trace($containingRule, '_CONTAIN_RULE: '))
    :)
    let $alignedProperty := $alignedRule ! .($pName)               
    let $alignedPvalue := $alignedProperty ! cu:propertyValue(.)                       
    let $annoInfo := $annoElem ! au:getAnnotationInfoMap(., $options?stylingDoc)
    let $addInfo := (
        if (not($details = 'zero-value')) then () else
            <valueZero>{string($alignedPvalue)}</valueZero>,
        if (not($details = 'status')) then () else 
        let $valueStatus := (
            if (empty($alignedPvalue)) then () else 
                if ($pValue = $alignedPvalue) then 'SAME' else 'CHANGED',
            if (not($annoInfo?varName)) then () else
                if ($pValue = $annoInfo?varValue) then 'EQVAR' else 'NEQVAR'
        )
        return <valueStatus>{$valueStatus}</valueStatus>,
        if (not($details = 'tags')) then ()
        else 
            <tags>{
                for $tag in $annoInfo?tags
                let $name := replace($tag, '=.*', '')
                let $value := replace($tag, '.+=', '')[. ne $tag]
                return <tag name="{$name}">{
                           $value[string()] ! attribute value{.}
                       }</tag>
            }</tags>        
    )
    let $detailElem := 
        if (not($addInfo)) then () 
        else <details>{$addInfo}</details>
    return (
        $annoInfo?text[normalize-space()] ! attribute annoText {.},
        $annoInfo?varName[normalize-space()] ! attribute varName {.},               
        $annoInfo?varValue[normalize-space()] ! attribute varValue {.},        
        $annoInfo?annoType ! attribute annoType {.},
        $annoInfo?varNames[normalize-space()] ! attribute varNames {.},
        $annoElem,
        $detailElem
    )
};

(:~
 : Constructs a map associating selector strings with
 : the rules using this selector. The rules for a
 : given selector are stored as a sequence.
 :)
declare function f:rulePropertyMap($css as element(css))
        as map(xs:string, item()*) {
    map:merge(
        for $rule in $css//rule
        let $selpath := $rule/ancestor-or-self::rule/cu:ruleSelector(.) => string-join('/')
        group by $selpath
        let $ruleMaps :=
            for $rule2 in $rule return 
                map:merge(
                    for $p in $rule2/properties/property
                    let $pname := $p/cu:propertyName(.)
                    return map:entry($pname, $p))
        return
            map:entry($selpath, $ruleMaps))
};

(:~
 : Creates a map mapping rule node Ids to the position of the
 : rule in document order among all rules with the same
 : selector, omitting all rule nodes at position 1.
 :)
declare function f:ruleNodeIdPositionMap($css as element(css))
        as map(xs:string, xs:integer) {
    map:merge(        
        for $rule in $css//rule            
        let $selpath := $rule/ancestor-or-self::rule/cu:ruleSelector(.) => string-join('/')
        group by $selpath
        for $rule2 at $pos in tail($rule)
        return
            map:entry(generate-id($rule2), $pos + 1))
};

(:~
 : Finalizes a CSS anno report.
 :)
declare function f:finalizeReportCssAnno(
                                     $report as element(css),
                                     $options as map(xs:string, item()*))
        as element(css) {
    let $view := $options?view 
    let $pElems := $report//p
    let $pValueAnno := $pElems[@varName]
    let $pTextAnno := $pElems[@annoType eq 'ofx:text']
    let $addRootAtts := (
        attribute countValueAnnos {count($pValueAnno)},
        attribute countTextAnnos {count($pTextAnno)}
    )
    let $report1 := $report ! element {node-name(.)} {@*, $addRootAtts, node()}
    let $report2 :=
        if (not($view)) then $report1
        else if ($view eq 'css') then $report1
        else if ($view eq 'anno') then f:editCssReport_anno($report1, $options)
        else error()
    return $report2        
};

(:~
 : Edits a CSS report in accordance with the 'anno' view.
 :)
declare function f:editCssReport_anno($report as element(), 
                                      $options as map(xs:string, item()*))
        as element() {
    f:editCssReport_annoREC($report, $options)        
};

(:~
 : Recursive helper function of `editCssReport_anno`.
 :)
declare function f:editCssReport_annoREC($n as node(),
                                         $options as map(xs:string, item()*))
        as node()? {
    typeswitch($n)        
    case document-node() return 
        document {$n/node() ! f:editCssReport_annoREC(., $options)}
    case element(annotation) return ()
    case element(p) return
        element {node-name($n)} {
            $n/@* ! f:editCssReport_annoREC(., $options),
            $n/node() ! f:editCssReport_annoREC(., $options)            
        }[@annoType]
    
    case element(rule) | element(rules) return
        let $content := (
            $n/@* ! f:editCssReport_annoREC(., $options),
            $n/node() ! f:editCssReport_annoREC(., $options)            
        )
        let $children := $content[self::*]
        where $children
        return element {node-name($n)} {$content}
    case element() return
        element {node-name($n)} {
            $n/@* ! f:editCssReport_annoREC(., $options),
            $n/node() ! f:editCssReport_annoREC(., $options)            
        }
    default return $n        
};

(:
 :    S t a n d a r d    r e p o r t    f u n c t i o n
 :)
 
(:~
 : Standard CSS report function. Further processing can be added by supplying
 : function items in $options:
 :   $options?addinfo?property($p, $options)
 :
 : Support for further element-specific functions, like
 :   $options?addinfo?rule($r, $options) 
 :
 : etc will be added when the need arises.
 :)
declare function f:reportCss(
                             $css as xs:string,
                             $options as map(xs:string, item()*))
        as item()* {
  f:repCss($css, $options)
};

declare function f:repCss(
                   $css as element(css), 
                   $options as map(xs:string, item()*)) 
        as element(css) {
    <css>{
        $options?uri ! attribute uri {.},
        $css/rules ! f:repRules(., $options)
    }</css>
};
declare function f:repRules(
                   $rs as element(rules),
                   $options as map(xs:string, item()*)) 
        as element(rules) {
    <rules>{
        for $r in $rs/rule
        order by $r/cu:ruleSelector(.)
        return $r ! f:repRule(., $options)
    }</rules>
};
declare function f:repRule(
                   $r as element(rule),
                   $options as map(xs:string, item()*)) 
        as element(rule)? {
    let $selectorsFilter := $options?selectorsFilter
    return
        if ($selectorsFilter and 
            not(some $sel in $r/cu:ruleSelectors(.) satisfies
                nf:matchesNameFilter($sel, $selectorsFilter))) then ()
        else
    <rule sel="{cu:ruleSelector($r)}">{
        $r/properties ! f:repProperties(., $options),
        $r/rules ! f:repRules(., $options)
    }</rule>
};
declare function f:repProperties(
                   $ps as element(properties),
                   $options as map(xs:string, item()*)) 
        as element(p)* {
    for $p in $ps/property
    order by $p/cu:propertyName(.)
    return $p ! f:repProperty(., $options)
};
declare function f:repProperty(
                   $p as element(property),
                   $options as map(xs:string, item()*)) 
        as element(p)? {
    let $propertiesFilter := $options?propertiesFilter
    return
        if ($propertiesFilter and 
            not(nf:matchesNameFilter($p/cu:propertyName(.), $propertiesFilter))) then ()
        else
    let $addinfo := $options?addinfo?property($p, $options)
    return if ($addinfo instance of element(DELETE)) then () else
    
    <p name="{cu:propertyName($p)}"
       value="{cu:propertyValue($p)}">{
       $addinfo
       }</p>
};
