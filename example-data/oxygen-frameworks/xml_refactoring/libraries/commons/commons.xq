xquery version "3.0" encoding "utf-8";

module namespace xr = "http://www.oxygenxml.com/ns/xmlRefactoring";

(: Value used to represent that any value is accepted for a certain property. :)
declare variable $xr:ANY-VALUE as xs:string := '<ANY>';

(: Value used to represent the "no-value" for a namespace URI. :)
declare variable $xr:NO-NAMESPACE as xs:string := '<NO_NAMESPACE>';

(: 
   The namespace URI for the temporary attributes used by the XML Refactory processor.
   Note: The attributes belonging to this namespace should not be matched by any expression.
:)
declare variable $xr:ADDITIONAL-ATTRIBUTES-NS-URI := 'http://www.oxygenxml.com/ns/xmlRefactoring/additional_attributes';

(: Line feed :)
declare variable $xr:LF as xs:string := '&#xA;';

(:
 : Returns a prefix for the given namespace URI forom the the in-scope namespaces declarations of the context element.
 : If no prefix is found, then the empty string '' is retuned.
 : 
 : $nsUri - The namespace URI to search a prefix for.
 : $contextElem - The element node used to determine the in-scope namespaces declarations.
 : 
 :)
declare function xr:find-prefix($nsUri as xs:string, $contextElem as node()) as xs:string {
    let $normalizeNs := normalize-space($nsUri)
    return 
     	if (($contextElem instance of element()) and $normalizeNs != '' and $normalizeNs != $xr:NO-NAMESPACE and $normalizeNs != $xr:ANY-VALUE)
    	then 
        (: Compute the prefix for the given namespace URI :)
        let $allPrefixes := in-scope-prefixes($contextElem)        
        let $elemPrefix :=
    	    		for $prefix in $allPrefixes
    	    			where $normalizeNs = namespace-uri-for-prefix($prefix, $contextElem)
    	        		return $prefix
    	  return 
    	    if (empty($elemPrefix)) 
    	    then ""
    	    else $elemPrefix[1]
    	else ""
	        
};

(:
 : Returns a qualified name having the provided local part, the namespace URI and a prefix for the given namespace URI computed
 : from the the in-scope namespaces declarations of the context element. 
 : 
 : $nsUri - The namespace URI to search a prefix for.
 : $contextElem - The element node used to determine the in-scope namespaces declarations.
 : 
 :)
declare function xr:compute-qname($localName as xs:string, $nsUri as xs:string?, $contextElem as node()) as xs:QName {
  let $prefix := xr:find-prefix($nsUri, $contextElem)
  let $expandedNsUri := (if ($nsUri = $xr:NO-NAMESPACE or $nsUri = $xr:ANY-VALUE) then '' else $nsUri)
    return      
      xr:get-qname($prefix, $localName, $expandedNsUri)
};

declare function xr:get-qname($prefix as xs:string?, $localName as xs:string, $nsUri as xs:string?) as xs:QName {
  if ($prefix != "") 
    then QName($nsUri, $prefix || ":" || $localName )
    else QName($nsUri, $localName)
};

(: Parse the given XML fragment and get the nodes sequence :)
declare function xr:parse-xml-fragment($xml_fragment as xs:string) as node()* {
    let $wellformedXmlFragment := "<root>" || $xml_fragment || "</root>" 
    let $xmlDoc := parse-xml($wellformedXmlFragment)        
    
    return $xmlDoc/*:root/node()
};

(:
 : Checks if the given namespace URI matches the namespace URI of the provided node.
 :)
declare function xr:check-namespace-uri($nsUri as xs:string, $node as node(), $acceptsAnyValue as xs:boolean) as xs:boolean {
  let $nodeNsUri := namespace-uri($node)
  let $nsUriMatch :=
      (($acceptsAnyValue and $nsUri = $xr:ANY-VALUE and 
        (: 
           Filter the nodes from our internally used namespace. 
           The nodes from this namespace are artificially added by the XQuery Update Processor for 
           a more precise processing of the input XML file.
        :)
        not($nodeNsUri = $xr:ADDITIONAL-ATTRIBUTES-NS-URI)) or
      ($nsUri = $xr:NO-NAMESPACE and not($nodeNsUri)) or 
      ($nsUri = $nodeNsUri))
  return $nsUriMatch    
};

(:
 : Checks if the given local name matches the local name of the provided node.
 :)
declare function xr:check-local-name($localName as xs:string, $node as node(), $acceptsAnyValue as xs:boolean) as xs:boolean {
  let $nodeLocalName := local-name($node)
  let $namesMatch :=
      (($acceptsAnyValue and $localName = $xr:ANY-VALUE) or
      ($nodeLocalName = $localName))
  return $namesMatch    
};

(: 
 : Utility function used for logging purposes.
 : Inserts the given message as a comment node at the end of the children list of the context node.
 :)
declare %updating function xr:log($message as xs:string, $context as node()) {
  let $toInsert as node()+ := ordered { text {$xr:LF} | comment {$message}}
  return 
    insert nodes $toInsert as last into $context
};