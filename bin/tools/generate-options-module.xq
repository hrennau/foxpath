declare namespace f="http://www.foxpath.org/ns/generate-options";

declare variable $format external := 'module';
declare variable $fconfig external := '../../functions/functions.xml';
declare variable $pconfig external := '../../functions/params.xml'; 
declare variable $skipwrite as xs:boolean external := false();
declare variable $moduleUri external := '../foxpath-fox-functions-options.gen.xqm'
    ! resolve-uri(.);

(:~
 : Generates the XQuery module providing the function option models.
 :)
declare function f:writeModule($fconfig as element(),
                               $pconfig as element()?)
    as item() {
    let $fconfige := $fconfig/f:expandConfigREC(.)
    let $pconfige := $pconfig/f:expandConfigREC(.)
    let $fmapx := $fconfige/f:writeMapx(.)
    let $pmapx := $pconfige/f:writeMapx(.)
    let $ffunction :=
'declare function op:buildOptionMaps() {
'
||'  '||($fmapx ! f:serializeMap(., '  '))
||'&#xA;};'
    let $pfunction := if (not($pconfig)) then () else
'
declare function op:buildParamMaps() {
'
||'  '||($pmapx ! f:serializeMap(., '  '))
||'&#xA;};'
    
    return 
        if ($format eq 'mapx') then $fmapx
        else 
'(: Function options models :)
module namespace op="http://www.foxpath.org/ns/fox-functions-options";

(: declare variable $f:OPTION_MODELS := prof:time(opt:buildOptionMaps()); :)
declare variable $op:OPTION_MODELS := op:buildOptionMaps();
declare variable $op:PARAM_MODELS := op:buildParamMaps();
        
'||$ffunction
||$pfunction
};

(:~
 : Expands the function options contig.
 :)
declare function f:expandConfig($functions as element(functions))
        as node() {
    f:expandConfigREC($functions)        
};

(:~
 : Recursive helper function of `expandConfig`.
 :)
declare function f:expandConfigREC($n as node())
        as node()? {
    typeswitch($n)
    case document-node() return document {$n/node() ! f:expandConfigREC(.)}
    case element(function) | element(param) return
        let $optionValues :=
            for $v in $n/options/option//value 
            let $oname := $v/ancestor::option/@name 
            return
                <optionValue value="{$v/@string}" option="{$oname}"/>
        let $optionValuesElem :=
            <optionValues count="{count($optionValues)}">{
                $optionValues
            }</optionValues>
        return
            element {node-name($n)} {
                $n/@* ! f:expandConfigREC(.),
                $n/*[not(. >> options)] ! f:expandConfigREC(.),
                $optionValuesElem,
                $n/*[. >> options] ! f:expandConfigREC(.)
            }
    case element() return 
        element {node-name($n)} {
            $n/@* ! f:expandConfigREC(.),
            $n/node() ! f:expandConfigREC(.)
        }
    case text() return
        if ($n/../* and not($n/matches(., '\S'))) then () else $n
    default return $n    
};

(:~
 : Maps the extended config to a mapx element.
 :)
declare function f:writeMapx($configExt as element())
        as element(map) {
    let $entities := 
        typeswitch($configExt)
        case element(params) return $configExt//param
        default return $configExt//function
    return
    
    <map>{
        for $f in $entities
        return
            <entry name="{$f/@name}" type="map">{
                <map>{
                    <entry name="options" type="map">{
                        <map>{
                            $f/options/option/f:writeMapx_option(.)
                        }</map>
                    }</entry>,
                    if (not($f/optionValues)) then () else
                    <entry name="optionValues" type="map">{
                        <map>{
                            for $v in $f/optionValues/optionValue
                            return
                                <entry name="{$v/@value}" type="string" value="{$v/@option}"/>
                        }</map>
                    }</entry>                    
                }</map>                
            }</entry>
    }</map>        
};    

(:~
 : Helper function of `writeMapx`.
 :)
declare function f:writeMapx_option($o as element(option))
        as element() {
    let $content :=        
        if (not($o/(@* except (@name, @type[. eq 'boolean']), 
                   (* except documentation)))
        ) then ()
        else 
            let $entries := (
                $o/@type ! <entry name="type" type="string" value="{.}"/>,
                $o/@pattern ! <entry name="pattern" type="string" value="{.}"/>,
                $o/@patternExplanation ! 
                    <entry name="patternExplanation" 
                           type="string" 
                           value="{normalize-space(.)}"/>,
                $o/@default ! <entry name="default" type="{$o/@type}" value="{.}"/>,
                let $values := $o/values/value
                where exists($values)
                return
                    <entry name="values" type="strings">{
                        $values/<string>{@string/string()}</string>
                    }</entry>
            )
            return $entries 
    return
        <entry name="{$o/@name}">{
           if (empty($content)) then () else (
               attribute type {'map'},
               <map>{$content}</map>
           )
        }</entry>
};   

(:~
 : Serializes a mapx element to an XQuery map constructor.
 :)
declare function f:serializeMap($map as element(map), $indent as xs:string)
        as xs:string {
    if (empty($map/entry)) then 'map{}' else
    
    let $entries :=
        for $entry in $map/entry
        let $label := "'"||$entry/@name||"': "
        let $value := $entry ! (
            switch(string(@type))
            case 'empty'
            case '' return '()'
            case 'map' return (map/f:serializeMap(., "  "))
            case 'integer' return @value
            case 'strings' return
                "("||(string/("'"||.||"'") => string-join(", ")||")")
            default return "'"||@value||"'"
            ) 
        return '  '||$label||$value
    return (
        'map{&#xA;'||
        ($entries => string-join(',&#xA;')) ! 
        tokenize(., '&#xA;') ! ($indent||.) 
        => string-join('&#xA;')
    )||'&#xA;'||$indent||'}'
};

let $docF := $fconfig ! doc(.)/*
let $docP := $pconfig ! doc(.)/*
let $module := f:writeModule($docF, $docP)
let $_write :=
    if ($skipwrite) then () else
        file:write($moduleUri, $module)
return
    'Module generated: '||$moduleUri
