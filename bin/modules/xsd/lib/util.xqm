module namespace util="http://www.parsqube.de/xspy/util";
import module namespace const="http://www.parsqube.de/xspy/constants"
    at "constants.xqm";
import module namespace ufpath="http://www.parsqube.de/xquery/util/file-path"
    at "../util/util-filePath.xqm";
import module namespace unamef="http://www.parsqube.de/xquery/util/name-filter"
    at "../util/util-nameFilter.xqm";
import module namespace uns="http://www.parsqube.de/xspy/util/namespace"
    at "util-namespace.xqm";

(:~
 : Retrieves a document. A relative URI is resolved
 : against the current working directory, not
 : against the XQuery module.
 :
 : @param uri the URI of the document
 : @return the document located at the URI
 :)
declare function util:getDoc($uri as xs:string)
        as document-node() {
    $uri ! ufpath:resolvePath(.) ! doc(.)        
};        


(:~
 : Returns the "kind" of a type definition.
 :
 : @typeDef a type definition
 : @return string identifying the kind of type
 :)
declare function util:getTypeKind($typeDef as element())
      as xs:string {
    if ($typeDef/self::xs:complexType) then
        let $cc := $typeDef/xs:complexContent
        let $cs := $typeDef/xs:simpleContent
        let $ext := ($cc, $cs)/xs:extension
        let $res := ($cc, $cs)/xs:restriction
        let $postfix := ($ext, $res) ! local-name(.) ! substring(., 1, 1)
        return
        if ($cc) then 'cc'||$postfix
        else if ($cs) then 'cs'||$postfix
        else if (empty($typeDef/(* except xs:annotation))) then 'ce'
        else 'cc'
    else
        if ($typeDef/xs:restriction) then 'sr'
        else if ($typeDef/xs:list) then 'sl'
        else if ($typeDef/xs:union) then 'su'
        else 's?'
};

declare function util:schemaCompNormalized($comp as element(), 
                                           $nsmap as element())
        as element() {
    $comp ! util:schemaCompNormalizedREC(., $nsmap)        
};        

declare function util:schemaCompNormalizedREC($n as node(), 
                                              $nsmap as element())
        as node()* {
    typeswitch($n)
    case document-node() return
        document {$n/node() ! util:schemaCompNormalizedREC(., $nsmap)}
    case element(xs:annotation) return ()
    case element() return
        let $qnameNorm := uns:normalizeQName(node-name($n), $nsmap)
        return
            element {$qnameNorm} {
                $n/@* ! util:schemaCompNormalizedREC(., $nsmap),
                $n/node() ! util:schemaCompNormalizedREC(., $nsmap)
            }
    case text() return
        if ($n/../* and not(normalize-space($n))) then () else $n
    case attribute(base) | attribute(type) | attribute(ref) | attribute(itemType) return
        let $qname := $n/resolve-QName(., ..)
        return attribute {node-name($n)} {uns:normalizeQName($qname, $nsmap)}
    case attribute(memberTypes) return
        let $qnames := $n/tokenize(.) ! $n/resolve-QName(., ..)
        return attribute {node-name($n)} {$qnames ! uns:normalizeQName(., $nsmap)}
    default return $n            
};  

(:~
 : Returns the tsummary labels.
 :)
declare function util:getTsummaryLabels($tsummary as xs:string?)
        as xs:string* {
    let $all := $const:TSUMMARY_LABELS
    let $tsummaryFilter:= $tsummary ! unamef:parseNameFilter(.)
    return
        if (not($tsummaryFilter)) then $all else
            $all[unamef:matchesNameFilterObject(., $tsummaryFilter)]
};        

declare function util:getTsummaryLabels($tsummary as xs:string?,
                                        $defaultAll as xs:boolean?)
        as xs:string* {
    let $all := $const:TSUMMARY_LABELS
    let $tsummary := $tsummary ! normalize-space(.)
    return 
       if (not($tsummary)) then
           if ($defaultAll) then $all else ()
       else
    let $tsummaryFilter:= $tsummary ! unamef:parseNameFilter(.)
    return
        $all[unamef:matchesNameFilterObject(., $tsummaryFilter)]
};        

(:~
 : Returns the schema elements found in a folder and
 : all recursive subfolders.
 :)
declare function util:getSchemas($dir as xs:string) 
        as element(xs:schema)* {
    let $dirR := $dir ! ufpath:resolvePath(.)
    let $uris := file:descendants($dirR)[ends-with(., '.xsd')]
    return $uris ! doc(.)/*
};

(:~
 : Returns the example documents found in a folder and
 : all recursive subfolders.
 :)
declare function util:getExampleDocs($dir as xs:string) 
        as element()* {
    let $dirR := $dir ! ufpath:resolvePath(.)
    let $uris := file:descendants($dirR)[ends-with(., '.xml')]
    return $uris ! doc(.)/*
};

declare function util:TRACE($items, $label)
        as item()* {
    if ($const:DEBUG_LEVEL lt 1) then () else
    trace($items, $label)
};

declare function util:TRACE($label)
        as item()* {
    if ($const:DEBUG_LEVEL lt 1) then () else
    trace($label)
};