module namespace f="http://www.foxpath.org/ns/module-functions";
import module namespace i="http://www.ttools.org/xquery-functions" 
at "foxpath-processorDependent.xqm",
   "foxpath-uri-operations.xqm",
   "foxpath-parser.xqm";

import module namespace op="http://www.parsqube.de/xquery/util/options"
    at "options.xqm";

import module namespace opm="http://www.parsqube.de/xquery/util/options-model"
    at "options-model.xqm";
(:
import module namespace opm="http://www.parsqube.de/xquery/util/options-model"
    at "options-model.xqm";

import module namespace op="http://www.foxpath.org/ns/fox-functions-options" 
at "foxpath-fox-functions-options.gen.xqm";
:)

import module namespace uth="http://www.foxpath.org/ns/urithmetic" 
at  "foxpath-urithmetic.xqm";

import module namespace util="http://www.ttools.org/xquery-functions/util" 
at  "foxpath-util.xqm";

import module namespace use="http://www.foxpath.org/ns/unified-string-expression" 
at  "foxpath-unified-string-expression.xqm";

import module namespace const="http://www.foxpath.org/ns/constants" 
at  "foxpath-constants.xqm";

(:
 :   M o d u l e :    x s d
 :
 :)
(:~
 : Returns a type inheritance report.
 :
 : @param xsds the XSDs to be analyzed
 : @param options options controlling details of the behaviour 
 : @param options processing options
 : @return true or false
 :)
declare function f:xsd.getInheritanceReport($xsds as item()*,
                                            $options as xs:string?,
                                            $pop as map(*))
        as item()* {
    let $ops := ($opm:OPTION_MODELS?xsd.inheritance-report !
                 op:optionsMap($options, ., 'xsd.inheritance-report'), map{})[1]
        
    let $xsdDocs := $xsds[file:is-file(.)] ! doc(.)/*
    let $fnIR := f:getModuleFunction('getInheritanceReport')
    return 
        try {$fnIR($xsdDocs, $ops)} catch * {$err:code, $err:description}
};

(:~
 : Returns a type summary report.
 :
 : @param xsds the XSDs to be analyzed
 : @param options options controlling details of the behaviour 
 : @param options processing options
 : @return true or false
 :)
declare function f:xsd.getTypeSummaryReport($xsds as item()*,
                                            $options as xs:string?,
                                            $pop as map(*))
        as item()* {
    let $ops := ($opm:OPTION_MODELS?xsd.type-summary-report !
                 op:optionsMap($options, ., 'xsd.type-summary-report'), map{})[1]
        
    let $xsdDocs := $xsds[file:is-file(.)] ! doc(.)/*
    let $fnTS := f:getModuleFunction('typeSummaryReport')
    return 
        try {$fnTS($xsdDocs, $ops)} catch * {$err:code, $err:description}
};

(:~
 : Returns a "module function". Module functions are functions
 : which are only parsed and loaded if actually used.
 :)
declare function f:getModuleFunction($fname as xs:string)
        as function(*) {
    let $module :=
        switch($fname)
        case 'cssdocResource' return
            'modules/css/css-util.xqm'
        case 'writeCssdocResource' return
            'modules/css/css-util.xqm'
        case 'parseCss' return
            'modules/css/css-parser.xqm'
        case 'serializeCss' return
            'modules/css/css-serializer.xqm'
        case 'checkUnusedNamespaces' return
            'modules/check/check-namespaces.xqm'
        case 'replaceAndMarkChars' return
            'modules/characters/char-marker.xqm'
            
        (: XSD analysis tools :)
        case 'typeSummaryReport' return
            'modules/xsd/lib/type-summary.xqm'        
        case 'getInheritanceReport' return
            'modules/xsd/lib/type-inheritance.xqm'
            
        default return error((), 'Unknown function name: '||$fname)
    return
        inspect:functions($module)
            [function-name(.) ! local-name-from-QName(.) eq $fname]
};

