(:
foxpath-uri-operation.xqm - library of functions operating on URIs

Overview:

Group: resource properties
  uriDomain
  fox-is-file
  fox-is-dir
  fox-file-size
  fox-file-date
  fox-file-sdate

Group: resource retrieval
  fox-unparsed-text
  fox-unparsed-text-lines
  
:)
module namespace f="http://www.ttools.org/xquery-functions";
import module namespace i="http://www.ttools.org/xquery-functions" at 
    "foxpath-processorDependent.xqm",
    "foxpath-util.xqm";

(: 
 : ===============================================================================
 :
 :     r e s o u r c e    p r o p e r t i e s
 :
 : ===============================================================================
 :)

(: 
 : ===============================================================================
 :
 :     r e s o u r c e    r e t r i e v a l
 :
 : ===============================================================================
 :)

(:~
 : Returns an XML document identified by a github URI.
 :
 : @param uri the URI
 : @param options options controlling the evaluation
 : @return the document, or the empty sequence if retrieval or parsing fails
 :)
declare function f:fox-doc_github($uri as xs:string, $options as map(*)?)
        as document-node()? {
    let $useUri := replace($uri, '^github-', '')
    let $binary := f:get-request_github($useUri, $f:TOKEN)
    let $text := $binary//content/convert:binary-to-string(xs:base64Binary(.))  
    return
        try {parse-xml($text)} catch * {()}        
};

(:~
 : Returns true if a given github URI points to a well-formed XML document.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return true if the URI points to a well-formed XML document
 :)
declare function f:fox-doc-available_github($uri as xs:string, $options as map(*)?)
        as xs:boolean {
    let $useUri := replace($uri, '^github-', '')
    let $binary := f:get-request_github($useUri, $f:TOKEN)
    let $text := $binary//content/convert:binary-to-string(xs:base64Binary(.))  
    return
        try {
            (: bug? exists(parse-xml($text)) does not work ! :)
            let $doc := parse-xml($text)
            let $count := count($doc//*)
            return
                $count > 0
        } catch * {false()}        
};

(:~
 : Returns the string representation of a github resource.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return the text of the resource, or the empty sequence if retrieval fails
 :)
declare function f:fox-unparsed-text_github($uri as xs:string, 
                                            $encoding as xs:string?, 
                                            $options as map(*)?)
        as xs:string? {
    let $useUri := replace($uri, '^github-', '')
    let $binary := f:get-request_github($useUri, $f:TOKEN)
    let $text := $binary//content/convert:binary-to-string(xs:base64Binary(.))  
    return
        $text        
};

(:~
 : Returns the lines of the string representation of a resource identified
 :     by a github URI.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return the text lines, or the empty sequence if retrieval fails
 :)
declare function f:fox-unparsed-text-lines_github($uri as xs:string, 
                                                  $encoding as xs:string?, 
                                                  $options as map(*)?)
        as xs:string* {
    let $useUri := replace($uri, '^github-', '')
    let $binary := f:get-request_github($useUri, $f:TOKEN)
    let $text := $binary//content/convert:binary-to-string(xs:base64Binary(.))  
    return
        tokenize($text, '&#xA;')        
};

(:~
 : Returns an XML representation of the JSON record identified by a github URI.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return an XML document representing JSON data, or the empty sequence if 
 :     retrieval or parsing fails
 :)
declare function f:fox-json-doc_github($uri as xs:string,
                                       $options as map(*)?)
        as document-node()? {
    let $useUri := replace($uri, '^github-', '')
    let $binary := f:get-request_github($useUri, $f:TOKEN)
    let $text := $binary//content/convert:binary-to-string(xs:base64Binary(.))  
    return
        try {json:parse($text)} catch * {()}        
};

(:~
 : Returns true if a given github URI points to a valid JSON record.
 :
 : @param uri the URI or file path of the resource
 : @param options options controlling the evaluation
 : @return true if a JSON record can be retrieved
 :)
declare function f:fox-json-doc-available_github($uri as xs:string, 
                                                 $options as map(*)?)
        as xs:boolean {
    let $useUri := replace($uri, '^github-', '')
    let $binary := f:get-request_github($useUri, $f:TOKEN)
    let $text := $binary//content/convert:binary-to-string(xs:base64Binary(.))  
    return
        try {
            json:parse($text) ! exists(.)
        } catch * {false()}        
};

(:~
 : Returns the content of a file as the Base64 representation of its bytes.
 :
 : @param uri the URI or file path of the resource
 : @return the Base64 representation, if available, the empty sequence otherwise
 :)
declare function f:fox-binary_github($uri as xs:string, 
                                     $options as map(*)?)
        as xs:base64Binary? {
    let $useUri := replace($uri, '^github-', '')
    let $restResponse := f:get-request_github($useUri, $f:TOKEN)
    let $binary := $restResponse//content/xs:base64Binary(.)
    return
        $binary       
};


(: 
 : ===============================================================================
 :
 :     u t i l i t i e s 
 :
 : ===============================================================================
 :)
(:~
 : Sends a github API - GET request and returns the response. Returns the response body,
 : if there is one, otherwise the response header.
 
 : @param uri the URI
 : @param token if specified, used for authorization
 : @return the response
 :)
declare function f:get-request_github($uri as xs:string, $token as xs:string)
        as node()+ {
    let $DUMMY := trace(substring($uri, 1, 80), 'GITHUB RETRIEVAL, URI: ')
    let $rq :=
        <http:request method="get" href="{$uri}">{
            <http:header name="Authorization" value="{concat('Token ', $token)}"/>[$token]
        }</http:request>
    let $rs := try {http:send-request($rq)} catch * {trace((), 'EXCEPTION_IN_SEND_REQUEST: ')}
    let $rsHeader := $rs[1]
    let $body := $rs[position() gt 1]
    return
        ($body, $rsHeader)[1]
};        


(:~
 : Retrieves the text of a resource identified by a github navigation URI.
 :
 : @param uri the URI
 : @param options options controlling the evaluation
 : @return the domain
 :)
declare function f:fox-navURI-to-text_github($uri as xs:string,
                                             $encoding as xs:string?,
                                             $options as map(*)?)
        as xs:string? {
    let $redirect :=
        if (not(f:uriDomain($uri, $options) eq 'REDIRECTING_URI_TREE')) then ()
        else if (empty($options)) then ()
        else
            for $buri in map:get($options, 'URI_TREES_BASE_URIS')[starts-with($uri, .)] return
            $buri/..//file[$uri eq concat($buri, @path)]/@uri
            
    return
        try {
            if ($redirect) then
                let $response := f:get-request_github($redirect, $f:TOKEN)
                return $response//content/convert:binary-to-string(xs:base64Binary(.))  
            else ()
        } catch * {()}            
};


